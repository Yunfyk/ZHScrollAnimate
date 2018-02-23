//
//  ZHWeakTimer.h
//  ZHBCollectionView
//
//  Created by zhusanbao on 2017/12/30.
//  Copyright © 2017年 zhusanbao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHWeakTimer : NSObject

- (void)invaliadTimer;
- (void)fireTimer;
- (void)pauseTimer;
- (void)resumeTimer;

+ (instancetype)weakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

@end
