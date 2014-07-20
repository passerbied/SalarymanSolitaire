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
#import "SSNutrientButton.h"
#import "SSGiveupAlertView.h"
#import "SSItemAlertView.h"
#import "PopupShopView.h"

#define kPokerOffsetY    86

@interface SSChallengeController ()
{
    // ステージ情報
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

// ショップ表示
- (void)handlePresentShop;

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
    SSStage *stage = manager.currentStage;
    _stageID = stage.stageID;
    if (stage) {
        // めくり枚数
        self.numberOfPokers = stage.numberOfPokers;
        
        // クリア回数
        _minimalClearTimes = stage.minimalClearTimes;
        
        // クリア済み回数
        if (_stageID == manager.lastStageID) {
            // 最新ステージを引き続き挑戦する場合
            _currentClearTimes = manager.clearTimes;
        } else {
            // クリアしたステージを再び挑戦する場合
            _currentClearTimes = 0;
        }
        
        // 山札戻し回数
        self.maximumYamafuda = stage.maximumYamafuda;
        
        // 体力
        _physicalView.maxPower = manager.maxPower;
        _physicalView.currentPower = manager.currentPower;
        
        // 画面活性制御
        [self modifySolitaireUserInteractionEnabledIfNecessary];
        
        // 敵イメージ設定
        if ([UIDevice isPhone5]) {
            // 敵のイメージを設定する
            NSString *name = [NSString stringWithFormat:@"enemy_%03d_banner", (int)stage.enemyID];
            [self.enemyView setImage:[UIImage imageNamed:name]];
        }
    }
    
    // 栄養剤制御
    _nutrientButton.numberOfNutrients = manager.nutrients;
}

- (void)initView
{
    [super initView];
}

- (void)layoutSubviewsForPhone4
{
    [super layoutSubviewsForPhone4];
    
    // 敵イメージを非表示にする
    [self.enemyView setHidden:YES];
    
    CGRect rect = self.finishedPokerPane.frame;
    rect.origin.y = rect.origin.y - kPokerOffsetY;
    
    self.pokerImageView.frame = rect;
    
    self.finishedPokerPane.frame = rect;
    
    // ポーカー表示位置設定
    CGFloat height = self.view.bounds.size.height;
    CGFloat y = self.physicalView.bounds.size.height;
    height = height - y - self.bottomBar.bounds.size.height;
    rect = CGRectMake(0.0f, y, self.view.bounds.size.width, height);
    self.pokerView.frame = rect;

    // ボタン表示位置設定
    rect = self.bottomBar.frame;
    rect.origin.y = y + self.pokerView.bounds.size.height;
    self.bottomBar.frame = rect;
}

// 画面活性制御
- (void)modifySolitaireUserInteractionEnabledIfNecessary
{
    // ポーカー活性制御
    BOOL enabled = _physicalView.currentPower > 0;
    self.pokerView.userInteractionEnabled = enabled;
    self.yamafudaButton.userInteractionEnabled = enabled;
    
    // 栄養剤活性制御
    if ([self.physicalView isPowerOFF]) {
        self.nutrientButton.enabled = YES;
    } else {
        self.nutrientButton.enabled = NO;
    }
}

// 経過時間タイマー
- (void)handleUpdateTimer:(NSTimer *)timer;
{
    // 体力値更新
    [super handleUpdateTimer:timer];
    [self.physicalView setDuration:self.duration];
    
    // 画面活性制御
    [self modifySolitaireUserInteractionEnabledIfNecessary];
}

// ショップ表示
- (void)handlePresentShop;
{
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
        _manager = [PurchaseManager sharedManager];
        _manager.productIdentifiers = _productIdentifiers;
        _manager.sandboxMode = kIAPSandBoxMode;
    }
    
    [_manager requestProductsWithCompletion:^(NSArray *products, PurchaseStatus status) {
        // ステータスチェック
        if (status == PurchaseStatusOK) {
            // 請求成功の場合、取得した商品情報を画面に表示する。
            PopupShopView *popopView = [[PopupShopView alloc] initWithProducts:products];
            [popopView popupInViewController:self];
        }
        
        // 待ち画面を隠す
        [WUProgressView dismiss];
        
        // ゲームを再開する
        [self resume];
    }];
}
#pragma mark - 画面操作
// ギブアップ
- (IBAction)giveupAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];
    
    // ソリティアを一時停止する
    [self pause];
    
    // モード選択警告画面表示
    SSGiveupAlertView *alert = [SSGiveupAlertView alertWithDelegate:self];
    [alert show];
}

