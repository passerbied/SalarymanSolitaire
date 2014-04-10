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

+ (instancetype)pokerView;

//　ポーカーシャッフル
//- (void)shuffle:(BOOL)retry;

// ゲーム開始
- (void)start;

// リトライ
- (void)retry;

- (NSInteger)firstVisiblePokersInSection:(NSInteger)section;
@end
