//
//  UIView+Screenshot.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-30.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "UIView+Screenshot.h"

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
