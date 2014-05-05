//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import "LSCollectionViewHelper.h"
#import "UICollectionViewLayout_Warpable.h"
#import "UICollectionViewDataSource_Draggable.h"
#import "LSCollectionViewLayoutHelper.h"
#import <QuartzCore/QuartzCore.h>

static int kObservingCollectionViewLayoutContext;

#ifndef CGGEOMETRY__SUPPORT_H_
CG_INLINE CGPoint
_CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}
#endif

typedef NS_ENUM(NSInteger, _ScrollingDirection) {
    _ScrollingDirectionUnknown = 0,
    _ScrollingDirectionUp,
    _ScrollingDirectionDown,
    _ScrollingDirectionLeft,
    _ScrollingDirectionRight
};

@interface LSCollectionViewHelper ()
{
    NSIndexPath                         *_lastIndexPath;
    UIImageView                         *_ghostCell;
    CGPoint                             _ghostCellCenter;
    CGPoint                             _fingerTranslation;
    BOOL                                _canWarp;
    BOOL                                _needTurnFaceUp;
}
@property (readonly, nonatomic) LSCollectionViewLayoutHelper *layoutHelper;
@end

@implementation LSCollectionViewHelper

- (id)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        [_collectionView addObserver:self
                          forKeyPath:@"collectionViewLayout"
                             options:0
                             context:&kObservingCollectionViewLayoutContext];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_collectionView addGestureRecognizer:_tapGestureRecognizer];
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handleLongPressGesture:)];
        [_collectionView addGestureRecognizer:_longPressGestureRecognizer];
        
        _panPressGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handlePanGesture:)];
        _panPressGestureRecognizer.delegate = self;

        [_collectionView addGestureRecognizer:_panPressGestureRecognizer];
        
        for (UIGestureRecognizer *gestureRecognizer in _collectionView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
                break;
            }
        }
        
        [self layoutChanged];
    }
    return self;
}

- (LSCollectionViewLayoutHelper *)layoutHelper
{
    return [(id <UICollectionViewLayout_Warpable>)self.collectionView.collectionViewLayout layoutHelper];
}

- (void)layoutChanged
{
    _canWarp = [self.collectionView.collectionViewLayout conformsToProtocol:@protocol(UICollectionViewLayout_Warpable)];
    _longPressGestureRecognizer.enabled = _panPressGestureRecognizer.enabled = _canWarp && self.enabled;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &kObservingCollectionViewLayoutContext) {
        [self layoutChanged];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    _longPressGestureRecognizer.enabled = _canWarp && enabled;
    _panPressGestureRecognizer.enabled = _canWarp && enabled;
}

- (UIImage *)imageFromCell:(UICollectionViewCell *)cell {
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0.0f);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isEqual:_panPressGestureRecognizer]) {
        return self.layoutHelper.fromIndexPath != nil;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isEqual:_longPressGestureRecognizer]) {
        return [otherGestureRecognizer isEqual:_panPressGestureRecognizer];
    }
    
    if ([gestureRecognizer isEqual:_panPressGestureRecognizer]) {
        return [otherGestureRecognizer isEqual:_longPressGestureRecognizer];
    }
    
    return NO;
}

