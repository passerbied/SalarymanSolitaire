//
//  SSPlayViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPlayViewController.h"
#import "SSPhysicalView.h"
#import "SSNutrientButton.h"
#import "SSPoker.h"
#import "SSPokerViewCell.h"
#import "SSPokerViewLayout.h"
#import "UICollectionView+Draggable.h"
#import "SSYamafudaButton.h"

#define kPokerViewCellIdentifier        @"PokerCell"

NSString *const SolitaireWillResumeGameNotification = @"SolitaireWillResumeGameNotification";
NSString *const SolitaireWillPauseGameNotification = @"SolitaireWillPauseGameNotification";

#define kSolitairePokerColours          4
#define kSolitairePokerCount            13
#define kSolitairePokerColumnMax        7

@interface SSPlayViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource_Draggable,SSYamafudaButtonDelegate>
{
    // ポーカー
    NSMutableArray                      *_randomPokers;
    NSMutableArray                      *_allPokers;
    NSInteger                           _pokerMaxCount;
    SSDraggblePokerViewLayout           *_pokerLayout;
    
    // シャッフル
    NSInteger                           _currentItem;
    NSInteger                           _currentSection;
    
    // 山札戻し
    SSYamafudaButton                    *_yamafudaButton;
    
    // ポーカー引き枚数変更フラグ
    NSMutableArray                      *_reversePokers;
    
    // 完了アニメーション
    BOOL                                _completed;
}

- (SSYamafudaButton *)yamafudaButton;

- (void)distribute;

@end

@implementation SSPlayViewController

// ゲーム初期化
- (void)initGame;
{
    // 背景音声音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDPlayMusic];
    
    // 通知設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameWillResumeNotification:)
                                                 name:SolitaireWillResumeGameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameWillPauseNotification:)
                                                 name:SolitaireWillPauseGameNotification
                                               object:nil];
}

// 山札戻し使用
- (void)useYamafuda;
{
    // なにもしない
}

- (SSYamafudaButton *)yamafudaButton;
{
    if (!_yamafudaButton) {
        _yamafudaButton = [[SSYamafudaButton alloc] initWithDelegate:self];
        [_pokerView addSubview:_yamafudaButton];
    }
    return _yamafudaButton;
}

