//
//  SharingMessage.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SharingTypeMail,
    SharingTypeFacebook,
    SharingTypeTwitter
} SharingType;

@interface SharingMessage : NSObject

// メッセージ種類
@property (nonatomic) SharingType sharingType;


// メール標題
- (NSString *)title;

// メールメッセージ
- (NSString *)message;


@end