// 栄養剤使用
- (IBAction)willUseNutrientAction:(id)sender;
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];
    
    // ソリティアを一時停止する
    [self pause];
    
    // 栄養剤使用＆購入画面を表示する
    SSItemAlertView *alert = [SSItemAlertView alertWithDelegate:self];
    alert.datasource = SSItemAlertDatasourceNutrient;
    alert.numberOfItems = [[SolitaireManager sharedManager] nutrients];
    [alert show];
}

// ショップ
- (IBAction)presentShopAction:(id)sender;
{
//    // ボタン押下音声再生
//    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];
//    
//    // ソリティアを一時停止する
//    [self pause];
//    
//    // ショップ表示
//    [self handlePresentShop];
//
    DebugLog(@"clear times= %d",[SolitaireManager sharedManager].clearTimes);
    if ([[SolitaireManager sharedManager] canClearCurrentStage]) {
        SSClearPopupView *clearPopupView = [[SSClearPopupView alloc] init];
        if (![UIDevice isPhone5]) {
            clearPopupView.top = 25.0f;
        }
        [clearPopupView show];
    }
}

// ゲーム完了処理
- (void)willCompletSolitaire;
{
    [super willCompletSolitaire];
    
    //クリア条件に合ったら、クリアポップアップ画面を表示
    if ([[SolitaireManager sharedManager] canClearCurrentStage]) {
        SSClearPopupView *clearPopupView = [[SSClearPopupView alloc] init];
        if (![UIDevice isPhone5]) {
            clearPopupView.top = 25.0f;
        }
        [clearPopupView show];
    }
}

#pragma mark - SSYamafudaButtonDelegate

// ショップ表示
- (void)requireMoreYamafuda;
{
    // 山札戻し使用＆購入画面を表示する
    SSItemAlertView *alert = [SSItemAlertView alertWithDelegate:self];
    alert.datasource = SSItemAlertDatasourceYamafuda;
    alert.numberOfItems = [[SolitaireManager sharedManager] yamafudas];
    [alert show];
}

#pragma mark - 警告処理
// 閉じるタップ処理
- (void)closeAlertView;
{
    // ゲーム再開
    [self resume];
}

// 山札戻しを使用する
- (void)willUseYamafuda;
{
    // 該当ステージの山札戻しの利用回数をチェックする
    if ([self.yamafudaButton numberOfYamafuda]) {
        [self.yamafudaButton restartYamafuda];
        return;
    }
    
    // 最大利用回数を超えた場合
    SolitaireManager *manager = [SolitaireManager sharedManager];
    [manager handleRestartYamafuda];
    
    // 山札戻し実行
    [self handleRestartYamafuda];
    
    // ゲームを再開する
    [self resume];
}

// 栄養剤を使用する
- (void)willUseDrink;
{
    // 体力ゲージを全て回復する
    [_physicalView recovery];
    
    // ゲームを再開する
    [self resume];
}

// 山札戻しを購入する
- (void)willBuyYamafuda;
{
    // ショップ表示
    [self handlePresentShop];
}

// 栄養剤を購入する
- (void)willBuyDrink;
{
    // ショップ表示
    [self handlePresentShop];
}

// ゲーム終了
- (void)gameWillExit;
{
    // 場合により体力減らす
    [self reducePowerIfNecessary];

    // ゲーム終了（前画面へ遷移）
    [self end];
}

// リトライ
- (void)gameWillRetry;
{
    // 場合により体力減らす
    [self reducePowerIfNecessary];

    // リトライ（新規にゲームスタート）
    [self start];
}

- (void)reducePowerIfNecessary
{
    // 体力ビュー更新
    [_physicalView powerUp:NO];
    
    // 再び挑戦する場合、処理を飛ばす。
    if ([self playAgainMode]) {
        return;
    }
    
    // 体力値を減らす
    [[SolitaireManager sharedManager] handleUsePower];
}

@end
