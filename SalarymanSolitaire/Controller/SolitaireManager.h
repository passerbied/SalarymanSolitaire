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

/****************************************/
/* ユーザ情報                             */
/****************************************/

// 初回実行フラグ
@property (nonatomic, getter = isFirstRun) BOOL firstRun;

// 最大体力値
@property (nonatomic) NSInteger maxPower;

// 体力値
@property (nonatomic) NSInteger currentPower;

// 最新ステージ
@property (nonatomic) NSInteger lastStageID;

// クリア済み回数
@property (nonatomic) NSInteger clearTimes;

// 基礎体力＋
@property (nonatomic) NSInteger additionalPower;

// 栄養剤個数
@property (nonatomic) NSInteger nutrients;

// 山札戻し個数
@property (nonatomic) NSInteger yamafudas;

// ユーザ情報保存
- (void)synchronize;

/****************************************/
/* ステージ情報                           */
/****************************************/

// ステージ設定情報取得
- (NSArray *)stageInfos;

// ステージ選択
- (void)selectStageWithID:(NSInteger)stageID;

// ステージ情報
@property (strong, nonatomic, readonly) SSStage *currentStage;

/****************************************/
/* 広告展示情報                           */
/****************************************/

// バナー広告
- (ADBannerView *)sharedBannerAD;

// インタースティシャル広告
- (ADInterstitialAd *)sharedInterstitialAD;


@end
