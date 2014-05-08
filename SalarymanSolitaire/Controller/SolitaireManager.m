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

// アプリ情報（ルート）
#define kUserInfoRootKey                @"SolitaireRootInfo"

// 初回実行フラグ
#define kUserInfoFirstRunKey            @"IsFirstRun"

// 最大体力値
#define kUserInfoMaxPower               @"MaxPower"

// 体力値
#define kUserInfoCurrentPower           @"CurrentPower"

// 最新ステージ
#define kUserInfoLastStageID            @"LastStageID"

// クリア済み回数
#define kUserInfoClearTimes             @"ClearTimes"

// アプリ内課金情報
#define kUserInfoInAppPurchase          @"SolitaireIAP"

// 基礎体力＋
#define kPurchaseAdditionalPower        @"ItemAdditionalPower"

// 栄養剤
#define kPurchaseNutrients              @"ItemNutrients"

// 山札戻し
#define kPurchaseYamafudas              @"ItemYamafudas"

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
    
    // ユーザ情報
    NSMutableDictionary                 *_userInfo;
    
    // アプリ内課金情報
    KeychainItemWrapper                 *_productWrapper;
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
    // アプリ情報取得
    if (!_userInfo) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _userInfo = [userDefaults objectForKey:kUserInfoRootKey];
        if (!_userInfo) {
            _userInfo = [NSMutableDictionary dictionary];
            
            // 初回実行フラグ
            self.firstRun = YES;
            
            // 最大体力値
            self.maxPower = 5;
            
            // 体力値
            self.currentPower = 5;
            
            // 最新ステージ
            self.lastStageID = 1;
            
            // クリア済み回数
            self.clearTimes = 0;
        } else {
            _firstRun = [[_userInfo objectForKey:kUserInfoFirstRunKey] boolValue];
            _maxPower = [[_userInfo objectForKey:kUserInfoMaxPower] integerValue];
            _currentPower = [[_userInfo objectForKey:kUserInfoCurrentPower] integerValue];
            _lastStageID = [[_userInfo objectForKey:kUserInfoLastStageID] integerValue];
            _clearTimes = [[_userInfo objectForKey:kUserInfoClearTimes] integerValue];
        }
    }
    
    // アプリ内課金情報取得
    if (!_productWrapper) {
        _productWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kUserInfoInAppPurchase accessGroup:nil];
        
        NSData *data = [_productWrapper objectForKey:(__bridge id)kSecValueData];
        NSDictionary *dictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (dictionary) {
            // 基礎体力＋
            _additionalPower = [[dictionary objectForKey:kPurchaseAdditionalPower] integerValue];
            
            // 栄養剤
            _nutrients = [[dictionary objectForKey:kPurchaseNutrients] integerValue];

            // 山札戻し
            _yamafudas = [[dictionary objectForKey:kPurchaseYamafudas] integerValue];
        } else {
            _additionalPower = 0;
            _nutrients = 3;
            _yamafudas = 4;
        }
    }
    [self synchronize];
}

#pragma mark - ユーザ情報扱い
// 初回実行フラグ
- (void)setFirstRun:(BOOL)firstRun
{
    if (_firstRun == firstRun) {
        return;
    }
    _firstRun = firstRun;
    [_userInfo setObject:[NSNumber numberWithBool:_firstRun] forKey:kUserInfoFirstRunKey];
    [self synchronize];
}

// 最大体力値
- (void)setMaxPower:(NSInteger)maxPower
{
    if (_maxPower == maxPower) {
        return;
    }
    _maxPower = maxPower;
    [_userInfo setObject:[NSNumber numberWithInteger:_maxPower] forKey:kUserInfoMaxPower];
}

// 体力値
- (void)setCurrentPower:(NSInteger)currentPower
{
    if (_currentPower == currentPower) {
        return;
    }
    _currentPower = currentPower;
    [_userInfo setObject:[NSNumber numberWithInteger:_currentPower] forKey:kUserInfoCurrentPower];
}

// 最新ステージ
- (void)setLastStageID:(NSInteger)lastStageID
{
    if (_lastStageID == lastStageID) {
        return;
    }
    _lastStageID = lastStageID;
    [_userInfo setObject:[NSNumber numberWithInteger:_lastStageID] forKey:kUserInfoLastStageID];
}

// クリア済み回数
- (void)setClearTimes:(NSInteger)clearTimes
{
    if (_clearTimes == clearTimes) {
        return;
    }
    _clearTimes = clearTimes;
    [_userInfo setObject:[NSNumber numberWithInteger:_clearTimes] forKey:kUserInfoClearTimes];
}

// ユーザ情報保存
- (void)synchronize;
{
    // ユーザ情報保存
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_userInfo forKey:kUserInfoRootKey];
    [userDefaults synchronize];
    
    // アプリ内課金情報保存
    NSDictionary *dictionary = @{kPurchaseAdditionalPower:[NSNumber numberWithInteger:_additionalPower],
                                 kPurchaseNutrients:[NSNumber numberWithInteger:_nutrients],
                                 kPurchaseYamafudas:[NSNumber numberWithInteger:_yamafudas]};
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [_productWrapper setObject:data forKey:(__bridge id)kSecValueData];
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
