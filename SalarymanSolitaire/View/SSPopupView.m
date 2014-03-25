//
//  SSPopupView.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-9.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPopupView.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

// 背景イメージ定義
#define __POPUP_BG_IMAGE                @"popup_frame.png"

/* 閉じるボタン定義 */

// ボタンイメージ
#define __POPUP_CLOSE_IMAGE_NORMAL      @"popup_btn_close.png"

// 表示位置
#define __BUTTON_CLOSE_OFFSET_TOP       15.0f
#define __BUTTON_CLOSE_SPACE_RIGHT      50.0f

/* コンテンツビュー */
#define __POPUP_CONTENT_MARGIN          6.5f
#define __POPUP_CONTENT_OFFSET_TOP      72.0f

@implementation UIView (Screenshot)

- (UIImage *)screenShotImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

@end

@implementation UIImage (Blur)

-(UIImage *)blurImageWithBlur:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    // create unchanged copy of the area inside the exclusionPath
    UIImage *unblurredImage = nil;
    if (exclusionPath != nil) {
        CAShapeLayer *maskLayer = [CAShapeLayer new];
        maskLayer.frame = (CGRect){CGPointZero, self.size};
        maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        maskLayer.fillColor = [UIColor whiteColor].CGColor;
        maskLayer.path = exclusionPath.CGPath;
        
        // create grayscale image to mask context
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big;
        
        CGContextRef context = CGBitmapContextCreate(nil, maskLayer.bounds.size.width, maskLayer.bounds.size.height, 8, 0, colorSpace, bitmapInfo);
        CGContextTranslateCTM(context, 0, maskLayer.bounds.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        [maskLayer renderInContext:context];
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        UIImage *maskImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        
        UIGraphicsBeginImageContext(self.size);
        context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, maskLayer.bounds.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        CGContextClipToMask(context, maskLayer.bounds, maskImage.CGImage);
        CGContextDrawImage(context, maskLayer.bounds, self.CGImage);
        unblurredImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
    NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             bitmapInfo);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    // overlay images?
    if (unblurredImage != nil) {
        UIGraphicsBeginImageContext(returnImage.size);
        [returnImage drawAtPoint:CGPointZero];
        [unblurredImage drawAtPoint:CGPointZero];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end

@interface SSPopupView ()
{
    // 閉じるボタン
    UIButton                            *_btnClose;
    
    // 表題イメージビュー
    UIImageView                         *_titleImageView;

}
@end

@implementation SSPopupView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}
- (void)initView
{
    _blurLevel = 0.3f;
    _animationDuration = 0.25f;
    _backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    _bounces = YES;
    
    // 背景
    UIImage *bgImage = [UIImage imageNamed:__POPUP_BG_IMAGE];
    CGRect rect = self.view.bounds;
    CGFloat x = (rect.size.width - bgImage.size.width)/2.0f;
    CGFloat y = (rect.size.height - bgImage.size.height)/2.0f;
    _popView = [[UIView alloc] initWithFrame:CGRectMake(x, y, bgImage.size.width, bgImage.size.height)];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgImageView.backgroundColor = [UIColor clearColor];
    [_popView addSubview:bgImageView];
    _popView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    // ボタン「閉じる」作成
    if (!_btnClose) {
        UIImage *image = nil;
        image = [UIImage imageNamed:__POPUP_CLOSE_IMAGE_NORMAL];
        
        _btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnClose setImage:image forState:UIControlStateNormal];
        [_btnClose addTarget:self
                      action:@selector(closeAction:)
            forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat x = bgImage.size.width - __BUTTON_CLOSE_SPACE_RIGHT;
        CGFloat y = __BUTTON_CLOSE_OFFSET_TOP;
        CGRect frame = CGRectMake(x, y, image.size.width, image.size.height);
        _btnClose.frame = frame;
        [_btnClose addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.popView addSubview:_btnClose];
    }
    
//    // 表題イメージビュー作成
//    if (!_titleImageView) {
//        _titleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        [self.popView addSubview:_titleImageView];
//    }
//    
//    // 表題イメージ設定
//    if (_titleImage && !_titleImageView.image) {
//        _titleImageView.image = _titleImage;
//        
//        CGFloat x, y, width, height;
//        width = _titleImage.size.width;
//        height = _titleImage.size.height;
//        
//        x = (self.view.bounds.size.width - _btnClose.bounds.size.width/2.0f - __BUTTON_CLOSE_SPACE_RIGHT - width)/2.0f;
//        y = __BUTTON_CLOSE_OFFSET_TOP + _btnClose.bounds.size.height/2.0f;
//        
//        _titleImageView.frame = CGRectMake(x, y, width, height);
//    }
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.popView.backgroundColor = self.backgroundColor;
    self.popView.opaque = NO;
    self.popView.clipsToBounds = YES;
    
    CGFloat m34 = 1 / 300.f;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34;
    self.popView.layer.transform = transform;
//    self.popView.layer.cornerRadius = self.cornerRadius;
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.blurView.frame = bounds;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if ([self isViewLoaded] && self.view.window != nil) {
        [self createScreenshotAndLayoutWithScreenshotCompletion:nil];
    }
}

- (void)closeAction:(id)sender
{
    [self dismiss];
}

// コンテンツサイズ
- (CGRect)popupContentRect;
{
    CGFloat x,y,width,height;
    x = __POPUP_CONTENT_MARGIN;
    y = __POPUP_CONTENT_OFFSET_TOP;
    width = self.popView.bounds.size.width - 2*__POPUP_CONTENT_MARGIN;
    height = self.popView.bounds.size.height - __POPUP_CONTENT_MARGIN - __POPUP_CONTENT_OFFSET_TOP - 10;
    return CGRectMake(x, y, width, height);
}

// 画面表示
- (void)showInViewController:(UIViewController *)parentViewController center:(CGPoint)center;
{
    NSParameterAssert(parentViewController != nil);
    
    [self addToParentViewController:parentViewController];
    self.menuCenter = [self.view convertPoint:center toView:self.view];
    self.view.frame = parentViewController.view.bounds;
    
    [self showAnimated:YES];
}

- (void)showAnimated:(BOOL)animated
{
    self.blurView = [[UIView alloc] initWithFrame:self.parentViewController.view.bounds];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blurView];
    [self.view addSubview:self.popView];
    
    [self createScreenshotAndLayoutWithScreenshotCompletion:^{
        if (animated) {
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = @0.;
            opacityAnimation.toValue = @1.;
            opacityAnimation.duration = self.animationDuration * 0.5f;
            
            CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            
            CATransform3D startingScale = CATransform3DScale(self.popView.layer.transform, 0, 0, 0);
            CATransform3D overshootScale = CATransform3DScale(self.popView.layer.transform, 1.05, 1.05, 1.0);
            CATransform3D undershootScale = CATransform3DScale(self.popView.layer.transform, 0.98, 0.98, 1.0);
            CATransform3D endingScale = self.popView.layer.transform;
            
            NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startingScale]];
            NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
            NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            
            if (self.bounces) {
                [scaleValues addObjectsFromArray:@[[NSValue valueWithCATransform3D:overshootScale], [NSValue valueWithCATransform3D:undershootScale]]];
                [keyTimes addObjectsFromArray:@[@0.5f, @0.85f]];
                [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            }
            
            [scaleValues addObject:[NSValue valueWithCATransform3D:endingScale]];
            [keyTimes addObject:@1.0f];
            [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            scaleAnimation.values = scaleValues;
            scaleAnimation.keyTimes = keyTimes;
            scaleAnimation.timingFunctions = timingFunctions;
            
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.animations = @[scaleAnimation, opacityAnimation];
            animationGroup.duration = self.animationDuration;
            
            [self.popView.layer addAnimation:animationGroup forKey:nil];
        }
    }];
}