- (void)initView
{
    [super initView];
    
    // ゲーム初期化
    [self initGame];

    // 背景イメージビュー
    UIImage *tableImage = [UIImage imageNamed:@"bg_table.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:tableImage];
    [self.view insertSubview:imageView atIndex:0];
    imageView.translatesAutoresizingMaskIntoConstraints  = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(imageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    UIImage *pokerImage = [UIImage imageNamed:@"bg_finished_area"];
    UIImageView *pokerImageView = [[UIImageView alloc] initWithImage:pokerImage];
    CGPoint point = self.pokerView.frame.origin;
    point.x += 3;
    point.y += 3;
    CGRect rect = CGRectMake(point.x, point.y, pokerImage.size.width, pokerImage.size.height);
    pokerImageView.frame = rect;
    [self.view insertSubview:pokerImageView belowSubview:self.pokerView];
    
    // ポーカービュー
    self.pokerView.dataSource = self;
    self.pokerView.backgroundColor = [UIColor clearColor];
    
    UIImage *finishedPokerImage = [UIImage imageNamed:@"bg_finished_area"];
    UIImageView *finishedPokerPane = [[UIImageView alloc] initWithImage:finishedPokerImage];
    point = _pokerView.frame.origin;
    point.x += 3;
    point.y += 3;
    rect = CGRectMake(point.x, point.y, finishedPokerImage.size.width, finishedPokerImage.size.height);
    finishedPokerPane.frame = rect;
    [self.view insertSubview:finishedPokerPane belowSubview:_pokerView];
    
    _pokerMaxCount = SSPokerColorCount * SSPokerNameCount;
    _pokerLayout = [[SSDraggblePokerViewLayout alloc] init];
    _pokerView.collectionViewLayout = _pokerLayout;
    _pokerView.dataSource = self;
    _pokerView.delegate = self;
    [_pokerView setDraggable:YES];
    _pokerView.backgroundColor = [UIColor clearColor];
    [_pokerView registerClass:[SSPokerViewCell class] forCellWithReuseIdentifier:kPokerViewCellIdentifier];
    
    [self distribute];
    
    // ゲーム開始
    [self start];
}

#pragma mark - setter
- (void)setFreeMode:(BOOL)freeMode
{
    _freeMode = freeMode;
}

- (void)setMaximumYamafuda:(NSInteger)maximumYamafuda
{
    if (_maximumYamafuda == maximumYamafuda) {
        return;
    }
    _maximumYamafuda = maximumYamafuda;
    [[self yamafudaButton] setMaximumYamafuda:maximumYamafuda];
}

- (void)setNumberOfPokers:(NSInteger)numberOfPokers
{
    if (_numberOfPokers == numberOfPokers) {
        return;
    }
    _numberOfPokers = numberOfPokers;
    _pokerLayout.numberOfPokers = _numberOfPokers;

    
    NSMutableArray *yamafudaPokers = [_allPokers objectAtIndex:SSPokerSectionYamafuda];
    NSInteger count = [yamafudaPokers count];
    if (count == 0) {
        return;
    }
    
    NSMutableArray *recyclePokers = nil;
    NSMutableArray *hiddenPokers = nil;
    
    if (!_reversePokers) {
        _reversePokers = [NSMutableArray array];
    }
    if ([_reversePokers count]) {
        recyclePokers = [_allPokers objectAtIndex:SSPokerSectionRecycle];
        hiddenPokers = [_allPokers objectAtIndex:SSPokerSectionHidden];
        
        if (count > _numberOfPokers) {
            // 山札　ー＞　非表示(3->1)
            [yamafudaPokers removeObjectsInArray:_reversePokers];
            for (NSInteger i = [_reversePokers count] - 1; i >= 0; i--) {
                SSPoker *poker = [_reversePokers objectAtIndex:i];
                [hiddenPokers insertObject:poker atIndex:0];
            }
        } else if (count < _numberOfPokers) {
            // リサイクル　ー＞　山札(1->3)
            [recyclePokers removeObjectsInArray:_reversePokers];
            for (NSInteger i = 0; i < [_reversePokers count]; i++) {
                SSPoker *poker = [_reversePokers objectAtIndex:i];
                [yamafudaPokers addObject:poker];
            }
        } else {
            // 一致する場合、何もしない。
            return;
        }
        [_reversePokers removeAllObjects];
    } else {
        recyclePokers = [_allPokers objectAtIndex:SSPokerSectionRecycle];
        hiddenPokers = [_allPokers objectAtIndex:SSPokerSectionHidden];
        
        if (count > _numberOfPokers) {
            // 山札　ー＞　リサイクル(3->1)
            for (NSInteger i = _numberOfPokers; i < count; i++) {
                SSPoker *poker = [yamafudaPokers objectAtIndex:i];
                [recyclePokers addObject:poker];
                [_reversePokers addObject:poker];
            }
            NSRange range = NSMakeRange(_numberOfPokers, count - _numberOfPokers);
            [yamafudaPokers removeObjectsInRange:range];
        } else if (count < _numberOfPokers) {
            // 非表示　ー＞　山札(1->3)
            NSInteger len = 0;
            for (NSInteger i = 0; i < [hiddenPokers count] && i < _numberOfPokers - count; i++) {
                SSPoker *poker = [hiddenPokers objectAtIndex:i];
                [yamafudaPokers addObject:poker];
                [_reversePokers addObject:poker];
                len++;
            }
            NSRange range = NSMakeRange(0, len);
            [hiddenPokers removeObjectsInRange:range];
        } else {
            // 一致する場合、何もしない。
            return;
        }
    }
    
    // 山札エリア再表示
    [_pokerView reloadSections:[NSIndexSet indexSetWithIndex:SSPokerSectionYamafuda]];
}

- (void)dealloc
{
    // タイマー停止
    [self setTimerEnabled:NO];
    
    // 通知監視削除
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateView
{
    [super updateView];
}

- (BOOL)shouldShowBannerAD
{
    return NO;
}

#pragma mark - ゲーム制御
// ゲーム停止通知
- (void)gameWillPauseNotification:(NSNotification *)notification
{
    [self pause];
}

// ゲーム再開通知
- (void)gameWillResumeNotification:(NSNotification *)notification
{
    [self resume];
}

// タイマー設定
- (void)setTimerEnabled:(BOOL)enabled
{
    if (enabled) {
        // タイマー再開
        if ([self.updateTimer isValid]) {
            [self.updateTimer invalidate];
        }
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                            target:self
                                                          selector:@selector(handleUpdateTimer:)
                                                          userInfo:nil
                                                           repeats:YES];
    } else {
        // タイマー停止
        if ([self.updateTimer isValid]) {
            [self.updateTimer invalidate];
            self.updateTimer = nil;
        }
    }
}


#pragma mark - ゲーム制御
// リトライ（新規にゲームスタート）
- (void)start;
{
    _duration = 0;
    [self setTimerEnabled:YES];
    [_reversePokers removeAllObjects];
    
    if (_freeMode) {
        [[self yamafudaButton] setDisplayMode:YamafudaDisplayModeFree];
    } else {
        [[self yamafudaButton] setDisplayMode:YamafudaDisplayModeUsable];
    }
    
    [self distribute];
}

// ゲーム終了（前画面へ遷移）
- (void)end;
{
    // タイマー停止
    [self setTimerEnabled:NO];
    
    // 前画面へ遷移する
    [self.navigationController popViewControllerAnimated:YES];
}

//　ゲーム一時停止
- (void)pause;
{
    // タイマー停止
    [self setTimerEnabled:NO];
}

// ゲーム再開
- (void)resume;
{
    // タイマー再開
    [self setTimerEnabled:YES];
}
- (void)handleUpdateTimer:(NSTimer *)timer;
{
    _duration++;
}

- (void)distribute;
{
    // 初期化
    if (_randomPokers) {
        [_randomPokers removeAllObjects];
        [_allPokers removeAllObjects];
    } else {
        _randomPokers = [NSMutableArray arrayWithCapacity:_pokerMaxCount];
        _allPokers = [NSMutableArray arrayWithCapacity:SSPokerSectionTotal];
    }
    for (NSInteger section = SSPokerSectionDeck1; section < SSPokerSectionTotal; section++) {
        [_allPokers addObject:[NSMutableArray array]];
    }
    [self.pokerView reloadData];
    _pokerLayout.pokers = _allPokers;
    _pokerLayout.currentMode = SSPokerViewLayoutModeDistribution;
    
    // 手当たり次第、ポーカー作成
    SSPokerColor color = SSPokerColorHeart;
    for (NSInteger i = 0; i < SSPokerColorCount; i++) {
        SSPokerName name = SSPokerNameA;
        for (NSInteger j = 0; j < SSPokerNameCount; j++) {
            // ポーカー作成
            SSPoker *poker = [SSPoker pokerWithColor:color name:name];
            [_randomPokers addObject:poker];
            
            // 次へ
            name++;
        }
        // 次へ
        color++;
    }
    for (NSInteger index = 0; index < _pokerMaxCount; index++) {
        NSInteger randomIndex = arc4random()%_pokerMaxCount;
        if (index != randomIndex) {
            [_randomPokers exchangeObjectAtIndex:index withObjectAtIndex:randomIndex];
        }
    }
    
    // アニメーション表示
    [self playDistributionAnimation];
}

- (void)playDistributionAnimation
{
    _currentSection = SSPokerSectionDeck1;
    _currentItem = 0;
    
    [self distributePoker];
}

- (void)distributePoker
{
    // ビリからポーカーを配布する
    SSPoker *lastPoker = [_randomPokers lastObject];
    NSMutableArray *pokersForDistributing = [_allPokers objectAtIndex:_currentSection];
    if ([pokersForDistributing count] != _currentSection) {
        [lastPoker setFaceUp:NO];
    }
    
    [pokersForDistributing addObject:lastPoker];
    [_randomPokers removeLastObject];
    
    
    [_pokerView performBatchUpdates:^{
        // ポーカー追加
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentItem inSection:_currentSection];
        if (_currentItem == 0) {
            [_pokerView reloadSections:[NSIndexSet indexSetWithIndex:_currentSection]];
        } else {
            [_pokerView insertItemsAtIndexPaths:@[indexPath]];
        }
    } completion:^(BOOL finished) {
        _currentSection++;
        if (_currentSection > SSPokerSectionDeck7) {
            _currentItem++;
            _currentSection = SSPokerSectionDeck1 + _currentItem;
        }
        
        if (_currentItem <= SSPokerSectionDeck7) {
            // 次のポーカーを配布する
            [self distributePoker];
            
        } else {
            // ポーカー配布が完了次第、残りポーカーを山札へ移す。
            __block NSInteger capacity = [_randomPokers count];
            NSMutableArray *pokersForYamafuda = [_allPokers objectAtIndex:SSPokerSectionYamafuda];
            NSMutableArray *pokersForHidden = [_allPokers objectAtIndex:SSPokerSectionHidden];
            
            for (NSInteger index = 0; index < capacity; index++) {
                SSPoker *poker = [_randomPokers lastObject];
                
                if (index < _numberOfPokers) {
                    [pokersForYamafuda addObject:poker];
                } else {
                    [pokersForHidden addObject:poker];
                }
                [_randomPokers removeLastObject];
            }
            [_pokerView performBatchUpdates:^{
                [_pokerView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(SSPokerSectionYamafuda, 1)]];
            } completion:^(BOOL finished) {
                _pokerLayout.currentMode = SSPokerViewLayoutModeChallenge;
                
            }];
        }
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return SSPokerSectionTotal;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section >= SSPokerSectionHidden) {
        return 0;
    }
    NSArray *pokers = [_allPokers objectAtIndex:section];
    return [pokers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *pokers = [_allPokers objectAtIndex:indexPath.section];
    SSPoker *poker = [pokers objectAtIndex:indexPath.item];
    SSPokerViewCell *pokerCell = (SSPokerViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPokerViewCellIdentifier forIndexPath:indexPath];
    pokerCell.poker = poker;
    return pokerCell;
}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;
{
    if (indexPath.section == toIndexPath.section) {
        return NO;
    }
    NSMutableArray *fromPokers = [_allPokers objectAtIndex:indexPath.section];
    NSMutableArray *toPokers = [_allPokers objectAtIndex:toIndexPath.section];
    SSPoker *poker = [fromPokers lastObject];
    SSPoker *targetPoker = [toPokers lastObject];
    return [poker isValidNeighbourToPoker:targetPoker inSection:toIndexPath.section];
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section == toIndexPath.section) {
        return;
    }
    NSMutableArray *fromPokers = [_allPokers objectAtIndex:fromIndexPath.section];
    NSMutableArray *toPokers = [_allPokers objectAtIndex:toIndexPath.section];
    
    SSPoker *poker = [fromPokers objectAtIndex:fromIndexPath.item];
    if (toIndexPath.section > SSPokerSectionYamafuda) {
        [poker setFinished:YES];
    } else {
        [poker setFinished:NO];
    }
    [fromPokers removeLastObject];
    [toPokers addObject:poker];
}

- (void)collectionView:(UICollectionView *)collectionView didMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;
{
    NSIndexPath *preIndexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
    SSPokerViewCell *cell = (SSPokerViewCell *)[_pokerView cellForItemAtIndexPath:preIndexPath];
    if (cell) {
        [cell.poker setFaceUp:YES];
        [cell setNeedsLayout];
    }
    
    // ゲーム完了可否チェック
    [self completGameIfNecessary];
}

- (void)collectionView:(UICollectionView *)collectionView moveItemsFromSection:(NSInteger)section;
{
    // ポーカー有無チェック
    NSMutableArray *pokers = [_allPokers objectAtIndex:section];
    if (![pokers count]) {
        return;
    }
    
    // ポーカー移動可否チェック
    NSInteger toSection;
    NSInteger count = [self moveableItemsInSection:section toSection:&toSection];
    if (count) {
        [self movePokersFromSection:section toSection:toSection count:count];
    } else {
        DebugLog(@"移動不可です。");
    }
}

- (void)movePokersFromSection:(NSInteger)fromSection toSection:(NSInteger)toSection count:(NSInteger)count
{
    // 移動元
    NSMutableArray *fromPokers = [_allPokers objectAtIndex:fromSection];
    NSMutableArray *fromIndexPaths = [NSMutableArray arrayWithCapacity:count];
    
    // 移動先
    NSMutableArray *toPokers = [_allPokers objectAtIndex:toSection];
    NSMutableArray *toIndexPaths = [NSMutableArray arrayWithCapacity:count];
    
    // データ編集
    NSInteger location = [fromPokers count] - count;
    for (NSInteger index = location; index < [fromPokers count]; index++) {
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:index inSection:fromSection];
        [fromIndexPaths addObject:fromIndexPath];
        
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:[toPokers count] inSection:toSection];
        [toIndexPaths addObject:toIndexPath];
        
        SSPoker *poker = [fromPokers objectAtIndex:index];
        [toPokers addObject:poker];
        if (toSection > SSPokerSectionYamafuda) {
            [poker setFinished:YES];
        } else {
            [poker setFinished:NO];
        }
    }
    NSRange range = NSMakeRange(location, count);
    [fromPokers removeObjectsInRange:range];
    
    // アニメーション表示
    [_pokerView performBatchUpdates:^{
        for (NSInteger index = 0; index < [fromIndexPaths count]; index++) {
            NSIndexPath *from = [fromIndexPaths objectAtIndex:index];
            NSIndexPath *to = [toIndexPaths objectAtIndex:index];
            [_pokerView moveItemAtIndexPath:from toIndexPath:to];
        }
    }completion:^(BOOL finished) {
        NSMutableIndexSet *updateIndex = [NSMutableIndexSet indexSetWithIndex:fromSection];
        [updateIndex addIndex:toSection];
        if (fromSection < SSPokerSectionYamafuda) {
            // 次のポーカーを表示にする
            NSInteger item = [(NSIndexPath *)[fromIndexPaths objectAtIndex:0] item];
            if (item > 0) {
                item--;
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:fromSection];
                SSPokerViewCell * cell = (SSPokerViewCell *)[_pokerView cellForItemAtIndexPath:lastIndexPath];
                if (cell) {
                    [cell.poker setFaceUp:YES];
                    [cell setNeedsLayout];
                }
            }
            
        } else if (fromSection == SSPokerSectionYamafuda) {
            // 山札補完
            NSMutableArray *yamafudaPokers = [_allPokers objectAtIndex:SSPokerSectionYamafuda];
            if ([yamafudaPokers count] == 0) {
                // 補完要と扱う
                NSMutableArray *hiddenPokers = [_allPokers objectAtIndex:SSPokerSectionHidden];
                if ([hiddenPokers count] == 0) {
                    NSMutableArray *recyclePokers = [_allPokers objectAtIndex:SSPokerSectionRecycle];
                    [hiddenPokers addObjectsFromArray:recyclePokers];
                    [recyclePokers removeAllObjects];
                }
                
                if ([hiddenPokers count]) {
                    NSInteger len = 0;
                    for (NSInteger i = 0; i < [hiddenPokers count] && i < _numberOfPokers; i++) {
                        SSPoker *poker = [hiddenPokers objectAtIndex:i];
                        [yamafudaPokers addObject:poker];
                        len++;
                    }
                    NSRange range = NSMakeRange(0, len);
                    [hiddenPokers removeObjectsInRange:range];
                }
                [updateIndex addIndex:SSPokerSectionYamafuda];
            }
        }
        
        _pokerLayout.currentSection = toSection;
        [_pokerView.collectionViewLayout invalidateLayout];
        [_pokerView reloadSections:updateIndex];

        // ゲーム完了可否チェック
        [self completGameIfNecessary];
    }];
}

