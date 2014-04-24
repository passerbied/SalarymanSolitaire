//
//  SSPokerView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-31.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPokerView.h"
#import "SSPokerViewLayout.h"

#define kPokerShuffleTotalCount         28
@interface SSPokerView ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSInteger                           _pokerMaxCount;
    SSPokerAnimationMode                _animationMode;
    BOOL                                _animating;
}

@property (nonatomic, strong) SSPokerViewLayout *shuffleLayout;
@property (nonatomic, strong) SSPokerViewLayout *fanLayout;

@end

@implementation SSPokerView
{
    // ポーカー
    NSMutableArray                      *_randomPokers;
    NSMutableArray                      *_allPokers;
    
    // シャッフル
    NSInteger                           _currentItem;
    NSInteger                           _currentSection;
    NSInteger                           _currentIndex;
    
    // タッチ
    UITapGestureRecognizer              *_tapGestureRecognizer;
    
    BOOL                                _first;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

+ (instancetype)pokerView;
{
    SSPokerViewLayout *layout = [[SSPokerViewLayout alloc] init];
    return [[self alloc] initWithFrame:CGRectMake(0, 0, 320, 404) collectionViewLayout:layout];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    // ポーカービュー設定
    [self registerClass:[SSPokerViewCell class] forCellWithReuseIdentifier:@"SSPokerViewCell"];
    self.backgroundColor = [UIColor clearColor];
    self.fanLayout = (SSPokerViewLayout *)self.collectionViewLayout;
    self.delegate = self;
    self.dataSource = self;
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
    
    // 初期化
    _pokerMaxCount = SSPokerColorCount * SSPokerNameCount;
    if (!_randomPokers) {
        _randomPokers = [NSMutableArray arrayWithCapacity:_pokerMaxCount];
    }
    if (!_allPokers) {
        _allPokers = [NSMutableArray arrayWithCapacity:SSPokerSectionTotal];
        for (NSInteger section = 0; section < SSPokerSectionTotal; section++) {
            [_allPokers addObject:[NSMutableArray array]];
        }
    }
    
    // シャッフル
    [self shuffle];
}

// シャッフル
- (void)shuffle
{
    // 初期化
    if (_randomPokers) {
        [_randomPokers removeAllObjects];
    } else {
        _randomPokers = [NSMutableArray arrayWithCapacity:_pokerMaxCount];
    }
    
    // 手当たり次第、ポーカー作成
    SSPokerColor color = SSPokerColorHeart;
    for (NSInteger i = 0; i < SSPokerColorCount; i++) {
        SSPokerName name = SSPokerNameA;
        for (NSInteger j = 0; j < SSPokerNameCount; j++) {
            SSPoker *poker = [SSPoker new];
            poker.color = color;
            poker.name = name;
            poker.visible = NO;
            poker.faceUp = NO;
            [_randomPokers addObject:poker];
            
            name++;
        }
        color++;
    }
    for (NSInteger index = 0; index < _pokerMaxCount; index++) {
        NSInteger randomIndex = arc4random()%_pokerMaxCount;
        if (index != randomIndex) {
            [_randomPokers exchangeObjectAtIndex:index withObjectAtIndex:randomIndex];
        }
    }
}

- (void)clear
{
    for (NSInteger section = SSPokerSectionDeck; section < SSPokerSectionTotal; section++) {
        NSMutableArray *pokers = [_allPokers objectAtIndex:section];
        [pokers removeAllObjects];
    }
    [self reloadData];
}

// ゲーム開始（シャッフル必要）
- (void)start;
{
    [self dealPokerWithShuffle:YES];
}

// リトライ（シャッフル不要）
- (void)retry;
{
    [self dealPokerWithShuffle:NO];
}

- (void)dealPokerWithShuffle:(BOOL)shuffle
{
    // ポーカークリア
    [self clear];
    
    if (shuffle) {
        // シャッフル
        [self shuffle];
    }
    
    // ポーカー配布アニメーション表示
    [self playDealPokerAnimation];
}

- (void)playDealPokerAnimation;
{
    _animationMode = SSPokerAnimationModeFan;
    _currentItem = 0;
    _currentIndex = 0;
    _currentSection = 0;
    [self addPokerToDeck];
}

- (void)addPokerToDeck
{
    NSInteger item = _currentItem;
    if (_currentItem >= _pokerMaxCount) {
        [self playShuffleAnimation];
        return;
    }
    SSPoker *poker = [_randomPokers objectAtIndex:_currentItem];
    
    NSMutableArray *deckPokers = [_allPokers objectAtIndex:SSPokerSectionDeck];
    [deckPokers addObject:poker];
    _currentItem++;
    [self performBatchUpdates:^{
        if (item == 0) {
            [self reloadSections:[NSIndexSet indexSetWithIndex:SSPokerSectionDeck]];
        } else {
            [self insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:item inSection:SSPokerSectionDeck]]];
        }
    } completion:^(BOOL finished) {
        [self addPokerToDeck];
    }];
}

