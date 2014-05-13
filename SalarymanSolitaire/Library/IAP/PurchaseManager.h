//
//  PurchaseManager.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-11.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

// 商品種類
typedef enum
{
    ProductTypeConsumable,
    ProductTypeNonConsumable,
    ProductTypeFreeSubscription,
    ProductTypeAutoRenewableSubscriptions,
    ProductTypeNonRenewingSubscription
} ProductType;

// エラー
typedef enum
{
    PurchaseStatusOK,
    PurchaseStatusNoProduct,
    PurchaseStatusNotReachable,
    PurchaseStatusCannotMakePayments,
    PurchaseStatusInvalidProduct,
    PurchaseStatusRequestFailed,
    PurchaseStatusReceiptFailed
} PurchaseStatus;

@interface PurchaseManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

// 初期化
+ (instancetype)sharedManager;

// 商品ID
@property (nonatomic, strong) NSSet *productIdentifiers;

// サンドボックス
@property (nonatomic, getter = inSandboxMode) BOOL sandboxMode;

// レシート検証サーバアドレス
@property (nonatomic, strong) NSString *customReceiptVerifyURL;

// Step(1):商品情報請求
- (void)requestProductsWithCompletion:(void (^)(NSArray *products, PurchaseStatus status))completion;

// Step(2):商品購入
- (void)buyProduct:(SKProduct *)product withQuantity:(NSInteger)quantity completion:(void (^)(NSArray *productIdentifiers, BOOL succeed))completion;
@end

@interface SKProduct (LocalizedPrice)

- (NSString *)localizedPrice;

@end
