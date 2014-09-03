//
//  SSPhysicalView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-16.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPhysicalView.h"
#import "SSChallengeController.h"

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
    
    // ゲージ
    CGPoint                             _gaugeOriginal;
    
    UIImageView                         *_physicalBarView;
    
    NSTimeInterval                      _tempduration;
    
}

// 体力
@property (nonatomic, strong) UILabel *powerLabel;

// 時間
@property (nonatomic, strong) UILabel *timeLabel;

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
        _timeLabelOriginal = CGPointMake(4.0f, 11.0f);
        
        _gaugeOriginal = CGPointMake(55.0f, 15.0f);
    } else {
        // iPhone4の場合
        _height = 29.0f;
        _powerLabelFontSize = 12.0f;
        _powerLabelOriginal = CGPointMake(2.5f, 6.5f);
        
        _timeLabelFontSize = 9.0f;
        _timeLabelOriginal = CGPointMake(288.0f, 11.0f-kGaugeMarginTop);
        
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
        CGFloat strokeWidth = 7.0f;
        NSDictionary *attributes = @{ NSFontAttributeName:font,
                                      NSStrokeWidthAttributeName:[NSNumber numberWithFloat:strokeWidth]};
        CGSize size = [text sizeWithAttributes:attributes];
        CGRect powerLabelRect = CGRectMake(_powerLabelOriginal.x, _powerLabelOriginal.y, size.width, size.height);
        _powerLabel = [[UILabel alloc] initWithFrame:powerLabelRect];
        _powerLabel.backgroundColor = [UIColor clearColor];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = NSMakeRange(0, [text length]);
        [attrString addAttribute:NSFontAttributeName value:font range:range];
        [attrString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:strokeWidth] range:range];
        [attrString addAttribute:NSStrokeColorAttributeName value:SSColorWhite range:range];
        _powerLabel.attributedText = attrString;
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
            timeLabelRect = CGRectMake((rect.size.width - size.width + _gaugeOriginal.x)/2, _timeLabelOriginal.y - size.height, size.width, size.height);
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
    
    // バー
    if (!_physicalBarView) {
        _physicalBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"physical_bar.png"]];
        [self addSubview:_physicalBarView];
    }
    [self showCurrentPower];
}

- (void)setDuration:(NSTimeInterval)duration
{
    if (_duration == duration) {
        return;
    }
    
    _duration = duration;
    
    // 時間表示
    _timeLabel.text = [self currentTime];
    
    // 残り体力表示
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kGameInfoPowerLastUsingTime]) {
        double savedTime = [[[NSUserDefaults standardUserDefaults] valueForKey:kGameInfoPowerLastUsingTime] doubleValue];
        
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval now = [dat timeIntervalSince1970]*1;
        
        double savedDuration = now - savedTime;
        
        if (savedDuration > 60*15) {
            if (_currentPower < _maxPower) {
                [self powerUp:YES];
            }
        }
         [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGameInfoPowerLastUsingTime];
    } else {
        
        if ((long)_duration%(60*15) == 0) {
            if (_currentPower < _maxPower) {
                [self powerUp:YES];
            }
        }
    }
    
    [self showCurrentPower];    
}

- (void)setPowerUsedDuration:(NSTimeInterval)duration
{
    if (_powerUsedDuration == duration) {
        return;
    }
    
    _powerUsedDuration = duration;
    
    // 残り体力表示
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kGameInfoPowerLastUsingTime]) {
        double savedTime = [[[NSUserDefaults standardUserDefaults] valueForKey:kGameInfoPowerLastUsingTime] doubleValue];
        
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval now = [dat timeIntervalSince1970]*1;
        
        double savedDuration = now - savedTime;
        
        if (savedDuration > 15) {
            if (_currentPower < _maxPower) {
                [self powerUp:YES];
            }
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGameInfoPowerLastUsingTime];
        [[SSChallengeController sharedChallengeController] setPowerUsedDuration:0];
    } else {
        
        if ((long)_powerUsedDuration%(15) == 0) {
            if (_currentPower < _maxPower) {
                [self powerUp:YES];
            }
        }
    }
}

- (NSString *)currentTime
{
    NSInteger duration = (NSInteger)_duration;
    NSInteger minute = duration / kSecondPerMinute;
    NSInteger second = duration % kSecondPerMinute;
    return [NSString stringWithFormat:@"%02d:%02d", (int)minute, (int)second];
}

- (void)showCurrentPower
{
    // ゲージ表示制御
    for (NSInteger tag = kGaugeTag; tag < kGaugeTag + kPowerValueMax; tag++) {
        UIImageView *gagueView = (UIImageView *)[self viewWithTag:tag];
        if (_currentPower >= tag - kGaugeTag + 1 ) {
            gagueView.hidden = NO;
        } else {
            gagueView.hidden = YES;
        }
    }
}

- (void)powerUp:(BOOL)up;
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

- (void)setMaxPower:(NSInteger)maxPower
{
    if (_maxPower == maxPower) {
        return;
    }
    
    _maxPower = maxPower;
    // 白いバー位置制御
    if (_maxPower >= kPowerValueMax) {
        _physicalBarView.hidden = YES;
    } else {
        _physicalBarView.hidden = NO;
        
    }
    CGRect rect = [[self viewWithTag:kGaugeTag + _maxPower - 1] frame];
    CGFloat dx = -3.0f;
    CGFloat dy = -5.0f;
    CGFloat x = rect.origin.x + kGaugeSizeWidth + dx;
    CGFloat y = rect.origin.y + dy;
    rect = _physicalBarView.frame;
    rect.origin = CGPointMake(x, y);
    _physicalBarView.frame = rect;
}

- (void)setCurrentPower:(NSInteger)currentPower
{
    if (_currentPower == currentPower) {
        return;
    }
    _currentPower = currentPower;
    [self showCurrentPower];
}

// 体力値をすべて回復する
- (void)recovery;
{
    self.currentPower = _maxPower;
}

// 体力有無チェック
- (BOOL)isPowerOFF;
{
    if (_currentPower > 0) {
        return NO;
    }
    return YES;
}
@end
