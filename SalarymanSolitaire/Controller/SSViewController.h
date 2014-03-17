//
//  SSViewController.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSViewController : UIViewController<ADBannerViewDelegate>
{
    
}

// 画面初期設定
- (void)setup;

// 広告表示可否
- (BOOL)shouldShowADBanner;
@end
