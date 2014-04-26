//
//  SSAlertView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUAlertView.h"
enum { SSAlertViewFirstButton = 1 };
@protocol SSAlertViewDelegate;
@interface SSAlertView : NSObject<WUAlertViewDelegate>

// 警告画面初期化
+ (instancetype)alertWithDelegate:(id<SSAlertViewDelegate>)delegate;

// 委託対象
@property (nonatomic, weak) id<SSAlertViewDelegate> delegate;

// 警告画面を表示する
- (void)show;

// 警告画面を非表示する
- (void)dismiss;

// 警告画面
@property (nonatomic, strong) WUAlertView *alertView;
@end

@protocol SSAlertViewDelegate <NSObject>

@optional
// ゲーム終了
- (void)gameWillExit;

// 商品購入
- (void)itemWillBuy;

// ギブアップ
- (void)gameWillGiveup;

// リトライ
- (void)gameWillRetry;

// モード選択
- (void)toogleToSingleMode:(BOOL)singleMode;
@end