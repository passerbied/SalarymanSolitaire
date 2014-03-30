//
//  SSAlertView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSAlertView.h"
@implementation SSAlertView

// 警告画面表示
+ (instancetype)alert
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _alertView = [WUAlertView alertWithTitle:nil message:nil];
        _alertView.delegate = self;
    }
    return self;
}

- (void)show;
{
    
}


#pragma mark - ボタンタップ処理
// ボタンタップ処理
- (void)alertView:(WUAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
}
@end
