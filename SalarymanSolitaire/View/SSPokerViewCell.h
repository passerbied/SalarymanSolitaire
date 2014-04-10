//
//  SSPokerViewCell.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-2.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSPoker.h"

@interface SSPokerViewCell : UICollectionViewCell

// ポーカー情報
@property (nonatomic, strong) SSPoker *poker;

// 表示方向
- (void)setPokerFaceUp:(BOOL)faceUp;

@end
