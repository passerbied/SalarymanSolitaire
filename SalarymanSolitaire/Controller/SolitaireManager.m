//
//  SolitaireManager.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SolitaireManager.h"
#import "SSStage.h"

// 初回起動フラグ
#define __USER_FIRST_TIME_KEY           @"UserFirstRun"

// ステージID
#define __USER_SELECTED_STAGEID_KEY     @"UserSelectedStageID"

// クリア回数
#define __USER_SELECTED_CLEARTIMES_KEY  @"UserSelectedStageClearTimes"

// 挑戦開始
#define __USER_SELECTED_STARTED_KEY     @"UserSelectedStageStarted"


@interface SolitaireManager () 

@end

@implementation SolitaireManager
{
    // ステージ設定情報
    NSMutableArray                      *_stageInfos;
    
    // 最新のステージ
    SSStage                             *_selectedStage;
    
    // 最新ステージID
    NSInteger                           _lastStageID;
}

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

// ステージ設定情報取得
- (NSArray *)stageInfos;
{
    if (!_stageInfos) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Stage" ofType:@"plist"];
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
        NSArray *array = [dict objectForKey:@"StageList"];
        _stageInfos = [NSMutableArray arrayWithCapacity:[array count]];
        for (NSDictionary *dic in array) {
            SSStage *stage = [[SSStage alloc] init];
            stage.stageID = [[dic objectForKey:@"StageID"] integerValue];
            stage.enemyID = [[dic objectForKey:@"EnemyID"] integerValue];
            stage.minClearTimes = [[dic objectForKey:@"MinClearTimes"] integerValue];
            stage.numberOfCards = [[dic objectForKey:@"NumberOfCards"] integerValue];
            stage.returnTimes = [[dic objectForKey:@"ReturnTimes"] integerValue];
            stage.title = [dic objectForKey:@"StageName"];
            [_stageInfos addObject:stage];
        }
    }
    return _stageInfos;
}

// 最新のステージID
- (NSInteger)lastStageID
{
    if (!_lastStageID) {
        
        NSArray *array = [self stageInfos];
        
        // 最新のステージ取得
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _lastStageID = [userDefaults integerForKey:__USER_SELECTED_STAGEID_KEY];
        if (_lastStageID) {
            _selectedStage = (SSStage *)[array objectAtIndex:_lastStageID];
            _selectedStage.clearTimes = [userDefaults integerForKey:__USER_SELECTED_CLEARTIMES_KEY];
            if ([userDefaults boolForKey:__USER_SELECTED_STARTED_KEY]) {
                _selectedStage.stage = SSStageStatePlaying;
            }
        } else {
            _lastStageID = 1;
            _selectedStage = (SSStage *)[array objectAtIndex:0];
        }
    }
    return _lastStageID;
}

// ステージ選択
- (void)selectStageWithID:(NSInteger)stageID;
{
    if (_lastStageID != stageID) {
        _lastStageID = stageID;
        _selectedStage = [_stageInfos objectAtIndex:stageID - 1];
    }
}

// 初回起動チェック
- (BOOL)isFirstTime;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:__USER_FIRST_TIME_KEY]) {
        return NO;
    }
    return YES;
}

- (void)setSelectedStage:(SSStage *)selectedStage
{
    _selectedStage = selectedStage;
}

// 初回起動設定
- (void)setFirstTimePlay;
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:__USER_FIRST_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// バナー広告
- (ADBannerView *)sharedBannerAD;
{
    static ADBannerView *_sharedBannerAD = nil;
    if (!_sharedBannerAD) {
        _sharedBannerAD = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        _sharedBannerAD.alpha = 0.0f;
    }
    return _sharedBannerAD;
}

// インタースティシャル広告
- (ADInterstitialAd *)sharedInterstitialAD;
{
    static ADInterstitialAd *_sharedInterstitialAD = nil;
    if (!_sharedInterstitialAD) {
        _sharedInterstitialAD = [ADInterstitialAd new];
    }
    return _sharedInterstitialAD;
}


@end
