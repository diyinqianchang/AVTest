//
//  LevelMeterView.h
//  ZGLVideoRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelMeterView : UIView

@property (nonatomic) CGFloat level;
@property (nonatomic) CGFloat peakLevel;

- (void)resetLevelMeter;

@end
