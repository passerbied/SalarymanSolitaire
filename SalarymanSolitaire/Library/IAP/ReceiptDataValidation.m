//
//  ReceiptDataValidation.m
//  Purchase
//
//  Created by dev on 14-4-14.
//  Copyright (c) 2014年 dev. All rights reserved.
//

#import "ReceiptDataValidation.h"
#include <openssl/pkcs7.h>
#include <openssl/objects.h>
#include <openssl/sha.h>
#include <openssl/x509.h>
#include <openssl/err.h>


@implementation SKPaymentTransaction (ReceiptValidation)
- (NSData *)receipt;
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    return [NSData dataWithContentsOfURL:receiptURL];
}
@end

NSString *kReceiptBundleIdentifier                      = @"bid";
NSString *kReceiptBundleIdentifieriOS7                  = @"bundle_id";
NSString *kReceiptBundleIdentifierData                  = @"bid_data";
NSString *kReceiptVersion                               = @"application_version";
NSString *kReceiptOpaqueValue                           = @"opaque";
NSString *kReceiptHash                                  = @"secret";
NSString *kReceiptInApp                                 = @"in-app";
NSString *kReceiptOriginalVersion                       = @"original_application_version";
NSString *kReceiptExpirationDate                        = @"expiration_date";
NSString *kReceiptInAppQuantity                         = @"quantity";
NSString *kReceiptInAppProductIdentifier                = @"product_id";
NSString *kReceiptInAppProductIdentifierPurch           = @"product-id";
NSString *kReceiptInAppTransactionIdentifier            = @"transaction_id";
NSString *kReceiptInAppPurchaseDate                     = @"purchase_date";
NSString *kReceiptInAppOriginalTransactionIdentifier    = @"original_transaction_id";
NSString *kReceiptInAppOriginalPurchaseDate             = @"original_purchase_date";
NSString *kReceiptInAppSubscriptionExpirationDate       = @"expires_date";
NSString *kReceiptInAppCancellationDate                 = @"cancellation_date";
NSString *kReceiptInAppWebOrderLineItemID               = @"web_order_line_item_id";
@implementation NSData (ReceiptValidation)



static int POS(char c)
{
    if (c>='A' && c<='Z') return c - 'A';
    if (c>='a' && c<='z') return c - 'a' + 26;
    if (c>='0' && c<='9') return c - '0' + 52;
    if (c == '+') return 62;
    if (c == '/') return 63;
    if (c == '=') return -1;
    
    [NSException raise:@"invalid BASE64 encoding" format:@"Invalid BASE64 encoding"];
    return 0;
}


char* base64_encode(const void* buf, size_t size)
{
    static const char base64[] =  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    char* str = (char*) malloc((size+3)*4/3 + 1);
    
    char* p = str;
    unsigned char* q = (unsigned char*) buf;
    size_t i = 0;
    
    while(i < size) {
        int c = q[i++];
        c *= 256;
        if (i < size) c += q[i];
        i++;
        
        c *= 256;
        if (i < size) c += q[i];
        i++;
        
        *p++ = base64[(c & 0x00fc0000) >> 18];
        *p++ = base64[(c & 0x0003f000) >> 12];
        
        if (i > size + 1)
            *p++ = '=';
        else
            *p++ = base64[(c & 0x00000fc0) >> 6];
        
        if (i > size)
            *p++ = '=';
        else
            *p++ = base64[c & 0x0000003f];
    }
    
    *p = 0;
    
    return str;
}

void* base64_decode(const char* s, size_t* data_len_ptr)
{
    size_t len = strlen(s);
    
    if (len % 4)
        [NSException raise:@"Invalid input in base64_decode" format:@"%zd is an invalid length for an input string for BASE64 decoding", len];
    
    unsigned char* data = (unsigned char*) malloc(len/4*3);
    
    int n[4];
    unsigned char* q = (unsigned char*) data;
    
    for(const char*p=s; *p; )
    {
        n[0] = POS(*p++);
        n[1] = POS(*p++);
        n[2] = POS(*p++);
        n[3] = POS(*p++);
        
        if (n[0]==-1 || n[1]==-1)
            [NSException raise:@"Invalid input in base64_decode" format:@"Invalid BASE64 encoding"];
        
        if (n[2]==-1 && n[3]!=-1)
            [NSException raise:@"Invalid input in base64_decode" format:@"Invalid BASE64 encoding"];
        
        q[0] = (n[0] << 2) + (n[1] >> 4);
        if (n[2] != -1) q[1] = ((n[1] & 15) << 4) + (n[2] >> 2);
        if (n[3] != -1) q[2] = ((n[2] & 3) << 6) + n[3];
        q += 3;
    }
    
    // make sure that data_len_ptr is not null
    if (!data_len_ptr)
        [NSException raise:@"Invalid input in base64_decode" format:@"Invalid destination for output string length"];
    
    *data_len_ptr = q-data - (n[2]==-1) - (n[3]==-1);
    
    return data;
}

