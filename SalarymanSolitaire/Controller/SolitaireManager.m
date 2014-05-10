//
//  SolitaireManager.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SolitaireManager.h"
#import "KeychainItemWrapper.h"
#import "SSStage.h"

// デフォルト体力
NSInteger const DefaultPower = 5;

//
// 下記情報をNSUserDefaultsに保存します。
//
// ルートキー
NSString* const SolitaireUserInfo               = @"SolitaireUserInfo";

// 初回実行フラグ
NSString* const UserInfoFirstRunKey             = @"IsFirstRun";

//
// 下記情報をKeychainに保存します。
//
// ルートキー
NSString* const SolitaireGameInfo               = @"SolitaireGameInfo";

// 最新ステージ
NSString* const GameInfoLastStageID             = @"LastStageID";

// クリア済み回数
NSString* const GameInfoLastStageClearTimes     = @"LastStageClearTimes";

// 基礎体力＋
NSString* const GameInfoItemAdditionalPower     = @"ItemAdditionalPower";

// 栄養剤
NSString* const GameInfoItemNutrients           = @"ItemNutrients";

// 山札戻し
NSString* const GameInfoItemYamafudas           = @"ItemYamafudas";

// 栄養剤残り個数

//numberOfNutrients

@interface SolitaireManager () 


@end

@implementation SolitaireManager
{
    // ステージ設定情報
    NSMutableArray                      *_stageInfos;
    
    // 最新のステージ
    SSStage                             *_selectedStage;
    
    // 最新ステージID
    NSInteger                           _lastStageID;
    
    // 最新ステージの残り体力
    NSInteger                           _lastStagePower;
    
    // ユーザ情報
    NSMutableDictionary                 *_userInfo;
    
    // アプリ内課金情報
    KeychainItemWrapper                 *_wrapper;
}


// 初期化
+ (instancetype)sharedManager;
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedManager = nil;
    dispatch_once(&pred, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // ユーザ情報取得
    if (!_userInfo) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _userInfo = [userDefaults objectForKey:SolitaireUserInfo];
        if (!_userInfo) {
            _userInfo = [NSMutableDictionary dictionary];
            
            // 初回実行フラグ
            self.firstRun = YES;
        } else {
            _firstRun = [[_userInfo objectForKey:UserInfoFirstRunKey] boolValue];
        }
    }
    
    // ゲーム情報取得
    if (!_wrapper) {
        _wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:SolitaireGameInfo accessGroup:nil];
        
        NSData *data = [_wrapper objectForKey:(__bridge id)kSecValueData];
        
        if ([data length]) {
            NSDictionary *dictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
            // 最新ステージ
            _lastStageID = [[dictionary objectForKey:GameInfoLastStageID] integerValue];
            
            // 最新ステージのクリア済み回数
            _clearTimes = [[dictionary objectForKey:GameInfoLastStageClearTimes] integerValue];
            
            // 購入体力
            _additionalPower = [[dictionary objectForKey:GameInfoItemAdditionalPower] integerValue];
            
            // 購入栄養剤
            _nutrients = [[dictionary objectForKey:GameInfoItemNutrients] integerValue];
            
            // 購入山札戻し
            _yamafudas = [[dictionary objectForKey:GameInfoItemYamafudas] integerValue];
        } else {
            // 最新ステージ
            self.lastStageID = 1;
            
            // 最新ステージのクリア済み回数
            self.clearTimes = 0;
            
            // 購入体力
            self.additionalPower = 0;
            
            // 購入栄養剤
            self.nutrients = 0;
            
            // 購入山札戻し
            self.yamafudas = 0;
            
            // 初期化
            [self synchronize];
        }
    }
}

#pragma mark - ユーザ情報扱い
// 初回実行フラグ
- (void)setFirstRun:(BOOL)firstRun
{
    if (_firstRun == firstRun) {
        return;
    }
    _firstRun = firstRun;
    [_userInfo setObject:[NSNumber numberWithBool:_firstRun] forKey:UserInfoFirstRunKey];
    
    if (!firstRun) {
        // ユーザ情報保存
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_userInfo forKey:UserInfoFirstRunKey];
        [userDefaults synchronize];
    }
}

// 体力
- (NSInteger)currentPower;
{
    if (_selectedStage.stageID == _lastStageID) {
        // 前回に引き続き挑戦する場合
        return _lastStagePower;
    } else {
        // クリア済みステージを再挑戦する場合
        return (DefaultPower + _additionalPower);
    }
}

// 最大体力値
- (NSInteger)maxPower;
{
    return (DefaultPower + _additionalPower);
}

// ユーザ情報保存
- (void)synchronize;
{
    // アプリ内課金情報保存
    NSDictionary *dictionary = @{GameInfoLastStageID:[NSNumber numberWithInteger:_lastStageID],
                                 GameInfoLastStageClearTimes:[NSNumber numberWithInteger:_clearTimes],
                                 GameInfoItemAdditionalPower:[NSNumber numberWithInteger:_additionalPower],
                                 GameInfoItemNutrients:[NSNumber numberWithInteger:_nutrients],
                                 GameInfoItemYamafudas:[NSNumber numberWithInteger:_yamafudas]};
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [_wrapper setObject:data forKey:(__bridge id)kSecValueData];
}

#pragma mark - ステージ情報
// ステージ設定情報取得
- (NSArray *)stageInfos;
{
    if (!_stageInfos) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Stage" ofType:@"plist"];
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
        NSArray *array = [dict objectForKey:@"StageList"];
        _stageInfos = [NSMutableArray arrayWithCapacity:[array count]];
        for (NSDictionary *dic in array) {
            SSStage *stage = [[SSStage alloc] init];
            stage.stageID = [[dic objectForKey:@"StageID"] integerValue];
            stage.enemyID = [[dic objectForKey:@"EnemyID"] integerValue];
            stage.minimalClearTimes = [[dic objectForKey:@"MinClearTimes"] integerValue];
            stage.numberOfPokers = [[dic objectForKey:@"NumberOfPokers"] integerValue];
            stage.maximumYamafuda = [[dic objectForKey:@"ReturnTimes"] integerValue];
            stage.title = [dic objectForKey:@"StageName"];
            [_stageInfos addObject:stage];
        }
    }
    return _stageInfos;
}

// ステージ選択
- (void)selectStageWithID:(NSInteger)stageID;
{
    // 最新ステージ更新要否チェック
    if (stageID > _lastStageID) {
        self.lastStageID = stageID;
    }
    
    // 該当ステージ情報取得
    NSArray *array = [self stageInfos];
    if (stageID <= [array count] && stageID) {
        _currentStage = (SSStage *)[array objectAtIndex:stageID - 1];
    }
}

#pragma mark - 広告展示関連
// バナー広告
- (ADBannerView *)sharedBannerAD;
{
    static ADBannerView *_sharedBannerAD = nil;
    if (!_sharedBannerAD) {
        _sharedBannerAD = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        _sharedBannerAD.backgroundColor = SSColorADBanner;
        _sharedBannerAD.alpha = 1.0f;
    }
    return _sharedBannerAD;
}

// インタースティシャル広告
- (ADInterstitialAd *)sharedInterstitialAD;
{
    static ADInterstitialAd *_sharedInterstitialAD = nil;
    if (!_sharedInterstitialAD) {
        _sharedInterstitialAD = [ADInterstitialAd new];
    }
    return _sharedInterstitialAD;
}


@end