- (void)playShuffleAnimation
{
    _animationMode = SSPokerAnimationModeShuffle;
    _currentIndex = _pokerMaxCount - 1;
    _currentItem = 0;
    _currentSection = SSPokerSectionPlaying1;
    [self addPoker];
}

- (void)addPoker
{
    NSInteger section = _currentSection;
    NSInteger item = _currentItem;
    NSMutableArray *deckPokers = [_allPokers objectAtIndex:SSPokerSectionDeck];
    SSPoker *poker = [deckPokers lastObject];

    NSMutableArray *playingPokers = [_allPokers objectAtIndex:_currentSection];
    [playingPokers addObject:poker];
    if ([playingPokers count] == _currentSection) {
        poker.faceUp = YES;
    } else {
        poker.faceUp = NO;
    }
    [deckPokers removeLastObject];

    [self performBatchUpdates:^{
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:SSPokerSectionDeck];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        [self moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        SSPokerViewCell * cell = (SSPokerViewCell *)[self cellForItemAtIndexPath:fromIndexPath];
        [cell setAnimationMode:_animationMode];
        cell.poker = poker;
    } completion:^(BOOL finished) {
        _currentIndex--;
        _currentSection++;
        if (_currentSection > SSPokerSectionPlaying7) {
            _currentItem++;
            _currentSection = SSPokerSectionPlaying1 + _currentItem;
        }
        
        if (_currentItem <= 6) {
            [self addPoker];
        } else {
            __block NSInteger capacity = [deckPokers count];
            __block NSMutableArray *fromArray = [NSMutableArray arrayWithCapacity:capacity];
            __block NSMutableArray *toArray = [NSMutableArray arrayWithCapacity:capacity];
            _currentItem = 0;
            
            NSMutableArray *usablePokers = [_allPokers objectAtIndex:SSPokerSectionUsable];
            for (NSInteger index = capacity - 1; index >= 0; index--) {
                NSIndexPath *from = [NSIndexPath indexPathForItem:index inSection:SSPokerSectionDeck];
                [fromArray addObject:from];
                SSPoker *poker = [deckPokers lastObject];
                [usablePokers addObject:poker];
                [deckPokers removeLastObject];
                NSIndexPath *to = [NSIndexPath indexPathForItem:_currentItem inSection:SSPokerSectionUsable];
                [toArray addObject:to];
                _currentItem++;
            }
            [self performBatchUpdates:^{
                capacity = [fromArray count];
                for (NSInteger i = 0;i < capacity; i++) {
                    NSIndexPath *from = [fromArray objectAtIndex:i];
                    NSIndexPath *to = [toArray objectAtIndex:i];
                    [self moveItemAtIndexPath:from toIndexPath:to];
                }
                
            } completion:^(BOOL finished) {
                _animationMode = SSPokerAnimationModePlay;
            }];
        }
    }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return SSPokerSectionTotal;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *pokers = [_allPokers objectAtIndex:section];
    return [pokers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *pokers = [_allPokers objectAtIndex:indexPath.section];
    SSPoker *poker = [pokers objectAtIndex:indexPath.item];;
//    DebugLog(@"%@: [%d-%d]",indexPath,poker.color,poker.name);
    
    SSPokerViewCell *pokerCell = (SSPokerViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SSPokerViewCell" forIndexPath:indexPath];
    pokerCell.poker = poker;
    [pokerCell setAnimationMode:_animationMode];
    return pokerCell;
}


- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_animating) {
        return;
    }
    CGPoint location;
    NSIndexPath *currentIndexPath;
    NSInteger section;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded: {
            location = [gestureRecognizer locationInView:self];
            currentIndexPath = [self indexPathForItemAtPoint:location];
            if (currentIndexPath) {
                section = currentIndexPath.section;
                if (section < SSPokerSectionUsable) {
                    [self movePokersFromSection:section];
                } else if (section == SSPokerSectionUsable) {
                    
                } else {
                    
                }
            }
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
}

- (void)movePokersFromSection:(NSInteger)section
{
    NSMutableArray *pokers = [_allPokers objectAtIndex:section];
    if (![pokers count]) {
        // 空
        return;
    }
    
    SSPoker *poker = (SSPoker *)[pokers lastObject];
    if (section < SSPokerSectionUsable) {
        // 仕上げ可能チェック
        NSInteger targetSection = [poker sectionForCurrentColor];
        NSMutableArray *targetPokers = [_allPokers objectAtIndex:targetSection];
        SSPoker *targetPoker = [targetPokers lastObject];
        if ([poker canMoveToWithPoker:targetPoker inSection:targetSection]) {
            [self movePokerFromSection:section toSection:targetSection count:1];
            return;
        }
        
        BOOL canMove = NO;
        
        // 横へ移動可能チェック
        NSInteger maxLevel = 0;
        NSInteger level = 0;
        NSInteger count = [pokers count];
        NSInteger bestSection;
        NSInteger firstPoker = [self firstVisiblePokersInSection:section];
        for (targetSection = SSPokerSectionPlaying1; targetSection <= SSPokerSectionPlaying7; targetSection++) {
            if (targetSection == section) {
                continue;
            }
            targetPoker = [self lastPokerInSection:targetSection];
            if ([poker canMoveToWithPoker:targetPoker inSection:targetSection]) {
                canMove = YES;
                break;
            }

            targetPoker = [self lastPokerInSection:targetSection];
            level = 0;
            for (NSInteger i = firstPoker; i < count; i++) {
                poker = [pokers objectAtIndex:i];
                if ([poker canMoveToWithPoker:targetPoker inSection:targetSection]) {
                    level = count - i;
                    if (level > maxLevel) {
                        maxLevel = level;
                        bestSection = targetSection;
                    }
                    break;
                }
            }
        }
        if (canMove) {
            [self movePokerFromSection:section toSection:targetSection count:1];
            return;
        }
        
        if (maxLevel) {
            [self movePokerFromSection:section toSection:bestSection count:maxLevel];
        }
        
        // 空列に移動可能チェック
    }
}

- (void)movePokerFromSection:(NSInteger)section toSection:(NSInteger)newSection count:(NSInteger)count;
{
    _animating = YES;
    
    // 移動元
    NSMutableArray *fromPokers = [_allPokers objectAtIndex:section];
    NSMutableArray *fromIndexPaths = [NSMutableArray arrayWithCapacity:count];
    
    // 移動先
    NSMutableArray *toPokers = [_allPokers objectAtIndex:newSection];
    NSMutableArray *pokers = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *toIndexPaths = [NSMutableArray arrayWithCapacity:count];
    
    // データ編集
    NSInteger firstItem = [fromPokers count] - 1;
    NSInteger lastItem = firstItem - count;
    NSInteger atItem = [toPokers count];
    for (NSInteger item = firstItem; item > lastItem; item--) {
        SSPoker *poker = [fromPokers objectAtIndex:item];
        [pokers addObject:poker];
        if (newSection > SSPokerSectionUsable) {
            [poker setFinished:YES];
        } else {
            [poker setFinished:NO];
        }
        [fromPokers removeObjectAtIndex:item];
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        [fromIndexPaths addObject:fromIndexPath];

        NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:atItem inSection:newSection];
        [toIndexPaths addObject:toIndexPath];
        
        atItem++;
    }
    for (NSInteger i = count - 1; i >= 0; i--) {
        SSPoker *poker = [pokers objectAtIndex:i];
        [toPokers addObject:poker];
    }
    
    [self performBatchUpdates:^{
        for (NSInteger i = 0; i < [fromIndexPaths count]; i++) {
            NSIndexPath *from = [fromIndexPaths objectAtIndex:[fromIndexPaths count] - 1 - i];
            NSIndexPath *to = [toIndexPaths objectAtIndex:i];
            SSPokerViewCell * cell = (SSPokerViewCell *)[self cellForItemAtIndexPath:from];
            [cell setAnimationMode:SSPokerAnimationModePlay];
            [self moveItemAtIndexPath:from toIndexPath:to];
        }
    }completion:^(BOOL finished) {
        NSInteger item = [(NSIndexPath *)[fromIndexPaths objectAtIndex:0] item];
        item -= [fromIndexPaths count];
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        SSPokerViewCell * cell = (SSPokerViewCell *)[self cellForItemAtIndexPath:lastIndexPath];
        [cell setPokerFaceUp:YES];
        _animating = NO;
    }];
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
        if ([poker isFaceUp]) {
            item = i;
            break;
        }
    }
    return item;
}
@end
