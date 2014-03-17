//
//  SSStage.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-12.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSStage : NSObject

// ステージID
@property (nonatomic) NSInteger stageID;

// キャラクターID
@property (nonatomic) NSInteger character;

// ストーリー(画像ファイル)
@property (nonatomic, strong) UIImage *storyImage;

// カード枚数
@property (nonatomic) NSInteger numberOfCards;

// 山札戻し回数
//@property (nonatomic) NSInteger numberOfCards;

// クリア回数
@property (nonatomic) NSInteger clearTimes;

// クリア標識
@property (nonatomic, getter = isFinished) BOOL finished;

// キャラクターID
@property (nonatomic) NSInteger characterID;

// 名前
@property (nonatomic, strong) NSString *name;

// 所属部署
@property (nonatomic, strong) NSString *department;

// 画像
@property (nonatomic, strong) UIImage *photo;

@end
