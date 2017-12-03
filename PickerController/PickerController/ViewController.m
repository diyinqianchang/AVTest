//
//  ViewController.m
//  PickerController
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIImageView *mainView;
@property (nonatomic,assign)BOOL isVideo;

@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic,strong) AVPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    self.isVideo = YES;

}

-(UIImagePickerController *)imagePicker{
    
    if (!_imagePicker) {
        
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera; //来源
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear; //设置摄像头
        if(self.isVideo){
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        }else{
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    return _imagePicker;


}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *image;
        if (self.imagePicker.allowsEditing) {
        
            image = [info objectForKey:UIImagePickerControllerEditedImage];//编辑过的图片
        }else{
            image = [info objectForKey:UIImagePickerControllerOriginalImage];//原始图片
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        NSLog(@"video.....");
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];//获取视频路径
        NSString *urlStr = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video: didFinishSavingWithError:contextInfo:), nil);
        }
    
    }


}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    NSLog(@"取消");


}


-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{

    if (error) {
        NSLog(@"保存视频出错");
    }else{
    
        NSLog(@"保存成功");
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        _player = [AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = self.mainView.bounds;
        [self.mainView.layer addSublayer:playerLayer];
        [self.player play];
    }
     [self dismissViewControllerAnimated:YES completion:nil]; //录制视频
}

- (IBAction)playClick:(id)sender {
    
    NSLog(@"开始录制视频");
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
