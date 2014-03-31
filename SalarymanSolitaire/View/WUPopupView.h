//
//  WUPopupView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-30.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WUPopupView : UIViewController

// 表示位置
@property (nonatomic) CGFloat top;

// ポップアップ
- (void)show;

// 閉じる
- (void)dismiss;
@end
