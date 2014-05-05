//
//  SSYamafudaButton.m
//  Poker
//
//  Created by IfelseGo on 14-5-3.
//
//

#import "SSYamafudaButton.h"
#import "SSPokerViewLayout.h"

@implementation SSYamafudaButton

- (instancetype)initWithDelegate:(id<SSYamafudaButtonDelegate>)delegate
{
    CGRect rect = [SSPokerViewLayout rectForYamafuda];
    self = [super initWithFrame:rect];
    if (self) {
        _usable = YES;
        _delegate = delegate;
        
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

- (void)setFreeMode:(BOOL)freeMode
{
    _freeMode = freeMode;
    if (_freeMode) {
        _backgroundImageView.image = [UIImage imageNamed:@"free_icon_yamafuda.png"];
        _numbersLabel.hidden = YES;
    } else {
        _backgroundImageView.image = [UIImage imageNamed:@"product_item.png"];
        _numbersLabel.hidden = NO;
    }
}

- (void)setUsableYamafudas:(NSInteger)maximumYamafuda
{
    if (_maximumYamafuda == maximumYamafuda) {
        return;
    }
    _maximumYamafuda = maximumYamafuda;
    
    // 山戻し回数表示
    if (_maximumYamafuda) {
        _numbersLabel.hidden = NO;
        _numbersLabel.text = [NSString stringWithFormat:@"%d", _maximumYamafuda];
    } else {
        _numbersLabel.hidden = YES;
    }
    
}

- (void)yamafudaDidTouched:(UITapGestureRecognizer *)tapGesture;
{
    // 利用可否チェック
    if (!_usable) {
        return;
    }
    
    // ステータスチェック
    if (tapGesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    if (_freeMode) {
        // フリープレイモードの場合、山札戻しを実行する
        [_delegate willUseYamafuda];
    } else {
        // 山札戻し回数チェック
        if (_maximumYamafuda) {
            // 山札戻し回数更新
            NSInteger count = _maximumYamafuda - 1;
            self.maximumYamafuda = count;
            
            // 山札戻しの回数が「０」になった場合、追加ボタンの形で表示させる
            if (count == 0) {
                _maximumYamafuda = 0;
                _backgroundImageView.image = [UIImage imageNamed:@"btn_more_card.png"];
            }
            
            // 山札戻しを実行する
            [_delegate willUseYamafuda];
        } else {
            // ショップを表示する
            [_delegate willPresentShop];
        }
    }
}
@end