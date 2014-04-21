//
//  WebRequest.m
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "WebRequest.h"
#import "XmlParser.h"

@implementation WebRequest

- (id)init
{
    self = [super init];
    if (self) {
        self.tagName = NSStringFromClass([self class]);
    }
    return self;
}

+ (id)request
{
    return [[self alloc] init];
}

- (NSData*)requestData
{
    XmlParser *parser = [[XmlParser alloc] init];
    parser.testMode = self.testMode;
    NSString *xmlString = [XmlParser XMLWith:self rootNoteName:_rootTagName];
    if (_testMode) {
        DebugLog(@"[POST]%@", xmlString);
    }
    
    NSData* data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSArray *)XMLNotes
{
    return nil;
}

@end
