//
//  SSViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "SSAppDelegate.h"

@interface SSViewController ()<ADBannerViewDelegate, ADInterstitialAdDelegate>
{
}

// インタースティシャル広告
@property (nonatomic, strong) ADInterstitialAd *interstitialAD;
@end

@implementation SSViewController

// 初期化方法
+ (instancetype)controller;
{
    return [[self alloc] initWithNibName:nil bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 画面初期設定
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // バナー広告取得
    ADBannerView *bannerView = [[SolitaireManager sharedManager] sharedBannerAD];
    
    // 広告表示可否チェック
    if ([self shouldShowBannerAD]) {
        CGFloat y = self.view.bounds.size.height - bannerView.bounds.size.height;
        CGRect rect = CGRectMake(0.0f, y, bannerView.bounds.size.width, bannerView.bounds.size.height);
        bannerView.frame = rect;
        bannerView.delegate = self;
        [self.view addSubview:bannerView];
    } else {
        bannerView.delegate = nil;
        [bannerView removeFromSuperview];
    }
    
    // ナビゲートバー表示
    self.navigationController.navigationBarHidden = YES;
    
    // 画面表示更新
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ステータスバー非表示
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// 画面初期設定
- (void)initView;
{

}

// 画面表示更新
- (void)updateView;
{

}

#pragma mark - バナー広告
// 広告表示可否
- (BOOL)shouldShowBannerAD;
{
    return YES;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd Load");
    [UIView animateWithDuration:0.2f animations:^{
        banner.alpha = 1.0f;
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAd Failed");
    [UIView animateWithDuration:0.2f animations:^{
        banner.alpha = 0.0f;
    }];
}


#pragma mark - インタースティシャル広告

// インタースティシャル広告表示
- (void)presentInterstitialAD;
{
    self.interstitialAD = [[SolitaireManager sharedManager] sharedInterstitialAD];
    self.interstitialAD.delegate = self;
    NSLog(@"interstitialAD");
}

-(void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    [interstitialAd presentInView:self.view];
    NSLog(@"广告加载成功");
}

-(void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"广告卸载");
}

-(void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    NSLog(@"广告加载失败");
}

-(BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"可以执行一个广告动作");
    return YES;
}

-(void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"广告关闭, 用户关闭模态窗口时回调");
}
@end
