//
//  WebService.m
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "WebService.h"
#import "WebResponse.h"
#import "XmlParser.h"
#import "Reachability.h"

static NSString *_WebServiceHostAddress;
static NSTimeInterval _WebServiceTimeout;
static NSString *_AccessKey = @"NULL";

#define kDefaultHTTPMethod              @"POST"

@implementation WebService

+ (id)serviceWithDelegate:(id<WebServiceDelegate>)delegate
{
    return [[self alloc] initWebServiceWithDelegate:delegate];
}

+ (void)setHostAddress:(NSString *)address
{
    if (_WebServiceHostAddress == address) {
        return;
    }
    
    _WebServiceHostAddress = address;
}

+ (void)setTimeout:(NSTimeInterval)timeout
{
    _WebServiceTimeout = timeout;
}

+ (void)setAccessKey:(NSString *)accessKey
{
    _AccessKey = accessKey;
}

// 初期化処理
- (id)initWebServiceWithDelegate:(id<WebServiceDelegate>)delegate
{
    self = [self init];
    if (self) {
        // サービス開始
        self.willStartSelector = @selector(serviceWillStart:);
        
        // サービス成功
        self.didSucceedSelector = @selector(serviceDidSucceed:);
        
        // サービス失敗
        self.didFailedSelector = @selector(serviceDidFailed:);
        
        // サービス完了
        self.didEndedSelector = @selector(serviceDidEnded:);
    
        // ネットワーク接続不可
        self.unreachableSelector = @selector(serviceUnreachable:);
        
        // 委譲対象設定
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Webサービス通信処理
// ユーザ認証
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge && [challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential = [NSURLCredential credentialWithUser:_userName
                                                   password:_password
                                                persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
    }
}

// 通信開始
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // レスポンステータスリセット
    [_responseData setLength:0];
    
    // エンコーディング設定
    if (!_encoding) {
        NSString *encodingName = [response textEncodingName];
        if (encodingName) {
            _encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef) encodingName));
        } else {
            _encoding = NSUTF8StringEncoding;
        }
    }
}

// レスポンステータス退避
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

// Webサービス正常処理
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // レスポンステータス解析
    _succeed = [self autoParseResponse];
    
    // サービス実行終了
    [self serviceDidFinished:_succeed];
}

// Webサービス異常処理
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(serviceDidFailedTimeOut:)]) {
        [_delegate serviceDidFailedTimeOut:self];
    }
}

#pragma mark - レスポンステータス解析
- (BOOL)autoParseResponse
{
    // レスポンス取得
    if (!_responseData) {
		return NO;
	}
	
	NSString *responseString = [[NSString alloc] initWithBytes:[_responseData bytes]
                                                        length:[_responseData length]
                                                      encoding:_encoding];
    if (responseString == nil || [responseString length] == 0) {
        return NO;
    }
    
    XmlParser *parser_ = [[XmlParser alloc] init];
    if (_testMode) {
        [parser_ setTestMode:_testMode];
    }
    
    _response = [NSMutableDictionary dictionary];
    
    // レスポンステータス解析
    for (NSString *identifier in [_responseIdentifiers allObjects]) {
        NSArray *array = [parser_ fromXML:responseString withTagName:identifier];
        if (array) {
            [_response setObject:array forKey:identifier];
        }
    }

    return YES;
}

// レスポンステータス取得
- (NSArray*)responseDataWithIdentifier:(NSString*)idertifier
{
    return [_response objectForKey:idertifier];
}

#pragma mark - Webサービス実行
// Webサービス実行開始
- (BOOL)start
{
    // URL編集
    if (!_address || [_address length] == 0) {
        __LOG(@"アドレス異常");
    }
    NSString *encodingAddress = [_address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (_testMode) {
        __LOG(@"[URL]%@", encodingAddress);
    }
    NSURL *url = [NSURL URLWithString:encodingAddress];
    
    // リクエスト作成
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    if (_request) {
        // post data
        [request setHTTPBody:[_request requestData]];
    }
    if (_WebServiceTimeout) {
        [request setTimeoutInterval:_WebServiceTimeout];
    }
    [request setHTTPMethod:kDefaultHTTPMethod];
    
    // サービス実行
    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                  delegate:self
                                          startImmediately:NO];
    if (_connection) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

        // サーバアクセスチェック
        if ([WebService isReachable]) {
            // アクセスできる場合
            self.reachable = YES;
            // Webサービス実行開始
            if ([_delegate respondsToSelector:_willStartSelector]) {
                [_delegate performSelector:_willStartSelector withObject:self];
            }

            _responseData = [[NSMutableData alloc] init];
            [_connection start];
            
            return YES;
        } else {
            // アクセスできない場合
            if ([_delegate respondsToSelector:_unreachableSelector]) {
                [_delegate performSelector:_unreachableSelector withObject:self];
            }
        }
#pragma clang diagnostic pop
    }
    
    return NO;
}

// キャンセル
- (void)cancel
{
    _delegate = nil;
    [_connection cancel];
    [self serviceDidFailed];
}

// Webサービス実行失敗
- (void)serviceDidFailed
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    if ([_delegate respondsToSelector:_didFailedSelector]) {
        [_delegate performSelector:_didFailedSelector withObject:self];
    }
#pragma clang diagnostic pop
}

// Webサービス実行終了
- (void)serviceDidFinished:(BOOL)succeed
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    if (succeed) {
        // サービス実行成功の場合
        if ([_delegate respondsToSelector:_didSucceedSelector]) {
            [_delegate performSelector:_didSucceedSelector withObject:self];
        }
    } else {
        // サービス実行異常の場合
        if ([_delegate respondsToSelector:_didFailedSelector]) {
            [_delegate performSelector:_didFailedSelector withObject:self];
        }
    }
    
    // サービス実行完了
    if ([_delegate respondsToSelector:_didEndedSelector]) {
        [_delegate performSelector:_didEndedSelector withObject:self];
    }
#pragma clang diagnostic pop
}

// ネットワーク接続チェック
+ (BOOL)isReachable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return [reachability isReachable];
}

@end
