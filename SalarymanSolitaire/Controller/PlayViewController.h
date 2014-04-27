//
//  PlayViewController.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "SSPokerView.h"
#import "PurchaseManager.h"

@interface PlayViewController : SSViewController

// フリーモード
@property (nonatomic, getter = isFreeMode) BOOL freeMode;

// カード引き枚数
@property (nonatomic, getter = isSingleMode) BOOL singleMode;

// 山札戻し利用可能回数
@property (nonatomic) NSInteger usableYamafudas;


// ポーカービュー
@property (nonatomic, weak) IBOutlet SSPokerView *pokerView;

@end
