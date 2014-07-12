//
//  SSPoker.m
//  Poker
//
//  Created by IfelseGo on 14-5-2.
//
//

#import "SSPoker.h"

@interface SSPoker ()
{
    
}

// 次のポーカー名称
- (SSPokerName)neighbourName;

// 色チェック
- (BOOL)isSimilarColorWithPoker:(SSPoker *)poker;

// 色
//- (BOOL)isBlackPoker;
@end

@implementation SSPoker

- (instancetype)init
{
    self = [super init];
    if (self) {
        _displayOptions = SSPokerOptionAnimationDistribution | SSPokerOptionShowFaceUp;
    }
    return self;
}
// 初期化
+ (instancetype)pokerWithColor:(SSPokerColor)color name:(SSPokerName)name;
{
    SSPoker *poker = [[SSPoker alloc] init];
    poker.color = color;
    poker.name = name;
    return poker;
}

// 表示方向
- (void)setFaceUp:(BOOL)faceUp;
{
    if (faceUp) {
        _displayOptions |= SSPokerOptionShowFaceUp;
    } else {
        _displayOptions &= (~SSPokerOptionShowFaceUp);
    }
}

// 完了標識
- (void)setFinished:(BOOL)finished;
{
    if (finished) {
        _displayOptions |= SSPokerOptionSectionFinished;
    } else {
        _displayOptions &= (~SSPokerOptionSectionFinished);
    }
}

// 配布標識
- (void)setDistributionMode:(BOOL)mode;
{
    if (mode) {
        _displayOptions |= SSPokerOptionAnimationDistribution;
    } else {
        _displayOptions &= (~SSPokerOptionAnimationDistribution);
    }
}

// ポーカー画像
- (UIImage *)image;
{
    NSString *name;
    if (_displayOptions & SSPokerOptionShowFaceUp) {
        name = [NSString stringWithFormat:@"card_%ld_%ld", (long)_color, (long)_name];
    } else {
        name = @"bg_card_back";
    }
    return [UIImage imageNamed:name];;
}

// 色
- (SSPokerSection)sectionForCurrentColor;
{
    SSPokerSection section;
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
    if (_displayOptions & SSPokerOptionSectionFinished) {
        // 完了済み
        if (_name == SSPokerNameK) {
            return SSPokerNameNone;
        }
        return (_name + 1);
    } else {
        // プレイン中
        if (_name == SSPokerNameA) {
            return SSPokerNameNone;
        }
        return (_name - 1);
    }
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
- (BOOL)isValidNeighbourToPoker:(SSPoker *)poker inSection:(SSPokerSection)section
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
            // 名前チェック
            if ([poker neighbourName] != self.name) {
                return NO;
            }
            
            // 色チェック
            if (poker.color != self.color) {
                return NO;
            }
            
            // 上記外の場合、移動可能と扱う
            return YES;
        }
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

// デバーグ情報出力
- (NSString *)description;
{
    NSString *colorName;
    if (_color == SSPokerColorHeart) {
        colorName = @"♥️";
    }
    
    switch (_color) {
        case SSPokerColorHeart:
            colorName = @"♥️";
            break;
        case SSPokerColorDiamond:
            colorName = @"♦️";
            break;
        case SSPokerColorClub:
            colorName = @"♣️";
            break;
        case SSPokerColorSpade:
            colorName = @"♠️";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@ %02ld",colorName, (long)_name];
}
@end
