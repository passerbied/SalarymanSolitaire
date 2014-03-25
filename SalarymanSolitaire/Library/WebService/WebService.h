//
//  WebService.h
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRequest.h"
#import "WebResponse.h"

@protocol WebServiceDelegate;

@interface WebService : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    // レスポンステータス
    NSMutableData                       *_responseData;
    
    // 接続
    NSURLConnection                     *_connection;
}

// タイムアウト時間
+ (void)setTimeout:(NSTimeInterval)timeout;

// Webサービス対象作成
+ (id)serviceWithDelegate:(id<WebServiceDelegate>)delegate;

// サービスアドレス
@property (strong, nonatomic) NSString *address;

// Webサービス実行委譲
@property (weak, nonatomic) id<WebServiceDelegate> delegate;

// POSTデータ
@property (strong, nonatomic) WebRequest *request;

// レスポンス
@property (strong, nonatomic) NSMutableDictionary *response;

// 文字コード
@property (nonatomic) NSStringEncoding encoding;

// レスポンステータスID
@property (strong, nonatomic) NSSet *responseIdentifiers;

// テストモード
@property (nonatomic, getter = isTestMode) BOOL testMode;

/*** @brief ユーザ名称 */
@property (strong, nonatomic) NSString *userName;

/*** @brief パスワード*/
@property (strong, nonatomic) NSString *password;

// 処理結果コード
@property (strong, nonatomic) NSString *WebResultCode;

// Webサービス実行開始
- (BOOL)start;

// キャンセル
- (void)cancel;

// 正常終了
@property (nonatomic) BOOL succeed;

@property (nonatomic) BOOL reachable;

@property (nonatomic) BOOL showResultMessage;

// レスポンステータス取得
- (NSArray*)responseDataWithIdentifier:(NSString*)idertifier;

// ネットワーク接続チェック
+ (BOOL)isReachable;
@property (nonatomic,assign) SEL unreachableSelector;
@property (nonatomic,assign) SEL willStartSelector;
@property (nonatomic,assign) SEL didSucceedSelector;
@property (nonatomic,assign) SEL didFailedSelector;
@property (nonatomic,assign) SEL didEndedSelector;

@end


@protocol WebServiceDelegate <NSObject>

@optional
// サーバアクセスできない
- (void)serviceUnreachable:(WebService *)service;

// サービス開始
- (void)serviceWillStart:(WebService *)service;

// サービス成功
- (void)serviceDidSucceed:(WebService *)service;

// サービス失敗
- (void)serviceDidFailed:(WebService *)service;

// サーバアクセス終了
- (void)serviceDidEnded:(WebService *)service;

// タイムアウトの場合
- (void)serviceDidFailedTimeOut:(WebService *)service;

@end