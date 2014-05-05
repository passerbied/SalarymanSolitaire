//
//  SSPokerViewCell.m
//  Poker
//
//  Created by IfelseGo on 14-5-2.
//
//

#import "SSPokerViewCell.h"

@interface SSPokerViewCell ()
{
    // ポーカー画像
    UIImageView                         *_pokerImageView;
}

@end

@implementation SSPokerViewCell

- (void)setPoker:(SSPoker *)poker
{
    // ポーカー情報退避
    if (_poker != poker) {
        _poker = poker;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // ポーカービュー表示
    if (!_pokerImageView) {
        _pokerImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _pokerImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_pokerImageView];
    }
    _pokerImageView.image = [_poker image];
    
    // アニメーションスピード設定
    CGFloat speed;
    if (_poker.displayOptions & SSPokerOptionAnimationDistribution) {
        speed = 5.0f;
    } else {
        speed = 1.0f;
    }
    self.layer.speed = speed;
}

@end
