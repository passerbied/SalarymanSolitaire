//
//  SSFreePlayController.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSFreePlayController.h"

@interface SSFreePlayController ()

@end

@implementation SSFreePlayController


// ポーカー位置
- (CGRect)rectForPoker;
{
    CGRect rect = self.view.bounds;
    return CGRectInset(rect, 0.0f, 50.0f);
}
@end
