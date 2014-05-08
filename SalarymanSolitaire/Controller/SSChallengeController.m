//
//  SSChallengeController.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSChallengeController.h"
#import "WUProgressView.h"
#import "SSPhysicalView.h"
#import "PurchaseManager.h"
#import "SSShopView.h"
#import "SSNutrientButton.h"

@interface SSChallengeController ()
{
    // ステージ情報
    SSStage                             *_stage;
    PurchaseManager                     *_manager;
    
    // 商品リスト
    NSSet                               *_productIdentifiers;
}

// 体力ビュー
@property (nonatomic, weak) IBOutlet SSPhysicalView *physicalView;

// 敵ビュー
@property (nonatomic, weak) IBOutlet UIImageView *enemyView;

// ツールバー
@property (nonatomic, weak) IBOutlet UIView *bottomBar;

// 栄養剤ボタン
@property (nonatomic, weak) IBOutlet SSNutrientButton *nutrientButton;

// ステージ情報取得
- (void)loadStageInfo;

// ギブアップ
- (IBAction)giveupAction:(id)sender;

// 栄養剤使用
- (IBAction)willUseNutrientAction:(id)sender;

// ショップ
- (IBAction)presentShopAction:(id)sender;

@end

@implementation SSChallengeController

// ゲーム初期化
- (void)initGame;
{
    [super initGame];
    
    // 挑戦モード
    self.freeMode = NO;
    
    // ステージIDによりステージ情報を取得する
    [self loadStageInfo];
}

// ステージ情報取得
- (void)loadStageInfo;
{
    SolitaireManager *manager = [SolitaireManager sharedManager];
    [manager selectStageWithID:_stageID];
    _stage = manager.currentStage;
    if (_stage) {
        // めくり枚数
        self.numberOfPokers = _stage.numberOfPokers;
        
        // 山札戻し回数
        self.maximumYamafuda = _stage.maximumYamafuda;
        
        // クリア回数
        _minimalClearTimes = _stage.minimalClearTimes;
        
        // クリア済み回数
        _currentClearTimes = _stage.currentClearTimes;
        
        // 体力
        _physicalView.maxPower = manager.maxPower;
        _physicalView.currentPower = manager.currentPower;
    }
}

- (void)initView
{
    [super initView];
    
    // ステージ情報取得
    _stage = [[SolitaireManager sharedManager] currentStage];
    if (!_stage) {
        _stage = [[SSStage alloc] init];
    }
    _stage.stageID = 1;
    _stage.enemyID = 2;
    
    // 敵イメージ設定
    if ([UIDevice isPhone5]) {
        // 敵のイメージを設定する
        NSString *name = [NSString stringWithFormat:@"enemy_%03d_banner.png", (int)_stage.enemyID];
        [self.enemyView setImage:[UIImage temporaryImageNamed:name]];
    }
}

- (void)layoutSubviewsForPhone4
{
    [super layoutSubviewsForPhone4];
    
    // 敵イメージを非表示にする
    [self.enemyView setHidden:YES];
    
    // ポーカー表示位置設定
    CGFloat height = self.view.bounds.size.height;
    CGFloat y = self.physicalView.bounds.size.height;
    height = height - y - self.bottomBar.bounds.size.height;
    CGRect rect = CGRectMake(0.0f, y, self.view.bounds.size.width, height);
    self.pokerView.frame = rect;

    // ボタン表示位置設定
    rect = self.bottomBar.frame;
    rect.origin.y = y + self.pokerView.bounds.size.height;
    self.bottomBar.frame = rect;
}


// 経過時間タイマー
- (void)handleUpdateTimer:(NSTimer *)timer;
{
    [super handleUpdateTimer:timer];
    [self.physicalView setDuration:self.duration];
}

#pragma mark - 画面操作
// ギブアップ
- (IBAction)giveupAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];
    
    // リスタート
    [self start];
}

// 栄養剤使用
- (IBAction)willUseNutrientAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];
}

// ショップ
- (IBAction)presentShopAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDCardDeal];
    
    // 待ち画面表示
    [WUProgressView showWithStatus:@"商品情報取得中..."];
    
    // 商品IDセット編集
    if (!_productIdentifiers) {
        _productIdentifiers = [NSSet setWithObjects:
                               kProductIdentifierPowerUp1,
                               kProductIdentifierPowerUp2,
                               kProductIdentifierPowerUp3,
                               kProductIdentifierPowerUp4,
                               kProductIdentifierPowerUp5,
                               kProductIdentifierYamafuda5,
                               kProductIdentifierYamafuda30,
                               kProductIdentifierYamafuda60,
                               kProductIdentifierDrink3,
                               kProductIdentifierDrink20,
                               kProductIdentifierDrink50,
                               nil];
    }
    if (!_manager) {
        _manager = [[PurchaseManager alloc ] initWithProductIdentifiers:_productIdentifiers];
        _manager.sandboxMode = kIAPSandBoxMode;
    }
    
    [_manager requestProductsWithCompletion:^(NSArray *products, PurchaseStatus status) {
        // ステータスチェック
        if (status == PurchaseStatusOK) {
            // 請求成功の場合、取得した商品情報を画面に表示する。
            SSShopView *popopView = [[SSShopView alloc] init];
            popopView.products = products;
            popopView.view.bounds = CGRectMake(0, 0, 280, 400);
            [popopView showInViewController:self center:self.view.center];
        }
        
        // 待ち画面を隠す
        [WUProgressView dismiss];
    }];
}

// ゲーム完了処理
- (void)willCompletSolitaire;
{
    [super willCompletSolitaire];
    
    // ステージクリア条件
}
@end
