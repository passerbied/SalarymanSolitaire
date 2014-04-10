//
//  SSStageCell.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-22.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSStageCell.h"
#import "SSStage.h"

const NSInteger SolitaireStageCellMaxNumber = 101;
const NSInteger SolitaireStageCellNumberPerRow = 3;
const CGFloat SolitaireStageCellHeight = 165.0f;
const CGFloat SolitaireStageCellHeaderHeight = 15.0f;
static NSInteger _selectedStageID;

NSString *const StageDidSelectNotification = @"StageDidSelectNotification";
NSString *const StageDidSelectNotificationStageIDKey = @"StageDidSelectNotificationStageIDKey";
NSString *const StageDidSelectNotificationStateKey = @"StageDidSelectNotificationStateKey";
NSString *const StageDidSelectNotificationADKey = @"StageDidSelectNotificationADKey";

#define __HERE_MARK_MARGIN_X            27.0f
#define __HERE_MARK_MARGIN_Y            50.0f

@interface SSStageControl ()
// 最新の
- (BOOL)isSelectedStage;

// クリア
- (BOOL)isCleared;
@end

@interface SSStageCell ()

// ステージボタン
@property (strong, nonatomic) IBOutletCollection(SSStageControl) NSArray *stageControls;

// 矢印
@property (weak, nonatomic) IBOutlet SSStageCellArrow *arrowRight1;
@property (weak, nonatomic) IBOutlet SSStageCellArrow *arrowRight2;
@property (weak, nonatomic) IBOutlet SSStageCellArrow *arrowDown;
@end

@implementation SSStageCell
// 最新のステージ索引設定
+ (void)setSelectedStageID:(NSInteger)stageID;
{
    _selectedStageID = stageID;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    
    // 矢印種類設定
    [self.arrowRight1 setRightArrow:YES];
    [self.arrowRight2 setRightArrow:YES];
    [self.arrowDown setRightArrow:NO];
}

- (void)setFromStageID:(NSInteger)fromStageID
{
    _fromStageID = fromStageID;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 矢印設定
    self.arrowRight1.stageID = _fromStageID;
    self.arrowRight2.stageID = _fromStageID + 1;
    self.arrowDown.stageID = _fromStageID + 2;
    
    // 敵情報取得
    NSArray *array = [[SolitaireManager sharedManager] stageInfos];
    
    // 敵
    NSInteger toStageID = _fromStageID + 2;
    NSInteger index = 0;
    for (NSInteger stageID = _fromStageID; stageID <= toStageID; stageID++) {
        SSStageControl *stage = (SSStageControl *)[self.stageControls objectAtIndex:index];
        [stage setStageID:stageID];
        
        if (stageID <= SolitaireStageCellMaxNumber) {
            SSStage *info = (SSStage *)[array objectAtIndex:stageID - 1];
            [stage setEnemyID:info.enemyID];
        }
        [stage setNeedsLayout];
        
        index++;
    }
}

@end



@implementation SSStageControl
{
    // 敵イメージ
    UIImageView                         *_enemyImageView;
    
    // ステージタイトル
    UILabel                             *_stageLabel;
    
    // 最新の識別イメージ
    UIImageView                         *_hereImageView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
    self.showsTouchWhenHighlighted = YES;
}

- (void)setup
{
    // 敵イメージ作成
    if (!_enemyImageView) {
        _enemyImageView = [[UIImageView alloc] initWithImage:nil];
        _enemyImageView.frame = CGRectMake(0, 0, 84, 115);
        [self addSubview:_enemyImageView];
    }
    
    // ステージタイトル作成
    if (!_stageLabel) {
        _stageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 85.0f, 17.0f)];
        _stageLabel.backgroundColor = [UIColor clearColor];
        _stageLabel.textColor = [UIColor whiteColor];
        _stageLabel.textAlignment = NSTextAlignmentCenter;
        _stageLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12.0f];
        [self addSubview:_stageLabel];
    }
    
    // ステージ選択処理
    [self addTarget:self
             action:@selector(didSelectStageAction:)
   forControlEvents:UIControlEventTouchUpInside];
}


