//
//  LevelMeterColorThreshold.h
//  ZGLVideoRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LevelMeterColorThreshold : NSObject

@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, strong, readonly) UIColor *color;
@property (nonatomic, copy, readonly) NSString *name;

+ (instancetype)colorThresholdWithMaxValue:(CGFloat)maxValue color:(UIColor *)color name:(NSString *)name;

@end
