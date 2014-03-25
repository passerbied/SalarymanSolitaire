//
//  WUProgressView.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "WUProgressView.h"
#import <QuartzCore/QuartzCore.h>

NSString * const WUProgressDidTouchNotification = @"WUProgressDidTouchNotification";

static const CGFloat WUProgressRingRadius = 18;
static const CGFloat WUProgressRingThickness = 4;
static const CGFloat WUProgressParallaxDepthPoints = 10;

@interface WUProgressView ()

@property (strong, nonatomic, readonly) NSTimer *fadeOutTimer;
@property (nonatomic, readonly, getter = isClear) BOOL clear;

@property (strong, nonatomic) UIControl *overlayView;
@property (strong, nonatomic) UIView *hudView;
@property (strong, nonatomic) UILabel *stringLabel;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CALayer *indefiniteAnimatedLayer;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@property (nonatomic, readwrite) CGFloat progress;
@property (strong, nonatomic) CAShapeLayer *backgroundRingLayer;
@property (strong, nonatomic) CAShapeLayer *ringLayer;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;
@property (nonatomic, assign) UIOffset offsetFromCenter;
@property (nonatomic, assign) BOOL dimBackground;
@property (nonatomic, assign) BOOL allowUserInteraction;
@property (strong, nonatomic) NSDate *showStarted;
@property (strong, nonatomic) NSTimer *minShowTimer;

- (void)dismiss;

- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;
- (void)positionHUD:(NSNotification*)notification;
- (NSTimeInterval)displayDurationForString:(NSString*)string;

@end


@implementation WUProgressView

+ (WUProgressView *)sharedView {
    static dispatch_once_t once;
    static WUProgressView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}


+ (void)setStatus:(NSString *)string {
	[[self sharedView] setStatus:string];
}

+ (void)setDimBackgroundEnabled:(BOOL)enabled
{
    [[self sharedView] setDimBackground:enabled];
}

+ (void)setAllowUserInteraction:(BOOL)enabled
{
    [[self sharedView] setAllowUserInteraction:enabled];
}

#pragma mark - Show Methods

+ (void)show {
    [[self sharedView] showProgress:-1 status:nil];
}

+ (void)showWithStatus:(NSString *)status {
    [[self sharedView] showProgress:-1 status:status];
}

+ (void)showProgress:(float)progress {
    [[self sharedView] showProgress:progress status:nil];
}

+ (void)showProgress:(float)progress status:(NSString *)status {
    [[self sharedView] showProgress:progress status:status];
}

#pragma mark - Dismiss Methods

+ (void)dismiss {
    if ([WUProgressView isVisible]) {
        WUProgressView *progressView = [WUProgressView sharedView];
        if (progressView.minShowTime > 0.0 && progressView.showStarted) {
            NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:progressView.showStarted];
            // 判断是否达到最短显示时间
            if (interv < progressView.minShowTime) {
                progressView.minShowTimer = [NSTimer scheduledTimerWithTimeInterval:(progressView.minShowTime - interv)
                                                                             target:self
                                                                           selector:@selector(handleMinShowTimer:)
                                                                           userInfo:nil
                                                                            repeats:NO];
                return;
            }
        }
        [[self sharedView] dismiss];
    }
}

+ (void)dismissAfterDelay:(NSTimeInterval)delay
{
    if ([WUProgressView isVisible]) {
        if (delay > 0) {
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
        } else {
            [[self sharedView] dismiss];
        }
    }
}

- (void)handleMinShowTimer:(NSTimer *)theTimer
{
	[self dismiss];
}

#pragma mark - Offset

+ (void)setOffsetFromCenter:(UIOffset)offset {
    [self sharedView].offsetFromCenter = offset;
}

+ (void)resetOffsetFromCenter {
    [self setOffsetFromCenter:UIOffsetZero];
}

#pragma mark - Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
		self.alpha = 1.0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.backgroundColor = [UIColor whiteColor];
        self.statusFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.dimBackground = YES;
        [self registerNotifications];
    }
	
    return self;
}

