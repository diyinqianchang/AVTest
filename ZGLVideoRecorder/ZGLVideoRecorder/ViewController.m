//
//  ViewController.m
//  ZGLVideoRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import "ViewController.h"

#import "RecorderManager.h"
#import "Memo.h"
#import "MemoCell.h"

#import "LevelMeterView.h"
#import "LevelPair.h"

#define CANCEL_BUTTON    0
#define OK_BUTTON        1

#define MEMO_CELL        @"memoCell"
#define MEMOS_ARCHIVE    @"memos.archive"

@interface ViewController ()<RecorderManagerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet LevelMeterView *levelMeterView;



@property(strong,nonatomic)NSMutableArray *memos;
@property(strong,nonatomic)CADisplayLink *levelTimer;
@property(strong,nonatomic)NSTimer *timer;
@property(nonatomic,strong)RecorderManager *recorderManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recorderManager = [[RecorderManager alloc] init];
    _recorderManager.delegate = self;
//    _memos = [NSMutableArray array];
    
    self.stopBtn.enabled = NO;
    
    UIImage *recordImage = [[UIImage imageNamed:@"record"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *pauseImage = [[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *stopImage = [[UIImage imageNamed:@"stop"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.recordBtn setImage:recordImage forState:UIControlStateNormal];
    [self.recordBtn setImage:pauseImage forState:UIControlStateSelected];
    
    [self.stopBtn setImage:stopImage forState:UIControlStateNormal];
    
    NSData *data = [NSData dataWithContentsOfURL:[self archiveURL]];
    
    if (!data) {
        _memos = [NSMutableArray array];
    }else{
        _memos = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

#pragma mark - Memo Archiving

-(void)saveMemos{
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.memos];
    [data writeToURL:[self archiveURL] atomically:YES];

}

//从归档中取出数据
- (NSURL *)archiveURL {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    NSString *archivePath = [docsDir stringByAppendingPathComponent:MEMOS_ARCHIVE];
    return [NSURL fileURLWithPath:archivePath];
}



//代理
-(void)interruptionBegan{
    
    self.recordBtn.selected = NO;
    [self stopMeterTimer];
    [self stopTimer];

}

#pragma mark 定时任务

-(void)startTimer{
    
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

}
//处理显示时间的定时器
-(void)updateTimeDisplay{
    self.timeLabel.text = self.recorderManager.formattedCurrentTime;
}
-(void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}
#pragma mark - Level Metering

-(void)startMeterTimer{
    
    [self.levelTimer invalidate];
    self.levelTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
    self.levelTimer.frameInterval = 5;
    [self.levelTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

}
- (void)stopMeterTimer {
    [self.levelTimer invalidate];
    self.levelTimer = nil;
    [self.levelMeterView resetLevelMeter];
}

- (void)updateMeter {
    LevelPair *levels = [self.recorderManager levels];
    self.levelMeterView.level = levels.level;
    self.levelMeterView.peakLevel = levels.peakLevel;
    [self.levelMeterView setNeedsDisplay];
}


#pragma mark - UITableView Datasource and Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.memos.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MemoCell *cell = [tableView dequeueReusableCellWithIdentifier:MEMO_CELL forIndexPath:indexPath];
    Memo *memo = self.memos[indexPath.row];
    
    cell.titleLabel.text = memo.title;
    cell.dateLabel.text = memo.dateString;
    cell.timeLabel.text = memo.timeString;
    
    return cell;

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Memo *memo = self.memos[indexPath.row];
    [self.recorderManager playbackMemo:memo];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Memo *memo = self.memos[indexPath.row];
        [memo deleteMemo];
        [self.memos removeObjectAtIndex:indexPath.row];
        [self saveMemos];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}




- (IBAction)record:(id)sender {
    
    self.stopBtn.enabled = YES;
    if (![sender isSelected]) {
        [self startMeterTimer];
        [self startTimer];
        [self.recorderManager record];
    }else{
        [self stopMeterTimer];
        [self stopTimer];
        [self.recorderManager pause];
    }
    [sender setSelected:![sender isSelected]];
    
    
}

- (IBAction)stopRecording:(id)sender {
    
    [self stopMeterTimer];
    self.recordBtn.selected = NO;
    self.stopBtn.enabled = NO;
    [self.recorderManager stopWithCompletionHandler:^(BOOL isComplete) {
       
        double deplayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,(int64_t)(deplayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
           
            [self showSaveDialog];
        });
    }];
    
}

-(void)showSaveDialog{

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Save Recording"
                                          message:@"Please provide a name"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"My Recording", @"Login");
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *filename = [alertController.textFields.firstObject text];
        [self.recorderManager saveRecordingWithName:filename completionHandler:^(BOOL success, id object) {
            if (success) {
                [self.memos addObject:object];
                [self saveMemos];
                [self.tableView reloadData];
            } else {
                NSLog(@"Error saving file: %@", [object localizedDescription]);
            }
        }];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];


}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
