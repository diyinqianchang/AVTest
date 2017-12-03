//
//  LevelPair.m
//  ZGLVideoRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "LevelPair.h"

@implementation LevelPair

+ (instancetype)levelsWithLevel:(float)level peakLevel:(float)peakLevel {
    return [[self alloc] initWithLevel:level peakLevel:peakLevel];
}

- (instancetype)initWithLevel:(float)level peakLevel:(float)peakLevel {
    self = [super init];
    if (self) {
        _level = level;
        _peakLevel = peakLevel;
    }
    return self;
}

@end
