//
//  LevelPair.h
//  ZGLVideoRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelPair : NSObject

@property (nonatomic, readonly) float level;
@property (nonatomic, readonly) float peakLevel;

+ (instancetype)levelsWithLevel:(float)level peakLevel:(float)peakLevel;

- (instancetype)initWithLevel:(float)level peakLevel:(float)peakLevel;

@end
