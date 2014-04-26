//
//  SSViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "SSAppDelegate.h"

@interface SSViewController ()<ADBannerViewDelegate>
{
    BOOL                                _layouted;
}

@end

@implementation SSViewController

// 初期化方法
+ (instancetype)controller;
{
    return [[self alloc] initWithNibName:nil bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 画面初期設定
    [self initView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!_layouted) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (![UIDevice isPhone5]) {
                // レイアウト設定
                [self layoutSubviewsForPhone4];
            }
        }
        _layouted = YES;
    }
}

// レイアウト設定
- (void)layoutSubviewsForPhone4;
{
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // バナー広告取得
    ADBannerView *bannerView = [[SolitaireManager sharedManager] sharedBannerAD];
    
    // 広告表示可否チェック
    if ([self shouldShowBannerAD]) {
        CGFloat y = self.view.bounds.size.height - bannerView.bounds.size.height;
        CGRect rect = CGRectMake(0.0f, y, bannerView.bounds.size.width, bannerView.bounds.size.height);
        bannerView.frame = rect;
        bannerView.delegate = self;
        bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:bannerView];

    } else {
        bannerView.delegate = nil;
        [bannerView removeFromSuperview];
    }
    
    // ナビゲートバー非表示
    self.navigationController.navigationBarHidden = YES;
    
    // 画面表示更新
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ステータスバー非表示
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// 画面初期設定
- (void)initView;
{

}

// 画面表示更新
- (void)updateView;
{

}

#pragma mark - バナー広告
// 広告表示可否
- (BOOL)shouldShowBannerAD;
{
    return YES;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    DebugLog(@"iAd Load");
    [UIView animateWithDuration:0.2f animations:^{
        banner.alpha = 1.0f;
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    DebugLog(@"iAd Failed");
    [UIView animateWithDuration:0.2f animations:^{
        banner.alpha = 1.0f;
    }];
}



@end


@implementation UIDevice (iPhone5)

+ (BOOL)isPhone5;
{
    static dispatch_once_t pred = 0;
    static BOOL _isPhone5 = NO;
    dispatch_once(&pred, ^{
        if (CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) {
            _isPhone5 = YES;
        }
    });
    return _isPhone5;
}
@end


@implementation AudioEngine (Solitaire)

+ (void)playAudioWith:(SolitaireAudioID)audioID;
{
    AudioEngineType engine;
    NSString *audioName = nil;
    switch (audioID) {
        case SolitaireAudioIDButtonClicked:
            // ボタン押下(閉じる、戻るボタン以外)
            audioName = @"button.mp3";
            engine = AudioEngineTypeEffect;
            break;
            
        case SolitaireAudioIDMainMusic:
            // 背景音声（プレイ画面以外）
            audioName = @"opening.mp3";
            engine = AudioEngineTypeBackground;
            break;
            
        case SolitaireAudioIDPlayMusic:
            // プレイ画面の背景音声
            audioName = @"play.mp3";
            engine = AudioEngineTypeBackground;
            break;
            
        case SolitaireAudioIDCardPut:
            // カードを置いた時
            audioName = @"put_card.mp3";
            engine = AudioEngineTypeEffect;
            break;
            
        case SolitaireAudioIDCardDeal:
            // カード配布時
            audioName = @"deal_card.caf";
            engine = AudioEngineTypeSerial;
            break;
            
        case SolitaireAudioIDCardMove:
            // カードを選択／移動する時
            audioName = @"move_card.mp3";
            engine = AudioEngineTypeEffect;
            break;
            
        case SolitaireAudioIDClear:
            // ゲームクリア時
            audioName = @"clear.mp3";
            engine = AudioEngineTypeEffect;
            break;
            
        default:
            break;
    }
    if (!audioName) {
        return;
    }
    
    [AudioEngine playAudioWithName:audioName engine:engine];
}

@end