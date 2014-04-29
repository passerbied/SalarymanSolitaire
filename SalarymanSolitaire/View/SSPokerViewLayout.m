//
//  SSPokerViewLayout.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-6.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPokerViewLayout.h"
#import "SSPokerView.h"

// シャッフル
#define kPokerShuffleEdgeInsetBottom    40.0f

// ポーカーサイズ
#define kPokerSizeWidth                 41.0f
#define kPokerSizeHeight                61.0f
#define kPokerPlayingEdgeInsetTop       70.0f
#define kPokerPlayingEdgeInsetLeft      3.0f
#define kPokerTableEdgeInsetTop         3.5f
#define kPokerTableEdgeInsetLeft        4.0f
#define kPokerTableInteritemSpacing     4.0f

// 水平間隔
#define kPokerHorizontalSpacing         4.5f

// 垂直間隔
#define kPokerFaceDownVerticalSpacing   6.0f
#define kPokerFaceUpVerticalSpacing     20.0f

#define kPokerDeckEdgeInsetLeft         32.5f
#define kPokerDeckEdgeInsetBottom       40.0f
#define kPokerDeckInteritemSpacing      4.0f

// 山札
#define kPokerYamafudaInteritemSpacing  11.0f

@interface SSPokerViewLayout ()
{
    NSInteger                           _currentSection;
    CGFloat                             _tableWidth;
    CGFloat                             _yamafudaX;
    CGRect                              _rectForHiddenPoker;
}

@property (nonatomic) CGRect distributeFromRect;
@property (nonatomic) CGFloat locationY;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;
@property (nonatomic, strong) NSMutableArray *moveIndexPaths;
@end


@implementation SSPokerViewLayout

// 山札戻し位置
+ (CGRect)rectForYamafuda;
{
    CGFloat x = 320.0 - kPokerTableEdgeInsetLeft - kPokerSizeWidth;
    CGFloat y = kPokerTableEdgeInsetTop;
    return CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _pokerSize = CGSizeMake(kPokerSizeWidth, kPokerSizeHeight);
    }
    return self;
}
- (void)prepareLayout
{
    [super prepareLayout];
    _yamafudaMax = 3;
    _rectForHiddenPoker = [SSPokerViewLayout rectForYamafuda];
    _yamafudaX = kPokerPlayingEdgeInsetLeft + (kPokerSizeWidth + kPokerHorizontalSpacing)*4;
    
    _tableWidth = self.collectionView.bounds.size.width;
    CGFloat x = (self.collectionView.bounds.size.width - self.pokerSize.width)/2.0f;
    CGFloat y = self.collectionView.bounds.size.height - kPokerDeckEdgeInsetBottom - self.pokerSize.height;
    _distributeFromRect = CGRectMake(x, y, self.pokerSize.width, self.pokerSize.height);
    
    _locationY = self.collectionView.bounds.size.height - kPokerDeckEdgeInsetBottom - self.pokerSize.height;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributesArray = [NSMutableArray arrayWithCapacity:SSPokerSectionTotal];
    for (NSInteger section = SSPokerSectionDeck1; section < SSPokerSectionTotal; section++) {
        NSInteger count = [[self collectionView] numberOfItemsInSection:section];
        for (NSInteger item = 0; item < count; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:SSPokerSectionDeck1];
            [attributesArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = self.pokerSize;
    
    NSInteger section = indexPath.section;
    if (section <= SSPokerSectionDeck7) {
        // プレイ中ポーカー
        CGFloat x = kPokerPlayingEdgeInsetLeft + (kPokerSizeWidth + kPokerHorizontalSpacing)*(indexPath.section - SSPokerSectionDeck1);
        CGFloat y;
        SSPokerView *pokerView = (SSPokerView *)self.collectionView;
        NSInteger item = [pokerView firstVisiblePokersInSection:section];
        if (item == NSNotFound || item >= indexPath.item) {
            y = kPokerPlayingEdgeInsetTop + kPokerFaceDownVerticalSpacing*indexPath.item;
        } else {
            y = kPokerPlayingEdgeInsetTop + kPokerFaceDownVerticalSpacing*item + kPokerFaceUpVerticalSpacing*(indexPath.item - item);
        }
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
        attributes.zIndex = indexPath.item;
    } else if (section == SSPokerSectionYamafuda) {
        // 山札
        CGFloat x;
        CGFloat y = kPokerTableEdgeInsetTop;
        if (indexPath.item < _yamafudaMax) {
            x = _yamafudaX + indexPath.item*kPokerYamafudaInteritemSpacing;
            attributes.zIndex = indexPath.item;
        } else {
            x = _yamafudaX;
            attributes.zIndex = -1;
        }
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
    } else {
        // 仕上げ
        CGFloat x = kPokerTableEdgeInsetLeft + (kPokerSizeWidth + kPokerTableInteritemSpacing)*(section - SSPokerSectionHeart);
        
        
        CGFloat y = kPokerTableEdgeInsetTop;
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
        attributes.zIndex = indexPath.item + 100;
    }
    return attributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertIndexPaths = [NSMutableArray array];
    self.moveIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionInsert) {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        } else if (update.updateAction == UICollectionUpdateActionMove) {
            [self.moveIndexPaths addObject:update.indexPathAfterUpdate];
            _currentSection = update.indexPathAfterUpdate.section;
        }
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertIndexPaths containsObject:itemIndexPath] ||
        (itemIndexPath.section <= SSPokerSectionDeck7 && itemIndexPath.item == 0))
    {
        // ポーカー配布専用
        // only change attributes on inserted cells
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        // Configure attributes ...
        attributes.alpha = 1.0;
        attributes.frame = _distributeFromRect;
    }
    
    if ([self.moveIndexPaths containsObject:itemIndexPath])
    {
        // only change attributes on inserted cells
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        attributes.zIndex = itemIndexPath.item;
    }
    
    return attributes;
}
//

//
//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
//{
//    // So far, calling super hasn't been strictly necessary here, but leaving it in
//    // for good measure
//    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
//    
//    if ([self.deleteIndexPaths containsObject:itemIndexPath])
//    {
//        // only change attributes on deleted cells
//        if (!attributes)
//            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        
//        // Configure attributes ...
////        attributes.alpha = 0.0;
//    }
//    
//    [self printInfoIfnecessary:attributes];
//    return attributes;
//}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    self.insertIndexPaths = nil;
    self.moveIndexPaths = nil;
}

- (NSInteger)zIndexForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger zIndex;
    switch (indexPath.section) {
        case SSPokerSectionDeck1:
        case SSPokerSectionDeck2:
        case SSPokerSectionDeck3:
        case SSPokerSectionDeck4:
        case SSPokerSectionDeck5:
        case SSPokerSectionDeck6:
        case SSPokerSectionDeck7:
            zIndex = indexPath.item;
            break;
        case SSPokerSectionHeart:
        case SSPokerSectionDiamond:
        case SSPokerSectionClub:
        case SSPokerSectionSpade:
            zIndex = indexPath.item + 13;
            break;
            
        default:
            zIndex = indexPath.item;
            break;
    }
    return zIndex;
}
@end