//- (NSIndexPath *)indexPathForItemClosestToPoint:(CGPoint)point
//{
//    NSArray *layoutAttrsInRect;
//    NSInteger closestDist = NSIntegerMax;
//    NSIndexPath *indexPath;
//    NSIndexPath *toIndexPath = self.layoutHelper.toIndexPath;
//    
//    // We need original positions of cells
//    self.layoutHelper.toIndexPath = nil;
//    layoutAttrsInRect = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:self.collectionView.bounds];
//    self.layoutHelper.toIndexPath = toIndexPath;
//    
//    // What cell are we closest to?
//    for (UICollectionViewLayoutAttributes *layoutAttr in layoutAttrsInRect) {
//        CGFloat xd = layoutAttr.center.x - point.x;
//        CGFloat yd = layoutAttr.center.y - point.y;
//        NSInteger dist = sqrtf(xd*xd + yd*yd);
//        if (dist < closestDist) {
//            closestDist = dist;
//            indexPath = layoutAttr.indexPath;
//        }
//    }
//    
//    // Are we closer to being the last cell in a different section?
//    NSInteger sections = [self.collectionView numberOfSections];
//    for (NSInteger i = 0; i < sections; ++i) {
//        if (i == self.layoutHelper.fromIndexPath.section) {
//            continue;
//        }
//        NSInteger items = [self.collectionView numberOfItemsInSection:i];
//        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:items inSection:i];
//        UICollectionViewLayoutAttributes *layoutAttr;
//        CGFloat xd, yd;
//        
//        if (items > 0) {
//            layoutAttr = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:nextIndexPath];
//            xd = layoutAttr.center.x - point.x;
//            yd = layoutAttr.center.y - point.y;
//        } else {
//            // Trying to use layoutAttributesForItemAtIndexPath while section is empty causes EXC_ARITHMETIC (division by zero items)
//            // So we're going to ask for the header instead. It doesn't have to exist.
//            layoutAttr = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                                                                                                  atIndexPath:nextIndexPath];
//            xd = layoutAttr.frame.origin.x - point.x;
//            yd = layoutAttr.frame.origin.y - point.y;
//        }
//        
//        NSInteger dist = sqrtf(xd*xd + yd*yd);
//        if (dist < closestDist) {
//            closestDist = dist;
//            indexPath = layoutAttr.indexPath;
//        }
//    }
//    
//    return indexPath;
//}
//
- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    CGPoint location;
    NSIndexPath *currentIndexPath;
    if (sender.state == UIGestureRecognizerStateEnded) {
        location = [sender locationInView:self.collectionView];
        currentIndexPath = [self.collectionView indexPathForItemAtPoint:location];
        if (currentIndexPath) {
            id<UICollectionViewDataSource_Draggable> dataSource = (id<UICollectionViewDataSource_Draggable>)self.collectionView.dataSource;
            [dataSource collectionView:self.collectionView moveItemsFromSection:currentIndexPath.section];
        }
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateChanged) {
        return;
    }
    if (![self.collectionView.dataSource conformsToProtocol:@protocol(UICollectionViewDataSource_Draggable)]) {
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathForItemClosestToPoint:[sender locationInView:self.collectionView]];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath == nil) {
                return;
            }
            if (![(id<UICollectionViewDataSource_Draggable>)self.collectionView.dataSource
                  collectionView:self.collectionView
                  canMoveItemAtIndexPath:indexPath]) {
                return;
            }
            // Create mock cell to drag around
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            cell.highlighted = NO;
            [_ghostCell removeFromSuperview];
            _ghostCell = [[UIImageView alloc] initWithFrame:cell.frame];
            _ghostCell.image = [self imageFromCell:cell];
            _ghostCellCenter = _ghostCell.center;
            [self.collectionView addSubview:_ghostCell];
            [UIView
             animateWithDuration:0.3
             animations:^{
                 _ghostCell.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
             }
             completion:nil];
            
            // Start warping
            _lastIndexPath = indexPath;
            self.layoutHelper.fromIndexPath = indexPath;
            self.layoutHelper.hideIndexPath = indexPath;
            self.layoutHelper.toIndexPath = indexPath;
            [self.collectionView.collectionViewLayout invalidateLayout];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if(self.layoutHelper.fromIndexPath == nil) {
                return;
            }
            // Need these for later, but need to nil out layoutHelper's references sooner
            NSIndexPath *fromIndexPath = self.layoutHelper.fromIndexPath;
            NSIndexPath *toIndexPath = self.layoutHelper.toIndexPath;
            // Tell the data source to move the item
            id<UICollectionViewDataSource_Draggable> dataSource = (id<UICollectionViewDataSource_Draggable>)self.collectionView.dataSource;
            [dataSource collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
           
            // Move the item
            [self.collectionView performBatchUpdates:^{
                [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                self.layoutHelper.fromIndexPath = nil;
                self.layoutHelper.toIndexPath = nil;
            } completion:^(BOOL finished) {
                if (finished && _needTurnFaceUp) {
                    _needTurnFaceUp = NO;
                    if ([dataSource respondsToSelector:@selector(collectionView:didMoveItemAtIndexPath:toIndexPath:)]) {
                        [dataSource collectionView:self.collectionView didMoveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                    }
                }
            }];
            
            // Switch mock for cell
            UICollectionViewLayoutAttributes *layoutAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.layoutHelper.hideIndexPath];
            [UIView
             animateWithDuration:0.3
             animations:^{
                 _ghostCell.center = layoutAttributes.center;
                 _ghostCell.transform = CGAffineTransformMakeScale(1.f, 1.f);
             }
             completion:^(BOOL finished) {
                 [_ghostCell removeFromSuperview];
                 _ghostCell = nil;
                 self.layoutHelper.hideIndexPath = nil;
                 [self.collectionView.collectionViewLayout invalidateLayout];
             }];
            
            // Reset
            _lastIndexPath = nil;
        } break;
        default: break;
    }
}

