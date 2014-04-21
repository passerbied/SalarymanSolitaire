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
@property (nonatomic, strong) IBOutlet UIView *topBar;

// 条件
@property (nonatomic, strong) IBOutlet UIView *conditionView;

// 敵の画像
@property (nonatomic, weak) IBOutlet UIImageView *enemyPhotoView;

// 敵の肩書き
@property (nonatomic, weak) IBOutlet UILabel *enemyTitleLabel;

// 敵の名前
@property (nonatomic, weak) IBOutlet UILabel *enemyNameLabel;

// クリア条件タイトル
@property (nonatomic, weak) IBOutlet UILabel *conditionTitleLabel;

// クリア条件
@property (nonatomic, weak) IBOutlet UILabel *conditionLabel;


// ストーリー表示
- (IBAction)presentStoryAction:(id)sender;

// 戻る処理
- (IBAction)returnAction:(id)sender;

// スキップ処理
- (IBAction)skipAction:(id)sender;

// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;

// ボタン「プレイ」タップ処理
- (IBAction)playAction:(id)sender;

@end

@implementation StoryViewController

- (void)initView
{
    [super initView];
    
    // ステージ番号およびタイトルを設定する
    self.stage = [[SolitaireManager sharedManager] selectedStage];
    self.labelStageID.text = [NSString stringWithFormat:@"STAGE %d", (int)self.stage.stageID];
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

// クリア条件画面表示
- (void)presentConditionView;
{
    [self.view addSubview:self.conditionView];
    
    // 敵の画像
    NSString *imageName = [NSString stringWithFormat:@"enemy_%03d_poker.png", (int)self.stage.stageID];
    UIImage *photoImage = [UIImage temporaryImageNamed:imageName];
    self.enemyPhotoView.image = photoImage;
    
    // 敵の肩書き
    self.enemyTitleLabel.font = SSGothicProFont(15.0f);
    self.enemyTitleLabel.textColor = SSColorWhite;
    
    // 敵の名前
    self.enemyNameLabel.font = SSGothicProFont(24.0f);
    self.enemyNameLabel.textColor = SSColorWhite;
    
    // クリア条件タイトル
    self.conditionTitleLabel.font = SSGothicProFont(15.0f);
    self.conditionTitleLabel.textColor = SSColorWhite;
    
    // クリア条件
    self.conditionLabel.font = SSGothicProFont(15.0f);
    self.conditionLabel.textColor = SSColorBlack;
    self.conditionLabel.text = [self.stage condition];
}

#pragma mark - 画面操作
// ストーリー表示
- (IBAction)presentStoryAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    // ツールバー表示
    self.topBar.frame = CGRectMake(0, 0, 320, 60);
    [self.view addSubview:self.topBar];
    
    // ストーリー表示
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    UIImageView *imageView = [[UIImageView alloc] init];
    UIButton *btnNext = [UIButton buttonWithImage:@"story_next_btn"];
    [btnNext addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    NSString *imageName = [NSString stringWithFormat:@"stage_%03d_story.png", (int)self.stage.stageID];
    UIImage *storyImage = [UIImage temporaryImageNamed:imageName];
    [imageView setImage:storyImage];
    [scrollView addSubview:imageView];
    [scrollView addSubview:btnNext];
    [self.view addSubview:scrollView];
    
    // 画面約束設定
    scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    btnNext.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView, imageView, btnNext);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView(320)]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-59-[scrollView]-50-|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];

    NSDictionary *btnDictionary = NSDictionaryOfVariableBindings(scrollView, btnNext);
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-61-[btnNext]-61-|" options:0 metrics: 0 views:btnDictionary]];
    
    CGFloat height = storyImage.size.height;
    NSString *constrain = [NSString stringWithFormat:@"V:|-%f-[btnNext(50)]-10-|",height-60];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constrain options:0 metrics: 0 views:btnDictionary]];

    
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
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    // プレイ画面表示
    [self presentPlayView];
}

// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    // クリア条件画面表示
    [self presentConditionView];
}

// ボタン「プレイ」タップ処理
- (IBAction)playAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    // プレイ画面表示
    [self presentPlayView];
}
@end
