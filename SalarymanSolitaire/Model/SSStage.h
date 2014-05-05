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

// 最低クリア回数
@property (nonatomic) NSInteger minimalClearTimes;

// クリア済み回数
@property (nonatomic) NSInteger currentClearTimes;

// めくり枚数
@property (nonatomic) NSInteger numberOfPokers;

// 山札戻し回数
@property (nonatomic) NSInteger maximumYamafuda;

// タイトル
@property (nonatomic, strong) NSString *title;


// 状態
@property (nonatomic) SSStageState stage;

// クリア条件
- (NSString *)condition;

@end
