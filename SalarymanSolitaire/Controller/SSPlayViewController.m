//
//  SSPlayViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPlayViewController.h"
#import "SSPhysicalView.h"
#import "SSNutrientButton.h"

NSString *const SolitaireWillResumeGameNotification = @"SolitaireWillResumeGameNotification";
NSString *const SolitaireWillPauseGameNotification = @"SolitaireWillPauseGameNotification";

#define kSolitairePokerColours          4
#define kSolitairePokerCount            13
#define kSolitairePokerColumnMax        7

@interface SSPlayViewController ()
{
}

#pragma mark - UICollectionViewDelegate

@end

@implementation SSPlayViewController

- (void)initView
{
    [super initView];
    // 背景音声音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDPlayMusic];

    // 背景イメージビュー
    UIImage *tableImage = [UIImage imageNamed:@"bg_table.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:tableImage];
    [self.view insertSubview:imageView atIndex:0];
    imageView.translatesAutoresizingMaskIntoConstraints  = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(imageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    UIImage *pokerImage = [UIImage imageNamed:@"bg_finished_area"];
    UIImageView *pokerImageView = [[UIImageView alloc] initWithImage:pokerImage];
    CGPoint point = self.pokerView.frame.origin;
    point.x += 3;
    point.y += 3;
    CGRect rect = CGRectMake(point.x, point.y, pokerImage.size.width, pokerImage.size.height);
    pokerImageView.frame = rect;
    [self.view insertSubview:pokerImageView belowSubview:self.pokerView];
    
    // 通知設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameWillResumeNotification:)
                                                 name:SolitaireWillResumeGameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameWillPauseNotification:)
                                                 name:SolitaireWillPauseGameNotification
                                               object:nil];
    // ポーカービュー
    self.pokerView.backgroundColor = [UIColor clearColor];
    
    // ゲーム開始
    [self start];
}

- (void)dealloc
{
    // タイマー停止
    [self setTimerEnabled:NO];
    
    // 通知監視削除
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateView
{
    [super updateView];
}

- (BOOL)shouldShowBannerAD
{
    return NO;
}

#pragma mark - ゲーム制御
// ゲーム停止通知
- (void)gameWillPauseNotification:(NSNotification *)notification
{
    [self pause];
}

// ゲーム再開通知
- (void)gameWillResumeNotification:(NSNotification *)notification
{
    [self resume];
}

// タイマー設定
- (void)setTimerEnabled:(BOOL)enabled
{
    if (enabled) {
        // タイマー再開
        if ([self.updateTimer isValid]) {
            [self.updateTimer invalidate];
        }
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                            target:self
                                                          selector:@selector(handleUpdateTimer:)
                                                          userInfo:nil
                                                           repeats:YES];
    } else {
        // タイマー停止
        if ([self.updateTimer isValid]) {
            [self.updateTimer invalidate];
            self.updateTimer = nil;
        }
    }
}

//　ゲーム一時停止
- (void)pause;
{
    // タイマー停止
    [self setTimerEnabled:NO];
}

// ゲーム再開
- (void)resume;
{
    // タイマー再開
    [self setTimerEnabled:YES];
}

// ゲーム終了（前画面へ遷移）
- (void)end;
{
    // タイマー停止
    [self setTimerEnabled:NO];
    
    // 前画面へ遷移する
    [self.navigationController popViewControllerAnimated:YES];
}

// リトライ（新規にゲームスタート）
- (void)start;
{
    _duration = 0;
    [self setTimerEnabled:YES];
    
    [self.pokerView start];
}

- (void)handleUpdateTimer:(NSTimer *)timer;
{
    _duration++;
}
@end
