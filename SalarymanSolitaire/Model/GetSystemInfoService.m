//
//  GetSystemInfoService.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-22.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "GetSystemInfoService.h"

// 退避キー「お知らせ更新日時」
#define __USER_LAST_UPDATE_KEY          @"UserLastUpdate"

// 退避キー「お知らせURL」
#define __USER_NOTIFICATION_URL_KEY     @"UserNotificationURL"

// 退避キー「お知らせ新着」
#define __USER_NOTIFICATION_ISNEW_KEY   @"UserNotificationIsNew"

// 退避キー「ヘルプURL」
#define __USER_HELP_URL_KEY             @"UserHelpInfoURL"


@implementation GetSystemInfoRequest

- (NSString *)UpdateTime
{
    // システム日時取得
    if (!_UpdateTime) {
        _UpdateTime = [[NSUserDefaults standardUserDefaults] stringForKey:__USER_LAST_UPDATE_KEY];
        
        if (![_UpdateTime length]) {
            _UpdateTime = @"";
        }
    }
    return _UpdateTime;
}
@end

@implementation GetSystemInfoService

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.address = __GET_NOTIFICATION_URL;
        self.responseIdentifiers = [NSSet setWithObject:__GET_NOTIFICATION_RESPONSE];
    }
    return self;
}

// レスポンス取得
- (GetSystemInfoResponse *)notification;
{
    GetSystemInfoResponse *notification = nil;
    NSArray *array = [self responseDataWithIdentifier:__GET_NOTIFICATION_RESPONSE];
    if ([array count]) {
        notification = (GetSystemInfoResponse *)[array objectAtIndex:0];
        [[SolitaireManager sharedManager] saveNotificationWith:notification];
    }
    return notification;
}

@end

@implementation GetSystemInfoResponse

@end

@implementation SolitaireManager (GetSystemInfo)
// お知らせアドレス
- (NSURL *)notificationURL;
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *address = [userDefaults stringForKey:__USER_NOTIFICATION_URL_KEY];
    return [NSURL URLWithString:address];
}

// ヘルプアドレス
- (NSURL *)helpURL;
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *address = [userDefaults stringForKey:__USER_HELP_URL_KEY];
    
    if (![address length]) {
        address = __DEFAULT_HELP_URL;
    }
    return [NSURL URLWithString:__DEFAULT_HELP_URL];
}

// お知らせ情報退避
- (void)saveNotificationWith:(GetSystemInfoResponse *)notification;
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUpdateTime = [userDefaults stringForKey:__USER_LAST_UPDATE_KEY];
    
    [userDefaults setObject:notification.UpdateTime forKey:__USER_LAST_UPDATE_KEY];
    [userDefaults setObject:notification.NotificationURL forKey:__USER_NOTIFICATION_URL_KEY];
    [userDefaults setObject:notification.HelpURL forKey:__USER_HELP_URL_KEY];
    
    if ([notification.UpdateTime isEqualToString:lastUpdateTime]) {
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:__USER_NOTIFICATION_ISNEW_KEY];
    } else {
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:__USER_NOTIFICATION_ISNEW_KEY];
    }
    
    [userDefaults synchronize];
}

// お知らせ表示要否フラグ
- (BOOL)shouldPresentNotification;
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:__USER_NOTIFICATION_ISNEW_KEY];
}

// お知らせ表示済み
- (void)didPresentNotification;
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:__USER_NOTIFICATION_ISNEW_KEY];
}
@end
