//
//  AudioEngine.h
//  EasyKanji
//
//  Created by dev on 14-4-10.
//  Copyright (c) 2014年 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum
{
    AudioEngineTypeEffect               = 1 << 0,
    AudioEngineTypeMusic                = 1 << 1,
    AudioEngineTypeBackground           = 1 << 2,
    AudioEngineTypeAll                  = (AudioEngineTypeEffect    |
                                           AudioEngineTypeMusic     |
                                           AudioEngineTypeBackground)
} AudioEngineType;

@interface AudioEngine : NSObject

// 指定音声ファイルを再生する
+ (void)playAudioWithName:(NSString *)name engine:(AudioEngineType)engine;

// 音声エンジン制御
+ (void)playEngine:(AudioEngineType)engine;
+ (void)pauseEngine:(AudioEngineType)engine;
+ (void)stopEngine:(AudioEngineType)engine;

@end
