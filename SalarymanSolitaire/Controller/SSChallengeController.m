//
//  SSChallengeController.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSChallengeController.h"
#import "SSPhysicalView.h"
#import "SSPokerView.h"
@interface SSChallengeController ()
{
    // ステージ情報
    SSStage                             *_stage;
}

// 体力ビュー
@property (nonatomic, strong) SSPhysicalView *physicalView;

// 敵ビュー
@property (nonatomic, weak) IBOutlet UIImageView *enemyView;

// ツールバー
@property (nonatomic, weak) IBOutlet UIView *bottomBar;

// ギブアップ
- (IBAction)giveupAction:(id)sender;

// 栄養剤使用
- (IBAction)willUseNutrientAction:(id)sender;

// ショップ
- (IBAction)presentShopAction:(id)sender;

@end

@implementation SSChallengeController

- (void)initView
{
    [super initView];
    
    // ステージ情報取得
    _stage = [[SolitaireManager sharedManager] selectedStage];
    if (!_stage) {
        _stage = [[SSStage alloc] init];
    }
    _stage.stageID = 1;
    _stage.enemyID = 2;
    
    // 体力ビュー作成
    SSPhysicalView *physicalView = [[SSPhysicalView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:physicalView];
    physicalView.translatesAutoresizingMaskIntoConstraints  = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(physicalView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[physicalView]|" options:0 metrics: 0 views:viewsDictionary]];
    CGFloat height = physicalView.frame.size.height;
    NSString *constraints = [NSString stringWithFormat:@"V:|[physicalView(%f)]",height];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraints options:0 metrics: 0 views:viewsDictionary]];
    
    // ポーカービュー設定
    _pokerView = [SSPokerView pokerView];
    [self.view addSubview:self.pokerView];

    // 敵イメージ設定
    if ([UIDevice isPhone5]) {
        // 敵のイメージを設定する
        NSString *name = [NSString stringWithFormat:@"enemy_%03d_banner.png", _stage.enemyID];
        [self.enemyView setImage:[UIImage temporaryImageNamed:name]];
    } else {
        // 敵イメージを非表示にする
        [self.enemyView setHidden:YES];
        
        
    }

    _pokerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pokerView.backgroundColor = [UIColor clearColor];
    viewsDictionary = NSDictionaryOfVariableBindings(_pokerView, _bottomBar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pokerView]|" options:0 metrics: 0 views:viewsDictionary]];
    CGFloat top = physicalView.frame.size.height;
    if ([UIDevice isPhone5]) {
        top = physicalView.frame.size.height + self.enemyView.bounds.size.height;
    } else {
        top = physicalView.frame.size.height;
    }
    CGFloat bottomBarHeight = self.bottomBar.bounds.size.height;
    constraints = [NSString stringWithFormat:@"V:|-%f-[_pokerView]-%f-|",top, bottomBarHeight];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraints options:0 metrics: 0 views:viewsDictionary]];
    
    
    // ツールバー
    [self.view bringSubviewToFront:self.bottomBar];
    _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    top = 480.0f - bottomBarHeight;
    if ([UIDevice isPhone5]) {
        top = 568.0f - bottomBarHeight;;
    } else {
        top = 480.0f - bottomBarHeight;;
    }
    constraints = [NSString stringWithFormat:@"V:|-%f-[_bottomBar]-0-|",top];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomBar]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraints options:0 metrics: 0 views:viewsDictionary]];
    
    // ゲームスタート
    [self.pokerView start];
}

// ポーカー位置
- (CGRect)rectForPoker;
{
    CGFloat y = 45.0f + 70.0f;
    CGFloat height = self.view.bounds.size.height - y - 49.0f;
    return CGRectMake(0.0f, y, self.view.bounds.size.width, height);
}

#pragma mark - 画面操作
// ギブアップ
- (IBAction)giveupAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    [self.pokerView start];
}

// 栄養剤使用
- (IBAction)willUseNutrientAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    [self.pokerView retry];
}

// ショップ
- (IBAction)presentShopAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

}
@end
