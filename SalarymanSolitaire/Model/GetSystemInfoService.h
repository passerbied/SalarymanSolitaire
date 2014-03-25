//
//  GetSystemInfoService.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-22.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSWebService.h"

@class GetSystemInfoResponse;

// リクエスト
@interface GetSystemInfoRequest : WebRequest

// システム日時
@property (strong, nonatomic) NSString *UpdateTime;

@end

// サービス
@interface GetSystemInfoService : WebService

// レスポンス取得
- (GetSystemInfoResponse *)notification;
@end

// レスポンス
@interface GetSystemInfoResponse : WebResponse

// アドレス（お知らせ）
@property (strong, nonatomic) NSString *NotificationURL;

// アドレス（ヘルプ）
@property (strong, nonatomic) NSString *HelpURL;

// システム日時
@property (strong, nonatomic) NSString *UpdateTime;

@end

@interface SolitaireManager (GetSystemInfo)

// お知らせアドレス
- (NSURL *)notificationURL;

// ヘルプアドレス
- (NSURL *)helpURL;

// お知らせ情報退避
- (void)saveNotificationWith:(GetSystemInfoResponse *)notification;

// お知らせ表示要否フラグ
- (BOOL)shouldPresentNotification;

// お知らせ表示済み
- (void)didPresentNotification;

@end