//
//  SSPlayViewController.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "SSPokerView.h"
#import "PurchaseManager.h"

@interface SSPlayViewController : SSViewController

// フリーモード
@property (nonatomic, getter = isFreeMode) BOOL freeMode;

// カード引き枚数
@property (nonatomic, getter = isSingleMode) BOOL singleMode;

// 山札戻し利用可能回数
@property (nonatomic) NSInteger usableYamafudas;

// ポーカービュー
@property (nonatomic, weak) IBOutlet SSPokerView *pokerView;

//　ゲーム一時停止
- (void)pause;

// ゲーム再開
- (void)resume;

// ゲーム終了（前画面へ遷移）
- (void)end;

// リトライ（新規にゲームスタート）
- (void)start;

// タイマー
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) NSTimeInterval duration;
- (void)handleUpdateTimer:(NSTimer *)timer;

@end

extern NSString *const SolitaireWillResumeGameNotification;
extern NSString *const SolitaireWillPauseGameNotification;
