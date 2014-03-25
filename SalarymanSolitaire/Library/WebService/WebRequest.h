//
//  WebRequest.h
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebRequest : NSObject


// ルートタグ名称
@property (nonatomic, copy) NSString *rootTagName;

// タグ名称
@property (nonatomic, copy) NSString *tagName;

// テストモード（XML出力）
@property (nonatomic) BOOL testMode;

// 初期化
+ (id)request;

// XMLデータ作成
- (NSData*)requestData;

@end
