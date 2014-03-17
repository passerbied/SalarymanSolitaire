//
//  TutorialViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "TutorialViewController.h"
#import "StageListViewController.h"

// チュートリアルファイル定義
#define __TUTORIAL_FILE_NAME            @"Tutorial"

// コンテンツ定義
#define __TUTORIAL_CONTENT_KEY          @"Contents"

// ボタンイメージ「次へ」
#define __IMG_NEXT_STEP_NORMAL          @"btn_next_step_normal"

@interface TutorialViewController ()
{
    // チュートリアルコンテンツ
    NSArray                             *_contents;
    
    // 表示中コンテンツの索引
    NSInteger                           _currentIdex;
}
// ラベル「コンテンツ」
@property (nonatomic, weak) IBOutlet UILabel *labelContent;

// ボタン「次へ」
@property (nonatomic, weak) IBOutlet UIButton *btnNext;

// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;

// チュートリアル読み込み処理
- (void)loadTutorial;

// チュートリアル表示
- (void)showTutorialAtIndex:(NSInteger)index;

@end

@implementation TutorialViewController


- (void)setup
{
    [super setup];
    
    // ボタン「次へ」
    UIImage *image;
    image = [UIImage imageNamed:__IMG_NEXT_STEP_NORMAL];
    [_btnNext setImage:image forState:UIControlStateNormal];
    
    // チュートリアル読み込み処理
    [self loadTutorial];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // チュートリアル表示
    if (![_labelContent.text length]) {
        _currentIdex = 0;
        [self showTutorialAtIndex:_currentIdex];
    }
}

// チュートリアル読み込み処理
- (void)loadTutorial;
{
    // チュートリアル読み込み
    NSString *path = [[NSBundle mainBundle] pathForResource:__TUTORIAL_FILE_NAME ofType:@"plist"];
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:path]
                                 mutableCopy];
    _contents = [dict objectForKey:__TUTORIAL_CONTENT_KEY];
    if (![_contents count]) {
        return;
    }
}

// チュートリアル表示
- (void)showTutorialAtIndex:(NSInteger)index;
{
    // チェック
    if (index >= [_contents count]) {
        return;
    }
    
    // コンテンツ表示
    NSString *content = [_contents objectAtIndex:index];
    _labelContent.text = content;
    [_labelContent sizeToFit];
    
    // アニメーション
    if (index) {
        CGRect frame = _labelContent.frame;
        CGFloat x = frame.origin.x;
        
        _labelContent.frame = CGRectMake(320, frame.origin.y, frame.size.width, frame.size.height);
        NSTimeInterval duration = 0.7f;
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _labelContent.frame = CGRectMake(x, frame.origin.y, frame.size.width, frame.size.height);
                         }
                         completion:^(BOOL finished){}];
    }
    
    // ボタン画像変更
    if ([_contents count] == (index + 1)) {
//        _btnNext.userInteractionEnabled = NO;
    }
}

#pragma mark - 画面操作
// ボタン「次へ」タップ処理
- (IBAction)nextAction:(id)sender;
{
    if ([_contents count] == (_currentIdex + 1)) {
        // 初回起動設定
        [[SolitaireManager sharedManager] setFirstTimePlay];
        
        // ステージ選択画面に遷移する。
        StageListViewController *controller = [[StageListViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
        
    } else {
        // 上記以外の場合、次のページを表示する。
        _currentIdex++;
        [self showTutorialAtIndex:_currentIdex];
    }
}
@end
