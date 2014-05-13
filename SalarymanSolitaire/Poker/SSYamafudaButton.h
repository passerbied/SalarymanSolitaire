//
//  SSYamafudaButton.h
//  Poker
//
//  Created by IfelseGo on 14-5-3.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YamafudaButtonDisplayMode)
{
    YamafudaButtonDisplayModeDisable,
    YamafudaButtonDisplayModeReload,
    YamafudaButtonDisplayModeRestart,
    YamafudaButtonDisplayModeMore
};

@protocol SSYamafudaButtonDelegate <NSObject>
@required

// 表示モード
- (YamafudaButtonDisplayMode)yamafudaDisplayMode;

// トランプ更新
- (void)reloadTrump;

// 山札戻し実行
- (void)willRestartYamafuda;

@optional
// ショップ表示
- (void)requireMoreYamafuda;
@end

@interface SSYamafudaButton : UIView

// 委託対象
@property (nonatomic, weak) id<SSYamafudaButtonDelegate> delegate;

// 山札戻しの回数
@property (nonatomic) NSInteger maximumYamafuda;

// 山札戻しの残り回数
@property (nonatomic, readonly) NSInteger numberOfYamafuda;

// 表示モード
@property (nonatomic, readonly) YamafudaButtonDisplayMode displayMode;

// フリーモード
@property (nonatomic) BOOL freeMode;

// 初期化
- (instancetype)initWithDelegate:(id<SSYamafudaButtonDelegate>)delegate;

// 山札戻し使用
- (void)restartYamafuda;

// リセット(ソリティアをリトライするときに行う)
- (void)reset;

@end
