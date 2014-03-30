//
//  SharingMessage.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SharingMessage.h"

@implementation SharingMessage
{
    // 設定情報
    NSDictionary                        *_dictionary;
}

// 設定情報取得
- (NSDictionary *)settingInfo;
{
    if (!_dictionary) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SharingMessage" ofType:@"plist"];
        _dictionary = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
    }
    return _dictionary;
}

// メール標題
- (NSString *)title;
{
    NSDictionary *dictionary = [self settingInfo];
    return [dictionary objectForKey:@"Title"];
}

// メールメッセージ
- (NSString *)message;
{
    NSDictionary *dictionary = [self settingInfo];
    if (_sharingType == SharingTypeMail) {
        return [dictionary objectForKey:@"Mail"];
    } else if (_sharingType == SharingTypeFacebook) {
        return [dictionary objectForKey:@"FaceBook"];
    } else {
        return [dictionary objectForKey:@"Twitter"];
    }
}

@end

