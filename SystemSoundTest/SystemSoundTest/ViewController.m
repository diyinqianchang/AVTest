//
//  ViewController.m
//  SystemSoundTest
//
//  Created by 张国林 on 2017/12/2.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@end


static void completionCallback(SystemSoundID mySSID){
    
    
    
}

SystemSoundID crash;

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *play = [UIButton buttonWithType:UIButtonTypeSystem];
    [play setTitle:@"play" forState:UIControlStateNormal];
    play.frame = CGRectMake(20, 100, 280, 40);
    [play addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:play];
    
    NSURL *crashUrl = [[NSBundle mainBundle] URLForResource:@"crash" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)crashUrl,&crash);
    
    AudioServicesAddSystemSoundCompletion(crash, NULL, NULL, (void *)completionCallback, NULL);
    
    
    
}


-(void)playClick:(UIButton *)btn{
    
    NSLog(@"nihao");
    AudioServicesPlayAlertSound(crash);
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
