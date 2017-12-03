//
//  ViewController.m
//  AVPlayerLayer
//
//  Created by 张国林 on 2017/12/2.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic,strong) AVPlayer *player;//播放器对象

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
//    self.contentView.frame = CGRectMake(0, 30, self.view.bounds.size.width, self.view.bounds.size.height*0.5);
    
    [self setupUI];
    

}

-(void)setupUI{

    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playLayer.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    playLayer.contentsScale = [UIScreen mainScreen].scale;
    playLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    NSLog(@"%.f,%.f,%.f,%f",self.contentView.frame.origin.y,self.contentView.frame.origin.x,self.contentView.frame.size.width,self.contentView.frame.size.height);
    
    NSLog(@"%f",playLayer.frame.origin.y);
    
//    self.contentView.layer = playLayer;
    
    [self.contentView.layer addSublayer:playLayer];
    
   
    [self.player play];
   
}

-(void)orientChange:(NSNotification *)notification{
    
//    NSDictionary *dict = notification.userInfo;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"竖屏");
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        NSLog(@"横屏");
    }
    NSLog(@"%@",self.contentView.layer.sublayers);
    
    AVPlayerLayer *playLayer = (AVPlayerLayer *)self.contentView.layer.sublayers[0];
     playLayer.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    

}


-(AVPlayer *)player{
    
    if (!_player) {
        
        AVPlayerItem *playerItem = [self getPlayItem:1];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
        [self addNotification];
    }
    return _player;

}

-(AVPlayerItem *)getPlayItem:(int)videoIndex{
    
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"story.mp4" ofType:nil];
//    NSURL *url = [NSURL URLWithString:@"http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithURL:url];
    
    NSLog(@"%@",playItem);
    
    return playItem;

}


-(void)addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];

}
//如果需要重新播放 需要从新生成一个AVPlayer AVPlayerLayer等播放组件

-(void)playbackFinished:(NSNotification *)notification{

//    [self.player stop]
    
    self.player.rate = 0.0;
    
    [self.playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    
//    self.player = nil;
    NSLog(@"完成");
}

-(void)addProgressObserver{

    AVPlayerItem *playerItem = self.player.currentItem;
    UIProgressView *progress = self.progressView;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([playerItem duration]);
        if (current) {
            [progress setProgress:(current/total) animated:YES];
        }
        
    }];

}


-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{

    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    AVPlayerItem *playerItem = object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            NSLog(@"正在播放....%.2f",CMTimeGetSeconds(playerItem.duration));
        }
        
    }else if ([keyPath isEqualToString:@"loadTimeRanges"]){
        
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    
    }

}




- (IBAction)playOrPause:(id)sender {
    
    if(self.player.rate==0){ //说明时暂停
        [sender setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
        [sender setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    }
    NSLog(@"Click");
}




- (IBAction)switchVideoClick:(UIButton *)sender {
    
    NSLog(@"%ld",(long)sender.tag);
    
}
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc{
    
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];

}


@end
