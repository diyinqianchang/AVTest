//
//  ViewController.m
//  ZGLAVAudioPlayer
//
//  Created by 张国林 on 2017/12/2.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

static NSString * const kMusicFile = @"刘若英-原来你也在这里.mp3";
static NSString * const kMusicSinger = @"刘若英";
static NSString * const kMusicTitle = @"原来你也在这里";

@interface ViewController ()<AVAudioPlayerDelegate>

@property (nonatomic,strong)AVAudioPlayer *audioPlayer;   //播放器
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *playProgress;
@property (weak, nonatomic) IBOutlet UIButton *playOrPause;
@property (nonatomic,strong) NSTimer *timer;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
}


-(void)setupUI{
    
    self.title = kMusicTitle;
    self.contentLabel.text = kMusicSinger;
    
    
    
}

-(AVAudioPlayer *)audioPlayer{
    
    if (!_audioPlayer) {
        
        NSString *urlStr = [[NSBundle mainBundle] pathForResource:kMusicFile ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:urlStr];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (error) {
            
            NSLog(@"%@",[error localizedDescription]);
            
            return nil;
        }
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.delegate = self;  //代理
        [_audioPlayer prepareToPlay]; //预加载
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        //线路改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return _audioPlayer;
    
}

//播放完成
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    NSLog(@"finished");
    [[AVAudioSession sharedInstance]setActive:NO error:nil];
    
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    NSLog(@"%@",[error description]);
    
}



/**
 处理中断
 
 @param notification 中断通知
 */
-(void)handleInterruptionNotification:(NSNotification *)notification{
    
    NSDictionary *info = notification.userInfo;
    
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        
        [self pause]; //暂停播放
        
    }else{
        
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            
            [self play]; //播放
        }
        
    }
    
    
}



-(void)routeChange:(NSNotification*)notice{
    
    NSDictionary *dic = notice.userInfo;
    int changeReason = [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    
    //获取线路改变的原因   一般只需要监听到 耳机中断的事件就可以
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        
        AVAudioSessionRouteDescription *routeDescription = dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription = [routeDescription.outputs firstObject];
        if ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self pause];
        }
    }
}
-(NSTimer *)timer{
    
    if (!_timer) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
    return _timer;
    
}
-(void)play{
    
    if (![self.audioPlayer isPlaying]) {
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.audioPlayer play];
        });
        self.timer.fireDate = [NSDate distantPast]; //恢复
    }
    
    
}




-(void)pause{
    
    if ([self.audioPlayer isPlaying]) {
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.audioPlayer pause];
        });
        self.timer.fireDate = [NSDate distantFuture];  //暂停
    }
    
}

-(void)updateProgress:(NSTimer *)timer{
    
    //    NSLog(@"----------");
    //    NSLog(@"%@",timer.userInfo);
    float progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
    [self.playProgress setProgress:progress animated:YES];
}


- (IBAction)playClick:(UIButton *)sender {
    
    if (sender.tag) {   //表示为 1
        sender.tag = 0;
        [sender setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
        [self pause];
        
    }else{
        
        sender.tag=1;
        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
        [self play];
    }
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
