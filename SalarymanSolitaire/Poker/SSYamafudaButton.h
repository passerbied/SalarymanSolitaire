//
//  SSYamafudaButton.h
//  Poker
//
//  Created by IfelseGo on 14-5-3.
//
//

#import <UIKit/UIKit.h>

@protocol SSYamafudaButtonDelegate <NSObject>
@required
//  山札戻し実行
- (void)willUseYamafuda;

// ショップ表示
- (void)willPresentShop;
@end

@interface SSYamafudaButton : UIView
{
    // 山札戻しの回数
    UILabel                             *_numbersLabel;
    
    // 背景イメージ
    UIImageView                         *_backgroundImageView;
}

// 委託対象
@property (nonatomic, weak) id<SSYamafudaButtonDelegate> delegate;

// 山札戻しの回数
@property (nonatomic) NSInteger maximumYamafuda;

// フリープレイモード
@property (nonatomic, getter = isFreeMode) BOOL freeMode;

// 利用可否（山札足りない場合、利用不可
@property (nonatomic) BOOL usable;

// 初期化
- (instancetype)initWithDelegate:(id<SSYamafudaButtonDelegate>)delegate;

@end