- (void)updatePosition {
	
    CGFloat hudWidth = 100;
    CGFloat hudHeight = 100;
    CGFloat stringHeightBuffer = 20;
    CGFloat stringAndImageHeightBuffer = 80;
    
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    NSString *string = self.stringLabel.text;
    // False if it's text-only
    BOOL imageUsed = (self.imageView.image) || (self.imageView.hidden);
    
    if(string) {
        CGSize constraintSize = CGSizeMake(200, 300);
        CGRect stringRect = [string boundingRectWithSize:constraintSize options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: self.stringLabel.font} context:NULL];
        stringWidth = stringRect.size.width;
        stringHeight = stringRect.size.height;
        
        if (imageUsed)
            hudHeight = stringAndImageHeightBuffer + stringHeight;
        else
            hudHeight = stringHeightBuffer + stringHeight;
        
        if(stringWidth > hudWidth)
            hudWidth = ceil(stringWidth/2)*2;
        
        CGFloat labelRectY = imageUsed ? 68 : 9;
        
        if(hudHeight > 100) {
            labelRect = CGRectMake(12, labelRectY, hudWidth, stringHeight);
            hudWidth+=24;
        } else {
            hudWidth+=24;
            labelRect = CGRectMake(0, labelRectY, hudWidth, stringHeight);
        }
    }
	
	self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    
    if(string) {
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36);
    } else {
       	self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
    }
	
	self.stringLabel.hidden = NO;
	self.stringLabel.frame = labelRect;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	if(string) {
        CGPoint center = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), 36);
        self.indefiniteAnimatedLayer.position = center;
        
        if(self.progress != -1)
            self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), 36);
	} else {
        CGPoint center = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), CGRectGetHeight(self.hudView.bounds)/2);
        self.indefiniteAnimatedLayer.position = center;
        
        if(self.progress != -1)
            self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), CGRectGetHeight(self.hudView.bounds)/2);
    }
    
    [CATransaction commit];
}

- (void)setStatus:(NSString *)string {
    
	self.stringLabel.text = string;
    [self updatePosition];
    
}

- (void)setFadeOutTimer:(NSTimer *)newTimer {
    
    if(_fadeOutTimer)
        [_fadeOutTimer invalidate], _fadeOutTimer = nil;
    
    if(newTimer)
        _fadeOutTimer = newTimer;
}


- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)positionHUD:(NSNotification*)notification {
    
    CGFloat keyboardHeight;
    double animationDuration;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = keyboardFrame.size.height;
            else
                keyboardHeight = keyboardFrame.size.width;
        } else
            keyboardHeight = 0;
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    if(keyboardHeight > 0)
        activeHeight += statusBarFrame.size.height*2;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floor(activeHeight*0.45);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    
    if(notification) {
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                         } completion:NULL];
    }
    
    else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
    
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = CGPointMake(newCenter.x + self.offsetFromCenter.horizontal, newCenter.y + self.offsetFromCenter.vertical);
}

- (void)overlayViewDidTouchAction:(id)sender forEvent:(UIEvent *)event
{
    if (self.allowUserInteraction) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WUProgressDidTouchNotification object:event];
    }
}

#pragma mark - Master show/dismiss methods

- (void)showProgress:(float)progress status:(NSString*)string
{
    // 开始时间保存
    self.showStarted = [NSDate date];
    
    if(!self.overlayView.superview){
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows)
            if (window.windowLevel == UIWindowLevelNormal) {
                if (self.dimBackground) {
                    [window addSubview:self.overlayView];
                }
                [window addSubview:self.hudView];
                break;
            }
    }
    
    self.fadeOutTimer = nil;
    self.imageView.hidden = YES;
    self.progress = progress;
    
    self.stringLabel.text = string;
    [self updatePosition];
    
    if(progress >= 0) {
        [self.indefiniteAnimatedLayer removeFromSuperlayer];
        
        self.ringLayer.strokeEnd = progress;
    }
    else {
        [self cancelRingLayerAnimation];
        [self.hudView.layer addSublayer:self.indefiniteAnimatedLayer];
    }
    
    if (self.dimBackground) {
        self.overlayView.hidden = NO;
    } else {
        self.overlayView.hidden = YES;
    }
    
    [self positionHUD:nil];
    
    if(self.alpha != 1) {
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        
        if(self.isClear) {
            self.alpha = 1;
            self.hudView.alpha = 0;
        }
        
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                             
                             if(self.isClear) // handle iOS 7 UIToolbar not answer well to hierarchy opacity change
                                 self.hudView.alpha = 1;
                             else
                                 self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        
        [self setNeedsDisplay];
    }
}




