//
//  WUPopupView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-30.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "WUPopupView.h"

@interface WUPopupView ()
{
    // 表示サイズ
    CGSize                              _popupSize;
}

// ポップアップビュー
@property (nonatomic, strong) UIWindow *popupWindow;

// ブラービュー
@property (nonatomic, strong) UIView *blurView;
@end

@implementation WUPopupView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _top = NSIntegerMin;
    }
    return self;
}
// ポップアップ
- (void)show;
{
    // 背景ビュー作成
    if (!_popupWindow) {
        _popupWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _popupWindow.windowLevel = UIWindowLevelAlert;
        _popupWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    }
    
    self.view.alpha = 0.0;
    _popupWindow.alpha = 0.0;
    
    // アニメーション
    NSTimeInterval duration = 0.3f;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = duration;
    [self.view.layer addAnimation:animation forKey:@"PopupShow"];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.alpha = 1.0;
        _popupWindow.alpha = 1.0;
    } completion:^(BOOL finished) {

    }];
    
    _popupSize = self.view.bounds.size;
    [_popupWindow addSubview:self.view];
    _popupWindow.rootViewController = self;
    [_popupWindow makeKeyAndVisible];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect parentRect = _popupWindow.bounds;
    CGFloat dx = (parentRect.size.width - _popupSize.width)/2.0f;
    CGFloat dy = (parentRect.size.height - _popupSize.height)/2.0f;
    CGRect rect = CGRectInset(parentRect, dx, dy);
    if (_top > 0) {
        rect.origin.y = _top;
    }
    self.view.frame = rect;
}

// 閉じる
- (void)dismiss;
{
    NSTimeInterval duration = 0.2f;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeRemoved;
    animation.duration = duration;
    [self.view.layer addAnimation:animation forKey:@"PopupDismiss"];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.alpha = 0;
        _popupWindow.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [_popupWindow removeFromSuperview];
        _popupWindow = nil;
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                [window makeKeyAndVisible];
                break;
            }
        }
    }];
}
@end