- (NSInteger)moveableItemsInSection:(NSInteger)section toSection:(NSInteger *)to
{
    BOOL topEnabled = NO;
    BOOL neighbourEnabled = NO;
    BOOL deckEnabled = NO;
    NSInteger maxItems = 0;
    NSInteger toSection = NSIntegerMin;
    NSInteger moveableItems = 0;
    
    if (section < SSPokerSectionYamafuda) {
        // プレイン中
        topEnabled = YES;
        neighbourEnabled = YES;
    } else if (section == SSPokerSectionYamafuda) {
        // 山札
        topEnabled = YES;
        deckEnabled = YES;
    } else {
        // 完了済み
        deckEnabled = YES;
    }
    
    // 上へ移動可否チェック
    if (topEnabled) {
        NSMutableArray *pokers = [_allPokers objectAtIndex:section];
        SSPoker *poker = (SSPoker *)[pokers lastObject];
        
        NSInteger to = [poker sectionForCurrentColor];
        NSMutableArray *topPokers = [_allPokers objectAtIndex:to];
        SSPoker *lastTopPoker = [topPokers lastObject];
        if ([poker isValidNeighbourToPoker:lastTopPoker inSection:to]) {
            moveableItems = 1;
            if (moveableItems > maxItems) {
                maxItems = moveableItems;
                toSection = to;
            }
        }
    }
    
    // 下に移動可否チェック
    if (deckEnabled) {
        NSMutableArray *pokers = [_allPokers objectAtIndex:section];
        SSPoker *poker = (SSPoker *)[pokers lastObject];
        
        for (NSInteger deck = SSPokerSectionDeck1; deck <= SSPokerSectionDeck7; deck++) {
            // 移動可否チェック
            SSPoker *targetPoker = [self lastPokerInSection:deck];
            if ([poker isValidNeighbourToPoker:targetPoker inSection:deck]) {
                moveableItems = 1;
                if (moveableItems > maxItems) {
                    maxItems = moveableItems;
                    toSection = deck;
                }
            }
        }
    }
    
    // 両側へ移動可否チェック
    if (neighbourEnabled) {
        NSMutableArray *pokers = [_allPokers objectAtIndex:section];
        SSPoker *poker = nil;
        NSInteger level = 0, maxLevel = 0;
        NSInteger distance = 0, minDistance = 0;
        NSInteger count = [pokers count];
        NSInteger bestSection = 0;
        SSPoker *targetPoker;
        BOOL end = NO;
        NSInteger firstVisibleItem = [self firstVisiblePokersInSection:section];
        for (NSInteger deck = SSPokerSectionDeck1; deck <= SSPokerSectionDeck7; deck++) {
            // 同一セクションの場合、飛び出す
            if (deck == section) {
                continue;
            }
            
            // 移動可否チェック
            targetPoker = [self lastPokerInSection:deck];
            level = count - firstVisibleItem;
            distance = (NSInteger)abs((int)(deck - section));
            for (NSInteger i = firstVisibleItem; i < count; i++) {
                poker = [pokers objectAtIndex:i];
                if ([poker isValidNeighbourToPoker:targetPoker inSection:deck]) {
                    if (targetPoker || (!targetPoker && i != 0)) {
                        if (level > maxLevel) {
                            bestSection = deck;
                            maxLevel = level;
                            minDistance = distance;
                            break;
                        } else if (level == maxLevel) {
                            if (distance < minDistance) {
                                bestSection = deck;
                                minDistance = distance;
                                break;
                            }
                        }
                    } else {
                        poker = [pokers lastObject];
                        if (poker.name == SSPokerNameK  && i != 0) {
                            bestSection = deck;
                            maxLevel = 1;
                            end = YES;
                            break;
                        }
                    }
                }
                level--;
            }
            if (end) {
                break;
            }
        }
        
        if (maxLevel > maxItems) {
            maxItems = maxLevel;
            toSection = bestSection;
        }
    }
    *to = toSection;
    return maxItems;
}

