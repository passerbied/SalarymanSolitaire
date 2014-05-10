//
//  SSGiveupAlertView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSGiveupAlertView.h"
@implementation SSGiveupAlertView

- (void)show
{
    self.alertView.alertTitle = @"ギブアップしますか？";
    [self.alertView setCloseButtonHidden:NO];
    self.alertView.backgroundImage = [UIImage imageNamed:@"popup_alert.png"];
    
    [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_end"]];
    [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_retry"]];
    [self.alertView show];
}

// ボタンタップ処理
- (void)alertView:(WUAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        [self.delegate closeAlertView];
    } else if (buttonIndex == SSAlertViewFirstButton) {
        // ゲーム終了
        [self.delegate gameWillExit];
    } else {
        // ゲームリトライ
        [self.delegate gameWillRetry];
    }
}

@end
