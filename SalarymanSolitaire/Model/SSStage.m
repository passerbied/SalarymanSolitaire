//
//  SSStage.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-12.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSStage.h"

@implementation SSStage

// クリア条件
- (NSString *)condition;
{
    // 山札戻し条件編集
    NSString *returnCondition;
    if (_maximumYamafuda > 0) {
        returnCondition = [NSString stringWithFormat:@"山札戻し%d回", (int)_maximumYamafuda];
    } else {
        returnCondition = @"無制限にて";
    }
    
    // その他条件
    return [NSString stringWithFormat:@"%d枚めくり・%@\n%d回クリアする", (int)_numberOfPokers, returnCondition, (int)_minimalClearTimes];
}
@end
