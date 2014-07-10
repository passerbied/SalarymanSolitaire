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
    SSItemAlertButtonIndexUse = SSAlertViewFirstButton,
    SSItemAlertButtonIndexBuy
};

@interface SSItemAlertView ()
{
    CGFloat                             _iconPosY;
}

// アイコン
@property (nonatomic, strong) UIImageView *iconView;

// X
@property (nonatomic, strong) UILabel *xLabel;

// 残り個数
@property (nonatomic, strong) UILabel *numberLabel;

// 単位
@property (nonatomic, strong) UILabel *unitLabel;
@end

@implementation SSItemAlertView

- (void)show
{
    _iconPosY = 100.0f;
    
    // レイアウト設定
    if (_datasource == SSItemAlertDatasourceNutrient) {
        // 栄養剤ボタン押下した場合
        [self initPutrientAlertView];
    } else {
        // 山札戻しボタン押下した場合
        [self initTalonAlertView];
    }
    
    // 残り個数設定
    CGFloat x = 140.0f;
    CGFloat y;
    CGFloat offset = 8.0f;
    CGSize size;
    NSString *string = nil;
    UIFont *font = SSGothicProFont(17);
    NSDictionary *attributes = @{NSFontAttributeName:font};
    
    // X
    if (!_xLabel) {
        string = @"X";
        size = [string sizeWithAttributes:attributes];
        y = _iconPosY - size.height/2.0f;
        _xLabel = [self customLabelWitiFrame:CGRectMake(x, y, size.width, size.height)];
        _xLabel.font = font;
        _xLabel.textColor = SSColorBlack;
        [self.alertView addAccessoryView:_xLabel];
        x = x + size.width + offset;
    }
    [_xLabel setText:string];

    // 残り個数設定
    string = [NSString stringWithFormat:@"%d", (int)_numberOfItems];
    if (!_numberLabel) {
        size = [string sizeWithAttributes:attributes];
        y = _iconPosY - size.height/2.0f;
        _numberLabel = [self customLabelWitiFrame:CGRectMake(x, y, size.width, size.height)];
        _numberLabel.font = font;
        _numberLabel.textColor = SSColorRed;
        [self.alertView addAccessoryView:_numberLabel];
        x = x + size.width + offset;
    }
    [_numberLabel setText:string];
    
    // 単位設定
    string = @"個";
    if (!_unitLabel) {
        size = [string sizeWithAttributes:attributes];
        y = _iconPosY - size.height/2.0f;
        _unitLabel = [self customLabelWitiFrame:CGRectMake(x, y, size.width, size.height)];
        _unitLabel.font = font;
        _unitLabel.textColor = SSColorBlack;
        [self.alertView addAccessoryView:_unitLabel];
    }
    [_unitLabel setText:string];
    
    // 警告画面表示
    [self.alertView show];
}

- (UILabel *)customLabelWitiFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.alertView addAccessoryView:_iconView];
    }
    return _iconView;
}

- (void)initPutrientAlertView
{
    self.alertView.alertTitle = @"体力が不足しています。";
    
    UIButton *cancelButton = [UIButton buttonWithImage:@"popup_btn_cancel"];
    [self.alertView addButton:cancelButton];
    
    UIImage *icon = [UIImage imageNamed:@"popup_icon_drink"];
    self.iconView.image = icon;
    CGFloat x = cancelButton.frame.origin.x + cancelButton.frame.size.width - icon.size.width;
    CGFloat y = _iconPosY - icon.size.height/2.0f;
    CGRect rect = CGRectMake(x, y, icon.size.width, icon.size.height);
    self.iconView.frame = rect;
    
    if (_numberOfItems) {
        // 栄養剤を持っている場合
        self.alertView.alertMessage = @"栄養剤を使用しますか？";
        [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_use"]];
    } else {
        // 上記以外の場合
        self.alertView.alertMessage = @"栄養剤を購入しますか？";
        [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_buy"]];
    }
    self.alertView.backgroundImage = [UIImage imageNamed:@"popup_alert.png"];
}

- (void)initTalonAlertView
{
    self.alertView.alertTitle = @"山札が終了しました。";
    UIButton *cancelButton = [UIButton buttonWithImage:@"popup_btn_cancel"];
    [self.alertView addButton:cancelButton];
    
    UIImage *icon = [UIImage imageNamed:@"popup_icon_yamafuda"];
    self.iconView.image = icon;
    CGFloat x = cancelButton.frame.origin.x + cancelButton.frame.size.width - icon.size.width;
    CGFloat y = _iconPosY - icon.size.height/2.0f;
    CGRect rect = CGRectMake(x, y, icon.size.width, icon.size.height);
    self.iconView.frame = rect;

    if (_numberOfItems) {
        // 栄養剤を持っている場合
        self.alertView.alertMessage = @"山札戻しを使用しますか？";
        [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_use"]];
    } else {
        // 上記以外の場合
        self.alertView.alertMessage = @"山札戻しを購入しますか？";
        [self.alertView addButton:[UIButton buttonWithImage:@"popup_btn_buy"]];
    }
    self.alertView.backgroundImage = [UIImage imageNamed:@"popup_alert.png"];
}

#pragma mark - ボタンタップ処理
// ボタンタップ処理
- (void)alertView:(WUAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == SSItemAlertButtonIndexUse) {
        // 商品利用
        if (self.datasource == SSItemAlertDatasourceNutrient) {
            // 栄養剤使用
            [self.delegate willUseDrink];
        } else {
            // 山札戻し使用
            [self.delegate willUseYamafuda];
        }
        DebugLog(@"商品利用");
    } else if (buttonIndex == SSItemAlertButtonIndexBuy) {
        // 商品購入
        if (self.datasource == SSItemAlertDatasourceNutrient) {
            // 栄養剤購入
            [self.delegate willBuyDrink];
        } else {
            // 山札戻し購入
            [self.delegate willBuyYamafuda];
        }
        DebugLog(@"商品購入");
    }
}

@end
