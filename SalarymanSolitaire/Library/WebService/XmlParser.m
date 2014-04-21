//
//  XmlParser.m
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "XmlParser.h"

#import "GDataXMLNode.h"

#import <Foundation/NSObjCRuntime.h>
#import "objc/runtime.h"

#define kNSStringType               @"NSString"
#define kNSArrayType                @"NSArray"
#define kNSMutableArrayType         @"NSMutableArray"


NSString* getPropertyType(objc_property_t property)
{
    // parse the property attribues. this is a comma delimited string. the type of the attribute starts with the
    
    // character 'T' should really just use strsep for this, using a C99 variable sized array.
    
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    
    char *state = buffer;
    char *attribute;
    
    while ((attribute = strsep(&state, ",")) != NULL) {
        
        if (attribute[0] == 'T' && strlen(attribute)>2) {
            
            return [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            
        } else if (attribute[0] == 'T' && strlen(attribute)==2) {
            return [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) encoding:NSASCIIStringEncoding];
        }
    }
    
    return @"@";
}


@implementation XmlParser
@synthesize testMode;

//return value of a root element
//such as: <?xml version="1.0" encoding="UTF-8"?><postResult namespace="http://xxx.com">2</postResult>
//this method will return the postResult:2

+ (NSString *)getResult:(NSString *)xmlString{
	
	NSString *xmlStr = xmlString;
	
	NSError *error;
	
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&error];
	
    if (doc == nil) {
		return nil;
	}
	
	
	GDataXMLElement *anElement = [doc rootElement];
	
	if (anElement) {
		return anElement.stringValue;
	}
	else {
		return @"";
	}
	
}


-(NSMutableArray*)fromXML:(NSString*)XML withTagName:(NSString*)tagName
{
    // 解析する前にXMLデータを整形する
    NSString *xmlStr = XML;
    xmlStr = [XML stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	xmlStr = [xmlStr stringByReplacingOccurrencesOfString:@"ns1:" withString:@""];
	
    // XMLドキュメント作成
	NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&error];
    if (doc == nil || error) {
        if ([self isTestMode]) {
            DebugLog(@"XML Document 异常[%@]", XML);
        }
		return nil;
	}
    
    // 引数に指定タグ名により検索を行う
    NSArray *elements;
    NSString *searchTagName;
    if (tagName) {
        searchTagName = tagName;
        elements = [doc nodesForXPath:[NSString stringWithFormat:@"//%@", tagName] error:nil];
        
        if (error) {
            DebugLog(@"检索XML文档失败[%@]",searchTagName);
            return nil;
        }
    } else {
        NSString *rootTagName = [[doc rootElement] name];
        searchTagName = rootTagName;
        elements = [NSArray arrayWithObject:[doc rootElement]];
    }
    
    // 指定节点不存在
	if (![elements count]) {
        DebugLog(@"XML节点不存在 [%@]",searchTagName);
		return nil;
	}
    
    // 解析開始
    NSMutableArray *result = [self arrayWithElements:elements tagName:tagName];
    return result;
}

- (NSMutableArray*)arrayWithElements:(NSArray*)elements tagName:(NSString*)tagName
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *thisObeject in elements) {
        
        // タグ名より対象クラスのオブジェクト作成
        NSObject * model = [self objectWithElement:thisObeject tagName:tagName];
        
        if (model) {
            [returnArray addObject:model];
        }
    }
    return returnArray;
}

- (NSObject *)objectWithElement:(GDataXMLElement *)element tagName:(NSString *)tagName
{
    // タグ名より対象クラスのオブジェクト作成
    NSObject * tagObject = [[NSClassFromString(tagName) alloc] init];
    
    // 属性リスト取得
    NSMutableDictionary *propertyDictionary = [tagObject propertyDictionary];;
    
    for (NSString *key in propertyDictionary) {
        
        NSArray *anArray = [element elementsForName:key];
        
        if (anArray.count > 0) {
            GDataXMLElement *firstElement = (GDataXMLElement *) [anArray objectAtIndex:0];
            
            NSString *property_ = [propertyDictionary objectForKey:key];
            if ([property_ isEqualToString:kNSStringType]) {
                // 文字列の場合(NSString)
                [tagObject setValue:firstElement.stringValue forKey:key];
            } else if ([property_ isEqualToString:kNSMutableArrayType] ||
                       [property_ isEqualToString:kNSArrayType]){
                // 配列の場合
                NSArray *children = [firstElement children];
                if ([children count]) {
                    GDataXMLElement *firstChild = [children objectAtIndex:0];
                    NSString *childTagName = [firstChild name];
                    NSArray *arrayObject = [self arrayWithElements:children tagName:childTagName];
                    if (arrayObject) {
                        [tagObject setValue:arrayObject forKey:key];
                    }
                }
            } else {
                // 上記以外の場合にオブジェクトとして扱う
                NSObject *obj = [self objectWithElement:firstElement tagName:key];
                if (obj) {
                    [tagObject setValue:obj forKey:key];
                }
            }
        }
    }
    return tagObject;
}

