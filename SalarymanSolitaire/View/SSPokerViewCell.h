//
//  SSPokerViewCell.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-2.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSPoker.h"

typedef enum
{
    SSPokerAnimationModeDistribute,
    SSPokerAnimationModePlay,
    SSPokerAnimationModeDone
} SSPokerAnimationMode;

@interface SSPokerViewCell : UICollectionViewCell

// ポーカー情報
@property (nonatomic, strong) SSPoker *poker;

// アニメーションモード設定
- (void)setAnimationMode:(SSPokerAnimationMode)mode;

// 表示方向
- (void)setPokerFaceUp:(BOOL)faceUp;

@end
