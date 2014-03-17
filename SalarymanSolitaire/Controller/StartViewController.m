//
//  StartViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "StartViewController.h"
#import "HelpInfoViewController.h"
#import "TutorialViewController.h"
#import "StageListViewController.h"

#import "SSPopupView.h"

@interface StartViewController ()

// お知らせビュー
@property (nonatomic, strong) IBOutlet UIView *notificationView;

// お知らせビュー表示要否チェック
- (BOOL)shouldShowNotification;

/* 画面操作 */

// ヘルプ情報表示
- (IBAction)showHelpInfoAction:(id)sender;

// おすすめ情報表示
- (IBAction)showRecommendInfoAction:(id)sender;

// フリープレイモード
- (IBAction)freePlayAction:(id)sender;

// プレイスタート
- (IBAction)gameStartAction:(id)sender;

// お知らせ画面閉じる
- (IBAction)closeNotificationAction:(id)sender;
@end

@implementation StartViewController

- (void)setup
{
    [super setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ナビゲートバー表示
    self.navigationController.navigationBarHidden = YES;
    
    // お知らせビュー表示
    if ([self shouldShowNotification]) {
//        [self setNotificationViewHidden:NO];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// お知らせビュー表示要否チェック
- (BOOL)shouldShowNotification;
{
    return YES;
}

// お知らせビュー表示
- (void)setNotificationViewHidden:(BOOL)hidden;
{
    SSPopupView *popView = [SSPopupView new];
    popView.view.backgroundColor = [UIColor clearColor];
    [popView showInViewController:self center:self.view.center];
    
    return;
    // 画面の真ん中に追加する
    if (self.notificationView.superview == nil && !hidden) {
        [self.view addSubview:self.notificationView];
        CGFloat x = (self.view.bounds.size.width - self.notificationView.bounds.size.width)/2.0f;
        CGFloat y = (self.view.bounds.size.height - self.notificationView.bounds.size.height)/2.0f;
        CGFloat width = self.notificationView.bounds.size.width;
        CGFloat height = self.notificationView.bounds.size.height;
        self.notificationView.frame = CGRectMake(x, y, width, height);
    }

    // アニメーション設定
    NSTimeInterval duration;
    CGFloat alpha;
    if (hidden) {
        duration = 0.5f;
        alpha = 0;
    } else {
        duration = 0.35f;
        alpha = 1;
    }
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.notificationView.alpha = alpha;
                     }
                     completion:^(BOOL finished){}];
}

#pragma mark - 画面操作

// ヘルプ情報表示
- (IBAction)showHelpInfoAction:(id)sender;
{
    HelpInfoViewController *controller = [[HelpInfoViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

// おすすめ情報表示
- (IBAction)showRecommendInfoAction:(id)sender;
{
    SSPopupView *popView = [SSPopupView new];
    popView.backgroundColor = [UIColor clearColor];
    popView.view.bounds = CGRectMake(0, 0, 280, 400);
    [popView showInViewController:self center:self.view.center];
}

// フリープレイモード
- (IBAction)freePlayAction:(id)sender;
{
    
}

// プレイスタート
- (IBAction)gameStartAction:(id)sender;
{
    UIViewController *controller = nil;
    
    if ([[SolitaireManager sharedManager] isFirstTime]) {
        // 初回起動時のみチュートリアル画面に遷移する
        controller = [[TutorialViewController alloc] initWithNibName:nil bundle:nil];
    } else {
        // 上記以外の場合、ステージ選択画面に遷移する
        controller = [[StageListViewController alloc] initWithNibName:nil bundle:nil];
    }
    [self.navigationController pushViewController:controller animated:YES];
}

// お知らせ画面閉じる
- (IBAction)closeNotificationAction:(id)sender;
{
    // お知らせ画面を閉じる
    [self setNotificationViewHidden:YES];
}

@end
