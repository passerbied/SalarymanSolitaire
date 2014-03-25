//
//  StoryViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "StoryViewController.h"
#import "PlayViewController.h"
#import "SSStage.h"

@interface StoryViewController ()

// 選択したステージ情報
@property (nonatomic, strong) SSStage *stage;

// ステージID
@property (nonatomic, weak) IBOutlet UILabel *labelStageID;

// ステージタイトル
@property (nonatomic, weak) IBOutlet UILabel *labelStageTitle;

// ツールバー
@property (nonatomic, weak) IBOutlet UIView *topBar;

// スクロールビュー
//@property (nonatomic, strong) UIView *storyView;
//@property (nonatomic, strong) UIScrollView *scrollView;
//
//// ストーリービュー
//@property (nonatomic, strong) UIImageView *storyImageView;

// ストーリー表示
- (IBAction)presentStoryAction:(id)sender;

// 戻る処理
- (IBAction)returnAction:(id)sender;

// スキップ処理
- (IBAction)skipAction:(id)sender;

// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;

@end

@implementation StoryViewController



- (void)initView
{
    [super initView];
    
    // ステージ番号およびタイトルを設定する
    self.stage = [[SolitaireManager sharedManager] selectedStage];
    self.labelStageID.text = [NSString stringWithFormat:@"STAGE %d", self.stage.stageID];
    self.labelStageTitle.text = self.stage.title;
}

- (void)updateView
{
    [super updateView];
    
    // バナー広告非表示
    ADBannerView *bannerAD = [[SolitaireManager sharedManager] sharedBannerAD];
    [self.view sendSubviewToBack:bannerAD];
}

// プレイ画面表示
- (void)presentPlayView
{
    PlayViewController *controller = [PlayViewController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 画面操作
// ストーリー表示
- (IBAction)presentStoryAction:(id)sender;
{
    // ツールバー表示
    self.topBar.hidden = NO;
    
    // ストーリー表示
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    UIImageView *imageView = [[UIImageView alloc] init];
    NSString *imageName = [NSString stringWithFormat:@"stage_%03d_story.png", self.stage.stageID];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
    UIImage *storyImage = [UIImage imageWithContentsOfFile:path];
    [imageView setImage:storyImage];
    [scrollView addSubview:imageView];
    [self.view addSubview:scrollView];
    
    // 画面約束設定
    scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView, imageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[scrollView]-50-|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    // バナー広告表示
    ADBannerView *bannerAD = [[SolitaireManager sharedManager] sharedBannerAD];
    [self.view bringSubviewToFront:bannerAD];
}

// 戻る処理
- (IBAction)returnAction:(id)sender;
{
    [self.navigationController popViewControllerAnimated:YES];
}

// スキップ処理
- (IBAction)skipAction:(id)sender;
{
    // プレイ画面表示
    [self presentPlayView];
}

// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;
{
    // プレイ画面表示
    [self presentPlayView];
}
@end