- (void)dismiss {
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8, 0.8);
                         if(self.isClear) // handle iOS 7 UIToolbar not answer well to hierarchy opacity change
                             self.hudView.alpha = 0;
                         else
                             self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(self.alpha == 0 || self.hudView.alpha == 0) {
                             self.alpha = 0;
                             self.hudView.alpha = 0;
                             
                             [[NSNotificationCenter defaultCenter] removeObserver:self];
                             [self cancelRingLayerAnimation];
                             [_hudView removeFromSuperview];
                             _hudView = nil;
                             
                             [_overlayView removeFromSuperview];
                             _overlayView = nil;
                             
                             // Tell the rootViewController to update the StatusBar appearance
                             UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                             if ([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                                 [rootController setNeedsStatusBarAppearanceUpdate];
                             }
                         }
                     }];
}


#pragma mark - Ring progress animation

- (CALayer*)indefiniteAnimatedLayer {
    if(!_indefiniteAnimatedLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        CGRect frame = CGRectMake(center.x-WUProgressRingRadius-WUProgressRingThickness,
                                  center.y-WUProgressRingRadius-WUProgressRingThickness,
                                  WUProgressRingRadius*2+WUProgressRingThickness,
                                  WUProgressRingRadius*2+WUProgressRingThickness);
        
        // mask image check
        UIImage *maskImage = [UIImage imageNamed:@"WUProgressViewMask@2x"];
        if (maskImage) {
            CGPoint arcCenter = CGPointMake(WUProgressRingRadius+WUProgressRingThickness/2, WUProgressRingRadius+WUProgressRingThickness/2);
            UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                        radius:WUProgressRingRadius
                                                                    startAngle:-M_PI_2 + M_PI*0.05
                                                                      endAngle:-M_PI_2 - M_PI*0.05
                                                                     clockwise:YES];
            
            CAShapeLayer *slice = [CAShapeLayer layer];
            slice.contentsScale = [[UIScreen mainScreen] scale];
            slice.frame = frame;
            slice.fillColor = [UIColor clearColor].CGColor;
            slice.strokeColor = self.tintColor.CGColor;
            slice.lineWidth = WUProgressRingThickness;
            slice.lineCap = kCALineCapRound;
            slice.lineJoin = kCALineJoinBevel;
            slice.path = smoothedPath.CGPath;
            slice.masksToBounds = YES;
            
            _indefiniteAnimatedLayer = slice;
            
            CALayer *maskLayer = [CALayer layer];
            maskLayer.contents = (id)[maskImage CGImage];
            maskLayer.frame = slice.bounds;
            
            _indefiniteAnimatedLayer.mask = maskLayer;
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            animation.fromValue = 0;
            animation.toValue = [NSNumber numberWithFloat:M_PI*2];
            animation.duration = 1;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.removedOnCompletion = NO;
            animation.repeatCount = INFINITY;
            animation.fillMode = kCAFillModeForwards;
            animation.autoreverses = NO;
            [_indefiniteAnimatedLayer addAnimation:animation forKey:@"rotate"];
        } else {
            if (self.indicator) {
                [self.indicator removeFromSuperview];
            }
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicator.frame = frame;
            activityIndicator.color = [UIColor grayColor];
            self.indicator = activityIndicator;
            [(UIActivityIndicatorView *)activityIndicator startAnimating];
            [self addSubview:activityIndicator];
            _indefiniteAnimatedLayer = activityIndicator.layer;
        }
        
    }
    return _indefiniteAnimatedLayer;
}

