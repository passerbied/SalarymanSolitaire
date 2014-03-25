//
//  SSPopupView.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-9.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSViewController.h"

@protocol SSPopupViewDelegate;

@interface SSPopupView : UIViewController
{
    
}

//
@property (nonatomic, readonly) UIView *popView;
@property (nonatomic) UIView *blurView;
@property (nonatomic, assign) CGPoint menuCenter;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL bounces;
@property (strong, nonatomic) UIColor *backgroundColor;

@property (nonatomic, assign) CGFloat blurLevel;
@property (strong, nonatomic) UIBezierPath *blurExclusionPath;

// 表題イメージ
@property (strong, nonatomic) UIImage *titleImage;

// 委譲対象
@property (nonatomic, weak) id<SSPopupViewDelegate> delegate;

// コンテンツサイズ
- (CGRect)popupContentRect;

// 画面表示
- (void)showInViewController:(UIViewController *)parentViewController center:(CGPoint)center;

// 画面を隠す
- (void)dismiss;

@end

@protocol SSPopupViewDelegate <NSObject>


@end