- (SSPoker *)lastPokerInSection:(NSInteger)section
{
    NSArray *array = [_allPokers objectAtIndex:section];
    if ([array count]) {
        return (SSPoker *)[array objectAtIndex:array.count - 1];
    }
    return nil;
}

- (NSInteger)firstVisiblePokersInSection:(NSInteger)section;
{
    NSArray *array = [_allPokers objectAtIndex:section];
    NSInteger item = NSNotFound;
    for (NSInteger i = 0; i < [array count]; i++) {
        SSPoker *poker = [array objectAtIndex:i];
        if (poker.displayOptions & SSPokerOptionShowFaceUp) {
            item = i;
            break;
        }
    }
    return item;
}

#pragma mark - 山札戻し
//  山札戻し実行
- (void)willUseYamafuda;
{
    NSMutableArray *recyclePokers = [_allPokers objectAtIndex:SSPokerSectionRecycle];
    NSMutableArray *yamafudaPokers = [_allPokers objectAtIndex:SSPokerSectionYamafuda];
    NSMutableArray *hiddenPokers = [_allPokers objectAtIndex:SSPokerSectionHidden];
    
    // 山札戻しの場合
    if (_yamafudaButton.displayMode == YamafudaDisplayModeReturn) {
        [recyclePokers addObjectsFromArray:yamafudaPokers];
        [hiddenPokers addObjectsFromArray:recyclePokers];
        [recyclePokers removeAllObjects];
        [yamafudaPokers removeAllObjects];
        
        // 山札戻し使用
        [_yamafudaButton useYamafudaReturn];
    }
    
    // 山札に残ったトランプをリサイクルする
    if ([yamafudaPokers count]) {
        [recyclePokers addObjectsFromArray:yamafudaPokers];
        [yamafudaPokers removeAllObjects];
    }
    
    // 山札へ新しいトランプを追加する
    NSInteger count = [hiddenPokers count];
    NSInteger index = 0;
    NSInteger max;
    if (_numberOfPokers > count) {
        max = count;
    } else {
        max = _numberOfPokers;
    }
    while (index < max) {
        SSPoker *poker = [hiddenPokers objectAtIndex:index];
        [yamafudaPokers addObject:poker];
        index++;
    }
    NSRange range = NSMakeRange(0, max);
    [hiddenPokers removeObjectsInRange:range];
    
    // 山札を更新する
    [_pokerView performBatchUpdates:^{
        [_pokerView reloadSections:[NSIndexSet indexSetWithIndex:SSPokerSectionYamafuda]];
    }completion:^(BOOL finished) {
        // ゲーム完了可否チェック
        [self completGameIfNecessary];
    }];
    
    // 山札戻しボター表示状態更新
    if (![self isFreeMode]) {
        if (![hiddenPokers count]) {
            if ([recyclePokers count]) {
                // 山札戻し
                _yamafudaButton.displayMode = YamafudaDisplayModeReturn;
            } else {
                // ショップ
                _yamafudaButton.displayMode = YamafudaDisplayModeBuy;
            }
        } else {
            // 山札にトランプがある場合
            _yamafudaButton.displayMode = YamafudaDisplayModeUsable;
        }
    }
}

