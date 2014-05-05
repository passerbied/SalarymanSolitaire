//
//  SSModeAlertView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSModeAlertView.h"

@implementation SSModeAlertView
- (void)show
{
    self.alertView.alertTitle = @"ポーカーの引き枚数を\n選んで下さい。";
    [self.alertView setCloseButtonHidden:NO];
    self.alertView.backgroundImage = [UIImage imageNamed:@"popup_alert.png"];
    
    [self.alertView addButton:[UIButton buttonWithImage:@"free_btn_one"]];
    [self.alertView addButton:[UIButton buttonWithImage:@"free_btn_three"]];
    [self.alertView show];
}

// ボタンタップ処理
- (void)alertView:(WUAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSLog(@"Button [%d]",buttonIndex);
    if (buttonIndex == SSAlertViewFirstButton) {
        // カード引き枚数＝１枚
        [self.delegate toogleToSingleMode:YES];
    } else {
        // カード引き枚数＝３枚
        [self.delegate toogleToSingleMode:NO];
    }
}
@end
