//
//  SSPoker.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-31.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPoker.h"
@interface SSPoker ()
{

}

// ダミー
@property (nonatomic) BOOL dummyPoker;

// 関連ポーカー
//- (SSPokerName)nameForNextPoker;
//- (SSPokerName)nameForPrePoker;

// 次のポーカー名称
- (SSPokerName)neighbourName;

// 色チェック
- (BOOL)isSimilarColorWithPoker:(SSPoker *)poker;

// 色
//- (BOOL)isBlackPoker;
@end

@implementation SSPoker

// 初期化
+ (instancetype)pokerWithColor:(SSPokerColor)color name:(SSPokerName)name;
{
    SSPoker *poker = [[SSPoker alloc] init];
    poker.color = color;
    poker.name = name;
    poker.faceUp = NO;
    poker.visible = YES;
    poker.finished = NO;
    return poker;
}

// ダミーポーカー初期化
+ (instancetype)dummyPoker;
{
    SSPoker *poker = [[SSPoker alloc] init];
    poker.visible = YES;
    poker.dummyPoker = YES;
    return poker;
}

// ポーカー画像
- (UIImage *)image;
{
    NSString *name;
    if (_dummyPoker) {
        name = @"bg_card_front";
    } else {
        if (_faceUp) {
            name = [NSString stringWithFormat:@"card_%d_%d", _color, _name];
        } else {
            name = @"bg_card_back";
        }
    }
    return [UIImage imageNamed:name];;
}

// 色
- (NSInteger)sectionForCurrentColor;
{
    NSInteger section;
    switch (_color) {
        case SSPokerColorHeart:
            section = SSPokerSectionHeart;
            break;

        case SSPokerColorDiamond:
            section = SSPokerSectionDiamond;
            break;

        case SSPokerColorClub:
            section = SSPokerSectionClub;
            break;

        case SSPokerColorSpade:
            section = SSPokerSectionSpade;
            break;

        default:
            DebugLog(@"Section異常")
            break;
    }
    return section;
}

// 次のポーカー名称
- (SSPokerName)neighbourName;
{
    if (_finished) {
        if (_name == SSPokerNameK) {
            return SSPokerNameNone;
        }
        return (_name + 1);
    } else {
        if (_name == SSPokerNameA) {
            return SSPokerNameNone;
        }
        return (_name - 1);
    }
}

//// 関連ポーカー
//- (SSPokerName)nameForNextPoker;
//{
//    if (_name == SSPokerNameK) {
//        return SSPokerNameNone;
//    }
//    return (_name + 1);
//}
//
//- (SSPokerName)nameForPrePoker;
//{
//    if (_name == SSPokerNameA) {
//        return SSPokerNameNone;
//    }
//    return (_name - 1);
//}

// 色
- (BOOL)isBlackPoker;
{
    if (_color == SSPokerColorHeart || _color == SSPokerColorDiamond) {
        return NO;
    }
    return YES;
}

// 移動可否チェック
//- (BOOL)canMoveToWithPoker:(SSPoker *)poker inSection:(SSPokerSection)section;
//{
//    // 仕上げチェック
//    if (!poker) {
//        if (section >= SSPokerSectionHeart && _name == SSPokerNameA) {
//            return YES;
//        }
//        if (section <= SSPokerSectionDeck7 && _name == SSPokerNameK) {
//            return YES;
//        }
//    }
//    if (!poker && section >= SSPokerSectionHeart) {
//        if (_name == SSPokerNameA) {
//            return YES;
//        }
//        return NO;
//    }
//    
//    if ([poker isFinished]) {
//        // 色一致チェック
//        if (poker.color != self.color) {
//            return NO;
//        }
//        // 関連チェック
//        if ([poker nameForNextPoker] != self.name) {
//            return NO;
//        }
//        return YES;
//    } else {
//        // 色チェック
//        if ([poker isBlackPoker] == [self isBlackPoker]) {
//            return NO;
//        }
//        // 関連チェック
//        if ([poker nameForPrePoker] != self.name) {
//            return NO;
//        }
//        return YES;
//    }
//}

// 移動可否チェック
- (BOOL)isValidNeighbourToPoker:(SSPoker *)poker inSection:(SSPokerSection)section;
{
    // 上へ移動の場合
    if (section > SSPokerSectionYamafuda) {
        // 空っぽチェック
        if (!poker) {
            // 空っぽの場合、エースのみ移動可能と扱う
            if (_name == SSPokerNameA) {
                return YES;
            }
        } else {
            // 以外の場合、隣ポーカーのみ移動可能と扱う
            if ([poker neighbourName] == self.name) {
                return YES;
            }
        }
        
        // 上記外の場合、移動不可と扱う
        return NO;
    }
    
    // 両側／下へ移動の場合
    if (section < SSPokerSectionYamafuda) {
        // 空っぽチェック
        if (!poker) {
            // 空っぽの場合、キングのみ移動可能と扱う
            if (_name == SSPokerNameK) {
                return YES;
            }
        } else {
            // 以外の場合、下記処理を行う
            // 隣ポーカーチェック
            if ([poker neighbourName] != self.name) {
                return NO;
            }
            
            // 色チェック
            if ([self isSimilarColorWithPoker:poker]) {
                return NO;
            }
            return YES;
        }
    }
    
    return NO;
}

// 色チェック
- (BOOL)isSimilarColorWithPoker:(SSPoker *)poker;
{
    return ([self isBlackPoker] == [poker isBlackPoker]);
}

@end