// ショップ表示
- (void)willPresentShop;
{
    
}

// ゲーム完了可否チェック
- (void)completGameIfNecessary;
{
    // カード引き枚数変更チェック
    if ([self isFreeMode]) {
        [_reversePokers removeAllObjects];
    }
    
    // 完了チェック
    if ([self isFinishedSolitaire]) {
        [self willCompletSolitaire];
    }
}

// 完了チェック
- (BOOL)isFinishedSolitaire
{
    // 山札チェック
    NSArray *yamafudaPokers = [_allPokers objectAtIndex:SSPokerSectionYamafuda];
    if ([yamafudaPokers count]) {
        return NO;
    }

    BOOL finished = YES;
    
    // 非表示ポーカー有無チェック
    for (NSInteger section = SSPokerSectionHidden; section < SSPokerSectionTotal; section++) {
        NSArray *pokers = [_allPokers objectAtIndex:section];
        if ([pokers count]) {
            finished = NO;
            break;
        }
    }
    if (!finished) {
        return NO;
    }
    
    for (NSInteger section = SSPokerSectionDeck1; section <= SSPokerSectionDeck7; section++) {
        NSArray *pokers = [_allPokers objectAtIndex:section];
        for (NSInteger i = 0; i < [pokers count]; i++) {
            SSPoker *poker = [pokers objectAtIndex:i];
            if (!(poker.displayOptions & SSPokerOptionShowFaceUp)) {
                finished = NO;
                break;
            }
        }
        if (!finished) {
            break;
        }
    }
    return finished;
}

