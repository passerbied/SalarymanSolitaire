//
//  SSProductCell.m
//  SalarymanSolitaire
//
//  Created by many on 14-4-13.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSProductCell.h"

@interface SSProductCell ()

// 商品名称
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

// 商品説明
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

// 商品備考
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;


@end

@implementation SSProductCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    _nameLabel.font = SSGothicProFont(20.0f);
    _titleLabel.font = SSGothicProFont(15.0f);
}

- (void)setType:(ProductItemType)type
{
    if (_type == type) {
        return;
    }
    _type = type;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSString *name;
    NSString *title;
    NSString *detail;
    switch (_type) {
        case ProductItemTypePower:
            // 体力
            name = @"基礎体力";
            title = @"体力ゲージの最大値を ＋１ 増加";
            detail = @"※最大で ＋５ まで";
            break;
            
        case ProductItemTypeDring:
            // 栄養剤
            name = @"栄養剤";
            title = @"体力ゲージを満タンに回復";
            break;
            
        case ProductItemTypeYamafuda:
            // 山札戻し
            name = @"山札戻し";
            title = @"山札戻しを１回おこないます。";
            break;
            
        default:
            break;
    }
    _nameLabel.text = name;
    _titleLabel.text = title;
    _detailLabel.text = detail;
    
    if (!detail) {
        self.detailLabel.hidden = YES;
        return;
    }
    NSDictionary *attributes = @{NSFontAttributeName:_titleLabel.font};
    CGSize size = [title sizeWithAttributes:attributes];
    CGRect rect = _detailLabel.frame;
    CGFloat x = _titleLabel.frame.origin.x + (_titleLabel.bounds.size.width - size.width)/2;
    CGFloat width = self.contentView.bounds.size.width - x;
    _detailLabel.frame = CGRectMake(x, rect.origin.y, width, rect.size.height);
}

@end
