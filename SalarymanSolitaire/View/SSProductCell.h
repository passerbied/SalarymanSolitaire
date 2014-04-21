//
//  SSProductCell.h
//  SalarymanSolitaire
//
//  Created by many on 14-4-13.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ProductItemTypeNone,
    ProductItemTypePower,               // 体力アップ
    ProductItemTypeDring,               // 栄養剤
    ProductItemTypeYamafuda             // 山札戻し
} ProductItemType;
@interface SSProductCell : UITableViewCell

// 商品種類
@property (nonatomic) ProductItemType type;

@end
