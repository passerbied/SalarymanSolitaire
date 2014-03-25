//
//  SSStageCell.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-22.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSStageCell : UITableViewCell

// 最新のステージ索引設定
+ (void)setSelectedStageID:(NSInteger)stageID;

// 開始ステージ索引
@property (nonatomic) NSInteger fromStageID;

@end


@interface SSStageControl : UIButton

// ステージ索引
@property (nonatomic) NSInteger stageID;

// 敵索引
@property (nonatomic) NSInteger enemyID;

@end

// 最大ステージ数
extern const NSInteger SolitaireStageCellMaxNumber;

// ステージの表示数
extern const NSInteger SolitaireStageCellNumberPerRow;

// セルの高さ
extern const CGFloat SolitaireStageCellHeight;

// ヘッダーの高さ
extern const CGFloat SolitaireStageCellHeaderHeight;


@interface SSStageCellArrow : UIImageView

// ステージ索引
@property (nonatomic) NSInteger stageID;

// 矢印種類
@property (nonatomic, getter = isRightArrow) BOOL rightArrow;

@end

extern NSString *const StageDidSelectNotification;
extern NSString *const StageDidSelectNotificationStageIDKey;
extern NSString *const StageDidSelectNotificationStateKey;
extern NSString *const StageDidSelectNotificationADKey;