- (NSData *)receiptJSONData;
{
    NSString *receiptBase64Encoded = [NSString stringWithUTF8String:base64_encode(self.bytes, self.length)];
    NSString *receiptJSONFormat = @"{\"receipt-data\" : \"%@\"}";
    NSString *receiptJSONString = [NSString stringWithFormat:receiptJSONFormat, receiptBase64Encoded];
    return [receiptJSONString dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)isMatchToTransactions:(NSDictionary *)transactions;
{
    NSError *error;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self
                                                             options:0
                                                               error:&error];
    
    if (error) {
        return NO;
    }
    
    // Check the status of the verifyReceipt call
    id status = [response objectForKey:@"status"];
    if (!status) {
        DebugLog(@"Receipt Exception : Check the status of the verifyReceipt call");
        return NO;
    }
    
    int statusIntegerValue = (int)[status integerValue];
    if (0 != statusIntegerValue && 21006 != statusIntegerValue)
    {
        DebugLog(@"Receipt Exception : This receipt is valid but the subscription has expired.");
        return NO;
    }
    
    NSDictionary *receipt  = [response objectForKey:@"receipt"];
    NSArray *array = [receipt objectForKey:@"in_app"];
    
    BOOL succeed = YES;
    
    for (int i = 0; i < array.count; i++) {
        NSDictionary *receiptInfo = [array objectAtIndex:i];
        NSString *transactionId = [receiptInfo objectForKey:@"transaction_id"];
        
        // Get the transaction's receipt data from the transactionsReceiptStorageDictionary
        NSDictionary *transactionInfo = [transactions objectForKey:transactionId];
        if (!transactionInfo) {
            succeed = NO;
            break;
        }
        // Verify all the receipt specifics to ensure everything matches up as expected
        NSString *receiptBundleIdentifier = [receipt objectForKey:@"bundle_id"];
        NSString *savedBundleIdentifier = [transactionInfo objectForKey:@"bid"];
        if (![receiptBundleIdentifier isEqualToString:savedBundleIdentifier])
        {
            succeed = NO;
            break;
        }
        
        NSArray *purchaseInfoArray = [transactionInfo objectForKey:@"in-app"];
        for (NSDictionary *purchaseInfo in purchaseInfoArray) {
            NSString *receiptProductId = [receiptInfo objectForKey:@"product_id"];
            NSString *savedProductId = [purchaseInfo objectForKey:@"product_id"];
            if (![receiptProductId isEqualToString:savedProductId])
            {
                succeed = NO;
                break;
            }
            
            NSString *quantityInapp = [NSString stringWithFormat:@"%@",[receiptInfo objectForKey:@"quantity"]];
            NSString *quantityPurchase = [NSString stringWithFormat:@"%@",[purchaseInfo objectForKey:@"quantity"]];
            if (![quantityInapp isEqualToString:quantityPurchase])
            {
                succeed = NO;
                break;
            }
        }
    }

    return succeed;
}
@end
@implementation NSDictionary (ReceiptValidation)
// ASN.1 values for In-App Purchase values
#define INAPP_ATTR_START                1700
#define INAPP_QUANTITY                  1701
#define INAPP_PRODID                    1702
#define INAPP_TRANSID                   1703
#define INAPP_PURCHDATE                 1704
#define INAPP_ORIGTRANSID               1705
#define INAPP_ORIGPURCHDATE             1706
#define INAPP_ATTR_END                  1707
#define INAPP_SUBEXP_DATE               1708
#define INAPP_WEBORDER                  1711
#define INAPP_CANCEL_DATE               1712

