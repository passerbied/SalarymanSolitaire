//
//  SolitaireManager.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@class SSStage;

@interface SolitaireManager : NSObject

// 初期化
+ (instancetype)sharedManager;

// 初回起動チェック
- (BOOL)isFirstTime;

// 初回起動設定
- (void)setFirstTimePlay;

// バナー広告
- (ADBannerView *)sharedBannerAD;

// インタースティシャル広告
- (ADInterstitialAd *)sharedInterstitialAD;

// ステージ設定情報取得
- (NSArray *)stageInfos;

// ステージ情報
@property (strong, nonatomic, readonly) SSStage *selectedStage;

// ステージ選択
- (void)selectStageWithID:(NSInteger)stageID;

// 最新のステージID
@property (nonatomic, readonly) NSInteger lastStageID;
@end
