//
//  SSPokerViewLayout.m
//  Poker
//
//  Created by IfelseGo on 14-5-2.
//
//

#import "SSPokerViewLayout.h"
#import "SSPoker.h"

// 完了済みエリア
#define kPokerTableEdgeInsetTop         3.5f
#define kPokerTableEdgeInsetLeft        4.0f
#define kPokerTableInteritemSpacing     4.0f

// ポーカーサイズ
#define kPokerSizeWidth                 41.0f
#define kPokerSizeHeight                61.0f
#define kPokerDeckEdgeInsetTop          70.0f
#define kPokerDeckEdgeInsetLeft         3.0f
#define kPokerDeckEdgeInsetBottom       40.0f

// 垂直間隔
#define kPokerVerticalSpacing           6.0f
#define kPokerFaceUpVerticalSpacing     20.0f

// 水平間隔
#define kPokerHorizontalSpacing         4.5f

// 山札
#define kPokerYamafudaInteritemSpacing  11.0f

@interface SSPokerViewLayout ()
{
    CGFloat                             _tableWidth;
    CGFloat                             _yamafudaX;
    CGRect                              _rectForHiddenPoker;
    CGRect                              _distributeFromRect;
    CGFloat                             _locationY;
}

@property (nonatomic, strong) NSMutableArray *insertIndexPaths;
@property (nonatomic, strong) NSMutableArray *moveIndexPaths;

// 指定位置のポーカー情報を取得する
- (SSPoker *)pokerAtIndexPath:(NSIndexPath *)indexPath;

@end
@implementation SSPokerViewLayout

