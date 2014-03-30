//
//  SSItemAlertView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-27.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSItemAlertView.h"
#import "WUAlertView.h"

#import "UIButton+UIImage.h"

enum
{
    SSItemAlertButtonIndexCancel = SSAlertViewFirstButton,
    SSItemAlertButtonIndexUse,
    SSItemAlertButtonIndexBuy
};

@interface SSItemAlertView ()

// 残り個数
@property (nonatomic, strong) UILabel *numberLabel;

// 単位
@property (nonatomic, strong) UILabel *unitLabel;
@end

@implementation SSItemAlertView

- (void)show
{
    // レイアウト設定
    if (_datasource == SSItemAlertDatasourcePutrient) {
        // 栄養剤ボタン押下した場合
        [self initPutrientAlertView];
    } else {
        // 山札戻しボタン押下した場合
        [self initTalonAlertView];
    }
    
    // 残り個数設定
    CGFloat x = 170.0f;
    CGFloat y = 96.0f;
    CGFloat offset = 8.0f;
    NSString *string = nil;
    UIFont *font = [UIFont boldSystemFontOfSize:24.0f];
    NSDictionary *attributes = @{NSFontAttributeName:font};

    // 残り個数設定
    string = [NSString stringWithFormat:@"%d", _numberOfItems];
    CGSize size = [string sizeWithAttributes:attributes];
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, size.width, size.height)];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textColor = [UIColor redColor];
        _numberLabel.font = font;
        [self.alertView addAccessoryView:_numberLabel];
    }
    [_numberLabel setText:[NSString stringWithFormat:@"%d", _numberOfItems]];
    
    // 単位設定
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + size.width + offset, y, 40, size.height)];
        _unitLabel.backgroundColor = [UIColor clearColor];
        _unitLabel.textColor = [UIColor blackColor];
        _unitLabel.font = font;
        [self.alertView addAccessoryView:_unitLabel];
    }
    [_unitLabel setText:@"個"];
    
    // 警告画面表示
    [self.alertView show];
}

- (void)initPutrientAlertView
{
    self.alertView.alertTitle = @"体力が不足しています。";
    self.alertView.alertMessage = @"栄養剤を購入しますか？";
    self.alertView.backgroundImage = [UIImage imageNamed:@"popup_base.png"];
    
    [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_cancel"]];
    if (_numberOfItems) {
        [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_use"]];
    } else {
        [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_buy"]];
    }
}

- (void)initTalonAlertView
{
    self.alertView.alertTitle = @"山札が終了しました。";
    self.alertView.alertMessage = @"山札戻しを購入しますか？";
    self.alertView.backgroundImage = [UIImage imageNamed:@"popup_base.png"];
    
    [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_cancel"]];
    if (_numberOfItems) {
        [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_use"]];
    } else {
        [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_buy"]];
    }
}

#pragma mark - ボタンタップ処理
// ボタンタップ処理
- (void)alertView:(WUAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == SSItemAlertButtonIndexUse) {
        // 商品利用
        NSLog(@"商品利用");
    } else if (buttonIndex == SSItemAlertButtonIndexBuy) {
        // 商品購入
        NSLog(@"商品購入");
    }
}

@end