- (void)dismiss
{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1.;
    opacityAnimation.toValue = @0.;
    opacityAnimation.duration = self.animationDuration;
    [self.blurView.layer addAnimation:opacityAnimation forKey:nil];
    
    CATransform3D transform = CATransform3DScale(self.popView.layer.transform, 0, 0, 0);
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:self.popView.layer.transform];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:transform];
    scaleAnimation.duration = self.animationDuration;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[opacityAnimation, scaleAnimation];
    animationGroup.duration = self.animationDuration;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.popView.layer addAnimation:animationGroup forKey:nil];
    
    self.blurView.layer.opacity = 0;
    self.popView.layer.transform = transform;

    self.view.hidden = YES;
    
    if ([self.parentViewController.view respondsToSelector:@selector(setScrollEnabled:)] && [(UIScrollView *)self.parentViewController.view isScrollEnabled]) {
        [(UIScrollView *)self.parentViewController.view setScrollEnabled:YES];
    }
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)addToParentViewController:(UIViewController *)parentViewController
{
    if (self.parentViewController != nil) {
        [self removeFromParentViewController];
    }
    
    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:self.view];
    [self didMoveToParentViewController:self];
    
    if ([parentViewController.view respondsToSelector:@selector(setScrollEnabled:)] && [(UIScrollView *)parentViewController.view isScrollEnabled]) {
        [(UIScrollView *)parentViewController.view setScrollEnabled:NO];
    }
}

//- (void)removeFromParentViewController
//{
//    if ([self.parentViewController.view respondsToSelector:@selector(setScrollEnabled:)] && [(UIScrollView *)self.parentViewController.view isScrollEnabled]) {
//        [(UIScrollView *)self.parentViewController.view setScrollEnabled:YES];
//    }
//    
//    [self willMoveToParentViewController:nil];
//    [self.view removeFromSuperview];
//    [self removeFromParentViewController];
//}

- (void)createScreenshotAndLayoutWithScreenshotCompletion:(dispatch_block_t)screenshotCompletion
{
    if (self.blurLevel > 0.f) {
        self.blurView.alpha = 0.f;
        
        self.popView.alpha = 0.f;
        UIImage *screenshot = [self.parentViewController.view screenShotImage];
        self.popView.alpha = 1.f;
        self.blurView.alpha = 1.f;
        self.blurView.layer.contents = (id)screenshot.CGImage;
        
        if (screenshotCompletion != nil) {
            screenshotCompletion();
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            UIImage *blur = [screenshot blurImageWithBlur:self.blurLevel exclusionPath:self.blurExclusionPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *transition = [CATransition animation];
                
                transition.duration = 0.2;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                
                [self.blurView.layer addAnimation:transition forKey:nil];
                self.blurView.layer.contents = (id)blur.CGImage;
                
                [self.view setNeedsLayout];
                [self.view layoutIfNeeded];
            });
        });
    }
}

@end
