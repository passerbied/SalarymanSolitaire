//
//  AudioEngine.m
//  EasyKanji
//
//  Created by dev on 14-4-10.
//  Copyright (c) 2014年 dev. All rights reserved.
//

#import "AudioEngine.h"

@interface AudioEngine ()
{
    AVAudioPlayer                       *_effectPlayer;
    AVAudioPlayer                       *_musicPlayer;
    AVAudioPlayer                       *_backgroundPlayer;
    NSMutableArray                      *_serialPlayerList;
}
@end

@implementation AudioEngine

+ (instancetype)sharedEngine
{
    static dispatch_once_t once;
    static id sharedEngine;
    dispatch_once(&once, ^ { sharedEngine = [[self alloc] init];});
    return sharedEngine;
}

- (AVAudioPlayer *)playerWithData:(NSData *)data engine:(AudioEngineType)engine
{
    return nil;
    [AudioEngine stopEngine:engine];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    switch (engine) {
        case AudioEngineTypeEffect:
            _effectPlayer = player;
            break;
            
        case AudioEngineTypeMusic:
            _musicPlayer = player;
            break;
        default:
            _backgroundPlayer = player;
            break;
    }
    return player;
}

+ (void)playAudioWithName:(NSString *)name engine:(AudioEngineType)engine;
{
    AudioEngine *sharedEngine = [AudioEngine sharedEngine];
    NSString *path =[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        AVAudioPlayer *player = [sharedEngine playerWithData:data engine:engine];
        if ([player prepareToPlay]) {
            if (engine == AudioEngineTypeBackground) {
                player.numberOfLoops = -1;
            } else {
                player.numberOfLoops = 0;
            }
            [player play];
        }
    }
}

- (AVAudioPlayer *)playerWithEngine:(AudioEngineType)engineType
{
    AVAudioPlayer *player = nil;
    switch (engineType) {
        case AudioEngineTypeEffect:
            player = _effectPlayer;
            break;
            
        case AudioEngineTypeMusic:
            player = _musicPlayer;
            break;
        default:
            player = _backgroundPlayer;
            break;
    }
    return player;
}

- (void)setAudioPlayer:(AVAudioPlayer *)player engine:(AudioEngineType)engineType
{
    switch (engineType) {
        case AudioEngineTypeEffect:
            _effectPlayer = player;
            break;
            
        case AudioEngineTypeMusic:
            _musicPlayer = player;
            break;
        default:
            _backgroundPlayer = player;
            break;
    }
}

+ (void)playEngine:(AudioEngineType)engine;
{
    AudioEngine *sharedEngine = [AudioEngine sharedEngine];
    
    if (engine & AudioEngineTypeEffect) {
        [sharedEngine playerWithEngine:AudioEngineTypeEffect];
    }
    
    if (engine & AudioEngineTypeMusic) {
        [sharedEngine playerWithEngine:AudioEngineTypeMusic];
    }
    
    if (engine & AudioEngineTypeBackground) {
        [sharedEngine playerWithEngine:AudioEngineTypeBackground];
    }
}

- (void)playEngine:(AudioEngineType)engine
{
    AVAudioPlayer *player = [self playerWithEngine:engine];
    if (![player isPlaying]) {
        [player play];
    }
}

+ (void)pauseEngine:(AudioEngineType)engine;
{
    AudioEngine *sharedEngine = [AudioEngine sharedEngine];
    
    if (engine & AudioEngineTypeEffect) {
        [sharedEngine pauseEngine:AudioEngineTypeEffect];
    }
    
    if (engine & AudioEngineTypeMusic) {
        [sharedEngine pauseEngine:AudioEngineTypeMusic];
    }
    
    if (engine & AudioEngineTypeBackground) {
        [sharedEngine pauseEngine:AudioEngineTypeBackground];
    }
}

- (void)pauseEngine:(AudioEngineType)engine;
{
    AVAudioPlayer *player = [self playerWithEngine:engine];
    if ([player isPlaying]) {
        [player pause];
    }
}

+ (void)stopEngine:(AudioEngineType)engine;
{
    AudioEngine *sharedEngine = [AudioEngine sharedEngine];
    
    if (engine & AudioEngineTypeEffect) {
        [sharedEngine stopEngine:AudioEngineTypeEffect];
    }
    
    if (engine & AudioEngineTypeMusic) {
        [sharedEngine stopEngine:AudioEngineTypeMusic];
    }
    
    if (engine & AudioEngineTypeBackground) {
        [sharedEngine stopEngine:AudioEngineTypeBackground];
    }
}

- (void)stopEngine:(AudioEngineType)engine;
{
    AVAudioPlayer *player = [self playerWithEngine:engine];
    if ([player isPlaying]) {
        [player stop];
    }
}


@end
