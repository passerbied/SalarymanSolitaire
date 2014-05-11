//
//  SSItemAlertView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-27.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSAlertView.h"
#import "WUAlertView.h"

typedef enum
{
    SSItemAlertDatasourceNutrient,
    SSItemAlertDatasourceYamafuda,
} SSItemAlertType;

@interface SSItemAlertView : SSAlertView

// 商品種類
@property (nonatomic) SSItemAlertType datasource;

// 商品の残り個数
@property (nonatomic) NSUInteger numberOfItems;

@end
