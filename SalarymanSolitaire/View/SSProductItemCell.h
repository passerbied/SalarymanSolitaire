//
//  SSProductItemCell.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-13.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSProductCell.h"


@interface SSProductItemCell : UITableViewCell
{
    
}
// 商品種類
@property (nonatomic) ProductItemType type;

// 商品名称
@property (nonatomic, strong) NSString *itemName;

// 商品価格
@property (nonatomic, strong) NSString *itemPrice;

// 商品ID
@property (nonatomic, strong) NSString *identifier;

// 最後の行
@property (nonatomic) BOOL lastRow;
@end
