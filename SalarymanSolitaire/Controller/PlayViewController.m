//
//  PlayViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "PlayViewController.h"
#import "SSPhysicalView.h"
#import "SSNutrientButton.h"

@interface PlayViewController ()

// 体力ビュー
@property (nonatomic, weak) IBOutlet SSPhysicalView *physicalView;

// 敵ビュー
@property (nonatomic, weak) IBOutlet UIImageView *enemyView;

// 栄養剤ボタン
@property (nonatomic, weak) IBOutlet SSNutrientButton *btnNutrient;

// ギブアップ
- (IBAction)giveupAction:(id)sender;

// 栄養剤使用
- (IBAction)willUseNutrientAction:(id)sender;

// ショップ
- (IBAction)presentShopAction:(id)sender;

@end

@implementation PlayViewController

- (void)initView
{
    [super initView];
}

#pragma mark - 画面操作
// ギブアップ
- (IBAction)giveupAction:(id)sender;
{
    
}

// 栄養剤使用
- (IBAction)willUseNutrientAction:(id)sender;
{
    
}

// ショップ
- (IBAction)presentShopAction:(id)sender;
{
    
}
@end
