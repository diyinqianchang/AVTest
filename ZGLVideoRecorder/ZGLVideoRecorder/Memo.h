//
//  Memo.h
//  ZGLVideoRecorder
//
//  Created by 张国林 on 2017/12/3.
//  Copyright © 2017年 diyinqianchang. All rights reserved.
//

#import <Foundation/Foundation.h>


//存储录制音频资料的model
@interface Memo : NSObject<NSCoding>


@property (copy, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSURL *url;
@property (copy, nonatomic, readonly) NSString *dateString;
@property (copy, nonatomic, readonly) NSString *timeString;

+ (instancetype)memoWithTitle:(NSString *)title url:(NSURL *)url;

- (BOOL)deleteMemo;

@end
