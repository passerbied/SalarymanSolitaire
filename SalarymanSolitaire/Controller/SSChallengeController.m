//
//  SSChallengeController.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSChallengeController.h"
#import "SSPhysicalView.h"
#import "SSSolitaireView.h"
@interface SSChallengeController ()
{
    // ステージ情報
    SSStage                             *_stage;
}

// 体力ビュー
@property (nonatomic, weak) IBOutlet SSPhysicalView *physicalView;

// 敵ビュー
@property (nonatomic, weak) IBOutlet UIImageView *enemyView;

// プレイビュー
@property (nonatomic, weak) IBOutlet SSSolitaireView *playView;

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
    
    // 敵イメージ設定
    NSString *name = [NSString stringWithFormat:@"enemy_%03d_banner.png", _stage.enemyID];
    [self.enemyView setImage:[UIImage temporaryImageNamed:name]];
}

@end
