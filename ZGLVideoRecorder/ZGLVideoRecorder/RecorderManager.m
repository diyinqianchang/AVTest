//
//  RecorderManager.m
//  ZGLVideoRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "RecorderManager.h"
#import <AVFoundation/AVFoundation.h>
#import "Memo.h"
#import "LevelPair.h"
#import "MeterTable.h"

@interface RecorderManager ()<AVAudioRecorderDelegate>

@property(nonatomic,strong)AVAudioPlayer *player;
@property(nonatomic,strong)AVAudioRecorder *recorder;
@property(nonatomic,strong)RecordingStopCompletionHandler completionHandler;
@property(nonatomic,strong)MeterTable *meterTable;

@end

@implementation RecorderManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //临时文件中
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *filePath = [tmpDir stringByAppendingPathComponent:@"memo.caf"];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        
        NSDictionary *settings = @{
                                   AVFormatIDKey:@(kAudioFormatAppleIMA4),
                                   AVSampleRateKey:@44100.0f,
                                   AVNumberOfChannelsKey:@1,
                                   AVEncoderBitDepthHintKey:@16,
                                   AVEncoderAudioQualityKey:@(AVAudioQualityMedium)
                                   };
        NSError *error;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl settings:settings error:&error];
        if (self.recorder) {
            self.recorder.delegate = self;
            self.recorder.meteringEnabled = YES; //声音波动强度解析
            [self.recorder prepareToRecord];
        }else{
            NSLog(@"error:%@",[error localizedDescription]);
        }
        _meterTable = [[MeterTable alloc] init];  //用于解析声音分贝的
    }
    return self;
}

-(BOOL)record{

    return [self.recorder record];
}

-(void)pause{

    [self.recorder pause];
}

-(void)stopWithCompletionHandler:(RecordingStopCompletionHandler)handler{

    self.completionHandler = handler;
    [self.recorder stop];

}


//录制完成的代理
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{

    if(self.completionHandler){
        self.completionHandler(flag);
    }
}

//保存 用到从一个地方copy到另外一个地方
-(void)saveRecordingWithName:(NSString *)name completionHandler:(RecordingSaveCompletionHandler)handler{

    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *filename = [NSString stringWithFormat:@"%@-%f.m4a",name,timestamp];
    
    NSString *docsDir = [self documentsDirectory];
    NSString *destPath = [docsDir stringByAppendingPathComponent:filename];
    
    NSURL *srcUrl = self.recorder.url; //缓存中的url
    NSURL *destURL = [NSURL fileURLWithPath:destPath];
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:srcUrl toURL:destURL error:&error];
    if (success) {
        handler(YES,[Memo memoWithTitle:name url:destURL]);
        [self.recorder prepareToRecord];  //准备下一次继续开录制
    }else{
        handler(NO,error);
    }


}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//怎么报分贝信息绘制出啦
-(LevelPair *)levels{
    [self.recorder updateMeters]; //实时获取声音的分贝
    float avgPower = [self.recorder averagePowerForChannel:0];
    float peakPower = [self.recorder peakPowerForChannel:0];
    float linearLevel = [self.meterTable valueForPower:avgPower];
    float linearPeak = [self.meterTable valueForPower:peakPower];
    return [LevelPair levelsWithLevel:linearLevel peakLevel:linearPeak];

}

//录制了多长时间
-(NSString *)formattedCurrentTime{
    
    NSUInteger time = (NSUInteger)self.recorder.currentTime;
    NSInteger hours = (time/3600);
    NSInteger minutes = (time/60)%60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    return [NSString stringWithFormat:format,hours,minutes,seconds];
}

//播放音频
-(BOOL)playbackMemo:(Memo *)memo{
    
    [self.player stop];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:memo.url error:nil];
    if (self.player) {
        
        [self.player play];
        return YES;
    }
    return NO;
}

//表示要被放弃了 录制中断
-(void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    
    if(self.delegate){
        
        [self.delegate interruptionBegan];
    }


}






@end
