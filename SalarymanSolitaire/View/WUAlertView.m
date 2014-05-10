//
//  WUAlertView.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-9.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "WUAlertView.h"

@interface WUAlertViewStack : NSObject

@property (nonatomic) NSMutableArray *alertViews;

+ (WUAlertViewStack *)sharedInstance;

- (void)push:(WUAlertView *)alertView;
- (void)pop:(WUAlertView *)alertView;

@end

static const CGFloat AlertViewWidth = 300.0;
static const CGFloat AlertViewHeight = 190.0;
static const CGFloat AlertViewContentMargin = 10.0;
static const CGFloat AlertViewContentMarginTop = 20.0;
static const CGFloat AlertViewVerticalElementSpace = 25.0;
static const CGFloat AlertViewButtonMargin = 20.0;
static const CGFloat AlertViewButtonMarginBottom = 15.0;

@interface WUAlertView ()
{

}

@property (nonatomic) UIWindow *mainWindow;
@property (nonatomic) UIWindow *alertWindow;
@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) UIView *alertView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) UITapGestureRecognizer *tap;

@end

@implementation WUAlertView

- (UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.windowLevel == windowLevel) {
            return window;
        }
    }
    return nil;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
{
    self = [self init];
    if (self) {
        _mainWindow = [self windowWithLevel:UIWindowLevelNormal];
        _alertWindow = [self windowWithLevel:UIWindowLevelAlert];
        self.view.multipleTouchEnabled = NO;
        self.view.exclusiveTouch = YES;
        
        if (!_alertWindow) {
            _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _alertWindow.windowLevel = UIWindowLevelAlert;
            _alertWindow.backgroundColor = [UIColor clearColor];
        }
        _alertWindow.rootViewController = self;
        
        CGRect frame = [self frameForOrientation:self.interfaceOrientation];
        self.view.frame = frame;
        
        _backgroundView = [[UIView alloc] initWithFrame:frame];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        _backgroundView.alpha = 0;
        [self.view addSubview:_backgroundView];
        
        CGFloat dx = (frame.size.width - AlertViewWidth)/2.0f;
        CGFloat dy = (frame.size.height - AlertViewHeight)/2.0f;
        _alertView = [[UIView alloc] initWithFrame:CGRectInset(frame, dx, dy)];
        _alertView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
        _alertView.layer.cornerRadius = 12.0;
        _alertView.layer.opacity = .95;
        _alertView.clipsToBounds = YES;
        UIImage *image = [UIImage imageNamed:@"popup_alert.png"];
        _backgroundImageView = [[UIImageView alloc] initWithImage:image];
        _backgroundImageView.frame = _alertView.bounds;
        [_alertView insertSubview:_backgroundImageView atIndex:0];
        
        _alertView.center = [self centerWithFrame:frame];
        [self.view addSubview:_alertView];
        
        // Title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(AlertViewContentMargin,
                                                                AlertViewContentMarginTop,
                                                                AlertViewWidth - AlertViewContentMargin*2,
                                                                44)];
        _titleLabel.text = title;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        
        _titleLabel.textColor = SSColorText;
        _titleLabel.frame = [self adjustLabelFrameHeight:self.titleLabel title:YES];
        [_alertView addSubview:_titleLabel];
        
        CGFloat messageLabelY = _titleLabel.frame.origin.y + _titleLabel.frame.size.height + AlertViewVerticalElementSpace;
        
        // Message
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(AlertViewContentMargin,
                                                                  messageLabelY,
                                                                  AlertViewWidth - AlertViewContentMargin*2,
                                                                  44)];
        _messageLabel.text = message;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0;
        _titleLabel.font = SSGothicProFont(15);
        _titleLabel.textColor = SSColorText;
        _messageLabel.frame = [self adjustLabelFrameHeight:self.messageLabel title:NO];
        [_alertView addSubview:_messageLabel];        
    }
    return self;
}