- (void)warpToIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath == nil || [_lastIndexPath isEqual:indexPath]) {
        return;
    }
    _lastIndexPath = indexPath;
    
    if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:toIndexPath:)] == YES
        && [(id<UICollectionViewDataSource_Draggable>)self.collectionView.dataSource
            collectionView:self.collectionView
            canMoveItemAtIndexPath:self.layoutHelper.fromIndexPath
            toIndexPath:indexPath] == NO) {
        return;
    }
    
    
    [self.collectionView performBatchUpdates:^{
        _needTurnFaceUp = YES;
        self.layoutHelper.hideIndexPath = indexPath;
        self.layoutHelper.toIndexPath = indexPath;
    } completion:nil];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateChanged) {
        // Move mock to match finger
        _fingerTranslation = [sender translationInView:self.collectionView];
        _ghostCell.center = _CGPointAdd(_ghostCellCenter, _fingerTranslation);
        
        // Warp item to finger location
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self indexPathForItemClosestToPoint:point];
        [self warpToIndexPath:indexPath];
    }
}

/**
 *
 *
 *
 */
- (NSIndexPath *)indexPathForItemClosestToPoint:(CGPoint)point
{
    NSArray *layoutAttrsInRect;
    NSInteger closestDist = NSIntegerMax;
    NSIndexPath *indexPath;
    NSIndexPath *toIndexPath = self.layoutHelper.toIndexPath;
    
    // We need original positions of cells
    self.layoutHelper.toIndexPath = nil;
    BOOL inner = NO;
    layoutAttrsInRect = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:self.collectionView.bounds];
    self.layoutHelper.toIndexPath = toIndexPath;
    
    // What cell are we closest to?
    for (UICollectionViewLayoutAttributes *layoutAttr in layoutAttrsInRect) {
        if (self.layoutHelper.fromIndexPath) {
            // When pan gesture is valid
            if (self.layoutHelper.fromIndexPath.section == layoutAttr.indexPath.section) {
                continue;
            }
        }
        if (!CGRectContainsPoint(layoutAttr.frame, point)) {
            continue;
        }
        inner = YES;

        CGFloat xd = layoutAttr.center.x - point.x;
        CGFloat yd = layoutAttr.center.y - point.y;
        NSInteger dist = sqrtf(xd*xd + yd*yd);
        if (dist < closestDist) {
            closestDist = dist;
            indexPath = layoutAttr.indexPath;
        }
    }
    
    if (!inner) {
        return nil;
    }
    // get last indexPath
    NSInteger items = [self.collectionView numberOfItemsInSection:indexPath.section];
    if (self.layoutHelper.fromIndexPath) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:items inSection:indexPath.section];
        return nextIndexPath;
    } else {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:items - 1 inSection:indexPath.section];
        return lastIndexPath;
    }
}



@end
