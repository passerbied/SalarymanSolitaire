//
//  NotificationView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-22.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "NotificationView.h"
#import "GetSystemInfoService.h"

@interface NotificationView ()

@end

@implementation NotificationView
{
    // コンテンツビュー
    UIWebView                           *_webView;
    NSURL                               *_URL;
}

// お知らせ表示
- (id)initWithURL:(NSURL *)URL;
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _URL = URL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ウェブビュー作成
    _webView = [[UIWebView alloc] initWithFrame:[self popupContentRect]];
    _webView.delegate = self;
    [self.popView addSubview:_webView];
    
    // お知らせ表示
    [_webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [[SolitaireManager sharedManager] didPresentNotification];
    [self.view bringSubviewToFront:_webView];
}


@end
