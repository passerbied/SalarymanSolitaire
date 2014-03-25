//
//  XmlParserUtil.m
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "XmlParserUtil.h"
#import "Reachability.h"
#import "XmlParser.h"

@implementation XmlParserUtil

- (NSMutableDictionary *)parseXML
{
    // XML存在检查
    if (![[NSFileManager defaultManager] fileExistsAtPath:_xmlPath]) {
        return NO;
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:_xmlPath];
    NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    // HTTP请求返回数据检查
    if (xmlString == nil || [xmlString length] == 0) {
        return NO;
    }
    
    // 解析开始
    XmlParser *parser = [[XmlParser alloc] init];
    
    if (_responseDatas == nil) {
        NSInteger count = [_requiredResponseDataIdentifiers count];
        self.responseDatas = [NSMutableDictionary dictionaryWithCapacity:count];
    } else {
        [_responseDatas removeAllObjects];
    }
    // 正常数据解析
    for (NSString *identifier in [_requiredResponseDataIdentifiers allObjects]) {
        NSArray *array = [parser fromXML:xmlString withTagName:identifier];
        if (array) {
            [_responseDatas setObject:array forKey:identifier];
        }
    }
    return _responseDatas;
}

@end
