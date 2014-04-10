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

@interface SSViewController : UIViewController
{
    
}

// 初期化方法
+ (instancetype)controller;

// 画面初期設定
- (void)initView;

// 画面表示更新
- (void)updateView;

// バナー広告表示可否
- (BOOL)shouldShowBannerAD;

// インタースティシャル広告表示
- (void)presentInterstitialAD;

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