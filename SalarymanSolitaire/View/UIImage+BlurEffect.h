//
//  UIImage+BlurEffect.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-30.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BlurEffect)
-(UIImage *)blurImageWithBlur:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath;
@end
