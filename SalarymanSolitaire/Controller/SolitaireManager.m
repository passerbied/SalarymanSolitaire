//
//  SolitaireManager.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SolitaireManager.h"

// 初回起動フラグ
#define __USER_FIRST_TIME_KEY           @"UserFirstRun"

@implementation SolitaireManager
// 初期化
+ (instancetype)sharedManager;
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedManager = nil;
    dispatch_once(&pred, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

// 初回起動チェック
- (BOOL)isFirstTime;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:__USER_FIRST_TIME_KEY]) {
        return NO;
    }
    return YES;
}

// 初回起動設定
- (void)setFirstTimePlay;
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:__USER_FIRST_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 共有広告ビュー
- (ADBannerView *)sharedADBannerView;
{
    static ADBannerView *_sharedADBannerView = nil;
    if (!_sharedADBannerView) {
        _sharedADBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    }
    return _sharedADBannerView;
}

@end
