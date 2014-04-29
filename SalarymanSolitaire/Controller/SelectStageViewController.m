//
//  SelectStageViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SelectStageViewController.h"
#import "StoryViewController.h"
#import "SSStage.h"
#import "SSStageCell.h"

#define __STAGE_CELL_IDENTIFIER         @"StageCell"

@interface SelectStageViewController ()<ADInterstitialAdDelegate>
{
    // ステージ一覧
    NSArray                             *_stageList;
    
    // 選択済みステージID
    NSInteger                           _selectedStageID;
}

// ヘッダー
@property (nonatomic, weak) IBOutlet UIView *headerView;

// ステージ一覧
@property (nonatomic, weak) IBOutlet UITableView *stageListView;

// インタースティシャル広告
@property (nonatomic, strong) ADInterstitialAd *interstitialAD;

// 閉じる処理
- (IBAction)closeAction:(id)sender;

// インタースティシャル広告表示
- (void)presentInterstitialAD;
@end

@implementation SelectStageViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initView
{
    [super initView];
    
    // ヘッダーの背景色設定
    self.headerView.backgroundColor = SSColorHeader;
    
    // ステージ選択通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stageDidSelectNotification:)
                                                 name:StageDidSelectNotification
                                               object:nil];
    
    // ステージ一覧初期化
    UINib *nib = [UINib nibWithNibName:@"SSStageCell" bundle:nil];
    [self.stageListView registerNib:nib forCellReuseIdentifier:__STAGE_CELL_IDENTIFIER];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_select.png"]];
    self.stageListView.backgroundView = backgroundView;
    
    // ステージ設定情報読み込み
    _stageList = [[SolitaireManager sharedManager] stageInfos];
}

- (void)updateView
{
    [super updateView];
    
    // ステージ一覧表示
    NSInteger stageID = [[SolitaireManager sharedManager] lastStageID];
    [SSStageCell setSelectedStageID:stageID];
    [self.stageListView reloadData];
    
    // 最新のステージが画面の中央におく
    NSInteger row = (stageID - 1)/SolitaireStageCellNumberPerRow;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.stageListView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

// 広告表示可否
- (BOOL)shouldShowBannerAD;
{
    return NO;
}

#pragma mark - 画面操作
// 閉じる処理
- (IBAction)closeAction:(id)sender;
{
    if ([self isFirstRun]) {
        // 初回起動の場合、チュートリアル画面を経由で表示する
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        // 上記以外の場合
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// ステージ選択済み処理
- (void)stageDidSelectNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    // ステータスチェック
    SSStageState state = (SSStageState)[[userInfo objectForKey:StageDidSelectNotificationStateKey] integerValue];
    if (state == SSStageStateLocked) {
        // 挑戦不可
//        return;
    }
    
    // ステージID取得
    _selectedStageID = [[userInfo objectForKey:StageDidSelectNotificationStageIDKey] integerValue];
    
    // 広告表示要否チェック
    BOOL showAD = [[userInfo objectForKey:StageDidSelectNotificationADKey] boolValue];
    if (showAD) {
        [self presentInterstitialAD];
    }
    
    // ストーリー画面表示
    [self presentStoryView];
}

// ストーリー画面表示
- (void)presentStoryView;
{
    StoryViewController *controller = [StoryViewController controller];
    [[SolitaireManager sharedManager] selectStageWithID:_selectedStageID];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SolitaireStageCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = SolitaireStageCellMaxNumber/SolitaireStageCellNumberPerRow;
    if (SolitaireStageCellMaxNumber % SolitaireStageCellNumberPerRow) {
        rows++;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSStageCell *cell = [tableView dequeueReusableCellWithIdentifier:__STAGE_CELL_IDENTIFIER];
    cell.fromStageID = indexPath.row *SolitaireStageCellNumberPerRow + 1;
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SolitaireStageCellHeaderHeight)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

#pragma mark - インタースティシャル広告

// インタースティシャル広告表示
- (void)presentInterstitialAD;
{
    self.interstitialAD = [[SolitaireManager sharedManager] sharedInterstitialAD];
    self.interstitialAD.delegate = self;
    DebugLog(@"interstitialAD");
}

-(void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    [interstitialAd presentInView:self.view];
    DebugLog(@"インタースティシャル型広告請求成功");
}

-(void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    DebugLog(@"广告卸载");
}

-(void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    DebugLog(@"インタースティシャル型広告請求失敗");
}

-(BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

-(void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    DebugLog(@"インタースティシャル型広告閉じる");
    
    // ストーリー画面表示
    [self presentStoryView];
}
@end

