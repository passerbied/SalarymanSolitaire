//
//  SSPhysicalView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-16.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPhysicalView.h"

#define kSecondPerMinute                60
#define kPowerRecoveryTime              10
#define kPowerValueDefault              5
#define kPowerValueMax                  10

#define kGaugeTag                       100
#define kGaugeMarginLeft                3.5
#define kGaugeMarginTop                 2.5
#define kGaugeInnerSpacing              1.0
#define kGaugeSizeWidth                 24.5
#define kGaugeSizeHeight                18.0
@interface SSPhysicalView ()
{
    CGFloat                             _height;
    
    // 体力
    CGFloat                             _powerLabelFontSize;
    CGPoint                             _powerLabelOriginal;
    
    // 時間
    CGFloat                             _timeLabelFontSize;
    CGPoint                             _timeLabelOriginal;
    NSTimer                             *_updateTimer;
    NSInteger                           _currentTime;
    
    // ゲージ
    CGPoint                             _gaugeOriginal;
}

// 体力
@property (nonatomic, strong) UILabel *powerLabel;

// 時間
@property (nonatomic, strong) UILabel *timeLabel;

//
@end

@implementation SSPhysicalView

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
    _maxPower = kPowerValueMax;
    _currentPower = 0;
    
    if ([UIDevice isPhone5]) {
        // iPhone5の場合
        _height = 45.0f;
        _powerLabelFontSize = 18.0f;
        _powerLabelOriginal = CGPointMake(8.0f, 15.0f);
        
        _timeLabelFontSize = 9.0f;
        _timeLabelOriginal = CGPointMake(4.0f, 15.0f);
        
        _gaugeOriginal = CGPointMake(55.0f, 15.0f);
    } else {
        // iPhone4の場合
        _height = 29.0f;
        _powerLabelFontSize = 10.0f;
        _powerLabelOriginal = CGPointMake(6.0f, 10.0f);
        
        _timeLabelFontSize = 9.0f;
        _timeLabelOriginal = CGPointMake(288.0f, 11.0f);
        
        _gaugeOriginal = CGPointMake(27.0f, 1.0f);
    }
    
    // 画面サイズ調整
    CGRect rect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, _height);
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_physical_bar.png"]];
    backgroundImageView.frame = rect;
    [self addSubview:backgroundImageView];
    self.frame = rect;
    
    // 体力
    if (!_powerLabel) {
        UIFont *font = SSGothicProFont(_powerLabelFontSize);
        NSString *text = LocalizedString(@"体力");
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGSize size = [text sizeWithAttributes:attributes];
        CGRect powerLabelRect = CGRectMake(_powerLabelOriginal.x, _powerLabelOriginal.y, size.width, size.height);
        _powerLabel = [[UILabel alloc] initWithFrame:powerLabelRect];
        _powerLabel.backgroundColor = [UIColor clearColor];
        _powerLabel.textColor = SSColorWhite;
        _powerLabel.font = font;
        _powerLabel.text = text;
        [self addSubview:_powerLabel];
    }
    
    // 時間
    if (!_timeLabel) {
        UIFont *font = SSGothicProFont(_timeLabelFontSize);
        NSString *text = [self currentTime];
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGSize size = [text sizeWithAttributes:attributes];
        size.width += 2.0f;
        CGRect timeLabelRect;
        if ([UIDevice isPhone5]) {
            timeLabelRect = CGRectMake(rect.size.width - size.width - _timeLabelOriginal.x, _timeLabelOriginal.y - size.height, size.width, size.height);
        } else {
            timeLabelRect = CGRectMake(_timeLabelOriginal.x, _timeLabelOriginal.y, size.width, size.height);
        }
        _timeLabel = [[UILabel alloc] initWithFrame:timeLabelRect];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = SSColorWhite;
        _timeLabel.font = font;
        _timeLabel.text = text;
        [self addSubview:_timeLabel];
    }
    
    // タイマー設定
    if (!_updateTimer) {
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(showCurrentTimeAction:) userInfo:nil repeats:YES];;
    }
    
    // ゲージ
    UIImage *backgroundImage = [UIImage imageNamed:@"physical_gray.png"];
    UIImageView *gagueBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    gagueBackgroundView.frame = CGRectMake(_gaugeOriginal.x, _gaugeOriginal.y, backgroundImage.size.width, backgroundImage.size.height);
    [self addSubview:gagueBackgroundView];

    UIImage *gagueImage = [UIImage imageNamed:@"physical_red.png"];
    CGFloat x;
    CGFloat y = _gaugeOriginal.y + kGaugeMarginTop;

    for (NSInteger tag = kGaugeTag; tag < kGaugeTag + kPowerValueMax; tag++) {
        UIImageView *gagueView = [[UIImageView alloc] initWithImage:gagueImage];
        [gagueView setTag:tag];
        gagueView.hidden = YES;
        x = _gaugeOriginal.x + kGaugeMarginLeft + (kGaugeSizeWidth + kGaugeInnerSpacing)*(tag - kGaugeTag);
        CGRect gagueRect = CGRectMake(x, y, kGaugeSizeWidth, kGaugeSizeHeight);
        gagueView.frame = gagueRect;
        [self addSubview:gagueView];
    }
    [self showCurrentPower];
}

- (NSString *)currentTime
{
    NSInteger minute = _currentTime / kSecondPerMinute;
    NSInteger second = _currentTime % kSecondPerMinute;
    return [NSString stringWithFormat:@"%02d:%02d", (int)minute, (int)second];
}

- (void)showCurrentTimeAction:(NSTimer *)timer
{
    _currentTime++;
    if (_currentTime == kPowerRecoveryTime) {
        [self powerGrowthUp:YES];
        _currentTime = 0;
    }
    _timeLabel.text = [self currentTime];
}

- (void)showCurrentPower
{
    for (NSInteger tag = kGaugeTag; tag < kGaugeTag + kPowerValueMax; tag++) {
        UIImageView *gagueView = (UIImageView *)[self viewWithTag:tag];
        if (_currentPower >= tag - kGaugeTag + 1 ) {
            gagueView.hidden = NO;
        } else {
            gagueView.hidden = YES;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)dealloc
{
    if ([_updateTimer isValid]) {
        [_updateTimer invalidate];
        _updateTimer = nil;
    }
}

- (void)powerGrowthUp:(BOOL)up;
{
    NSInteger power;
    if (up) {
        power = _currentPower + 1;
    } else {
        power = _currentPower - 1;
    }
    if (power > _maxPower || power < 0) {
        return;
    }
    _currentPower = power;
    
    [self showCurrentPower];
}
@end
