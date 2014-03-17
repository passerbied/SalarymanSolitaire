//
//  SSNotificationView.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-9.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSNotificationView.h"

@interface SSNotificationView ()
{
    // コンテンツビュー
    UIWebView                           *_webView;
}

@end

@implementation SSNotificationView


// お知らせ表示
- (void)loadNotificationWith:(NSString *)address;
{
    // ウェブビュー作成
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:[self clientFrame]];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    
    // お知らせ表示
    NSURL *url = [NSURL URLWithString:address];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
