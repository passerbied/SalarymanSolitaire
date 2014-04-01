//
//  SSCard.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-31.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// カード種類
typedef enum
{
    SSCardTypeHeart = 1,
    SSCardTypeDiamond,
    SSCardTypeClub,
    SSCardTypeSpade
} SSCardType;

// カード名称
typedef enum
{
    SSCardNameA = 1,
    SSCardName2,
    SSCardName3,
    SSCardName4,
    SSCardName5,
    SSCardName6,
    SSCardName7,
    SSCardName8,
    SSCardName9,
    SSCardName10,
    SSCardNameJ,
    SSCardNameQ,
    SSCardNameK
} SSCardName;


@interface SSCard : NSObject

// カード種類
@property (nonatomic) SSCardType cardType;

// カード名称
@property (nonatomic) SSCardName cardName;

// 方向
@property (nonatomic, getter = isFaceup) BOOL faceup;
@end

@interface SSCardView : UIView

// カード情報
@property (nonatomic, strong) SSCard *card;

@end
