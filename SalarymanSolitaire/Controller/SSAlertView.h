//
//  SSAlertView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUAlertView.h"

@interface SSAlertView : NSObject<WUAlertViewDelegate>

// 警告画面初期化
+ (instancetype)alert;

// 警告画面を表示する
- (void)show;

// 警告画面
@property (nonatomic, strong) WUAlertView *alertView;
@end

enum { SSAlertViewFirstButton = 1 };
