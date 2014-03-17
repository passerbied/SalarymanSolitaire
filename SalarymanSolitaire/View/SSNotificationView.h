//
//  SSNotificationView.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-9.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPopupView.h"

@interface SSNotificationView : SSPopupView<UIWebViewDelegate>
{
    
}

// お知らせ表示
- (void)loadNotificationWith:(NSString *)address;

@end
