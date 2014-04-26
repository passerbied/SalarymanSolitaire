//
//  SSRetryAlertView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSRetryAlertView.h"

@implementation SSRetryAlertView
- (void)show
{
    self.alertView.alertTitle = @"最初からやり直しますか？";
    self.alertView.backgroundImage = [UIImage imageNamed:@"popup_alert.png"];
    
    [self.alertView addButton:[UIButton buttonWithImage:@"free_btn_yes"]];
    [self.alertView addButton:[UIButton buttonWithImage:@"free_btn_no"]];
    [self.alertView show];
}

// ボタンタップ処理
- (void)alertView:(WUAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == SSAlertViewFirstButton) {
        // 新規ゲームにスタートさせる
        [self.delegate gameWillRetry];
    }
}
@end
