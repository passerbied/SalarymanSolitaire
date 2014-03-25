//
//  NotificationView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-22.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSPopupView.h"

@interface NotificationView : SSPopupView<UIWebViewDelegate>

// お知らせ表示
- (id)initWithURL:(NSURL *)URL;
@end
