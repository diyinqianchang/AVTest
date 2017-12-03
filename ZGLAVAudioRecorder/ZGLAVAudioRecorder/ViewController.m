//
//  ViewController.m
//  ZGLAVAudioRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"myRecord.caf"

@interface ViewController ()<AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@property (weak, nonatomic) IBOutlet UIProgressView *audioPower;
@property (weak, nonatomic) IBOutlet UIButton *pause;
@property (weak, nonatomic) IBOutlet UIButton *resume;
@property (weak, nonatomic) IBOutlet UIButton *stop;
@property (weak, nonatomic) IBOutlet UIButton *record;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (self.audioPlayer) {
        
        [self.audioPlayer play];
    }
}


-(NSURL *)getSavePath{
    
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    urlStr = [urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

//录音参数设置
-(NSDictionary *)getAudioSetting{

    NSMutableDictionary *dicM = @{}.mutableCopy;
    
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dicM setObject:@(44100) forKey:AVSampleRateKey];
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    [dicM setObject:@(16) forKey:AVEncoderBitDepthHintKey];
    [dicM setObject:@(AVAudioQualityMedium) forKey:AVEncoderAudioQualityKey];
    
    return dicM;


}

//录音器
-(AVAudioRecorder *)audioRecorder{
    
    if (!_audioRecorder) {
        
        //保存路径
        NSURL *url = [self getSavePath];
        NSDictionary *setting = [self getAudioSetting];
        NSError *error;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        
    }
    return _audioRecorder;
}


-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

-(NSTimer *)timer{
    
    if (!_timer) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;

}

-(void)audioPowerChange{
    
    [self.audioRecorder updateMeters]; //测量值
    
    float power = [self.audioRecorder averagePowerForChannel:0];
    
    CGFloat progress = (1.0/160)*(power+160);
    [self.audioPower setProgress:progress];
}


//停止
- (IBAction)stopBtn:(id)sender {
    
    NSLog(@"nini");
    [self.audioRecorder stop];
    self.timer.fireDate = [NSDate distantFuture];
    self.audioPower.progress = 0.0;
    
}

//开始
- (IBAction)startBtn:(id)sender {
    
    NSLog(@"start");
    if (![self.audioRecorder isRecording]) {
        
        [self.audioRecorder record];
        self.timer.fireDate = [NSDate distantPast];
    }
}

//暂停
- (IBAction)recordBtn:(id)sender {
    
    if ([self.audioRecorder isRecording]) {
        
        [self.audioRecorder pause];
        self.timer.fireDate = [NSDate distantFuture];
    }
    
    NSLog(@"record");
}

//重启
- (IBAction)resumeBtn:(id)sender {
    
    NSLog(@"resume");
    [self startBtn:sender];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
