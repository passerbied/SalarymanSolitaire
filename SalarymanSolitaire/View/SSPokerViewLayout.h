//
//  SSPokerViewLayout.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-6.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSPoker.h"

@interface SSPokerViewLayout : UICollectionViewLayout

// ポーカーサイズ
@property (nonatomic) CGSize pokerSize;

// 山札戻し枚数
@property (nonatomic) NSInteger yamafudaMax;

// 山札戻し位置
+ (CGRect)rectForYamafuda;

@end