//
//  UIButton+UIImage.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "UIButton+UIImage.h"

@implementation UIButton (UIImage)

+ (id)buttonWithImage:(NSString *)imageName
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *normalImageName = [NSString stringWithFormat:@"%@.png", imageName];
    UIImage *imageNormal = [UIImage imageNamed:normalImageName];
    [button setImage:imageNormal forState:UIControlStateNormal];
    
    NSString *hilightImageName = [NSString stringWithFormat:@"%@_on.png", imageName];
    UIImage *imageHighlighted = [UIImage imageNamed:hilightImageName];
    [button setImage:imageHighlighted forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0.0f, 0.0f, imageNormal.size.width, imageNormal.size.height);
    return button;
}
@end
