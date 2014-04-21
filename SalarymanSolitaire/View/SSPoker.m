//
//  SSPoker.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-31.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPoker.h"
@interface SSPoker ()
// 関連ポーカー
- (SSPokerName)nameForNextPoker;
- (SSPokerName)nameForPrePoker;

// 色
- (BOOL)isBlackPoker;
@end

@implementation SSPoker

// ポーカー画像
- (UIImage *)image;
{
    UIImage *pokerImage;
    if (_faceUp) {
        NSString *pokerImageName = [NSString stringWithFormat:@"card_%d_%d", _color, _name];
        pokerImage = [UIImage imageNamed:pokerImageName];
    } else {
        pokerImage = [UIImage imageNamed:@"bg_card_back"];
    }
    return pokerImage;
}

// 色
- (NSInteger)sectionForCurrentColor;
{
    NSInteger section;
    switch (_color) {
        case SSPokerColorHeart:
            section = SSPokerSectionFinishedHeart;
            break;

        case SSPokerColorDiamond:
            section = SSPokerSectionFinishedDiamond;
            break;

        case SSPokerColorClub:
            section = SSPokerSectionFinishedClub;
            break;

        case SSPokerColorSpade:
            section = SSPokerSectionFinishedSpade;
            break;

        default:
            DebugLog(@"Section異常")
            break;
    }
    return section;
}

// 関連ポーカー
- (SSPokerName)nameForNextPoker;
{
    if (_name == SSPokerNameK) {
        return SSPokerNameNone;
    }
    return (_name + 1);
}

- (SSPokerName)nameForPrePoker;
{
    if (_name == SSPokerNameA) {
        return SSPokerNameNone;
    }
    return (_name - 1);
}

// 色
- (BOOL)isBlackPoker;
{
    if (_color == SSPokerColorHeart || _color == SSPokerColorDiamond) {
        return NO;
    }
    return YES;
}

// 移動可否チェック
- (BOOL)canMoveToWithPoker:(SSPoker *)poker inSection:(SSPokerSection)section;
{
    // 仕上げチェック
    if (!poker) {
        if (section >= SSPokerSectionFinishedHeart && _name == SSPokerNameA) {
            return YES;
        }
        if (section <= SSPokerSectionPlaying7 && _name == SSPokerNameK) {
            return YES;
        }
    }
    if (!poker && section >= SSPokerSectionFinishedHeart) {
        if (_name == SSPokerNameA) {
            return YES;
        }
        return NO;
    }
    
    if ([poker isFinished]) {
        // 色一致チェック
        if (poker.color != self.color) {
            return NO;
        }
        // 関連チェック
        if ([poker nameForNextPoker] != self.name) {
            return NO;
        }
        return YES;
    } else {
        // 色チェック
        if ([poker isBlackPoker] == [self isBlackPoker]) {
            return NO;
        }
        // 関連チェック
        if ([poker nameForPrePoker] != self.name) {
            return NO;
        }
        return YES;
    }
}
@end
