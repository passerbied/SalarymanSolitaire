//
//  SSPoker.h
//  Poker
//
//  Created by IfelseGo on 14-5-2.
//
//

#import <Foundation/Foundation.h>

// ポーカー種類
typedef NS_ENUM(NSInteger, SSPokerColor)
{
    SSPokerColorHeart = 1,
    SSPokerColorDiamond,
    SSPokerColorClub,
    SSPokerColorSpade,
    SSPokerColorCount = SSPokerColorSpade
};

// ポーカー名称
typedef NS_ENUM(NSInteger, SSPokerName)
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
};

// ポーカー所属位置
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

// 表示オプション
typedef NS_ENUM(NSInteger, SSPokerOptions)
{
    SSPokerOptionAnimationDefault       = 1 << 0,
    SSPokerOptionAnimationDistribution  = 1 << 1,
    
    SSPokerOptionSectionDeck            = 1 << 2,
    SSPokerOptionSectionFinished        = 1 << 3,
    SSPokerOptionSectionYamafuda        = 1 << 4,
    SSPokerOptionSectionHidden          = 1 << 5,
    
    SSPokerOptionShowFaceUp             = 1 << 6
};

#define SSPokerTotalCount               SSPokerNameCount * SSPokerColorCount

@interface SSPoker : NSObject

// 初期化
+ (instancetype)pokerWithColor:(SSPokerColor)color name:(SSPokerName)name;

// ポーカー種類
@property (nonatomic) SSPokerColor color;

// ポーカー名称
@property (nonatomic) SSPokerName name;

// 表示オプション
@property (nonatomic, readonly) SSPokerOptions displayOptions;

// 表示方向
- (void)setFaceUp:(BOOL)faceUp;

// 完了標識
- (void)setFinished:(BOOL)finished;

// 配布標識
- (void)setDistributionMode:(BOOL)mode;


// ポーカー画像
- (UIImage *)image;

// 色
- (SSPokerSection)sectionForCurrentColor;

// 移動可否チェック
- (BOOL)isValidNeighbourToPoker:(SSPoker *)poker inSection:(SSPokerSection)section;

// デバーグ情報出力
- (NSString *)description;
@end