- (CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributesArray = [NSMutableArray arrayWithCapacity:SSPokerSectionTotal];
    for (NSInteger section = SSPokerSectionDeck1; section < SSPokerSectionTotal; section++) {
        NSInteger count = [[self collectionView] numberOfItemsInSection:section];
        for (NSInteger item = 0; item < count; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [attributesArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    return attributesArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pokerSize = CGSizeMake(kPokerSizeWidth, kPokerSizeHeight);
        _numberOfPokers = 3;
        _rectForHiddenPoker = [SSPokerViewLayout rectForYamafuda];
        _yamafudaX = kPokerDeckEdgeInsetLeft + (kPokerSizeWidth + kPokerHorizontalSpacing)*4;
    }
    return self;
}

// 山札戻し位置
+ (CGRect)rectForYamafuda;
{
    CGFloat x = 320.0 - kPokerTableEdgeInsetLeft - kPokerSizeWidth;
    CGFloat y = kPokerTableEdgeInsetTop;
    return CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
}

// 指定位置のポーカー情報を取得する
- (SSPoker *)pokerAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [_pokers objectAtIndex:indexPath.section];
    if ([array count] > indexPath.item) {
        SSPoker *poker = (SSPoker *)[array objectAtIndex:indexPath.item];
        return poker;
    }
    return nil;
}

- (void)prepareLayout
{
    [super prepareLayout];
    CGSize size = self.collectionView.bounds.size;
    _tableWidth = size.width;
    CGFloat x = (size.width - self.pokerSize.width)/2.0f;
    CGFloat y = size.height - kPokerDeckEdgeInsetBottom - self.pokerSize.height;
    _distributeFromRect = CGRectMake(x, y, self.pokerSize.width, self.pokerSize.height);
    _locationY = size.height - kPokerDeckEdgeInsetBottom - self.pokerSize.height;
    
//    DebugLog(@"Prepare Layout");
}

- (NSInteger)firstVisiblePokerInSection:(NSInteger)section
{
    NSArray *array = [_pokers objectAtIndex:section];
    NSInteger count = [array count];
    NSInteger i = 0;
    for (; i < count; i++) {
        SSPoker *poker = (SSPoker *)[array objectAtIndex:i];
        if (poker.displayOptions & SSPokerOptionShowFaceUp) {
            break;
        }
    }
    
    return i;
}

//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    NSMutableArray* attributesArray = [NSMutableArray arrayWithCapacity:SSPokerSectionTotal];
//    for (NSInteger section = SSPokerSectionDeck1; section < SSPokerSectionTotal; section++) {
//        NSInteger count = [[self collectionView] numberOfItemsInSection:section];
//        for (NSInteger item = 0; item < count; item++) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
//            [attributesArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
//        }
//    }
//    return attributesArray;
//}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 表示サイズ設定
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = self.pokerSize;
    
    NSInteger section = indexPath.section;
    if (section <= SSPokerSectionDeck7) {
        // プレイ中ポーカー
        NSInteger item = [self firstVisiblePokerInSection:section];
        CGFloat x = kPokerDeckEdgeInsetLeft + (kPokerSizeWidth + kPokerHorizontalSpacing)*(indexPath.section - SSPokerSectionDeck1);
        CGFloat y;
        if (item >= indexPath.item) {
            y = kPokerDeckEdgeInsetTop + kPokerVerticalSpacing*indexPath.item;
        } else {
            y = kPokerDeckEdgeInsetTop + kPokerVerticalSpacing*item + kPokerFaceUpVerticalSpacing*(indexPath.item - item);
        }
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
        attributes.zIndex = indexPath.item;
        attributes.hidden = NO;
    } else if (section == SSPokerSectionYamafuda) {
        // 山札
        CGFloat x = _yamafudaX + indexPath.item*kPokerYamafudaInteritemSpacing;
        CGFloat y = kPokerTableEdgeInsetTop;
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
        attributes.zIndex = indexPath.item;
        attributes.hidden = NO;
    } else if (section < SSPokerSectionHidden){
        // 完了済み
        CGFloat x = kPokerTableEdgeInsetLeft + (kPokerSizeWidth + kPokerTableInteritemSpacing)*(section - SSPokerSectionHeart);
        CGFloat y = kPokerTableEdgeInsetTop;
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
        attributes.zIndex = indexPath.item + 100;
        attributes.hidden = NO;
    } else {
        // 非表示
        attributes.hidden = YES;
    }
    
//    if (attributes.indexPath.section == _currentSection) {
//        SSPoker *poker = [self pokerAtIndexPath:attributes.indexPath];
//        DebugLog(@"Poker [%@] Y:[%f] zIndex:[%d]",poker.description, attributes.frame.origin.y, attributes.zIndex);
//    }
    return attributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertIndexPaths = [NSMutableArray array];
    self.moveIndexPaths = [NSMutableArray array];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *update, NSUInteger idx, BOOL *stop) {
        if (update.updateAction == UICollectionUpdateActionInsert) {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        } else if (update.updateAction == UICollectionUpdateActionMove) {
            [self.moveIndexPaths addObject:update.indexPathAfterUpdate];
//            _currentSection = update.indexPathAfterUpdate.section;
        }
    }];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    if (_currentMode == SSPokerViewLayoutModeDistribution &&
        itemIndexPath.section <= SSPokerSectionDeck7) {
        // ポーカー配布際に
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        attributes.alpha = 1.0f;
        attributes.frame = _distributeFromRect;
    }
    
    if ([self.moveIndexPaths containsObject:itemIndexPath]) {
        
    }
    return attributes;
}
//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
//{
//    // Must call super
//    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//    
//    if ([self.insertIndexPaths containsObject:itemIndexPath] ||
//        (itemIndexPath.section <= XXPokerSectionDeck7 && itemIndexPath.item == 0))
//    {
//        // ポーカー配布専用
//        // only change attributes on inserted cells
//        if (!attributes) {
//            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        }
//        
//        // Configure attributes ...
//        attributes.alpha = 1.0;
//        attributes.frame = _distributeFromRect;
//    }
//    
//    if ([self.moveIndexPaths containsObject:itemIndexPath])
//    {
//        // only change attributes on inserted cells
//        if (!attributes) {
//            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        }
//        attributes.zIndex = itemIndexPath.item + 100;
//    }
//    
//    return attributes;
//}
@end


#import "LSCollectionViewLayoutHelper.h"

@interface SSDraggblePokerViewLayout ()
{
    LSCollectionViewLayoutHelper *_layoutHelper;
}
@end

@implementation SSDraggblePokerViewLayout

- (LSCollectionViewLayoutHelper *)layoutHelper
{
    if(_layoutHelper == nil) {
        _layoutHelper = [[LSCollectionViewLayoutHelper alloc] initWithCollectionViewLayout:self];
    }
    return _layoutHelper;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.layoutHelper modifiedLayoutAttributesForElements:[super layoutAttributesForElementsInRect:rect]];
}

@end
