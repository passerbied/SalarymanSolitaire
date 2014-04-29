//
//  PurchaseManager.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-11.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "PurchaseManager.h"
#import "Reachability.h"
#import "ReceiptDataValidation.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


#define kKeychainItemProductIdentifier  @"ProductIdentifier"
#define kKeychainItemProductCount       @"Count"


@interface KeychainItemProduct ()
{
    // 商品情報
    NSMutableDictionary                 *_productData;
    
    // 商品ID
    NSString                            *_productIdentifier;
}
@end

@implementation KeychainItemProduct

- (instancetype)initWithProductIdentifier:(NSString *)productIdentifier
{
    self = [super initWithIdentifier:productIdentifier accessGroup:nil];
    if (self) {
        _productIdentifier = productIdentifier;
    }
    return self;
}

+ (instancetype)itemWithProductIdentifier:(NSString *)productIdentifier;
{
    return [[self alloc] initWithProductIdentifier:productIdentifier];
}

- (NSMutableDictionary *)productData
{
    if (!_productData) {
        _productData = (NSMutableDictionary *)[self objectForKey:(__bridge id)kSecValueData];
    }
    
    return _productData;
}

// 有効チェック
- (BOOL)isValid;
{
    NSDictionary *dictionary = [self productData];
    
    // 商品IDチェック
    NSString *identifier = [dictionary objectForKey:kKeychainItemProductIdentifier];
    if (![identifier isEqualToString:_productIdentifier]) {
        return NO;
    }
        
    // 商品数量チェック
    _count = [[dictionary objectForKey:kKeychainItemProductCount] integerValue];
    if (_count <= 0) {
        return NO;
    }
    return YES;
}

// 商品の購入／使用
- (void)addProductWithCount:(NSInteger)count;
{
    _count += count;
    
    [self synchronize];
}

// 商品使用
- (void)consume;
{
    if (_count > 0) {
        _count--;
        
        [self synchronize];
    }
}

- (void)synchronize
{
    NSMutableDictionary *dictionary = [self productData];
    [dictionary setObject:[NSNumber numberWithInteger:_count] forKey:kKeychainItemProductCount];
}

@end


typedef void (^PresentProductsBlock)(NSArray *products, PurchaseStatus status);

typedef void (^ProvideContentBlock)(NSString *productIdentifier, BOOL succeed);

@interface PurchaseManager ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    // 商品ID
    NSSet                               *_productIdentifiers;
    
    // ステータス
    PurchaseStatus                      _status;
    
    // 商品情報請求リクエスト
    SKProductsRequest                   *_request;

    // 商品
    NSArray                             *_products;
    
    // レシート検証
    NSURLConnection                     *_verifyConnection;
    NSMutableData                       *_receiveData;
    NSMutableDictionary                 *_savedTransactionsReceipt;
}

// 商品情報請求リクエスト
@property (nonatomic, strong) SKProductsRequest *request;

// 商品情報表示処理
@property (nonatomic, strong) PresentProductsBlock presentProductsBlock;

// コンテンツ提供処理
@property (nonatomic, strong) ProvideContentBlock provideContentBlock;


@end

@implementation PurchaseManager

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
{
    self = [super init];
    if (self) {
        _productIdentifiers = productIdentifiers;
        [_productIdentifiers enumerateObjectsUsingBlock:^(NSString *productIdentifier, BOOL *stop) {
        }];
        
        // 支払いトランザクションのオブザーバー設定
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

//    if ((self = [super init])) {
//        
//        // Store product identifiers
//        _productIdentifiers = productIdentifiers;
//        
//        // Check for previously purchased products
//        NSMutableSet * purchasedProducts = [NSMutableSet set];
//        for (NSString * productIdentifier in _productIdentifiers) {
//            
//            BOOL productPurchased = NO;
//            
//            NSString* password = [SFHFKeychainUtils getPasswordForUsername:productIdentifier andServiceName:@"IAPHelper" error:nil];
//            if([password isEqualToString:@"YES"])
//            {
//                productPurchased = YES;
//            }
//            
//            if (productPurchased) {
//                [purchasedProducts addObject:productIdentifier];
//                
//            }
//        }
//        
//        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//        
//        self.purchasedProducts = purchasedProducts;
//        
//    }
//}?

- (BOOL)isPurchasedProductWith:(NSString *)identifier
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:identifier accessGroup:nil];
    keychain = nil;
    return YES;
}

#pragma mark - 商品情報リクエスト
// Step(1):商品情報請求
- (void)requestProductsWithCompletion:(void (^)(NSArray *products, PurchaseStatus status))completion;
{
    // 初期化
    _status = PurchaseStatusOK;
    _presentProductsBlock = nil;
    _request.delegate = nil;
    _request = nil;
    
    // 商品チェック
    if (![_productIdentifiers count]) {
        _status = PurchaseStatusNoProduct;
        return [self _requestProductsDidEnd];
    }
    
    // ネットワーク接続状態チェック
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([reach currentReachabilityStatus] == NotReachable) {
        _status = PurchaseStatusNotReachable;
        return [self _requestProductsDidEnd];
    }
    
    // アプリ内課金可否チェック
    if (![SKPaymentQueue canMakePayments]) {
        _status = PurchaseStatusCannotMakePayments;
        return [self _requestProductsDidEnd];
    }
    
    // 商品情報取得開始
    self.presentProductsBlock = completion;
    _request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _request.delegate = self;
    [_request start];
}

