//
//  RecorderManager.h
//  ZGLVideoRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import <Foundation/Foundation.h>

//处理中断
@protocol RecorderManagerDelegate <NSObject>
-(void)interruptionBegan;
@end

typedef void(^RecordingStopCompletionHandler)(BOOL isComplete);
typedef void(^RecordingSaveCompletionHandler)(BOOL isComplete,id obj);

@class Memo;
@class LevelPair;

@interface RecorderManager : NSObject

@property (nonatomic, readonly) NSString *formattedCurrentTime;
@property (weak, nonatomic) id <RecorderManagerDelegate> delegate;

-(BOOL)record;

-(void)pause;

- (void)stopWithCompletionHandler:(RecordingStopCompletionHandler)handler;

- (void)saveRecordingWithName:(NSString *)name
            completionHandler:(RecordingSaveCompletionHandler)handler;

//声音分贝
-(LevelPair *)levels;

//播放音频
-(BOOL)playbackMemo:(Memo *)memo;

@end
