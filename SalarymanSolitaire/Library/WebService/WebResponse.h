//
//  WebResponse.h
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebResponse : NSObject
{
    
}

// サービス実行結果コード
@property (strong, nonatomic) NSString *ResponseCode;

// 初期化
+ (id)response;

@end
