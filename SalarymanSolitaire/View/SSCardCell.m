//
//  SSCardCell.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-2.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSCardCell.h"
#import "SSCard.h"

@interface SSCardCell ()

// カードビュー
@property (nonatomic, strong) SSCardView *cardView;

@end

@implementation SSCardCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup
{
    if (!_cardView) {
        _cardView = [[SSCardView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_cardView];
    }
}
@end
