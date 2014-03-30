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
    self.alertView.alertTitle = @"カードの引き枚数を\n選んで下さい。";
    [self.alertView setCloseButtonHidden:NO];
    self.alertView.backgroundImage = [UIImage imageNamed:@"popup_base.png"];
    
    [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_card1"]];
    [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_card3"]];
    [self.alertView show];
}
@end
