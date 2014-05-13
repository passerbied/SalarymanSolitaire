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

// 時間
@property (nonatomic) NSTimeInterval duration;

// 体力値変化
- (void)powerUp:(BOOL)up;

// 体力値をすべて回復する
- (void)recovery;

// 体力有無チェック
- (BOOL)isPowerOFF;
@end
