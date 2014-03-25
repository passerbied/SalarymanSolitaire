//
//  SSStage.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-12.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SSStageStateLocked,
    SSStageStatePlaying,
    SSStageStateCleared
} SSStageState;

@interface SSStage : NSObject

// ステージID
@property (nonatomic) NSInteger stageID;

// 敵ID
@property (nonatomic) NSInteger enemyID;

// クリア回数
@property (nonatomic) NSInteger minClearTimes;
@property (nonatomic) NSInteger clearTimes;

// カード枚数
@property (nonatomic) NSInteger numberOfCards;

// 山札戻し回数
@property (nonatomic) NSInteger returnTimes;

// タイトル
@property (nonatomic, strong) NSString *title;

// 状態
@property (nonatomic) SSStageState stage;

@end
