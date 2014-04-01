//
//  SSSolitaireView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-31.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSSolitaireView.h"

@implementation SSSolitaireView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setup
{
//    // This array will contain the ColorName objects that populate the CollectionView, one array per section
//    self.sectionedColorNames = [NSMutableArray arrayWithObjects:[NSMutableArray array], nil];
//    
//    // Allocate and configure the layout.
//    LessBoringFlowLayout *layout = [[LessBoringFlowLayout alloc] init];
//    layout.minimumInteritemSpacing = 20.f;
//    layout.minimumLineSpacing = 20.f;
//    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    layout.sectionInset = UIEdgeInsetsMake(10.f, 20.f, 10.f, 20.f);
//    
//    // Bigger items for iPad
//    layout.itemSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? CGSizeMake(120, 120) : CGSizeMake(80, 80);
//    
//    // uncomment this to see the default flow layout behavior
//    //    [layout makeBoring];
//    
//    
//    // Allocate and configure a collection view
//    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
//    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    collectionView.backgroundColor = [UIColor whiteColor];
//    collectionView.bounces = YES;
//    collectionView.alwaysBounceVertical = YES;
//    collectionView.dataSource = self;
//    collectionView.delegate = self;
//    self.collectionView = collectionView;
//    
//    // Register reusable items
//    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([AddCell class]) bundle:nil]
//     forCellWithReuseIdentifier:NSStringFromClass([AddCell class])];
//    
//    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ColorNameCell class]) bundle:nil]
//     forCellWithReuseIdentifier:NSStringFromClass([ColorNameCell class])];
//    
//    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ColorSectionHeaderView class]) bundle:nil]
//     forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//            withReuseIdentifier:NSStringFromClass([ColorSectionHeaderView class])];
//    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ColorSectionFooterView class]) bundle:nil]
//     forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
//            withReuseIdentifier:NSStringFromClass([ColorSectionFooterView class])];
//    
//    // Add to view
//    [self.view addSubview:collectionView];
}
@end