- (void)setAlertTitle:(NSString *)alertTitle
{
    _alertTitle = alertTitle;
    _titleLabel.text = alertTitle;
    _titleLabel.frame = [self adjustLabelFrameHeight:self.titleLabel title:YES];
    if ([_alertTitle length]) {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_alertTitle];
        NSRange range = NSMakeRange(0, [_alertTitle length]);
        [attrString addAttribute:NSFontAttributeName value:SSGothicProFont(18) range:range];
        [attrString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:8.0f] range:range];
        [attrString addAttribute:NSStrokeColorAttributeName value:SSColorText range:range];
        _titleLabel.attributedText = attrString;
    } else {
        _titleLabel.text = alertTitle;
    }
}

- (void)setAlertMessage:(NSString *)alertMessage
{
    _alertMessage = alertMessage;
    _messageLabel.text = alertMessage;
    _messageLabel.frame = [self adjustLabelFrameHeight:self.messageLabel title:NO];
    if ([_alertMessage length]) {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_alertMessage];
        NSRange range = NSMakeRange(0, [_alertMessage length]);
        [attrString addAttribute:NSFontAttributeName value:SSGothicProFont(15) range:range];
        [attrString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:7.0f] range:range];
        [attrString addAttribute:NSStrokeColorAttributeName value:SSColorText range:range];
        _messageLabel.attributedText = attrString;
    } else {
        _messageLabel.text = _alertMessage;
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = backgroundImage;
}
- (CGRect)frameForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect frame;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
    } else {
        frame = [UIScreen mainScreen].bounds;
    }
    return frame;
}

- (CGRect)adjustLabelFrameHeight:(UILabel *)label title:(BOOL)title
{
    CGFloat height;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    context.minimumScaleFactor = 1.0;
    
    UIFont *font;
    CGFloat width;
    
    if (title) {
        font = SSGothicProFont(18);
        width = 8.0f;
    } else {
        font = SSGothicProFont(15);
        width = 7.0f;
    }
    CGRect bounds = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:font,
                                                       NSStrokeWidthAttributeName:[NSNumber numberWithFloat:width]
                                                       }
                                             context:context];
    height = bounds.size.height;
    
    return CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, height);
}

- (CGPoint)centerWithFrame:(CGRect)frame
{
    return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) - [self statusBarOffset]);
}

- (CGFloat)statusBarOffset
{
    CGFloat statusBarOffset = 0;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        statusBarOffset = 20;
    }
    return statusBarOffset;
}

- (void)show
{
    // Adjust frame
    if (![_messageLabel.text length]) {
        CGRect frame = self.titleLabel.frame;
        frame.origin.y += AlertViewContentMargin*2;
        self.titleLabel.frame = frame;
        
        for (UIButton *button in self.buttons) {
            frame = button.frame;
            frame.origin.y -= AlertViewContentMargin*3;
            button.frame = frame;
        }
    }
    [[WUAlertViewStack sharedInstance] push:self];
}

- (void)showInternal
{
    [self.alertWindow addSubview:self.view];
    [self.alertWindow makeKeyAndVisible];
    self.visible = YES;
    [self showBackgroundView];
    [self showAlertAnimation];
}

- (void)showBackgroundView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        [self.mainWindow tintColorDidChange];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 1;
    }];
}

- (void)hide
{
    [self.view removeFromSuperview];
}

// 警告画面非表示
- (void)dismiss;
{
    [self dismiss:nil animated:YES];
}

- (void)dismiss:(id)sender
{
    [self dismiss:sender animated:YES];
}

- (void)dismiss:(id)sender animated:(BOOL)animated
{
    self.visible = NO;
    
    if ([[[WUAlertViewStack sharedInstance] alertViews] count] == 1) {
        if (animated) {
            [self dismissAlertAnimation];
        }
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [self.mainWindow tintColorDidChange];
        }
        [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
            self.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.alertWindow removeFromSuperview];
            self.alertWindow = nil;
            [self.mainWindow makeKeyAndVisible];
        }];
    }
    
    [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
        self.alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [[WUAlertViewStack sharedInstance] pop:self];
        [self.view removeFromSuperview];
    }];
}

- (void)showAlertAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [self.alertView.layer addAnimation:animation forKey:@"showAlert"];
}

- (void)dismissAlertAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeRemoved;
    animation.duration = .2;
    
    [self.alertView.layer addAnimation:animation forKey:@"dismissAlert"];
}

#pragma mark -
#pragma mark UIViewController

