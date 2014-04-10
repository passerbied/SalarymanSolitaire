//
//  PlayViewController.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "SSPokerView.h"

@interface PlayViewController : SSViewController

// ゲームモード
@property (nonatomic, getter = isFreeMode) BOOL freeMode;

// ポーカー位置
- (CGRect)rectForPoker;

@end