NSArray *parseInAppPurchasesData(NSData *inappData)
{
    int type = 0;
    int xclass = 0;
    long length = 0;
    
    NSUInteger dataLenght = [inappData length];
    const uint8_t *p = [inappData bytes];
    
    const uint8_t *end = p + dataLenght;
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    while (p < end) {
        ASN1_get_object(&p, &length, &type, &xclass, end - p);
        
        const uint8_t *set_end = p + length;
        
        if(type != V_ASN1_SET) {
            break;
        }
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:6];
        
        while (p < set_end) {
            ASN1_get_object(&p, &length, &type, &xclass, set_end - p);
            if (type != V_ASN1_SEQUENCE) {
                break;
            }
            
            const uint8_t *seq_end = p + length;
            
            int attr_type = 0;
            int attr_version = 0;
            
            // Attribute type
            ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
            if (type == V_ASN1_INTEGER) {
                if(length == 1) {
                    attr_type = p[0];
                }
                else if(length == 2) {
                    attr_type = p[0] * 0x100 + p[1]
                    ;
                }
            }
            p += length;
            
            // Attribute version
            ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
            if (type == V_ASN1_INTEGER && length == 1) {
                // clang analyser hit (wontfix at the moment, since the code might come in handy later)
                // But if someone has a convincing case throwing that out, I might do so, Roddi
                attr_version = p[0];
            }
            p += length;
            
            // Only parse attributes we're interested in
            if ((attr_type > INAPP_ATTR_START && attr_type < INAPP_ATTR_END) || attr_type == INAPP_SUBEXP_DATE || attr_type == INAPP_WEBORDER || attr_type == INAPP_CANCEL_DATE) {
                NSString *key = nil;
                
                ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
                if (type == V_ASN1_OCTET_STRING) {
                    //NSData *data = [NSData dataWithBytes:p length:(NSUInteger)length];
                    
                    // Integers
                    if (attr_type == INAPP_QUANTITY || attr_type == INAPP_WEBORDER) {
                        int num_type = 0;
                        long num_length = 0;
                        const uint8_t *num_p = p;
                        ASN1_get_object(&num_p, &num_length, &num_type, &xclass, seq_end - num_p);
                        if (num_type == V_ASN1_INTEGER) {
                            NSUInteger quantity = 0;
                            if (num_length) {
                                quantity += num_p[0];
                                if (num_length > 1) {
                                    quantity += num_p[1] * 0x100;
                                    if (num_length > 2) {
                                        quantity += num_p[2] * 0x10000;
                                        if (num_length > 3) {
                                            quantity += num_p[3] * 0x1000000;
                                        }
                                    }
                                }
                            }
                            
                            NSNumber *num = [[NSNumber alloc] initWithUnsignedInteger:quantity];
                            if (attr_type == INAPP_QUANTITY) {
                                [item setObject:num forKey:kReceiptInAppQuantity];
                            } else if (attr_type == INAPP_WEBORDER) {
                                [item setObject:num forKey:kReceiptInAppWebOrderLineItemID];
                            }
                        }
                    }
                    
                    // Strings
                    if (attr_type == INAPP_PRODID ||
                        attr_type == INAPP_TRANSID ||
                        attr_type == INAPP_ORIGTRANSID ||
                        attr_type == INAPP_PURCHDATE ||
                        attr_type == INAPP_ORIGPURCHDATE ||
                        attr_type == INAPP_SUBEXP_DATE ||
                        attr_type == INAPP_CANCEL_DATE) {
                        
                        int str_type = 0;
                        long str_length = 0;
                        const uint8_t *str_p = p;
                        ASN1_get_object(&str_p, &str_length, &str_type, &xclass, seq_end - str_p);
                        if (str_type == V_ASN1_UTF8STRING) {
                            switch (attr_type) {
                                case INAPP_PRODID:
                                    key = kReceiptInAppProductIdentifier;
                                    break;
                                case INAPP_TRANSID:
                                    key = kReceiptInAppTransactionIdentifier;
                                    break;
                                case INAPP_ORIGTRANSID:
                                    key = kReceiptInAppOriginalTransactionIdentifier;
                                    break;
                            }
                            
                            if (key) {
                                NSString *string = [[NSString alloc] initWithBytes:str_p
                                                                            length:(NSUInteger)str_length
                                                                          encoding:NSUTF8StringEncoding];
                                [item setObject:string forKey:key];
                            }
                        }
                        if (str_type == V_ASN1_IA5STRING) {
                            switch (attr_type) {
                                case INAPP_PURCHDATE:
                                    key = kReceiptInAppPurchaseDate;
                                    break;
                                case INAPP_ORIGPURCHDATE:
                                    key = kReceiptInAppOriginalPurchaseDate;
                                    break;
                                case INAPP_SUBEXP_DATE:
                                    key = kReceiptInAppSubscriptionExpirationDate;
                                    break;
                                case INAPP_CANCEL_DATE:
                                    key = kReceiptInAppCancellationDate;
                                    break;
                            }
                            
                            if (key) {
                                NSString *string = [[NSString alloc] initWithBytes:str_p
                                                                            length:(NSUInteger)str_length
                                                                          encoding:NSASCIIStringEncoding];
                                [item setObject:string forKey:key];
                            }
                        }
                    }
                }
                
                p += length;
            }
            
            // Skip any remaining fields in this SEQUENCE
            while (p < seq_end) {
                ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
                p += length;
            }
        }
        
        // Skip any remaining fields in this SET
        while (p < set_end) {
            ASN1_get_object(&p, &length, &type, &xclass, set_end - p);
            p += length;
        }
        
        [resultArray addObject:item];
    }
    
    return resultArray;
}


