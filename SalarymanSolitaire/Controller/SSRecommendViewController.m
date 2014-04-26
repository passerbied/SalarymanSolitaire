//
//  SSRecommendViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSRecommendViewController.h"

@interface SSRecommendViewController ()

@end

@implementation SSRecommendViewController

- (void)initView
{
    [super initView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"おすすめ無料ゲーム";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(handleRefreshAD)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ナビゲートバー表示
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldShowBannerAD
{
    return NO;
}

- (void)handleRefreshAD
{
    NSLog(@"Refresh");
}

@end
