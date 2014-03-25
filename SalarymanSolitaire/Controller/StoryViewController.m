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

// スクロールビュー
@property (nonatomic, strong) IBOutlet UIView *storyView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

// ストーリービュー
@property (nonatomic, weak) IBOutlet UIImageView *storyImageView;

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
    NSString *imageName = [NSString stringWithFormat:@"stage_%03d_story.png", self.stage.stageID];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
    UIImage *storyImage = [UIImage imageWithContentsOfFile:path];
    [self.storyImageView setImage:storyImage];
    CGRect rect = self.storyImageView.frame;
    self.storyImageView.frame = CGRectMake(0.0f, rect.origin.y, storyImage.size.width, storyImage.size.height);
    self.scrollView.contentSize = storyImage.size;
    NSLog(@"size [%@]",NSStringFromCGSize(self.storyImageView.frame.size));
    
    [self.view addSubview:self.storyView];
    self.scrollView.frame = CGRectMake(0, 0, 320, 480);
    self.scrollView.contentSize = storyImage.size;
    [self.scrollView setContentSize:CGSizeMake(1280, 480)];
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
