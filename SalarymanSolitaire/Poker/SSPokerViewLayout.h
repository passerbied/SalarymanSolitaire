//
//  SSPokerViewLayout.h
//  Poker
//
//  Created by IfelseGo on 14-5-2.
//
//

#import <UIKit/UIKit.h>
#import "UICollectionViewLayout_Warpable.h"

typedef NS_ENUM(NSInteger, SSPokerViewLayoutMode)
{
    SSPokerViewLayoutModeDistribution,
    SSPokerViewLayoutModeChallenge,
    SSPokerViewLayoutModeYamafuda
};

@interface SSPokerViewLayout : UICollectionViewLayout

// ポーカーサイズ
@property (nonatomic) CGSize pokerSize;

// 山札戻し枚数
@property (nonatomic) NSInteger numberOfPokers;

// ポーカー情報
@property (nonatomic, strong) NSMutableArray *pokers;

// レイアウトモード
@property (nonatomic) SSPokerViewLayoutMode currentMode;
@property (nonatomic) NSInteger currentSection;

// 山札戻し位置
+ (CGRect)rectForYamafuda;
@end


@interface SSDraggblePokerViewLayout : SSPokerViewLayout<UICollectionViewLayout_Warpable>
@property (readonly, nonatomic) LSCollectionViewLayoutHelper *layoutHelper;
@end