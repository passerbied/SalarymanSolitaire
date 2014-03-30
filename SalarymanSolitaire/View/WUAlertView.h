//
//  WUAlertView.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-9.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WUAlertViewDelegate;
@interface WUAlertView : UIViewController

// 警告画面初期化
+ (instancetype)alertWithTitle:(NSString *)title;
+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message;


// 委譲対象
@property (nonatomic, strong) id<WUAlertViewDelegate> delegate;

// 警告画面表示中フラグ
@property (nonatomic, getter = isVisible) BOOL visible;

// タイトル
@property (nonatomic, strong) NSString *alertTitle;

// メッセージ
@property (nonatomic, strong) NSString *alertMessage;

// 背景イメージ
@property (nonatomic, strong) UIImage *backgroundImage;

// 閉じるボタン表示制御
- (void)setCloseButtonHidden:(BOOL)hidden;

// 背景タップ制御
- (void)setTapToDismissEnabled:(BOOL)enabled;

// 警告画面表示
- (void)show;

// アクセサリー追加
- (void)addAccessoryView:(UIView *)view;

// ボタン追加
- (void)addButton:(UIButton *)button;

@end

@protocol WUAlertViewDelegate <NSObject>
@optional
// ボタンタップ処理
- (void)alertView:(WUAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

