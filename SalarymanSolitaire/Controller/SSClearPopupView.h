//
//  SSClearPopupView.h
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSViewController.h"
#import "WUPopupView.h"

@protocol SSClearPopupViewDelegate;

@interface SSClearPopupView : WUPopupView

@property (nonatomic, strong) NSObject <SSClearPopupViewDelegate> *delegate;

- (void)setStageTitle:(NSString *)stageName;

@end

@protocol SSClearPopupViewDelegate <NSObject>

- (void)nextStageButtonDidTaped;

@end
