//
//  SelectStageViewController.h
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"

@interface SelectStageViewController : SSViewController<UITableViewDelegate, UITableViewDataSource>

// 初回起動モード
@property (nonatomic, getter = isFirstRun) BOOL firstRun;
@end
