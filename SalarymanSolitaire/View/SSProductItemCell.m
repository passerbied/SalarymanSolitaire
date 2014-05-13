//
//  SSProductItemCell.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-13.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSProductItemCell.h"
#import "PurchaseManager.h"
#import "SolitaireManager.h"

#define kProductItemImageMargin1        6.0f
#define kProductItemImageMargin2        24.0f
#define kProductItemLabelEdgeInset      6.0f

@interface SSProductItemCell ()
{
    UIImageView                         *_topSeperatorView;
    UIImageView                         *_bottomSeperatorView;
}

// 商品名称
@property (nonatomic, strong) NSString *itemName;

// 商品価格
@property (nonatomic, strong) NSString *itemPrice;

// 商品ID
@property (nonatomic, strong) NSString *identifier;

// 商品画像
@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;

// 商品説明
@property (nonatomic, weak) IBOutlet UILabel *itemLabel;

// 商品購入
- (IBAction)purchaseAction:(id)sender;
@end

@implementation SSProductItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    // 表示設定
    _itemLabel.font = SSGothicProFont(18.0f);
    _itemLabel.textAlignment = NSTextAlignmentCenter;
    _itemLabel.textColor = SSColorBlack;
    
    // 区切り設定
    UIImage *seperatorImage = [UIImage imageNamed:@"popup_btn_dot_line.png"];
    _topSeperatorView = [[UIImageView alloc] initWithImage:seperatorImage];
    _bottomSeperatorView = [[UIImageView alloc] initWithImage:seperatorImage];
    CGRect rect = self.contentView.bounds;
    CGSize size = seperatorImage.size;
    CGFloat x = self.contentView.bounds.size.width - size.width;
    CGFloat y = 0.0f;
    _topSeperatorView.frame = CGRectMake(x, y, size.width, size.height);
    y = rect.size.height - size.height;
    _bottomSeperatorView.frame = CGRectMake(x, y, size.width, size.height);
    [self.contentView addSubview:_topSeperatorView];
    [self.contentView addSubview:_bottomSeperatorView];
}

- (void)setProduct:(SKProduct *)product
{
    if (_product == product) {
        return;
    }
    
    _product = product;
    self.identifier = [product productIdentifier];
    self.itemName = product.localizedTitle;
    self.itemPrice = [product localizedPrice];
}

- (void)setType:(ProductItemType)type
{
    if (_type == type) {
        return;
    }
    _type = type;
    [self setNeedsLayout];
}

- (void)setItemName:(NSString *)itemName
{
    if (_itemName == itemName) {
        return;
    }
    _itemName = itemName;
    [self setNeedsLayout];
}

- (void)setItemPrice:(NSString *)itemPrice
{
    if (_itemPrice == itemPrice) {
        return;
    }
    _itemPrice = itemPrice;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 商品画像表示
    NSString *name = nil;
    UIImage *image = nil;
    switch (self.type) {
        case ProductItemTypePower:
            // 体力アップ
            name = @"popup_icon_power.png";
            break;
        case ProductItemTypeDring:
            // 栄養剤
            name = @"popup_icon_drink.png";
            break;
        case ProductItemTypeYamafuda:
            // 山札戻し
            name = @"popup_icon_yamafuda.png";
            break;
            
        default:
            break;
    }
    if (!name) {
        return;
    }
    image = [UIImage imageNamed:name];
    _itemImageView.image = image;
    CGSize size = image.size;
    CGFloat x;
    if (self.type == ProductItemTypePower) {
        x = kProductItemImageMargin1;
    } else {
        x = kProductItemImageMargin2;
    }
    CGFloat y = (self.contentView.bounds.size.height - size.height)/2.0f;
    _itemImageView.frame = CGRectMake(x, y, size.width, size.height);
    
    // 商品名称＆価格表示
    x = x + size.width;
    NSDictionary *attributes = @{ NSFontAttributeName:_itemLabel.font };
    NSString *itemDetail = [NSString stringWithFormat:@"%@\n%@", _itemName, _itemPrice];
    size = [itemDetail sizeWithAttributes:attributes];
    CGFloat width = size.width + 2*kProductItemLabelEdgeInset;
    y = (self.contentView.bounds.size.height - size.height)/2.0f;
    _itemLabel.frame = CGRectMake(x, y, width, size.height);
    _itemLabel.text = itemDetail;
    
    if (_lastRow) {
        _bottomSeperatorView.hidden = NO;
    } else {
        _bottomSeperatorView.hidden = YES;
    }
}

// 商品購入
- (IBAction)purchaseAction:(id)sender;
{
    PurchaseManager *manager = [PurchaseManager sharedManager];
    [manager buyProduct:_product withQuantity:1 completion:^(NSArray *productIdentifiers, BOOL succeed) {
        if (succeed) {
            for (NSString *identifier in productIdentifiers) {
                [self provideContentWithProductIdentifier:identifier];
            }
        }
    }];
}

- (void)provideContentWithProductIdentifier:(NSString *)identifier
{
    NSRange range;
    NSInteger quantity;
    SolitaireManager *manager = [SolitaireManager sharedManager];
    
    // 基礎体力チェック
    range = [identifier rangeOfString:kProductIdentifierPowerUp];
    if (range.location != NSNotFound) {
        quantity = [[identifier substringFromIndex:range.length] integerValue];
        [manager buyPowerWithQuantity:quantity];
        DebugLog(@"基礎体力:[%ld]", (long)quantity);
        return;
    }
    
    // 栄養剤チェック
    range = [identifier rangeOfString:kProductIdentifierDrink];
    if (range.location != NSNotFound) {
        quantity = [[identifier substringFromIndex:range.length] integerValue];
        [manager buyNutrientWithQuantity:quantity];
        DebugLog(@"栄養剤:[%ld]", (long)quantity);
        return;
    }
    
    // 山札戻しチェック
    range = [identifier rangeOfString:kProductIdentifierYamafuda];
    if (range.location != NSNotFound) {
        quantity = [[identifier substringFromIndex:range.length] integerValue];
        [manager buyYamafudaWithQuantity:quantity];
        DebugLog(@"山札戻し:[%ld]", (long)quantity);
        return;
    }
}
@end
