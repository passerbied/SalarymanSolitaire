//
//  SSViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "SSAppDelegate.h"

@interface SSViewController ()

@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 画面初期設定
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 共有広告ビュー取得
    ADBannerView *bannerView = [[SolitaireManager sharedManager] sharedADBannerView];
    
    // 広告表示可否チェック
    if ([self shouldShowADBanner]) {
        bannerView.delegate = self;
        [self.view addSubview:bannerView];
    } else {
        bannerView.delegate = nil;
        [bannerView removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 画面初期設定
- (void)setup;
{
    
}

// ステータスバー非表示
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// 広告表示可否
- (BOOL)shouldShowADBanner;
{
    return NO;
}
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}
@end
