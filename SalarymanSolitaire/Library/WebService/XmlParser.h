//
//  XmlParser.h
//  WebService
//
//  Created by IfelseGo on 14-3-19.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XmlParser : NSObject {

}

@property(nonatomic) BOOL generateDummyNote;

@property (nonatomic, assign, getter = isTestMode) BOOL testMode;

+ (NSString *)getResult:(NSString *)xmlString;

// カスタマイズ機能
- (NSMutableArray*)fromXML:(NSString*)XML withTagName:(NSString*)tagName;

// XML作成
+ (NSString *)XMLWith:(id)object rootNoteName:(NSString *)root;

@end


@interface NSObject(XML)
// プロパティ情報取得
- (NSMutableDictionary *)propertyDictionary;

// ノート順位指定
- (NSArray *)XMLNotes;

@end