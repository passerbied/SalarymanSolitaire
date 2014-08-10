//
//  SSPlayViewController.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "PurchaseManager.h"
#import "SSYamafudaButton.h"
#import "SSClearPopupView.h"

@interface SSPlayViewController : SSViewController
{

}

/**************************************************/
// ポーカービュー
/**************************************************/

// ポーカービュー
@property (nonatomic, weak) IBOutlet UICollectionView *pokerView;

@property (nonatomic, strong) UIImageView *pokerImageView;
@property (nonatomic, strong) UIImageView *finishedPokerPane;

/**************************************************/
// ゲーム設定
/**************************************************/

// フリーモード
@property (nonatomic, getter = isFreeMode) BOOL freeMode;

// めくり枚数
@property (nonatomic) NSInteger numberOfPokers;

// 山札戻し回数
@property (nonatomic) NSInteger maximumYamafuda;

// 山札戻しボタン
@property (nonatomic, strong) SSYamafudaButton *yamafudaButton;

// 山札戻し処理
- (void)handleRestartYamafuda;

// ゲーム初期化
- (void)initGame;


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

// 開始ポーカーのアニメ完成
@property (nonatomic,assign) BOOL animeCompleted;

// タイマー
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) NSTimeInterval duration;
- (void)handleUpdateTimer:(NSTimer *)timer;

// ゲーム完了処理
- (void)willCompletSolitaire;
@end

extern NSString *const SolitaireWillResumeGameNotification;
extern NSString *const SolitaireWillPauseGameNotification;
