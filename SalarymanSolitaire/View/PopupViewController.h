//
//  PopupViewController.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupViewController : UIViewController

// 初期化
- (id)initPopupViewWithNibName:(NSString *)nibName;

// ポップパップ表示
- (void)popupInViewController:(UIViewController *)controller;

// ブラーエフェクト
@property (nonatomic, getter = isBlurEnabled) BOOL blurEnabled;

@end
