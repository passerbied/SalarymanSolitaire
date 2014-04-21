//
//  PopupViewController.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "PopupViewController.h"

@interface PopupViewController ()
{

}

@property (nonatomic, strong) NSString *popupNibName;

// コンテナビュー
@property (nonatomic, strong) UIView *backgroundView;

// ポープアップビュー
@property (nonatomic, strong) IBOutlet UIView *popupView;

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, assign) CGFloat animationDuration;

- (IBAction)dismissAction:(id)sender;
@end

@implementation PopupViewController

- (id)initPopupViewWithNibName:(NSString *)nibName;
{
    self = [self init];
    if (self) {
        self.popupNibName = nibName;
        _blurEnabled = YES;
        _animationDuration = 0.25f;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setClipsToBounds:YES];
    self.view.backgroundColor = [UIColor clearColor];
    if (!_popupView) {
        // コンテナビュー
        if (_blurEnabled) {
            _backgroundView = [[UIToolbar alloc] initWithFrame:self.view.bounds];
        } else {
            _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
            _backgroundView.backgroundColor = [UIColor clearColor];
        }
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:_backgroundView atIndex:0];

        _backgroundView.alpha = 0.0f;
        [_backgroundView setClipsToBounds:YES];
        
        // ポップアップビュー
        [[NSBundle mainBundle] loadNibNamed:self.popupNibName owner:self options:nil];
        _popupView.clipsToBounds = YES;
        _popupView.backgroundColor = [UIColor clearColor];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [_backgroundView addSubview:_popupView];
    
        [_popupView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];

        
        [_popupView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_backgroundImageView]-0-|"
                                                                           options:0
                                                                           metrics:0
                                                                             views:NSDictionaryOfVariableBindings(_backgroundImageView)]];
        [_popupView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_backgroundImageView]-0-|"
                                                                           options:0
                                                                           metrics:0
                                                                             views:NSDictionaryOfVariableBindings(_backgroundImageView)]];
        CGSize size = _backgroundImageView.image.size;
        CGFloat dx = (self.view.bounds.size.width - size.width)/2.0f;
        CGFloat dy = (self.view.bounds.size.height - size.height)/2.0f;
        NSString *horizontalConstraint = [NSString stringWithFormat:@"H:|-%f-[_popupView]-%f-|", dx, dx];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraint
                                                                          options:0
                                                                          metrics:0
                                                                            views:NSDictionaryOfVariableBindings(_popupView)]];
        NSString *verticalConstraint = [NSString stringWithFormat:@"V:|-%f-[_popupView]-%f-|", dy, dy];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint
                                                                          options:0
                                                                          metrics:0
                                                                            views:NSDictionaryOfVariableBindings(_popupView)]];
        
        [self _executePresentAnimation];
    }
}

- (void)_executePresentAnimation
{
    _backgroundView.alpha = 1.0f;
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @0.0f;
    opacityAnimation.toValue = @1.0f;
    opacityAnimation.duration = _animationDuration * 0.5f;
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D startingScale = CATransform3DScale(_popupView.layer.transform, 0, 0, 0);
    CATransform3D overshootScale = CATransform3DScale(_popupView.layer.transform, 1.05, 1.05, 1.0);
    CATransform3D undershootScale = CATransform3DScale(_popupView.layer.transform, 0.98, 0.98, 1.0);
    CATransform3D endingScale = _popupView.layer.transform;
    
    NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startingScale]];
    NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
    NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [scaleValues addObjectsFromArray:@[[NSValue valueWithCATransform3D:overshootScale], [NSValue valueWithCATransform3D:undershootScale]]];
    [keyTimes addObjectsFromArray:@[@0.5f, @0.85f]];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [scaleValues addObject:[NSValue valueWithCATransform3D:endingScale]];
    [keyTimes addObject:@1.0f];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    scaleAnimation.values = scaleValues;
    scaleAnimation.keyTimes = keyTimes;
    scaleAnimation.timingFunctions = timingFunctions;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation, opacityAnimation];
    animationGroup.duration = _animationDuration;
    
    [_popupView.layer addAnimation:animationGroup forKey:nil];
}

- (IBAction)dismissAction:(id)sender;
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeRemoved;
    animation.duration = _animationDuration;
    [self.view.layer addAnimation:animation forKey:@"dismiss"];
    
    [UIView animateWithDuration:_animationDuration animations:^{
        self.view.alpha = 0;
        _popupView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

// ポップパップ表示
- (void)popupInViewController:(UIViewController *)controller;
{
    if (!controller) {
        return;
    }
    
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
}
@end
