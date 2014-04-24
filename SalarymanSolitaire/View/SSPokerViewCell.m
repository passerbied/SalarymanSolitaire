//
//  SSPokerViewCell.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-2.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPokerViewCell.h"
#import "SSPoker.h"


@interface SSPokerViewCell ()
{
    BOOL                                _faceUp;
}
// ポーカー画像
@property (nonatomic, strong) UIImageView *pokerImageView;
@end

@implementation SSPokerViewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        if (!_pokerImageView) {
            _pokerImageView = [[UIImageView alloc] initWithFrame:self.bounds];
            _pokerImageView.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_pokerImageView];
        }
    }
    return self;
}

- (void)setAnimationMode:(SSPokerAnimationMode)mode
{
    CGFloat speed;
    switch (mode) {
        case SSPokerAnimationModeFan:
            speed = 15.0f;
            break;
        case SSPokerAnimationModeShuffle:
            speed = 10.0f;
            break;
        case SSPokerAnimationModePlay:
            speed = 0.10f;
            break;
        case SSPokerAnimationModeDone:
            speed = 0.1f;
            break;
        default:
            break;
    }
    if (speed > 0) {
        self.layer.speed = speed;
    }
}
- (void)setPoker:(SSPoker *)poker
{
    // ポーカー情報退避
    if (_poker == poker && _faceUp == poker.faceUp) {
        return;
    }
    _poker = poker;
    
    // ポーカーイメージ更新
    _pokerImageView.image = [_poker image];
}

// 表示方向
- (void)setPokerFaceUp:(BOOL)faceUp;
{
    if (_poker.faceUp == faceUp) {
        return;
    }
    _poker.faceUp = faceUp;
    // ポーカーイメージ更新
    _pokerImageView.image = [_poker image];
}
@end
