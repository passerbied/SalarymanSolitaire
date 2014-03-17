//
//  WUProgressView.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

@interface WUProgressView : UIView

/**
 * @brief 初始化活动指示器.
 * @return 活动指示器.
 */
+ (WUProgressView *)sharedView;

/**
 * @brief 设置活动指示器标题的字体.
 */
@property (nonatomic, strong) UIFont *statusFont;

/**
 * @brief 设置活动指示器的背景颜色,默认为白色.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 * @brief 设置活动指示器显示的最短时间,默认为<i> 0秒 </i>.
 */
@property (nonatomic, assign) float minShowTime;

/** @name 活动指示器参数设置. */
/**
 * @brief 设置活动指示器显示位置的偏移坐标,默认为居中显示.
 * @param 活动指示器显示位置的偏移坐标.
 */
+ (void)setOffsetFromCenter:(UIOffset)offset;

/**
 * @brief 重置活动指示器显示位置的偏移坐标,重置后局中显示.
 */
+ (void)resetOffsetFromCenter;

/**
 * @brief 当活动指示器处于显示状态时,可以设置活动指示器的标题.
 * @param status 活动指示器的标题.
 */
+ (void)setStatus:(NSString *)string;

/**
 * @brief 设置当活动指示器处于显示状态时,背景是否变暗.默认下自动变暗.
 * @param enabled 背景自动变暗<i> YES </i>,否则<i> NO </i>..
 */
+ (void)setDimBackgroundEnabled:(BOOL)enabled;

/**
 * @brief 设置当活动指示器处于显示状态时,背景是否可以点击.默认下不可点击.
 * @param enabled 背景可以点击<i> YES </i>,否则<i> NO </i>..
 */
+ (void)setAllowUserInteraction:(BOOL)enabled;

/** @name 活动指示器显示／隐藏. */
/**
 * @brief 显示没有标题的活动指示器.
 */
+ (void)show;

/**
 * @brief 显示带有标题的活动指示器.
 * @param status 进度显示器的标题.
 */
+ (void)showWithStatus:(NSString *)status;

/**
 * @brief 显示带有进度的活动指示器.
 * @param status 进度显示器的标题.
 */
+ (void)showProgress:(float)progress;

/**
 * @brief 显示带有进度和标题的活动指示器.
 * @param status 进度显示器的标题.
 */
+ (void)showProgress:(float)progress status:(NSString *)status;

/**
 * @brief 隐藏活动指示器.
 */
+ (void)dismiss;

/**
 * @brief 延迟隐藏活动指示器.
 * @param delay 延迟时间,单位(秒).
 */
+ (void)dismissAfterDelay:(NSTimeInterval)delay;

/**
 * @brief 判断活动指示器是否处于显示状态.
 * @return 显示状态返回<i> YES </i>,否则返回<i> NO </i>.
 */
+ (BOOL)isVisible;

@end


// 活动指示器通知定义[点击]
extern NSString * const WUProgressDidTouchNotification;
