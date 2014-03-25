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

@interface SelectStageViewController ()
{
    NSArray                             *_stageList;
}

// ステージ一覧
@property (nonatomic, weak) IBOutlet UITableView *stageListView;

// 閉じる処理
- (IBAction)closeAction:(id)sender;
@end

@implementation SelectStageViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initView
{
    [super initView];
    
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
    NSInteger stageID = [[userInfo objectForKey:StageDidSelectNotificationStageIDKey] integerValue];
    StoryViewController *controller = [StoryViewController controller];
    [[SolitaireManager sharedManager] selectStageWithID:stageID];
    [self.navigationController pushViewController:controller animated:YES];
    return;
//    SSStageState state = (SSStageState)[[userInfo objectForKey:StageDidSelectNotificationStateKey] integerValue];
    BOOL showAD = [[userInfo objectForKey:StageDidSelectNotificationADKey] boolValue];
    if (showAD) {
        [self presentInterstitialAD];
    }
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
@end

