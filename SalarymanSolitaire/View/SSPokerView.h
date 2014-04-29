//
//  SSPokerView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-31.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSPokerViewCell.h"

@interface SSPokerView : UICollectionView

// 初期化
+ (instancetype)pokerView;

// 山札戻し枚数
@property (nonatomic) NSInteger yamafudaMax;

// カード引き枚数
@property (nonatomic, getter = isSingleMode) BOOL singleMode;

// フリーモード
- (void)setFreeMode:(BOOL)freeMode;

// 山札戻し利用可能回数
- (void)setUsableYamafudas:(NSInteger)usableYamafudas;

// ゲーム開始
- (void)start;

- (NSInteger)firstVisiblePokersInSection:(NSInteger)section;
@end
