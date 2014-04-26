//
//  SSViewController.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+UIImage.h"
#import "AudioEngine.h"
#import "SSAlertView.h"

@interface SSViewController : UIViewController<SSAlertViewDelegate>
{
    
}

// 初期化方法
+ (instancetype)controller;

// 画面初期設定
- (void)initView;

// レイアウト設定
- (void)layoutSubviewsForPhone4;

// 画面表示更新
- (void)updateView;

// バナー広告表示可否
- (BOOL)shouldShowBannerAD;

@end

@interface UIDevice (iPhone5)

+ (BOOL)isPhone5;
@end

typedef enum
{
    SolitaireAudioIDButtonClicked,
    SolitaireAudioIDMainMusic,
    SolitaireAudioIDPlayMusic,
    SolitaireAudioIDCardPut,
    SolitaireAudioIDCardDeal,
    SolitaireAudioIDCardMove,
    SolitaireAudioIDClear
} SolitaireAudioID;

@interface AudioEngine (Solitaire)

+ (void)playAudioWith:(SolitaireAudioID)audioID;
@end