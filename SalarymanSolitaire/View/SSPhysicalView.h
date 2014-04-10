//
//  SSPhysicalView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-16.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 体力ビュー
@interface SSPhysicalView : UIView

// 体力値
@property (nonatomic) NSInteger maxPower;
@property (nonatomic) NSInteger currentPower;

// 体力値変化
- (void)powerGrowthUp:(BOOL)up;
@end
