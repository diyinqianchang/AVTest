//
//  ViewController.m
//  ZGLMPMoviePlayerController
//
//  Created by 张国林 on 2017/12/2.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.moviePlayer play];
    
    [self addNotification];
    
    
    //缩略图
    [self thumbnailImageRequest];
    
    
}


-(void)thumbnailImageRequest{
    
    [self.moviePlayer requestThumbnailImagesAtTimes:@[@13.0,@21.5] timeOption:MPMovieTimeOptionNearestKeyFrame];
    
}


//没有代理  状态有通知控制
-(MPMoviePlayerController *)moviePlayer{
    
    if (!_moviePlayer) {
        
        NSURL *url = [self getFileUrl];
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
        _moviePlayer.view.frame = self.view.bounds;
        _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:_moviePlayer.view];
        
    }
    
    return _moviePlayer;
}

-(void)addNotification{
    
    NSNotificationCenter *noCenter = [NSNotificationCenter defaultCenter];
    
    [noCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [noCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [noCenter addObserver:self selector:@selector(mediaPlayerThumbnailRequestFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.moviePlayer];
    
    
}

//通知
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"playing....");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"Paused");
            break;
        case MPMoviePlaybackStateInterrupted:
            NSLog(@"interrupted");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"stopped....");
            break;
        default:
            NSLog(@"state:%li",self.moviePlayer.playbackState);
            break;
    }
    
    
}
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    
    NSLog(@"播放完成 %li",self.moviePlayer.playbackState);
}

/**
 *  缩略图请求完成,此方法每次截图成功都会调用一次
 *  缩略图的生成
 *  @param notification 通知对象
 */
-(void)mediaPlayerThumbnailRequestFinished:(NSNotification *)notification{
    
    //从通知的消息中 获取image
    UIImage *image = notification.userInfo[MPMoviePlayerThumbnailImageKey];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
}



-(NSURL *)getFileUrl{
    
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"story.mp4" ofType:nil];
    
    NSLog(@"%@",urlStr);
    
    if (!urlStr) {
        NSLog(@"文件不存在");
        return nil;
    }
    
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    
    return url;
    
    
    
    
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}




@end
