//
//  ZHWeakTimer.m
//  ZHBCollectionView
//
//  Created by zhusanbao on 2017/12/30.
//  Copyright © 2017年 zhusanbao. All rights reserved.
//

#import "ZHWeakTimer.h"

@interface ZHWeakTimer ()

@property (strong, nonatomic) NSTimer           *timer;
@property (assign, nonatomic) NSTimeInterval    duration;

@property (weak, nonatomic)   id                target;
@property (assign, nonatomic) SEL               selector;

@end

@implementation ZHWeakTimer

- (void)invaliadTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
- (void)fireTimer{
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.duration]];
}
- (void)pauseTimer{
    if (_timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}
- (void)resumeTimer{
    if (_timer) {
        [self.timer setFireDate:[NSDate date]];
    }
}

- (instancetype)initTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    if(self = [super init]){
        self.duration   = ti;
        self.target     = aTarget;
        self.selector   = aSelector;
        _timer = [NSTimer timerWithTimeInterval:self.duration target:self selector:@selector(timerAction) userInfo:nil repeats:yesOrNo];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

+ (instancetype)weakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    return [[self alloc] initTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

- (void)timerAction{
    if (_target && [_target respondsToSelector:_selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_selector];
#pragma clang diagnostic pop
    }
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
