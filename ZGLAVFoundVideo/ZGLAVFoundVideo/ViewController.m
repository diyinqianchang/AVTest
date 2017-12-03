//
//  ViewController.m
//  ZGLAVFoundVideo
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>


typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface ViewController ()



@property(nonatomic,strong)AVCaptureSession *captureSession;//捕捉的核心类 负责输入输出

@property(nonatomic,strong)AVCaptureDeviceInput *captureDeviceInput; //负责输入

@property(nonatomic,strong)AVCaptureStillImageOutput *captureStillImageOutput; //照片输出流

@property(nonatomic,strong)AVCaptureVideoPreviewLayer *captureVideoPrevireLayer;//捕捉预览类



@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;
@property (weak, nonatomic) IBOutlet UIButton *flashAutoButton;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *flashOffButton;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *focusImage;

@end

@implementation ViewController


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //1.创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    //高质量  制动适配获取当前设备的告知阿玲画面
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    //2.获取输入设备 摄像头还是麦克风等
    
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!captureDevice) {
        NSLog(@"设备不可用");
        return;
    }
    //3、创建设备输入 输出
    NSError *error;
    _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取设备输入出错%@",[error localizedDescription]);
        return;
    }
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    
    _captureStillImageOutput  = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];
    
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    //4. 创建预览层
    
    _captureVideoPrevireLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    CALayer *layer = self.viewContainer.layer;
    layer.masksToBounds = YES;
    _captureVideoPrevireLayer.frame = layer.bounds;
    
    _captureVideoPrevireLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [layer insertSublayer:_captureVideoPrevireLayer below:self.focusImage.layer];
    
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
    [self setFlashModeButtonStatus];

}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];

}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    // Do any additional setup after loading the view, typically from a nib.
}


/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    
    //设备有多个摄像头  返回一个摄像头
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *camera in cameras) {
        
        if ([camera position] == position) {
            return  camera;
        }
    }
    return nil;

}


-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];


}

-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)areaChange:(NSNotification *)notice{

    NSLog(@"区域改变了");
    
}

//添加手势获取聚焦
-(void)addGenstureRecognizer{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [self.viewContainer addGestureRecognizer:tapGesture];


}

-(void)tapScreen:(UITapGestureRecognizer *)gesture{
    
    //坐标转化
    CGPoint point = [gesture locationInView:self.viewContainer];
    CGPoint cameraPoint = [self.captureVideoPrevireLayer captureDevicePointOfInterestForPoint:point];
    //改变fouce的坐标
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];

}
/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    
    self.focusImage.center = point;
    
    self.focusImage.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusImage.alpha = 1.0;
    [UIView animateWithDuration:0.25 animations:^{
        self.focusImage.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusImage.alpha = 0.0;
    }];

}
//相机的曝光和聚焦
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
       
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

//改变属性都在这里了  聚焦 切换摄像头等
-(void)changeDeviceProperty:(PropertyChangeBlock)black{
    
    //获取设备
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    //先锁住 改变 在释放锁
    if ([captureDevice lockForConfiguration:&error]) {
        
        black(captureDevice);
        [captureDevice unlockForConfiguration];
        
    }else{
    
        NSLog(@"修改属性出错%@",[error localizedDescription]);
    }


}


//设置闪光灯
-(void)setFlashModeButtonStatus{
    
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    AVCaptureFlashMode flasheMode = captureDevice.flashMode;
    
    if ([captureDevice isFlashAvailable]) {
        self.flashAutoButton.hidden=NO;
        self.flashOnButton.hidden=NO;
        self.flashOffButton.hidden=NO;
        self.flashAutoButton.enabled=YES;
        self.flashOnButton.enabled=YES;
        self.flashOffButton.enabled=YES;
        
        switch (flasheMode) {
            case AVCaptureFlashModeAuto:
                self.flashAutoButton.enabled = NO;
                break;
            case AVCaptureFlashModeOn:
                self.flashOnButton.enabled = NO;
                break;
            case AVCaptureFlashModeOff:
                self.flashOffButton.enabled = NO;
                break;
                
            default:
                break;
        }
        
    }else{
        self.flashAutoButton.hidden=YES;
        self.flashOnButton.hidden=YES;
        self.flashOffButton.hidden=YES;
    }



}


//照片
- (IBAction)takeButtonClick:(UIButton *)sender {
    
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }];
}

//切换摄像头
- (IBAction)toggleButtonClick:(UIButton *)sender{
    
    AVCaptureDevice *currentDevie = [self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevie position];
    [self removeNotificationFromCaptureDevice:currentDevie];
    
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = currentPosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack:AVCaptureDevicePositionFront;
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.captureDeviceInput];
    
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    [self.captureSession commitConfiguration];
    [self setFlashModeButtonStatus];
}

//自动散光灯
- (IBAction)flashAutoClick:(UIButton *)sender {
    
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];


}

- (IBAction)flashOnClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOn];
    [self setFlashModeButtonStatus];



}

- (IBAction)flashOffClick:(UIButton *)sender{
    
    [self setFlashMode:AVCaptureFlashModeOff];
    [self setFlashModeButtonStatus];


}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{


    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
       
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