// 商品情報請求正常終了
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // 商品情報チェック
    _products = response.products;
    if ([response.invalidProductIdentifiers count]) {
        _status = PurchaseStatusInvalidProduct;
        [response.invalidProductIdentifiers enumerateObjectsUsingBlock:^(NSString *invalidProductIdentifier, NSUInteger idx, BOOL *stop){
            DebugLog(@"無効商品ID:[%@]", invalidProductIdentifier);
        }];
    }
    
    [self _requestProductsDidEnd];
}

// 商品情報請求異常終了
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    _status = PurchaseStatusRequestFailed;
    [self _requestProductsDidEnd];
}

- (void)_requestProductsDidEnd
{
    if (_presentProductsBlock) {
        _presentProductsBlock(_products, _status);
    }
}

#pragma mark - 商品購入
// Step(2):商品購入
- (void)buyProduct:(SKProduct *)product withQuantity:(NSInteger)quantity completion:(void (^)(NSString *productIdentifier, BOOL succeed))completion
{
    self.provideContentBlock = completion;
    if (quantity > 1) {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.quantity = quantity;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

#pragma mark - 支払いトランザクション
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self _completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self _restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self _failedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
}

- (void)_completeTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSData *receiptData = [transaction receipt];
    NSDictionary *receipt = [NSDictionary dictionaryWithAppStoreReceipt:receiptData];
    if (![receipt isValidReceipt]) {
        DebugLog(@"NG");
    }
    
    // 退避
    NSString *transactionID;
    if (transaction.originalTransaction == nil) {
        transactionID = transaction.transactionIdentifier;
    } else {
        transactionID = transaction.originalTransaction.transactionIdentifier;
    }
    
    NSArray *appStoreReceipts = [receipt objectForKey:@"in-app"];
    
    if (!_savedTransactionsReceipt) {
        _savedTransactionsReceipt = [NSMutableDictionary dictionary];
    }
    for (NSDictionary *dictionary in appStoreReceipts) {
        NSString *appTransactionIdentifier = [dictionary objectForKey:@"transaction_id"];
        
        if ([appTransactionIdentifier isEqualToString:transactionID]) {
            
            // Save the transaction receipt's purchaseInfo in the transactionsReceiptStorageDictionary.
            [_savedTransactionsReceipt setObject:receipt forKey:transactionID];
            
            break;
        }
    }
    
    // レシート検証実行
    NSURL *receiptVerifyURL = [self _receiptVerifyURL];
    NSData *receiptJSONData = [receiptData receiptJSONData];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:receiptVerifyURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:receiptJSONData];
    _receiveData = [NSMutableData data];
    _verifyConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_verifyConnection start];
}

- (void)_restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self _recordTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (_provideContentBlock) {
        _provideContentBlock(transaction.payment.productIdentifier, YES);
    }
}

- (void)_failedTransaction:(SKPaymentTransaction *)transaction
{
    // 支払いキャンセル以外の場合、エラー原因を出力する。
    if (transaction.error.code != SKErrorPaymentCancelled) {
        DebugLog(@"Error(%ld): %@",(long)transaction.error.code, transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (_provideContentBlock) {
        _provideContentBlock(transaction.payment.productIdentifier, NO);
    }
}

- (void)_recordTransaction:(SKPaymentTransaction *)transaction
{
    
}

- (void)_provideContent:(NSString *)productIdentifier
{
    
}

- (NSURL *)_receiptVerifyURL
{
    if (_customReceiptVerifyURL) {
        return [NSURL URLWithString:_customReceiptVerifyURL];
    }
    if (_sandboxMode) {
        return [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    } else {
        return [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    [_receiveData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    [_receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    [_receiveData isMatchToTransactions:_savedTransactionsReceipt];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
    
}

@end

@implementation SKProduct(LocalizedPrice)

- (NSString *)localizedPrice;
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSMutableString *string = [NSMutableString stringWithString:[numberFormatter stringFromNumber:self.price]];
    while ([string length]) {
        NSInteger length = [string length];
        NSRange range = NSMakeRange(length - 1, 1);
        NSString *lastCharacter = [string substringWithRange:range];
        if ([lastCharacter isEqualToString:@"0"]) {
            [string deleteCharactersInRange:range];
            continue;
        } else if ([lastCharacter isEqualToString:@"."]) {
            [string deleteCharactersInRange:range];
        }
        break;
    }
    
    return string;
}

@end
