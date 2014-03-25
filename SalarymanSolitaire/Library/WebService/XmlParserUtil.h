//
//  XmlParserUtil.h
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlParserUtil : NSObject
{

}
//@property(nonatomic,copy) NSString *xmlFileName;

@property(nonatomic,copy) NSString *xmlPath;

// HTTP请求返回数据ID
@property(nonatomic,copy) NSSet *requiredResponseDataIdentifiers;

// HTTP请求返回数据
@property(nonatomic,retain) NSMutableDictionary *responseDatas;

// HTTP请求返回数据解析
- (NSMutableDictionary *)parseXML;

@end
