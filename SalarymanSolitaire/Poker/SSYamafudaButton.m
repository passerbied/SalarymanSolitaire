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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_displayMode == YamafudaButtonDisplayModeRestart) {
        // 山札戻しの場合
        _numbersLabel.text = [NSString stringWithFormat:@"%ld", (long)_numberOfYamafuda];
        _numbersLabel.hidden = NO;
        _backgroundImageView.image = [UIImage imageNamed:@"product_item.png"];
        
    } else if (_displayMode == YamafudaButtonDisplayModeMore) {
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
    _numberOfYamafuda = maximumYamafuda;
    
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
    
    // 実行前のモード取得
    _displayMode = [_delegate yamafudaDisplayMode];
    
    if (_displayMode == YamafudaButtonDisplayModeReload) {
        // 新しいとランプをリロードする
        [_delegate reloadTrump];
    } else if (_displayMode == YamafudaButtonDisplayModeRestart) {
        // 山札戻し利用
        [_delegate willRestartYamafuda];
    } else if (_displayMode == YamafudaButtonDisplayModeMore) {
        // ショップ表示
        [_delegate requireMoreYamafuda];
    }
    
    // 実行後のモード取得
    _displayMode = [_delegate yamafudaDisplayMode];
    [self setNeedsLayout];
}

// 山札戻し使用
- (void)restartYamafuda;
{
    if (_freeMode) {
        return;
    }
    _numberOfYamafuda--;
    if (_numberOfYamafuda > 0) {
        [self setNeedsLayout];
    }
}

// リセット(ソリティアをリトライするときに行う)
- (void)reset;
{
    _numberOfYamafuda = _maximumYamafuda;
    
    _displayMode = [_delegate yamafudaDisplayMode];
    [self setNeedsLayout];
}
@end