// ASN.1 values for the App Store receipt
#define ATTR_START 1
#define BUNDLE_ID 2
#define VERSION 3
#define OPAQUE_VALUE 4
#define HASH 5
#define ATTR_END 6
#define INAPP_PURCHASE 17
#define ORIG_VERSION 19
#define EXPIRE_DATE 21

+ (NSDictionary *)dictionaryWithAppStoreReceipt:(NSData *)receiptData
{
    NSData * rootCertData = appleRootCert();
    
    ERR_load_PKCS7_strings();
    ERR_load_X509_strings();
    OpenSSL_add_all_digests();
    
    // Expected input is a PKCS7 container with signed data containing
    // an ASN.1 SET of SEQUENCE structures. Each SEQUENCE contains
    // two INTEGERS and an OCTET STRING.
    
    const uint8_t *receiptBytes = (uint8_t *)(receiptData.bytes);
    PKCS7 *p7 = d2i_PKCS7(NULL, &receiptBytes, (long)receiptData.length);
    
    // Check if the receipt file was invalid (otherwise we go crashing and burning)
    if (p7 == NULL) {
        return nil;
    }
    
    if (!PKCS7_type_is_signed(p7)) {
        PKCS7_free(p7);
        return nil;
    }
    
    if (!PKCS7_type_is_data(p7->d.sign->contents)) {
        PKCS7_free(p7);
        return nil;
    }
    
    int verifyReturnValue = 0;
    X509_STORE *store = X509_STORE_new();
    if (store) {
        const uint8_t *data = (uint8_t *)(rootCertData.bytes);
        X509 *appleCA = d2i_X509(NULL, &data, (long)rootCertData.length);
        if (appleCA) {
            BIO *payload = BIO_new(BIO_s_mem());
            X509_STORE_add_cert(store, appleCA);
            
            if (payload) {
                verifyReturnValue = PKCS7_verify(p7,NULL,store,NULL,payload,0);
                BIO_free(payload);
            }
            
            X509_free(appleCA);
        }
        
        X509_STORE_free(store);
    }
    
    EVP_cleanup();
    
    if (verifyReturnValue != 1) {
        PKCS7_free(p7);
        return nil;
    }
    
    ASN1_OCTET_STRING *octets = p7->d.sign->contents->d.data;
    const uint8_t *p = octets->data;
    const uint8_t *end = p + octets->length;
    
    int type = 0;
    int xclass = 0;
    long length = 0;
    
    ASN1_get_object(&p, &length, &type, &xclass, end - p);
    if (type != V_ASN1_SET) {
        PKCS7_free(p7);
        return nil;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    while (p < end) {
        ASN1_get_object(&p, &length, &type, &xclass, end - p);
        if (type != V_ASN1_SEQUENCE) {
            break;
        }
        
        const uint8_t *seq_end = p + length;
        
        int attr_type = 0;
        int attr_version = 0;
        
        // Attribute type
        ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
        if (type == V_ASN1_INTEGER && length == 1) {
            attr_type = p[0];
        }
        p += length;
        
        // Attribute version
        ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
        if (type == V_ASN1_INTEGER && length == 1) {
            attr_version = p[0];
            attr_version = attr_version;
        }
        p += length;
        
        // Only parse attributes we're interested in
        if ((attr_type > ATTR_START && attr_type < ATTR_END) || attr_type == INAPP_PURCHASE || attr_type == ORIG_VERSION || attr_type == EXPIRE_DATE) {
            NSString *key = nil;
            
            ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
            if (type == V_ASN1_OCTET_STRING) {
                NSData *data = [NSData dataWithBytes:p length:(NSUInteger)length];
                
                // Bytes
                if (attr_type == BUNDLE_ID || attr_type == OPAQUE_VALUE || attr_type == HASH) {
                    switch (attr_type) {
                        case BUNDLE_ID:
                            // This is included for hash generation
                            key = kReceiptBundleIdentifierData;
                            break;
                        case OPAQUE_VALUE:
                            key = kReceiptOpaqueValue;
                            break;
                        case HASH:
                            key = kReceiptHash;
                            break;
                    }
                    if (key) {
                        [info setObject:data forKey:key];
                    }
                }
                
                // Strings
                if (attr_type == BUNDLE_ID || attr_type == VERSION || attr_type == ORIG_VERSION) {
                    int str_type = 0;
                    long str_length = 0;
                    const uint8_t *str_p = p;
                    ASN1_get_object(&str_p, &str_length, &str_type, &xclass, seq_end - str_p);
                    if (str_type == V_ASN1_UTF8STRING) {
                        switch (attr_type) {
                            case BUNDLE_ID:
                                key = kReceiptBundleIdentifier;
                                break;
                            case VERSION:
                                key = kReceiptVersion;
                                break;
                            case ORIG_VERSION:
                                key = kReceiptOriginalVersion;
                                break;
                        }
                        
                        if (key) {
                            NSString *string = [[NSString alloc] initWithBytes:str_p
                                                                        length:(NSUInteger)str_length
                                                                      encoding:NSUTF8StringEncoding];
                            [info setObject:string forKey:key];
                        }
                    }
                }
                
                // In-App purchases
                if (attr_type == INAPP_PURCHASE) {
                    NSArray *inApp = parseInAppPurchasesData(data);
                    NSArray *current = info[kReceiptInApp];
                    if (current) {
                        info[kReceiptInApp] = [current arrayByAddingObjectsFromArray:inApp];
                    } else {
                        [info setObject:inApp forKey:kReceiptInApp];
                    }
                }
            }
            p += length;
        }
        
        // Skip any remaining fields in this SEQUENCE
        while (p < seq_end) {
            ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
            p += length;
        }
    }
    
    PKCS7_free(p7);
    
    return info;
}

NSData *appleRootCert(void)
{
    // Obtain the Apple Inc. root certificate from http://www.apple.com/certificateauthority/
    // Download the Apple Inc. Root Certificate ( http://www.apple.com/appleca/AppleIncRootCertificate.cer )
    // Add the AppleIncRootCertificate.cer to your app's resource bundle.
    
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"AppleIncRootCertificate" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:certPath];
    
    return certData;
}
- (BOOL)isValidReceipt;
{
    // 检查BundleID是否相等
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleIdentifier isEqualToString:[self objectForKey:kReceiptBundleIdentifier]]) {
        DebugLog(@"收据检查：BundleID不一致");
        return NO;
    }

    // 检查Version是否相等
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (![bundleVersion isEqualToString:[self objectForKey:kReceiptVersion]]) {
        DebugLog(@"收据检查：Version不一致");
        return NO;
    }

    // 检查哈希码是否相等
    unsigned char uuidBytes[16];
    NSUUID *vendorUUID = [[UIDevice currentDevice] identifierForVendor];
    [vendorUUID getUUIDBytes:uuidBytes];

    NSMutableData *input = [NSMutableData data];
    [input appendBytes:uuidBytes length:sizeof(uuidBytes)];
    [input appendData:[self objectForKey:kReceiptOpaqueValue]];
    [input appendData:[self objectForKey:kReceiptBundleIdentifierData]];

    NSMutableData *hash = [NSMutableData dataWithLength:SHA_DIGEST_LENGTH];
    SHA1([input bytes], [input length], [hash mutableBytes]);

    if (![hash isEqualToData:[self objectForKey:kReceiptHash]]) {
        DebugLog(@"收据检查：HASH不一致");
        return NO;
    }
    
    return YES;
}



@end
