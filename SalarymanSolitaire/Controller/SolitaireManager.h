//
//  SolitaireManager.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
@interface SolitaireManager : NSObject

// 初期化
+ (instancetype)sharedManager;

// 初回起動チェック
- (BOOL)isFirstTime;

// 初回起動設定
- (void)setFirstTimePlay;

// 共有広告ビュー
- (ADBannerView *)sharedADBannerView;


@end
