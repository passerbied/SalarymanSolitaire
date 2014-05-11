//
//  SSYamafudaButton.h
//  Poker
//
//  Created by IfelseGo on 14-5-3.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YamafudaDisplayMode)
{
    YamafudaDisplayModeUsable,
    YamafudaDisplayModeReturn,
    YamafudaDisplayModeBuy
};

@protocol SSYamafudaButtonDelegate <NSObject>
@required
//  山札戻し実行
- (void)willUseYamafuda;

// ショップ表示
- (void)willPresentShop;
@end

@interface SSYamafudaButton : UIView

// 委託対象
@property (nonatomic, weak) id<SSYamafudaButtonDelegate> delegate;

// 山札戻しの回数
@property (nonatomic) NSInteger maximumYamafuda;

// 表示モード
@property (nonatomic) YamafudaDisplayMode displayMode;

// フリーモード
@property (nonatomic) BOOL freeMode;

// 初期化
- (instancetype)initWithDelegate:(id<SSYamafudaButtonDelegate>)delegate;

// 山札戻し使用
- (void)useYamafuda;

// リセット(ソリティアをリトライするときに行う)
- (void)reset;

@end
