//
//  StageCell.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-9.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "StageCell.h"

// ステージセルサイズ定義
#define __STAGE_CELL_SIZE_WIDTH         84.0f
#define __STAGE_CELL_SIZE_HEIGHT        116.0f

// タイトル
#define __STAGE_CELL_TITLE_HEIGHT       18.0f
#define __STAGE_CELL_TITLE_FORMAT       @"STAGE %d"

// 画像
#define __STAGE_CELL_PHOTO_HEIGHT       72.0f

// 名前
#define __STAGE_CELL_NAME_HEIGHT        15.0f

// ファンとサイズ
#define __STAGE_FONT_SIZE_TITLE         20.0f
#define __STAGE_FONT_SIZE_DEPARTMENT    16.0f
#define __STAGE_FONT_SIZE_NAME          20.0f

@interface StageCell ()
{
    // タイトル
    UILabel                             *_labelTitle;
    
    // 画像
    UIImageView                         *_photoView;
    
    // 所属部署
    UILabel                             *_labelDepartment;

    // 名前
    UILabel                             *_labelName;
}
@end

@implementation StageCell

// 初期化作成
- (id)initWithIndex:(NSInteger)index;
{
    self = [self initWithFrame:CGRectMake(0, 0, __STAGE_CELL_SIZE_WIDTH, __STAGE_CELL_SIZE_HEIGHT)];
    if (self) {
        _index = index;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat x = 0.0f;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    // タイトル作成
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 0.0f, width, __STAGE_CELL_TITLE_HEIGHT)];
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.textColor = [UIColor whiteColor];
        _labelTitle.font = [UIFont systemFontOfSize:__STAGE_FONT_SIZE_TITLE];
        [self addSubview:_labelTitle];
    }
    _labelTitle.text = [NSString stringWithFormat:__STAGE_CELL_TITLE_FORMAT, _index];
    
    // 画像作成
    if (!_photoView) {
        _photoView = [[UIImageView alloc] initWithFrame:CGRectMake(x, __STAGE_CELL_TITLE_HEIGHT, width, __STAGE_CELL_PHOTO_HEIGHT)];
        [self addSubview:_photoView];
    }
    _photoView.image = _photo;
    
    // 名前作成
    if (!_labelName) {
        CGFloat y = height - __STAGE_CELL_PHOTO_HEIGHT;
        _labelName = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, __STAGE_CELL_NAME_HEIGHT)];
        _labelName.textAlignment = NSTextAlignmentLeft;
        _labelName.textColor = [UIColor blackColor];
        _labelName.font = [UIFont systemFontOfSize:__STAGE_FONT_SIZE_NAME];
        [self addSubview:_labelName];
    }
    _labelName.text = _name;

    // 所属部署作成
    if (!_labelDepartment) {
        CGFloat y = __STAGE_CELL_TITLE_HEIGHT + __STAGE_CELL_PHOTO_HEIGHT;
        _labelDepartment = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height - y -__STAGE_CELL_NAME_HEIGHT)];
        _labelDepartment.textAlignment = NSTextAlignmentLeft;
        _labelDepartment.textColor = [UIColor blackColor];
        _labelDepartment.font = [UIFont systemFontOfSize:__STAGE_FONT_SIZE_DEPARTMENT];
        [self addSubview:_labelDepartment];
    }
    _labelDepartment.text = _department;
}
@end
