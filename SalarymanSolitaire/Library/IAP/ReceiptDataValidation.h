//
//  ReceiptDataValidation.h
//  Purchase
//
//  Created by dev on 14-4-14.
//  Copyright (c) 2014年 dev. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKPaymentTransaction (ReceiptValidation)
- (NSData *)receipt;
@end

@interface NSData (ReceiptValidation)

- (NSData *)receiptJSONData;
- (NSArray *)matchedProductsWithTransactions:(NSDictionary *)transactions;
@end

@interface NSDictionary (ReceiptValidation)
+ (NSDictionary *)dictionaryWithAppStoreReceipt:(NSData *)receiptData;
- (BOOL)isValidReceipt;
@end