- (CAShapeLayer *)ringLayer {
    if(!_ringLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        _ringLayer = [self createRingLayerWithCenter:center
                                              radius:WUProgressRingRadius
                                           lineWidth:WUProgressRingThickness
                                               color:self.tintColor];
        [self.hudView.layer addSublayer:_ringLayer];
    }
    return _ringLayer;
}

- (CAShapeLayer *)backgroundRingLayer {
    if(!_backgroundRingLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        _backgroundRingLayer = [self createRingLayerWithCenter:center
                                                        radius:WUProgressRingRadius
                                                     lineWidth:WUProgressRingThickness
                                                         color:[self.tintColor colorWithAlphaComponent:0.1]];
        _backgroundRingLayer.strokeEnd = 1;
        [self.hudView.layer addSublayer:_backgroundRingLayer];
    }
    return _backgroundRingLayer;
}

- (void)cancelRingLayerAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_hudView.layer removeAllAnimations];
    
    _ringLayer.strokeEnd = 0.0f;
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
    }
    _ringLayer = nil;
    
    if (_backgroundRingLayer.superlayer) {
        [_backgroundRingLayer removeFromSuperlayer];
    }
    _backgroundRingLayer = nil;
    
    [CATransaction commit];
}

- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    
    UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI_2 endAngle:(M_PI + M_PI_2) clockwise:YES];
    
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.contentsScale = [[UIScreen mainScreen] scale];
    slice.frame = CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineCapRound;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    return slice;
}

#pragma mark - Utilities

+ (BOOL)isVisible {
    return ([self sharedView].alpha == 1);
}


#pragma mark - Getters

- (NSTimeInterval)displayDurationForString:(NSString*)string {
    return MIN((float)string.length*0.06 + 0.3, 5.0);
}

- (BOOL)isClear { // used for iOS 7
    return YES;
}

- (UIControl *)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f];
        [_overlayView addTarget:self action:@selector(overlayViewDidTouchAction:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _overlayView;
}

- (UIView *)hudView {
    if(!_hudView) {
        _hudView = [[UIToolbar alloc] initWithFrame:CGRectZero];
        ((UIToolbar *)_hudView).translucent = YES;
        ((UIToolbar *)_hudView).barTintColor = self.backgroundColor;
        
        _hudView.layer.cornerRadius = 14;
        _hudView.layer.masksToBounds = YES;
        
        _hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.x" type: UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        effectX.minimumRelativeValue = @(-WUProgressParallaxDepthPoints);
        effectX.maximumRelativeValue = @(WUProgressParallaxDepthPoints);
        
        UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.y" type: UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        effectY.minimumRelativeValue = @(-WUProgressParallaxDepthPoints);
        effectY.maximumRelativeValue = @(WUProgressParallaxDepthPoints);
        
        [_hudView addMotionEffect: effectX];
        [_hudView addMotionEffect: effectY];
        
        [self addSubview:_hudView];
    }
    return _hudView;
}

- (UILabel *)stringLabel {
    if (_stringLabel == nil) {
        _stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_stringLabel.backgroundColor = [UIColor clearColor];
		_stringLabel.adjustsFontSizeToFitWidth = YES;
        _stringLabel.textAlignment = NSTextAlignmentCenter;
		_stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		_stringLabel.textColor = self.tintColor;
		_stringLabel.font = self.statusFont;
        _stringLabel.numberOfLines = 0;
    }
    
    if(!_stringLabel.superview)
        [self.hudView addSubview:_stringLabel];
    
    return _stringLabel;
}

- (UIImageView *)imageView {
    if (_imageView == nil)
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    
    if(!_imageView.superview)
        [self.hudView addSubview:_imageView];
    
    return _imageView;
}


- (CGFloat)visibleKeyboardHeight {
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")])
            return possibleKeyboard.bounds.size.height;
    }
    
    return 0;
}

@end
