//
//  HelpInfoViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "HelpInfoViewController.h"
#import "WUProgressView.h"
#import "GetSystemInfoService.h"

@interface HelpInfoViewController ()
{

}

// ヘルプ情報表示
- (void)loadHelpInfo;
@end

@implementation HelpInfoViewController

- (void)initView
{
    [super initView];
    
    // タイトル設定
    self.title = LocalizedString(@"使い方");
    
    // ヘルプ情報表示
    [self loadHelpInfo];
}

- (void)updateView
{
    [super updateView];
    
    // ナビゲートバー非表示
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

// ヘルプ情報表示
- (void)loadHelpInfo;
{
    NSURL *url = [[SolitaireManager sharedManager] helpURL];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    webView.delegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

// 広告表示可否
- (BOOL)shouldShowBannerAD;
{
    return NO;
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
    webView.delegate = nil;
}

// ヘルプ情報ロード失敗
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [WUProgressView dismiss];
    webView.delegate = nil;
}

@end
