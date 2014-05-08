//
//  SSNutrientButton.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-16.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSNutrientButton.h"

@interface SSNutrientButton ()
{
    // 栄養剤使用回数
    UILabel                             *_numberLabel;
}

@end

@implementation SSNutrientButton

- (id)init
{
    self = [super init];
    if (self) {
        // 画面初期化
        [self initView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // 画面初期化
    [self initView];
}

// 画面初期化
- (void)initView
{
    if (!_numberLabel) {
        CGFloat width = 20.0f;
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, -6, width, width)];
        _numberLabel.backgroundColor = UIColorFromRGB(0xE7C929);
        _numberLabel.font = SSGothicProFont(15.0f);
        _numberLabel.textColor = SSColorWhite;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.layer.cornerRadius = width/2.0f;
        _numberLabel.layer.masksToBounds = YES;
        [self addSubview:_numberLabel];
    }
}

- (void)setNumberOfNutrients:(NSInteger)numberOfNutrients
{
    _numberOfNutrients = numberOfNutrients;
    if (numberOfNutrients) {
        _numberLabel.text = [NSString stringWithFormat:@"%ld", (long)_numberOfNutrients];
        _numberLabel.hidden = NO;
    } else {
        _numberLabel.hidden = YES;
    }
}

@end