+ (NSString *)XMLWith:(id)object rootNoteName:(NSString *)root;
{
    NSString *tagName = NSStringFromClass([object class]);
    XmlParser *parser = [[XmlParser alloc] init];
    GDataXMLElement * element = [parser elementWithObject:object tagName:tagName];
    
    GDataXMLElement * rootElement = nil;
    if (root) {
        rootElement = [GDataXMLNode elementWithName:root];
        [rootElement addChild:element];
    } else {
        rootElement = element;
    }
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:rootElement];;
	NSData *XMLData = document.XMLData;
	NSString *XMLString = [[NSString alloc] initWithData:XMLData encoding:NSUTF8StringEncoding];
	NSString *bodyString = [XMLString substringFromIndex:21];
	NSString *headerString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
	
	XMLString = [NSString stringWithFormat:@"%@%@",headerString,bodyString];
    return XMLString;
}

-(GDataXMLElement *)elementWithObject:(NSObject *)object tagName:(NSString *)tagName
{
    // 创建XML节点
    GDataXMLElement * element = [GDataXMLNode elementWithName:tagName];
    
    // 模型信息取得
    NSMutableDictionary * propertyDic = [object propertyDictionary];
    NSArray *customXMLNotes = [object XMLNotes];
    id allNotes = nil;
    if (customXMLNotes) {
        allNotes = customXMLNotes;
    } else {
        allNotes = propertyDic;
    }
    
    // 遍历
    for (NSString *key in allNotes) {
        id value = [object valueForKey:key];
        
        // 判断是否为空节点
        if (value == nil) {
            // 根据需要生成空节点
            if (self.generateDummyNote) {
                GDataXMLElement * childElement = [GDataXMLNode elementWithName:key stringValue:@""];
                [element addChild:childElement];
            }
            continue;
        }
        
        // 根据属性类型生成相应节点
        NSString *property = [propertyDic objectForKey:key];
        if ([property isEqualToString:kNSStringType]) {
            // 按照文字处理
            GDataXMLElement * childElement = [GDataXMLNode elementWithName:key
                                                               stringValue:value];
            [element addChild:childElement];
            
        } else if ([property isEqualToString:kNSMutableArrayType] ||
                   [property isEqualToString:kNSArrayType]) {
            // 按照数组处理
            GDataXMLElement *childElement = [self elementWithArray:value tagName:key];
            if (childElement) {
                [element addChild:childElement];
            }
            continue;
            
        } else {
            // 按照模型处理
            GDataXMLElement *childElement = [self elementWithObject:value tagName:key];
            if (childElement) {
                [element addChild:childElement];
            }
            continue;
        }
    }
    return element;
}

-(GDataXMLElement *)elementWithArray:(NSArray *)array tagName:(NSString *)tagName
{
    GDataXMLElement * rootElement = [GDataXMLNode elementWithName:tagName];
    if ([array count]) {
        NSObject *obj = [array objectAtIndex:0];
        NSString *className = NSStringFromClass([obj class]);
        
        for (obj in array) {
            GDataXMLElement *childElement = [self elementWithObject:obj tagName:className];
            if (childElement) {
                [rootElement addChild:childElement];
            }
        }
    }
    return rootElement;
}

@end

@implementation NSObject(XML)

//Method to get property type and name of a given object
- (NSMutableDictionary *)propertyDictionary
{
    
	unsigned int outCount, i;
	NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1];
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            NSString *propType = getPropertyType(property);
            [dic setValue:propType forKey:propertyName];
        }
    }
    
    free(properties);
	
	return dic;
	
}

- (NSArray *)XMLNotes
{
    return nil;
}

@end
