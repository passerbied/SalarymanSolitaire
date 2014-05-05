//
//  SSChallengeController.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPlayViewController.h"
#import "SSStage.h"

@interface SSChallengeController : SSPlayViewController

// ステージID
@property (nonatomic) NSInteger stageID;

// クリア回数
@property (nonatomic, readonly) NSInteger minimalClearTimes;

// クリア済み回数
@property (nonatomic, readonly) NSInteger currentClearTimes;

// 再び遊ぶモード
@property (nonatomic) BOOL playAgainMode;

@end
