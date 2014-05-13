//
//  SSProductItemCell.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-13.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "SSProductCell.h"


@interface SSProductItemCell : UITableViewCell
{
    
}
// 商品種類
@property (nonatomic) ProductItemType type;



// 商品情報
@property (nonatomic, strong) SKProduct *product;

// 最後の行
@property (nonatomic) BOOL lastRow;
@end
