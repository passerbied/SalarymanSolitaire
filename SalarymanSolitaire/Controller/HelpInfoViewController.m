//
//  HelpInfoViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "HelpInfoViewController.h"
#import "WUProgressView.h"

// ヘルプ情報を示すWebサイトURL定義
#define __HELP_INFO_URL                 @"http://www.yahoo.co.jp"

@interface HelpInfoViewController ()

// ヘルプ情報表示
- (void)loadHelpInfo;
@end

@implementation HelpInfoViewController

- (void)setup
{
    [super setup];
    
    // タイトル設定
    self.title = @"使い方";
    
    // ヘルプ情報表示
    [self loadHelpInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ナビゲートバー非表示
    self.navigationController.navigationBarHidden = NO;
}

// ヘルプ情報表示
- (void)loadHelpInfo;
{
    NSURL *url = [NSURL URLWithString:__HELP_INFO_URL];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    webView.delegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - UIWebViewDelegate

// ヘルプ情報ロード開始
- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    [WUProgressView showWithStatus:@"読み込み中..."];
}

// ヘルプ情報ロード完了
- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [WUProgressView dismiss];
}

// ヘルプ情報ロード失敗
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    
}

@end
