//
//  SSPoker.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-31.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// ポーカー種類
typedef enum
{
    SSPokerColorHeart = 1,
    SSPokerColorDiamond,
    SSPokerColorClub,
    SSPokerColorSpade,
    SSPokerColorCount = SSPokerColorSpade
} SSPokerColor;

// ポーカー名称
typedef enum
{
    SSPokerNameNone,
    SSPokerNameA = 1,
    SSPokerName2,
    SSPokerName3,
    SSPokerName4,
    SSPokerName5,
    SSPokerName6,
    SSPokerName7,
    SSPokerName8,
    SSPokerName9,
    SSPokerName10,
    SSPokerNameJ,
    SSPokerNameQ,
    SSPokerNameK,
    SSPokerNameCount = SSPokerNameK
} SSPokerName;

typedef NS_ENUM(NSInteger, SSPokerSection)
{
    SSPokerSectionDeck1,
    SSPokerSectionDeck2,
    SSPokerSectionDeck3,
    SSPokerSectionDeck4,
    SSPokerSectionDeck5,
    SSPokerSectionDeck6,
    SSPokerSectionDeck7,
    SSPokerSectionYamafuda,
    SSPokerSectionHeart,
    SSPokerSectionDiamond,
    SSPokerSectionClub,
    SSPokerSectionSpade,
    SSPokerSectionHidden,
    SSPokerSectionRecycle,
    SSPokerSectionTotal
};

#define SSPokerTotalCount               SSPokerNameCount * SSPokerColorCount

@interface SSPoker : NSObject

// ポーカー種類
@property (nonatomic) SSPokerColor color;

// ポーカー名称
@property (nonatomic) SSPokerName name;

// 方向
@property (nonatomic, getter = isFaceUp) BOOL faceUp;

// 表示／非表示
@property (nonatomic, getter = isVisible) BOOL visible;

// 完了フラグ
@property (nonatomic, getter = isFinished) BOOL finished;

// ポーカー画像
- (UIImage *)image;

// 色により所属セクションを取得
- (NSInteger)sectionForCurrentColor;

// 移動可否チェック
//- (BOOL)canMoveToWithPoker:(SSPoker *)poker inSection:(SSPokerSection)section;

// 移動可否チェック
- (BOOL)isValidNeighbourToPoker:(SSPoker *)poker inSection:(SSPokerSection)section;

// 初期化
+ (instancetype)pokerWithColor:(SSPokerColor)color name:(SSPokerName)name;

// ダミーポーカー初期化
+ (instancetype)dummyPoker;

@end
