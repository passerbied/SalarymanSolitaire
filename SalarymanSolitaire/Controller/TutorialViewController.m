//
//  TutorialViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "TutorialViewController.h"
#import "SelectStageViewController.h"

#define kBackgroundImage                @"tutorial_howto.png"
#define kBackgroundImage568h            @"tutorial_howto-568h.png"

@interface TutorialViewController ()
{
}

// 背景イメージ
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;

@end

@implementation TutorialViewController

- (void)initView
{
    [super initView];
    
    // 背景イメージ設定
    UIImage *image = nil;
    NSString *imageName = nil;
    if ([UIDevice isPhone5]) {
        imageName = kBackgroundImage568h;
    } else {
        imageName = kBackgroundImage;
    }
    image = [UIImage imageNamed:imageName];
    _backgroundImageView.image = image;

    // タップ処理設定「閉じる」
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(closeAction:)];
    [_backgroundImageView addGestureRecognizer:tapGesture];
    
}


#pragma mark - 画面操作
// ボタン「閉じる」タップ処理
- (IBAction)closeAction:(id)sender;
{
    // Howtoを非表示にする
    [_backgroundImageView removeFromSuperview];

    // ストーリー表示
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    UIImageView *imageView = [[UIImageView alloc] init];
    UIButton *btnNext = [UIButton buttonWithImage:@"story_next_btn"];
    [btnNext addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *storyImage = [UIImage imageNamed:@"tutorial_story"];
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-50-|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    NSDictionary *btnDictionary = NSDictionaryOfVariableBindings(scrollView, btnNext);
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-61-[btnNext]-61-|" options:0 metrics: 0 views:btnDictionary]];
    
    CGFloat height = storyImage.size.height;
    NSString *constrain = [NSString stringWithFormat:@"V:|-%f-[btnNext(50)]-10-|",height-60];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constrain options:0 metrics: 0 views:btnDictionary]];

}

// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    // 初回起動設定
    [[SolitaireManager sharedManager] setFirstRun:NO];
    
    // ステージ選択画面に遷移する。
    SelectStageViewController *controller = [SelectStageViewController controller];
    [controller setFirstRun:YES];
    [self.navigationController pushViewController:controller animated:YES];
}
@end

