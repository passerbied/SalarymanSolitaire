//
//  UIImage+MainBundleImage.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-2.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "UIImage+MainBundleImage.h"

@implementation UIImage (MainBundleImage)

+ (UIImage *)temporaryImageNamed:(NSString *)name;
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
    return [UIImage imageWithContentsOfFile:path];
}

@end