// 最新の
- (BOOL)isSelectedStage;
{
    return (_stageID == _selectedStageID);
}

// クリア
- (BOOL)isCleared
{
    return (_stageID < _selectedStageID);
}

- (void)setStageID:(NSInteger)stageID
{
    _stageID = stageID;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 表示切り替え
    if (_stageID > SolitaireStageCellMaxNumber) {
        self.hidden = YES;
        return;
    } else {
        self.hidden = NO;
    }
    
    // タイトル設定
    _stageLabel.text = [NSString stringWithFormat:@"STAGE %d", _stageID];
    
    // 敵イメージ設定
    NSString *imageName = nil;
    if ([self isCleared]) {
        imageName = [NSString stringWithFormat:@"enemy_%03d_clear.png", _enemyID];
    } else {
        imageName = [NSString stringWithFormat:@"enemy_%03d_not_clear.png", _enemyID];
    }
    UIImage *enemyImage = [UIImage temporaryImageNamed:imageName];
    [_enemyImageView setImage:enemyImage];
    
    // HERE
    if ([self isSelectedStage]) {
        if (!_hereImageView) {
            UIImage *image = [UIImage imageNamed:@"here_check.png"];
            _hereImageView = [[UIImageView alloc] initWithImage:image];            
            _hereImageView.frame = CGRectMake(__HERE_MARK_MARGIN_X, __HERE_MARK_MARGIN_Y, image.size.width, image.size.height);
            [self addSubview:_hereImageView];
        }
        _hereImageView.hidden = NO;
    } else {
        _hereImageView.hidden = YES;
    }
}

// ステージ選択処理
- (void)didSelectStageAction:(id)sender
{
    // ボタン押下音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDButtonClicked];

    // 選択済みID
    NSNumber *objForStageID = [NSNumber numberWithInteger:_stageID];
    
    // 状態
    SSStageState stageState;
    if (_stageID == _selectedStageID) {
        stageState = SSStageStatePlaying;
    } else if (_stageID > _selectedStageID) {
        stageState = SSStageStateLocked;
    } else {
        stageState = SSStageStateCleared;
    }
    NSNumber *objForState = [NSNumber numberWithInteger:stageState];
    
    // 広告表示
    BOOL showADView;
    if (_stageID != 1 && !(_stageID % 5)) {
        showADView = YES;
    } else {
        showADView = NO;
    }
    NSNumber *objForAd = [NSNumber numberWithBool:showADView];
    
    // ステージ選択済み通知発送
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              objForStageID,
                              StageDidSelectNotificationStageIDKey,
                              objForState,
                              StageDidSelectNotificationStateKey,
                              objForAd,
                              StageDidSelectNotificationADKey,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:StageDidSelectNotification object:nil userInfo:userInfo];
}

- (SSStageState)stageState
{
    if (_stageID == _selectedStageID) {
        return SSStageStatePlaying;
    } else if (_stageID > _selectedStageID) {
        return SSStageStateLocked;
    } else {
        return SSStageStateCleared;
    }
}
@end

@implementation SSStageCellArrow

- (void)setStageID:(NSInteger)stageID
{
    _stageID = stageID;
    
    // 表示切り替え
    if (_stageID >= SolitaireStageCellMaxNumber) {
        self.hidden = YES;
        return;
    } else {
        self.hidden = NO;
    }
    
    //  矢印イメージ設定
    NSString *name = nil;
    if ([self isRightArrow]) {
        if (_stageID < _selectedStageID) {
            name = @"arrow_right_red.png";
        } else {
            name = @"arrow_right_black.png";
        }
    } else {
        if (_stageID < _selectedStageID) {
            name = @"arrow_down_red.png";
        } else {
            name = @"arrow_down_black.png";
        }
    }
    self.image = [UIImage imageNamed:name];
}

@end