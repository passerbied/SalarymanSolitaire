//
//  SSFreePlayController.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSFreePlayController.h"
#import "SSRecommendViewController.h"
#import "SSExitAlertView.h"
#import "SSRetryAlertView.h"
#import "SSModeAlertView.h"

@interface SSFreePlayController ()
{
}

// バー
@property (nonatomic, weak) IBOutlet UIView *topBar;
@property (nonatomic, weak) IBOutlet UIView *bottomBar;
@property (nonatomic, weak) IBOutlet UIImageView *passedTimeHeader;
@property (nonatomic, weak) IBOutlet UIImageView *recommandHeader;

// 経過時間
@property (nonatomic, weak) IBOutlet UILabel *passedTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *passedTimeLabel;

// 僕のおすすめ
@property (nonatomic, weak) IBOutlet UILabel *recommandTitleLabel;

// ゲーム終了
- (IBAction)terminateAction:(id)sender;

// ゲームリトライ
- (IBAction)retryAction:(id)sender;

// モード選択
- (IBAction)selectModeAction:(id)sender;


@end

@implementation SSFreePlayController

- (BOOL)shouldShowBannerAD
{
    if ([UIDevice isPhone5]) {
        return YES;
    } else {
        return NO;
    }
}

// ゲーム初期化
- (void)initGame;
{
    [super initGame];
    
    // 挑戦モード
    self.freeMode = YES;
    
    // めくり枚数
    self.numberOfPokers = 1;
    
    // 山札戻し回数
    self.maximumYamafuda = NSIntegerMax;
}

- (void)initView
{
    [super initView];
    
    // トップヘッダー
    self.topBar.backgroundColor = SSColorBarBackground;
    
    // フォント設定
    self.passedTitleLabel.font = SSGothicProFont(8.0f);
    self.passedTimeLabel.font = SSLCDProFont(12.0f);
    self.recommandTitleLabel.font = SSGothicProFont(8.0f);
    
    // おすすめタップイベント
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleRecommendGesture:)];
    self.recommandHeader.userInteractionEnabled = YES;
    [self.recommandHeader addGestureRecognizer:tapGesture];
}

// レイアウト設定
- (void)layoutSubviewsForPhone4;
{
    [super layoutSubviewsForPhone4];
    
    // トップヘッダー
    CGFloat topHeaderHeight = 40.0f;
    CGRect rect = self.topBar.frame;
    rect.size.height = topHeaderHeight;
    self.topBar.frame = rect;
    
    // 経過時間
    CGSize size = self.passedTimeHeader.image.size;
    CGFloat x = 10.0f;
    CGFloat y = topHeaderHeight - size.height;
    rect = CGRectMake(x, y, size.width, size.height);
    self.passedTimeHeader.frame = rect;
    
    // おすすめ
    size = self.recommandHeader.image.size;
    x = self.view.bounds.size.width - self.recommandHeader.bounds.size.width - 5.0f;
    y = topHeaderHeight - size.height;
    rect = CGRectMake(x, y, size.width, size.height);
    self.recommandHeader.frame = rect;
    
    // ラベル
    CGFloat dx = 0.0f;
    CGFloat dy = -10.0f;
    rect = self.passedTitleLabel.frame;
    rect = CGRectOffset(rect, dx, dy);
    self.passedTitleLabel.frame = rect;
    
    rect = self.passedTimeLabel.frame;
    rect = CGRectOffset(rect, dx, dy);
    self.passedTimeLabel.frame = rect;
    
    rect = self.recommandTitleLabel.frame;
    rect = CGRectOffset(rect, dx, dy);
    self.recommandTitleLabel.frame = rect;
    
    // ボタン
    rect = self.bottomBar.frame;
    y = self.view.bounds.size.height - rect.size.height;
    rect = CGRectMake(0.0f, y, rect.size.width, rect.size.height);
    self.bottomBar.frame = rect;
}

#pragma mark - 経過時間関連
// 経過時間タイマー
- (void)handleUpdateTimer:(NSTimer *)timer;
{
    [super handleUpdateTimer:timer];
    [self setPassedTimeWith:self.duration];
}

// 経過時間表示
- (void)setPassedTimeWith:(NSTimeInterval)timeInterval
{
    NSInteger duration = timeInterval;
    NSInteger hour = duration  / (60*60);
    NSInteger minute = (duration - hour*60*60) / 60;
    NSInteger second = (duration - hour*60*60 - minute*60);
    NSString *string = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    [self.passedTimeLabel setText:string];
}

#pragma mark - 画面操作
// ゲーム終了
- (IBAction)terminateAction:(id)sender;
{
    // ゲーム終了警告画面表示
    SSExitAlertView *alert = [SSExitAlertView alertWithDelegate:self];
    [alert show];
}

// ゲームリトライ
- (IBAction)retryAction:(id)sender;
{
    // ゲームリトライ警告画面表示
    SSRetryAlertView *alert = [SSRetryAlertView alertWithDelegate:self];
    [alert show];
}

// モード選択
- (IBAction)selectModeAction:(id)sender;
{
    // モード選択警告画面表示
    SSModeAlertView *alert = [SSModeAlertView alertWithDelegate:self];
    [alert show];
}

// 僕のおすすめ
- (void)handleRecommendGesture:(UITapGestureRecognizer *)gesture
{
    // ステータス判断
    if (gesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    // おすすめ画面へ遷移する
    SSRecommendViewController *controller = [SSRecommendViewController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 警告委託処理

// ゲーム終了
- (void)gameWillExit;
{
    // ゲームを終了して前画面へ遷移する
    [self.navigationController popViewControllerAnimated:YES];
}

// リトライ
- (void)gameWillRetry;
{
    // ゲームを新規にスタートさせる
    [self start];
}

// モード選択
- (void)toogleToSingleMode:(BOOL)singleMode;
{
    // めくり枚数リセット
    if (singleMode) {
        self.numberOfPokers = 1;
    } else {
        self.numberOfPokers = 3;
    }
}
@end
