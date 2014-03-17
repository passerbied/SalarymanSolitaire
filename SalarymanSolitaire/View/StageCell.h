//
//  StageCell.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-9.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StageCell : UICollectionViewCell

// 初期化作成
- (id)initWithIndex:(NSInteger)index;

// ステージ索引
@property (nonatomic) NSInteger index;

// 名前
@property (nonatomic, strong) NSString *name;

// 所属部署
@property (nonatomic, strong) NSString *department;

// 画像
@property (nonatomic, strong) UIImage *photo;

@end
