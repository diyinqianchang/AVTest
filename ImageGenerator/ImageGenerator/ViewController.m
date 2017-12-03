//
//  ViewController.m
//  ImageGenerator
//
//  Created by 张国林 on 2017/12/2.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self thumbnailImageRequest:5];

    
}

/**
 资源 AVAsset抽象和不可变类

 @param timeBySecond 时间
 */
-(void)thumbnailImageRequest:(CGFloat )timeBySecond{
    
    NSURL *url = [self getFileUrl];
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    
    NSError *error = nil;
    
    CMTime time  = CMTimeMakeWithSeconds(timeBySecond, 10);
    CMTime actualTime;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    if (error) {
        NSLog(@"截取视频出错");
        return;
    }
    
    CMTimeShow(actualTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
    CGImageRelease(cgImage);
}






- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"%@",[error localizedDescription]);

}

-(NSURL *)getFileUrl{
    
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"story.mp4" ofType:nil];
    if (!urlStr) {
        
        return nil;
    }
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}




@end
