//
//  SSShopView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-14.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPopupView.h"

@interface SSShopView : SSPopupView<UITableViewDelegate, UITableViewDataSource>

// 商品一覧
- (void)setProducts:(NSArray *)products;
@end
