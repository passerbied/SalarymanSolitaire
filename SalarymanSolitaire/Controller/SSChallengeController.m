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
#import "SSPokerView.h"
#import "PurchaseManager.h"
#import "SSShopView.h"

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
    [self.pokerView setUsableYamafudas:20];
    [self.pokerView setFreeMode:NO];
    
    // 敵イメージ設定
    if ([UIDevice isPhone5]) {
        // 敵のイメージを設定する
        NSString *name = [NSString stringWithFormat:@"enemy_%03d_banner.png", (int)_stage.enemyID];
        [self.enemyView setImage:[UIImage temporaryImageNamed:name]];
    }
    
    // ゲームスタート
    [self.pokerView start];
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

    [self.pokerView start];
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
@end
