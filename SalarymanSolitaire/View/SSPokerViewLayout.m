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

@interface SSPokerViewLayout ()

@property (nonatomic) CGFloat locationY;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;
@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *moveIndexPaths;
@end


@implementation SSPokerViewLayout

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
    _locationY = self.collectionView.bounds.size.height - kPokerDeckEdgeInsetBottom - self.pokerSize.height;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributesArray = [NSMutableArray arrayWithCapacity:SSPokerSectionTotal];
    for (NSInteger section = SSPokerSectionDeck; section < SSPokerSectionTotal; section++) {
        NSInteger count = [[self collectionView] numberOfItemsInSection:section];
        for (NSInteger item = 0; item < count; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:SSPokerSectionDeck];
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
    if (section == SSPokerSectionDeck) {
        attributes.zIndex = 0;
        CGFloat x = kPokerDeckEdgeInsetLeft + kPokerDeckInteritemSpacing*indexPath.item;
        attributes.frame = CGRectMake(x, _locationY, self.pokerSize.width, self.pokerSize.height);        
    } else if (section <= SSPokerSectionPlaying7) {
        attributes.zIndex = indexPath.item;
        CGFloat x = kPokerPlayingEdgeInsetLeft + (kPokerSizeWidth + kPokerHorizontalSpacing)*(indexPath.section - SSPokerSectionPlaying1);
        CGFloat y;
        SSPokerView *pokerView = (SSPokerView *)self.collectionView;
        NSInteger item = [pokerView firstVisiblePokersInSection:section];
        if (item == NSNotFound || item >= indexPath.item) {
            y = kPokerPlayingEdgeInsetTop + kPokerFaceDownVerticalSpacing*indexPath.item;
        } else {
            y = kPokerPlayingEdgeInsetTop + kPokerFaceDownVerticalSpacing*(indexPath.item - item) + kPokerFaceUpVerticalSpacing*item;
        }
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
    } else if (section == SSPokerSectionUsable) {
        CGFloat x = self.collectionView.bounds.size.width - kPokerTableEdgeInsetLeft - kPokerSizeWidth;
        CGFloat y = kPokerTableEdgeInsetTop;
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
    } else {
        CGFloat x = kPokerTableEdgeInsetLeft + (kPokerSizeWidth + kPokerTableInteritemSpacing)*(section - SSPokerSectionFinishedHeart);
        CGFloat y = kPokerTableEdgeInsetTop;
        attributes.frame = CGRectMake(x, y, kPokerSizeWidth, kPokerSizeHeight);
        attributes.zIndex = 1000 + indexPath.item;
    }
    return attributes;
}

//- (UICollectionViewLayoutAttributes *)initialAttributesAtIndexPath:(NSIndexPath *)indexPath;
//{
//    UICollectionViewLayoutAttributes *attributes = [super initialAttributesAtIndexPath:indexPath];
//    CGFloat x = kPokerDeckEdgeInsetLeft;
//    attributes.frame = CGRectMake(x, _locationY, self.pokerSize.width, self.pokerSize.height);
//    return attributes;
//}
//
//- (UICollectionViewLayoutAttributes *)attributesAtIndexPath:(NSIndexPath *)indexPath;
//{
//    UICollectionViewLayoutAttributes *attributes = [super attributesAtIndexPath:indexPath];
//    CGFloat x = kPokerDeckEdgeInsetLeft + kPokerDeckInteritemSpacing*indexPath.item;
//    attributes.frame = CGRectMake(x, _locationY, self.pokerSize.width, self.pokerSize.height);
//    return attributes;
//}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    self.moveIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete) {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        } else if (update.updateAction == UICollectionUpdateActionInsert) {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        } else if (update.updateAction == UICollectionUpdateActionMove) {
            [self.moveIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertIndexPaths containsObject:itemIndexPath])
    {
        // only change attributes on inserted cells
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        // Configure attributes ...
        attributes.alpha = 0.0;
        CGFloat x = kPokerDeckEdgeInsetLeft;
        attributes.frame = CGRectMake(x, _locationY, self.pokerSize.width, self.pokerSize.height);
    }
    
//    if ([self.moveIndexPaths containsObject:itemIndexPath])
//    {
//        // only change attributes on inserted cells
//        if (!attributes) {
//            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        }
//        
////        static int level = 100;
////        // Configure attributes ...
////        attributes.zIndex = itemIndexPath.item + level;
////        level--;
//    }
    
    return attributes;
}
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
//        attributes.alpha = 0.0;
//    }
//    
//    return attributes;
//}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
    self.moveIndexPaths = nil;
}
@end