- (BOOL)prefersStatusBarHidden
{
	return [UIApplication sharedApplication].statusBarHidden;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = [self frameForOrientation:interfaceOrientation];
    self.backgroundView.frame = frame;
    self.alertView.center = [self centerWithFrame:frame];
}

#pragma mark -
#pragma mark Public

+ (instancetype)alertWithTitle:(NSString *)title
{
    WUAlertView *alert = [[self alloc] initWithTitle:title message:nil];
    return alert;
}

+ (instancetype)alertWithTitle:(NSString *)title
                           message:(NSString *)message
{
    WUAlertView *alert = [[self alloc] initWithTitle:title message:message];
    return alert;
}

// アクセサリー追加
- (void)addAccessoryView:(UIView *)view;
{
    [self.alertView addSubview:view];
}

- (void)addButton:(UIButton *)button;
{
    if (!_buttons) {
        _buttons = [NSMutableArray arrayWithCapacity:2];
    }
    NSInteger count = [_buttons count];
    button.tag = count + 1;
    
    CGFloat x,y;
    if (count) {
        x = AlertViewWidth - AlertViewButtonMargin - button.bounds.size.width;
    } else {
        x = AlertViewButtonMargin;
    }
    y = AlertViewHeight - AlertViewButtonMarginBottom - button.bounds.size.height;
    button.frame = CGRectMake(x, y, button.bounds.size.width, button.bounds.size.height);
    [_buttons addObject:button];
    [button addTarget:self action:@selector(didTouchUpInsideOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(didTouchDragEnterOnButton:) forControlEvents:UIControlEventTouchDragEnter];
    [button addTarget:self action:@selector(didTouchDragExitOnButton:) forControlEvents:UIControlEventTouchDragExit];
    [self.alertView addSubview:button];
}

- (void)didTouchUpInsideOnButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:button.tag];
        self.delegate = nil;
    }
    
    [self dismiss:button animated:YES];
}

- (void)didTouchDragEnterOnButton:(UIButton *)button
{
    
}

- (void)didTouchDragExitOnButton:(UIButton *)button
{

}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (buttonIndex >= 0 && buttonIndex < [self.buttons count]) {
        [self dismiss:self.buttons[buttonIndex] animated:animated];
    }
}

// 閉じるボタン表示制御
- (void)setCloseButtonHidden:(BOOL)hidden;
{
    if (!hidden && !_closeButton) {
        _closeButton = [UIButton buttonWithImage:@"popup_btn_close"];
        [_closeButton addTarget:self action:@selector(didTouchUpInsideOnButton:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton addTarget:self action:@selector(didTouchDragEnterOnButton:) forControlEvents:UIControlEventTouchDragEnter];
        [_closeButton addTarget:self action:@selector(didTouchDragExitOnButton:) forControlEvents:UIControlEventTouchDragExit];
        
        CGSize size = _closeButton.bounds.size;
        _closeButton.frame = CGRectMake(AlertViewWidth - AlertViewContentMargin - size.width, AlertViewContentMargin, size.width, size.height);
        _closeButton.tag = 0;
        [self.alertView addSubview:_closeButton];
    }
    self.closeButton.hidden = hidden;
}

- (void)setTapToDismissEnabled:(BOOL)enabled
{
    if (enabled && !_tap) {
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [self.tap setNumberOfTapsRequired:1];
        [self.backgroundView setUserInteractionEnabled:YES];
        [self.backgroundView setMultipleTouchEnabled:NO];
        [self.backgroundView addGestureRecognizer:self.tap];
    }
    self.tap.enabled = enabled;
}

@end

@implementation WUAlertViewStack

+ (instancetype)sharedInstance
{
    static WUAlertViewStack *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WUAlertViewStack alloc] init];
        _sharedInstance.alertViews = [NSMutableArray array];
    });
    
    return _sharedInstance;
}

- (void)push:(WUAlertView *)alertView
{
    [self.alertViews addObject:alertView];
    [alertView showInternal];
    for (WUAlertView *av in self.alertViews) {
        if (av != alertView) {
            [av hide];
        }
    }
}

- (void)pop:(WUAlertView *)alertView
{
    [self.alertViews removeObject:alertView];
    WUAlertView *last = [self.alertViews lastObject];
    if (last) {
        [last showInternal];
    }
}

@end

