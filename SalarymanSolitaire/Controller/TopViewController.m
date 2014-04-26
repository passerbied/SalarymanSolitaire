//
//  TopViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "TopViewController.h"
#import "HelpInfoViewController.h"
#import "TutorialViewController.h"
#import "SelectStageViewController.h"
#import "SSItemAlertView.h"
#import "SSModeAlertView.h"
#import "SSGiveupAlertView.h"
#import "SSClearPopupView.h"
#import "SSChallengeController.h"
#import "PopupNotificationView.h"
#import "SSFreePlayController.h"
#import "SSRecommendViewController.h"

@interface TopViewController ()
{
    // お知らせサービス実行中
    BOOL                                _serviceGetSystemInfoExecuting;
}

// お知らせアドレス
@property (strong, nonatomic) NSURL *notificationURL;

/* 画面操作 */

// ヘルプ情報表示
- (IBAction)showHelpInfoAction:(id)sender;

// フリープレイモード
- (IBAction)freePlayAction:(id)sender;

// おすすめ情報表示
- (IBAction)showRecommendInfoAction:(id)sender;

// プレイスタート
- (IBAction)gameStartAction:(id)sender;

// お知らせチェックサービス実行
- (void)performGetSystemInfoService;

@end

@implementation TopViewController

- (void)updateView
{
    [super updateView];
    
    // お知らせチェックサービス実行
    [self performGetSystemInfoService];
}

#pragma mark - 画面操作

// ヘルプ情報表示
- (IBAction)showHelpInfoAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];
    
    HelpInfoViewController *controller = [HelpInfoViewController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

// フリープレイモード
- (IBAction)freePlayAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];
    
    SSFreePlayController *controller = [SSFreePlayController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

// おすすめ情報表示
- (IBAction)showRecommendInfoAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    SSRecommendViewController *controller = [SSRecommendViewController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

// プレイスタート
- (IBAction)gameStartAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    UIViewController *controller = nil;
    if ([[SolitaireManager sharedManager] isFirstTime]) {
        // 初回起動時のみチュートリアル画面に遷移する
        controller = [TutorialViewController controller];
    } else {
        // 上記以外の場合、ステージ選択画面に遷移する
        controller = [SelectStageViewController controller];
    }
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - お知らせチェックサービス
// お知らせチェックサービス実行
- (void)performGetSystemInfoService;
{
    // サービス実行中チェック
    if (_serviceGetSystemInfoExecuting) {
        return;
    }
    
    // サービス実行
    GetSystemInfoService *service = [GetSystemInfoService serviceWithDelegate:self];
    service.request = [GetSystemInfoRequest request];
    [service setDidSucceedSelector:@selector(GetSystemInfoDidSucceed:)];
    [service setDidEndedSelector:@selector(GetSystemInfoDidEnded:)];
    [service start];
    _serviceGetSystemInfoExecuting = YES;
}

// サービス実行成功
- (void)GetSystemInfoDidSucceed:(GetSystemInfoService *)service
{
    GetSystemInfoResponse *response = [service notification];
    self.notificationURL = [NSURL URLWithString:response.NotificationURL];
}

// サービス実行完了
- (void)GetSystemInfoDidEnded:(GetSystemInfoService *)service
{
    if ([[SolitaireManager sharedManager] shouldPresentNotification]) {
        NSURL *URL = nil;
        if (self.notificationURL) {
            URL = self.notificationURL;
        } else {
            URL = [[SolitaireManager sharedManager] notificationURL];
        }
        PopupNotificationView *popopView = [[PopupNotificationView alloc] initWithURL:URL];
        [popopView popupInViewController:self];
    }
    _serviceGetSystemInfoExecuting = NO;
}

@end