- (void)willCompletSolitaire;
{
    // タイマー停止
    if ([self.updateTimer isValid]) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }

    // アニメーション表示
    _completed = NO;
    [self completeAnimation];
}

- (void)completeAnimation
{
    if (_completed) {
        return;
    }
    
    _completed = YES;
    for (NSInteger section = SSPokerSectionDeck1; section <= SSPokerSectionDeck7; section++) {
        // 最後のポーカーを取得する
        NSMutableArray *pokers = [_allPokers objectAtIndex:section];
        if (![pokers count]) {
            continue;
        }
        
        // 未完了と扱う
        _completed = NO;
        
        // 移動可否チェック
        SSPoker *lastPoker = [pokers lastObject];
        NSInteger targetSection = [lastPoker sectionForCurrentColor];
        NSMutableArray *targetPokers = [_allPokers objectAtIndex:targetSection];
        SSPoker *targetPoker = [targetPokers lastObject];
        if ([lastPoker isValidNeighbourToPoker:targetPoker inSection:targetSection]) {
            // アニメーション表示
            [targetPokers addObject:lastPoker];
            [lastPoker setFinished:YES];
            [pokers removeLastObject];
            
            [_pokerView performBatchUpdates:^{
                NSIndexPath *from = [NSIndexPath indexPathForItem:[pokers count] inSection:section];
                NSIndexPath *to = [NSIndexPath indexPathForItem:[targetPokers count] - 1 inSection:targetSection];
                [_pokerView moveItemAtIndexPath:from toIndexPath:to];
            }completion:^(BOOL finished) {
                [self completeAnimation];
            }];
            break;
        }
    }
}
@end
