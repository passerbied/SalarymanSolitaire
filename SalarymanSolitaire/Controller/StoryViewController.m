//
//  StoryViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "StoryViewController.h"
#import "SSChallengeController.h"
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

// 背景
@property (strong, nonatomic) UIImageView *termBackground;

// 敵の画像
@property (nonatomic, strong) UIImageView *enemyPhotoView;

// 条件
@property (nonatomic, strong) UIImageView *conditionView;

//プレイボタン
@property (nonatomic, strong) UIButton *playButton;

// クリア条件
@property (nonatomic, strong) UILabel *conditionLabel;

//広告
@property (nonatomic, strong) ADBannerView *bannerAD;


// ストーリー表示
- (IBAction)presentStoryAction:(id)sender;

// 戻る処理
- (IBAction)returnAction:(id)sender;

// スキップ処理
- (IBAction)skipAction:(id)sender;

// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;

// ボタン「プレイ」タップ処理
//- (IBAction)playAction:(id)sender;

@end

@implementation StoryViewController

- (void)initView
{
    [super initView];
    
    // ステージ番号&タイトル取得
    self.stage = [[SolitaireManager sharedManager] currentStage];
    
    NSDictionary *attributes = nil;
    NSString *text = nil;
    
    // ステージ番号設定
    text = [NSString stringWithFormat:@"STAGE %d", (int)self.stage.stageID];
    attributes = @{NSFontAttributeName:SSGothicProFont(26.0f),
                   NSKernAttributeName:[NSNumber numberWithFloat:8.0f],
                   NSStrokeColorAttributeName:[UIColor whiteColor]};
    self.labelStageID.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    // ステージタイトル設定
//    text = self.stage.title;
//    attributes = @{NSFontAttributeName:SSGothicProFont(18.0f),
//                   NSKernAttributeName:[NSNumber numberWithFloat:4.0f],
//                   NSStrokeColorAttributeName:[UIColor whiteColor]};
//    self.labelStageTitle.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)updateView
{
    [super updateView];
    
}

// レイアウト設定
- (void)layoutSubviewsForPhone4;
{
    NSString *imageName = [NSString stringWithFormat:@"stage_%03d_term", (int)self.stage.stageID];
    UIImage *enemyImage = [UIImage imageNamed:imageName];
    CGRect rect = CGRectMake(0, 36, 640, (344-38)*2);
    
    CGImageRef sourceImageRef = [enemyImage CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    self.enemyPhotoView.image = newImage;
    self.enemyPhotoView.frame = CGRectMake(0, 0, 320, 344-38);
    self.conditionView.frame = CGRectMake(0, 344-38, 320, 172);
    self.conditionLabel.frame = CGRectMake(20, 405-38, 280, 45);
    self.playButton.frame = CGRectMake(62, 460-38, 196, 50);
    
    self.bannerAD = [[SolitaireManager sharedManager] sharedBannerAD];
    [self.view sendSubviewToBack:self.bannerAD];
    
}

// プレイ画面表示
- (void)presentPlayView
{
    SSChallengeController *controller = [SSChallengeController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

// クリア条件画面表示
- (void)presentConditionView;
{
    //背景
    UIImage *backgroundImage = [UIImage imageNamed:@"term_bg"];
    self.termBackground = [[UIImageView alloc] initWithImage:backgroundImage];
    self.termBackground.frame = CGRectMake(0, 0, 320, 568);
    self.termBackground.userInteractionEnabled = YES;
    [self.view addSubview:self.termBackground];
    
    // 敵の画像
    NSString *imageName = [NSString stringWithFormat:@"stage_%03d_term", (int)self.stage.stageID];
    UIImage *enemyImage = [UIImage imageNamed:imageName];
    self.enemyPhotoView = [[UIImageView alloc] init];
    self.enemyPhotoView.image = enemyImage;
    self.enemyPhotoView.frame = CGRectMake(0, 0, 320, 344);
    [self.termBackground addSubview:self.enemyPhotoView];
    
    // クリア条件
    UIImage *conditionImage = [UIImage imageNamed:@"term_frame"];
    self.conditionView = [[ UIImageView alloc] init];
    self.conditionView.image = conditionImage;
    self.conditionView.frame = CGRectMake(0, 344, 320, 172);
    [self.termBackground addSubview:self.conditionView];
    
    self.conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 395, 280, 60)];
    self.conditionLabel.font = SSGothicProFont(15.0f);
    self.conditionLabel.textColor = SSColorBlack;
    self.conditionLabel.numberOfLines = 2;
    self.conditionLabel.textAlignment = NSTextAlignmentCenter;
    self.conditionLabel.text = [self.stage condition];
    [self.termBackground addSubview:self.conditionLabel];
    
    //プレイボタン
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(62, 460, 196, 50)];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"term_play_btn"]
                               forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"term_play_btn_on"]
                               forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playAction)
              forControlEvents:UIControlEventTouchUpInside];
    [self.termBackground addSubview:self.playButton];
    
    self.bannerAD = [[SolitaireManager sharedManager] sharedBannerAD];
    [self.view bringSubviewToFront:self.bannerAD];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (![UIDevice isPhone5]) {
            // レイアウト設定
            [self layoutSubviewsForPhone4];
        }
    }
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
    NSString *imageName = [NSString stringWithFormat:@"stage_%03d_story", (int)self.stage.stageID];
    UIImage *storyImage = [UIImage imageNamed:imageName];
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
    self.bannerAD = [[SolitaireManager sharedManager] sharedBannerAD];
    [self.view bringSubviewToFront:self.bannerAD];
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
- (void)playAction
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    // プレイ画面表示
    [self presentPlayView];
}
@end
