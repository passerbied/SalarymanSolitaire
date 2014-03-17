//
//  StageListViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "StageListViewController.h"
#import "SSStage.h"
#import "StageCell.h"

#define __STAGE_CELL_IDENTIFIER         @"StageCell"

@interface StageListViewController ()
{
    NSMutableArray                      *_stageList;
}

// ステージ一覧
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

// ステージ取得
- (void)loadStageInfos;

// 閉じる処理
- (IBAction)closeAction:(id)sender;
@end

@implementation StageListViewController

- (void)setup
{
    [super setup];

    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerClass:[StageCell class]
            forCellWithReuseIdentifier:__STAGE_CELL_IDENTIFIER];
}

// ステージ取得
- (void)loadStageInfos;
{
    _stageList = [[NSMutableArray alloc] initWithCapacity:100];
    for (int i = 0; i < 100; i++) {
        SSStage *stage = [SSStage new];
        [_stageList addObject:stage];
    }
}
#pragma mark - 画面操作
// 閉じる処理
- (IBAction)closeAction:(id)sender;
{
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return 6;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    StageCell *cell = (StageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:__STAGE_CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.name = [NSString stringWithFormat:@"%d",indexPath.row];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 10;
}

@end
