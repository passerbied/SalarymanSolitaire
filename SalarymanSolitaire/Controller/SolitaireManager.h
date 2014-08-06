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

@protocol SolitaireManagerDelegate;

@interface SolitaireManager : NSObject

// 初期化
+ (instancetype)sharedManager;

/****************************************/
/* ユーザ情報                             */
/****************************************/

// 初回実行フラグ54123456
@property (nonatomic, getter = isFirstRun) BOOL firstRun;

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

// クリア画面表示回数
@property (nonatomic) NSInteger clearPopupTimes;

// ステージ選択回数
@property (nonatomic) NSInteger stageSelectedTimes;

@property (nonatomic, assign) NSObject<SolitaireManagerDelegate> *delegate;

// 体力
- (NSInteger)currentPower;

// 最大体力値
- (NSInteger)maxPower;

// 山札戻し使用
- (void)handleRestartYamafuda;

// 栄養剤使用
- (void)handleUseNutrient;

// 体力ゲージ使用
- (void)handleUsePower;

// ステージクリアチェック
- (BOOL)canClearCurrentStage;

// ユーザ情報保存
- (void)synchronize;

/****************************************/
/* アイテム購入                           */
/****************************************/

// 栄養剤購入
- (void)buyNutrientWithQuantity:(NSInteger)quantity;

// 山札戻し購入
- (void)buyYamafudaWithQuantity:(NSInteger)quantity;

// 体力ゲージ購入
- (void)buyPowerWithQuantity:(NSInteger)quantity;

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

@protocol SolitaireManagerDelegate <NSObject>

- (void)reloadNutrient;
- (void)reloadYamafuda;
- (void)reloadPower;

@end
