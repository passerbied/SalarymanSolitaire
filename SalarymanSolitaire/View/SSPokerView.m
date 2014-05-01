//
//  SSPokerView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-31.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPokerView.h"
#import "SSPokerViewLayout.h"

@protocol YamafudaDelegate <NSObject>
@required
//  山札戻し実行
- (void)willUseYamafuda;

// ショップ表示
- (void)willPresentShop;
@end

@interface YamafudaButton : UIView
{
    // 山札戻しの回数
    UILabel                             *_numbersLabel;
    
    // 背景イメージ
    UIImageView                         *_backgroundImageView;
}

// 委託対象
@property (nonatomic, weak) id<YamafudaDelegate> delegate;

// 山札戻しの回数
@property (nonatomic) NSInteger usableYamafudas;

// フリープレイモード
@property (nonatomic, getter = isFreeMode) BOOL freeMode;

// 利用可否（山札足りない場合、利用不可
@property (nonatomic) BOOL usable;

// 初期化
- (instancetype)initWithDelegate:(id<YamafudaDelegate>)delegate;

@end


@implementation YamafudaButton

- (instancetype)initWithDelegate:(id<YamafudaDelegate>)delegate
{
    CGRect rect = [SSPokerViewLayout rectForYamafuda];
    self = [super initWithFrame:rect];
    if (self) {
        _usable = YES;
        _delegate = delegate;
        
        // 背景イメージビュー作成
        rect.origin = CGPointMake(0.0f, 0.0f);
        _backgroundImageView = [[UIImageView alloc] initWithFrame:rect];
        _backgroundImageView.userInteractionEnabled = YES;
        
        [self addSubview:_backgroundImageView];
        
        // 山札戻し回数ラベル作成
        CGFloat size = 20.0f;
        CGFloat x = (rect.size.width - size)/2.0f;
        CGFloat y = 6.0f;
        rect = CGRectMake(x, y, size, size);
        _numbersLabel = [[UILabel alloc] initWithFrame:rect];
        _numbersLabel.backgroundColor = [UIColor whiteColor];
        _numbersLabel.clipsToBounds = YES;
        _numbersLabel.layer.cornerRadius = size/2.0f;
        _numbersLabel.textColor = [UIColor blackColor];
        _numbersLabel.font = SSGothicProFont(12.0f);
        _numbersLabel.textAlignment = NSTextAlignmentCenter;
        _numbersLabel.userInteractionEnabled = YES;
        [self addSubview:_numbersLabel];
        
        _usableYamafudas = -1;
        
        // タップ処理追加
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yamafudaDidTouched:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setFreeMode:(BOOL)freeMode
{
    _freeMode = freeMode;
    if (_freeMode) {
        _backgroundImageView.image = [UIImage imageNamed:@"free_icon_yamafuda.png"];
        _numbersLabel.hidden = YES;
    } else {
        _backgroundImageView.image = [UIImage imageNamed:@"product_item.png"];
        _numbersLabel.hidden = NO;
    }
}

- (void)setUsableYamafudas:(NSInteger)usableYamafudas
{
    if (_usableYamafudas == usableYamafudas) {
        return;
    }
    _usableYamafudas = usableYamafudas;
    
    // 山戻し回数表示
    if (_usableYamafudas) {
        _numbersLabel.hidden = NO;
        _numbersLabel.text = [NSString stringWithFormat:@"%d", _usableYamafudas];
    } else {
        _numbersLabel.hidden = YES;
    }
    
}

- (void)yamafudaDidTouched:(UITapGestureRecognizer *)tapGesture;
{
    // 利用可否チェック
    if (!_usable) {
        return;
    }

    // ステータスチェック
    if (tapGesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    if (_freeMode) {
        // フリープレイモードの場合、山札戻しを実行する
        [_delegate willUseYamafuda];
    } else {
        // 山札戻し回数チェック
        if (_usableYamafudas) {
            // 山札戻し回数更新
            NSInteger count = _usableYamafudas - 1;
            self.usableYamafudas = count;
            
            // 山札戻しの回数が「０」になった場合、追加ボタンの形で表示させる
            if (count == 0) {
                _usableYamafudas = 0;
                _backgroundImageView.image = [UIImage imageNamed:@"btn_more_card.png"];
            }
            
            // 山札戻しを実行する
            [_delegate willUseYamafuda];
        } else {
            // ショップを表示する
            [_delegate willPresentShop];
        }
    }
}
@end

#define kPokerShuffleTotalCount         28
@interface SSPokerView ()<UICollectionViewDataSource, UICollectionViewDelegate, YamafudaDelegate>
{
    NSInteger                           _pokerMaxCount;
    SSPokerAnimationMode                _animationMode;
    BOOL                                _animating;
}

@property (nonatomic, strong) SSPokerViewLayout *pokerLayout;

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
    
    // 山札戻し
    YamafudaButton                      *_yamafuda;
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
    
    self.collectionViewLayout = [[SSPokerViewLayout alloc] init];
    [self setup];
}

- (void)setup
{
    // ポーカービュー設定
    [self registerClass:[SSPokerViewCell class] forCellWithReuseIdentifier:@"SSPokerViewCell"];
    self.backgroundColor = [UIColor clearColor];
    self.pokerLayout = (SSPokerViewLayout *)self.collectionViewLayout;
    self.delegate = self;
    self.dataSource = self;
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
    
    _yamafuda = [[YamafudaButton alloc] initWithDelegate:self];
    [self addSubview:_yamafuda];
    
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
}

- (void)setFreeMode:(BOOL)freeMode
{
    _yamafuda.freeMode = freeMode;
}

- (void)setUsableYamafudas:(NSInteger)usableYamafudas
{
    _yamafuda.usableYamafudas = usableYamafudas;
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
            SSPoker *poker = [SSPoker pokerWithColor:color name:name];
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
    for (NSInteger section = SSPokerSectionDeck1; section < SSPokerSectionTotal; section++) {
        NSMutableArray *pokers = [_allPokers objectAtIndex:section];
        [pokers removeAllObjects];
    }
    [self reloadData];
}

// ゲーム開始（シャッフル必要）
- (void)start;
{
    // 山札戻し利用可能にする
    _yamafuda.usable = YES;
    
    // ポーカークリア
    [self clear];
    
    // シャッフル
    [self shuffle];
    
    // 配布アニメーション表示
    [self playDistributeAnimation];
}

// 配布アニメーション表示
- (void)playDistributeAnimation
{
    // 初期化
    _animationMode = SSPokerAnimationModeDistribute;
    _currentItem = 0;
    _currentIndex = _pokerMaxCount - 1;
    _currentSection = SSPokerSectionDeck1;
    
    // ポーか配布
    [self distributePoker];
}

- (void)distributePoker
{
    // ビリからポーカーを配布する
    SSPoker *lastPoker = [_randomPokers lastObject];
    NSMutableArray *currentPokers = [_allPokers objectAtIndex:_currentSection];
    if ([currentPokers count] == _currentSection) {
        lastPoker.faceUp = YES;
    } else {
        lastPoker.faceUp = NO;
    }
    [currentPokers addObject:lastPoker];
    [_randomPokers removeLastObject];
    
    [self performBatchUpdates:^{
        // ポーカー追加
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentItem inSection:_currentSection];
        if (_currentItem == 0) {
            [self reloadSections:[NSIndexSet indexSetWithIndex:_currentSection]];
        } else {
            [self insertItemsAtIndexPaths:@[indexPath]];
        }
    } completion:^(BOOL finished) {
        _currentIndex--;
        _currentSection++;
        if (_currentSection > SSPokerSectionDeck7) {
            _currentItem++;
            _currentSection = SSPokerSectionDeck1 + _currentItem;
        }
        
        if (_currentItem <= SSPokerSectionDeck7) {
            [self distributePoker];
        } else {
            _yamafudaMax = 3;
            __block NSInteger capacity = [_randomPokers count];
            NSMutableArray *yamafudaPokers = [_allPokers objectAtIndex:SSPokerSectionYamafuda];
            NSMutableArray *hiddenPokers = [_allPokers objectAtIndex:SSPokerSectionHidden];
            
            for (NSInteger index = 0; index < capacity; index++) {
                SSPoker *poker = [_randomPokers lastObject];
                
                poker.faceUp = YES;
                if (index < _yamafudaMax) {
                    [yamafudaPokers addObject:poker];
                } else {
                    [hiddenPokers addObject:poker];
                }
                [_randomPokers removeLastObject];
            }
            [self performBatchUpdates:^{
                [self reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(SSPokerSectionYamafuda, 1)]];
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
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded: {
            location = [gestureRecognizer locationInView:self];
            currentIndexPath = [self indexPathForItemAtPoint:location];
            if (currentIndexPath) {
                [self movePokersFromSection:currentIndexPath.section];
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

//- (void)movePokersFromSection:(NSInteger)section
//{
//    NSMutableArray *pokers = [_allPokers objectAtIndex:section];
//    if (![pokers count]) {
//        // 空
//        return;
//    }
//    
//    SSPoker *poker = (SSPoker *)[pokers lastObject];
//    if (section < SSPokerSectionYamafuda) {
//        // 仕上げ可能チェック
//        NSInteger targetSection = [poker sectionForCurrentColor];
//        NSMutableArray *targetPokers = [_allPokers objectAtIndex:targetSection];
//        SSPoker *targetPoker = [targetPokers lastObject];
//        if ([poker canMoveToWithPoker:targetPoker inSection:targetSection]) {
//            [self movePokerFromSection:section toSection:targetSection count:1];
//            return;
//        }
//        
//        BOOL canMove = NO;
//        
//        // 横へ移動可能チェック
//        NSInteger maxLevel = 0;
//        NSInteger level = 0;
//        NSInteger count = [pokers count];
//        NSInteger bestSection;
//        NSInteger firstPoker = [self firstVisiblePokersInSection:section];
//        for (targetSection = SSPokerSectionDeck1; targetSection <= SSPokerSectionDeck7; targetSection++) {
//            if (targetSection == section) {
//                continue;
//            }
//            targetPoker = [self lastPokerInSection:targetSection];
//            if ([poker canMoveToWithPoker:targetPoker inSection:targetSection]) {
//                canMove = YES;
//                break;
//            }
//
//            targetPoker = [self lastPokerInSection:targetSection];
//            level = 0;
//            for (NSInteger i = firstPoker; i < count; i++) {
//                poker = [pokers objectAtIndex:i];
//                if ([poker canMoveToWithPoker:targetPoker inSection:targetSection]) {
//                    level = count - i;
//                    if (level > maxLevel) {
//                        maxLevel = level;
//                        bestSection = targetSection;
//                    }
//                    break;
//                }
//            }
//        }
//        if (canMove) {
//            [self movePokerFromSection:section toSection:targetSection count:1];
//            return;
//        }
//        
//        if (maxLevel) {
//            [self movePokerFromSection:section toSection:bestSection count:maxLevel];
//        }
//        
//        // 空列に移動可能チェック
//    }
//}


- (void)movePokersFromSection:(NSInteger)section
{
    // ポーカー有無チェック
    NSMutableArray *pokers = [_allPokers objectAtIndex:section];
    if (![pokers count]) {
        return;
    }
    
    // ポーカー移動処理振替
    BOOL topEnabled = NO;
    BOOL neighbourEnabled = NO;
    BOOL deckEnabled = NO;
    
    if (section < SSPokerSectionYamafuda) {
        // プレイン中
        topEnabled = YES;
        neighbourEnabled = YES;
    } else if (section == SSPokerSectionYamafuda) {
        // 山札
        topEnabled = YES;
        deckEnabled = YES;
    } else {
        // 収めた
        deckEnabled = YES;
    }
    
    // 上へ移動可否チェック
    if (topEnabled && [self movePokerToTopFromSection:section]) {
        return;
    }
    
    // 両側へ移動可否チェック
    if (neighbourEnabled && [self movePokerToNeighbourFromSection:section]) {
        return;
    }
    
    // 下に移動可否チェック
    if (deckEnabled && [self movePokerToDeckFromSection:section]) {
        return;
    }
    DebugLog(@"移動不可です。");
}

- (BOOL)movePokerToTopFromSection:(NSInteger)from
{
    NSMutableArray *pokers = [_allPokers objectAtIndex:from];
    SSPoker *poker = (SSPoker *)[pokers lastObject];
    NSInteger to = [poker sectionForCurrentColor];
    NSMutableArray *targetPokers = [_allPokers objectAtIndex:to];
    SSPoker *lastPoker = [targetPokers lastObject];
    if ([poker isValidNeighbourToPoker:lastPoker inSection:to]) {
        [self movePokerFromSection:from toSection:to count:1];
        return YES;
    }
    return NO;
}

- (BOOL)movePokerToNeighbourFromSection:(NSInteger)from
{
    NSMutableArray *pokers = [_allPokers objectAtIndex:from];
    SSPoker *poker = nil;
    NSInteger level = 0, maxLevel = 0;
    NSInteger distance = 0, minDistance = 0;
    NSInteger count = [pokers count];
    NSInteger bestSection;
    NSInteger section;
    SSPoker *targetPoker;
    BOOL end = NO;
    NSInteger firstVisibleItem = [self firstVisiblePokersInSection:from];
    for (section = SSPokerSectionDeck1; section <= SSPokerSectionDeck7; section++) {
        // 同一セクションの場合、飛び出す
        if (section == from) {
            continue;
        }
        
        // 移動可否チェック
        targetPoker = [self lastPokerInSection:section];
        level = count - firstVisibleItem;
        distance = abs(section - from);
        for (NSInteger i = firstVisibleItem; i < count; i++) {
            poker = [pokers objectAtIndex:i];
            if ([poker isValidNeighbourToPoker:targetPoker inSection:section]) {
                if (targetPoker || (!targetPoker && i != 0)) {
                    if (level > maxLevel) {
                        bestSection = section;
                        maxLevel = level;
                        minDistance = distance;
                        break;
                    } else if (level == maxLevel) {
                        if (distance < minDistance) {
                            bestSection = section;
                            minDistance = distance;
                            break;
                        }
                    }
                } else {
                    poker = [pokers lastObject];
                    if (poker.name == SSPokerNameK  && i != 0) {
                        bestSection = section;
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
    if (maxLevel) {
        [self movePokerFromSection:from toSection:bestSection count:maxLevel];
        return YES;
    }
    return NO;
}

- (BOOL)movePokerToDeckFromSection:(NSInteger)from
{
    NSMutableArray *pokers = [_allPokers objectAtIndex:from];
    SSPoker *poker = [pokers lastObject];
    BOOL canMove = NO;
    NSInteger section;
    for (section = SSPokerSectionDeck1; section <= SSPokerSectionDeck7; section++) {
        // 移動可否チェック
        SSPoker *targetPoker = [self lastPokerInSection:section];
        if ([poker isValidNeighbourToPoker:targetPoker inSection:section]) {
            canMove = YES;
            break;
        }
    }
    if (canMove) {
        [self movePokerFromSection:from toSection:section count:1];
        return YES;
    }
    return NO;
}

- (void)movePokerFromSection:(NSInteger)fromSection toSection:(NSInteger)toSection count:(NSInteger)count;
{
    _animating = YES;
    
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
    [self performBatchUpdates:^{
        for (NSInteger index = 0; index < [fromIndexPaths count]; index++) {
            NSIndexPath *from = [fromIndexPaths objectAtIndex:index];
            NSIndexPath *to = [toIndexPaths objectAtIndex:index];
            SSPokerViewCell * cell = (SSPokerViewCell *)[self cellForItemAtIndexPath:from];
            [cell setAnimationMode:SSPokerAnimationModePlay];
            [self moveItemAtIndexPath:from toIndexPath:to];
        }
    }completion:^(BOOL finished) {
        if (fromSection < SSPokerSectionYamafuda) {
            NSInteger item = [(NSIndexPath *)[fromIndexPaths objectAtIndex:0] item];
            if (item > 0) {
                item--;
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:fromSection];
                SSPokerViewCell * cell = (SSPokerViewCell *)[self cellForItemAtIndexPath:lastIndexPath];
                [cell setPokerFaceUp:YES];
            }
        }
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

#pragma mark - YamafudaDelegate
//  山札戻し実行
- (void)willUseYamafuda;
{
    if (!_yamafuda.usable) {
        return;
    }
    
    NSMutableArray *recyclePokers = [_allPokers objectAtIndex:SSPokerSectionRecycle];
    NSMutableArray *yamafudaPokers = [_allPokers objectAtIndex:SSPokerSectionYamafuda];
    NSMutableArray *hiddenPokers = [_allPokers objectAtIndex:SSPokerSectionHidden];
    
    // 山札の枚数をチェックする
    NSInteger count = [hiddenPokers count];
    if (count == 0) {
        // 山札がなくなると、山札戻しを行う
        [recyclePokers addObjectsFromArray:yamafudaPokers];
        [hiddenPokers addObjectsFromArray:recyclePokers];
        [recyclePokers removeAllObjects];
        [yamafudaPokers removeAllObjects];
        
        // 残り枚数チェック
        if ([hiddenPokers count] <= _yamafudaMax) {
            _yamafuda.usable = NO;
        }
    }
    
    // 山札にトランプを追加する
    count = [hiddenPokers count];
    if (count) {
        // 山札をリサイクルする
        if ([yamafudaPokers count]) {
            [recyclePokers addObjectsFromArray:yamafudaPokers];
            [yamafudaPokers removeAllObjects];
        }
        
        NSInteger index = 0;
        NSInteger max;
        if (_yamafudaMax > count) {
            max = count;
        } else {
            max = _yamafudaMax;
        }
        while (index < max) {
            SSPoker *poker = [hiddenPokers objectAtIndex:index];
            [yamafudaPokers addObject:poker];
            index++;
        }
        NSRange range = NSMakeRange(0, max);
        [hiddenPokers removeObjectsInRange:range];
        
        // 山札を更新する
        [self performBatchUpdates:^{
            [self reloadSections:[NSIndexSet indexSetWithIndex:SSPokerSectionYamafuda]];
        }completion:^(BOOL finished) {
            
        }];

    } else {
        DebugLog(@"ショップを表示する");
    }
}

// ショップ表示
- (void)willPresentShop;
{

}

@end
