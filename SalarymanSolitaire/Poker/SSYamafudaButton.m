//
//  SSYamafudaButton.m
//  Poker
//
//  Created by IfelseGo on 14-5-3.
//
//

#import "SSYamafudaButton.h"
#import "SSPokerViewLayout.h"

@interface SSYamafudaButton ()
{
    // 山札戻しの回数
    NSInteger                           _usableTimes;
    UILabel                             *_numbersLabel;
    
    // 背景イメージ
    UIImageView                         *_backgroundImageView;
    
    // 山札戻しモード
    BOOL                                _yamafudaModosi;
}
@end

@implementation SSYamafudaButton

- (instancetype)initWithDelegate:(id<SSYamafudaButtonDelegate>)delegate
{
    CGRect rect = [SSPokerViewLayout rectForYamafuda];
    self = [super initWithFrame:rect];
    if (self) {
        _delegate = delegate;
        _displayMode = NSIntegerMax;
        
        // 背景イメージビュー作成
        rect.origin = CGPointMake(0.0f, 0.0f);
        _backgroundImageView = [[UIImageView alloc] initWithFrame:rect];
        _backgroundImageView.userInteractionEnabled = YES;
        
        [self addSubview:_backgroundImageView];
        
        // 山札戻し回数ラベル作成
        CGFloat size = 20.0f;
        CGFloat x = (rect.size.width - size)/2.0f;
        CGFloat y = 6.0f;
        rect = CGRectMake(x, y, size, size);
        _numbersLabel = [[UILabel alloc] initWithFrame:rect];
        _numbersLabel.backgroundColor = [UIColor whiteColor];
        _numbersLabel.clipsToBounds = YES;
        _numbersLabel.layer.cornerRadius = size/2.0f;
        _numbersLabel.textColor = [UIColor blackColor];
        _numbersLabel.font = SSGothicProFont(12.0f);
        _numbersLabel.textAlignment = NSTextAlignmentCenter;
        _numbersLabel.userInteractionEnabled = YES;
        [self addSubview:_numbersLabel];
        
        _maximumYamafuda = -1;
        
        // タップ処理追加
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yamafudaDidTouched:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setDisplayMode:(YamafudaDisplayMode)displayMode
{
    if (_displayMode == displayMode) {
        return;
    }
    _displayMode = displayMode;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_displayMode == YamafudaDisplayModeReturn) {
        // 山札戻しの場合
        _numbersLabel.text = [NSString stringWithFormat:@"%ld", (long)_usableTimes];
        _numbersLabel.hidden = NO;
        _backgroundImageView.image = [UIImage imageNamed:@"product_item.png"];
        
    } else if (_displayMode == YamafudaDisplayModeBuy) {
        // 山札戻しの回数が０になった場合
        _numbersLabel.hidden = YES;
        _backgroundImageView.image = [UIImage imageNamed:@"btn_more_card.png"];
        
    } else {
        // フリープレイ、または山札にトランプがある場合
        _numbersLabel.hidden = YES;
        _backgroundImageView.image = [UIImage imageNamed:@"bg_card_back.png"];
    }
}

- (void)setMaximumYamafuda:(NSInteger)maximumYamafuda
{
    _maximumYamafuda = maximumYamafuda;
    _usableTimes = maximumYamafuda;
    
    // 山戻し回数表示
    if (_maximumYamafuda) {
        _numbersLabel.hidden = NO;
    } else {
        _numbersLabel.hidden = YES;
    }
}

- (void)yamafudaDidTouched:(UITapGestureRecognizer *)tapGesture;
{
    // ステータスチェック
    if (tapGesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    if (_displayMode == YamafudaDisplayModeBuy) {
        // ショップを表示する
        [_delegate willPresentShop];
    } else {
        // 山札を利用する
        [_delegate willUseYamafuda];
    }
}

// 山札戻し使用
- (void)useYamafudaReturn;
{
    if (_displayMode == YamafudaDisplayModeFree) {
        return;
    }
    _usableTimes--;
    if (_usableTimes > 0) {
        [self setNeedsLayout];
    }
}
@end