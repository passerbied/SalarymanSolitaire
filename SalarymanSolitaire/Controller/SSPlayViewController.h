//
//  SSPlayViewController.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "PurchaseManager.h"

@interface SSPlayViewController : SSViewController
{

}

/**************************************************/
// ポーカービュー
/**************************************************/

// ポーカービュー
@property (nonatomic, weak) IBOutlet UICollectionView *pokerView;

/**************************************************/
// ゲーム設定
/**************************************************/

// フリーモード
@property (nonatomic, getter = isFreeMode) BOOL freeMode;

// めくり枚数
@property (nonatomic) NSInteger numberOfPokers;

// 山札戻し回数
@property (nonatomic) NSInteger maximumYamafuda;

// ゲーム初期化
- (void)initGame;

// 山札戻し使用
- (void)useYamafuda;

// 山札戻し使用可否チェック
- (BOOL)isYamafudaEnabled;

/**************************************************/
// ゲーム制御
/**************************************************/

// リトライ（新規にゲームスタート）
- (void)start;

// ゲーム終了（前画面へ遷移）
- (void)end;

//　ゲーム一時停止
- (void)pause;

// ゲーム再開
- (void)resume;

// タイマー
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) NSTimeInterval duration;
- (void)handleUpdateTimer:(NSTimer *)timer;

// ゲーム完了処理
- (void)willCompletSolitaire;
@end

extern NSString *const SolitaireWillResumeGameNotification;
extern NSString *const SolitaireWillPauseGameNotification;
