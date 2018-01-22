//
//  ZHSimpleAnimateContent.h
//  ZHScrollAnimate
//
//  Created by zhusanbao on 2018/1/21.
//  Copyright © 2018年 zhusanbao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHSimpleScrollContentView.h"

@interface ZHSimpleAnimateContent : UIView

@property (nonatomic, copy)   UIView *(^viewForIndex)(NSInteger index);
@property (assign, nonatomic) NSUInteger                    numberOfRows;
@property (assign, nonatomic) BOOL                          autoAnimate;
/** 动画间隔,默认3s */
@property (assign, nonatomic) NSTimeInterval                timeInterval;

@property (assign, nonatomic) NSInteger                     index;
@property (assign, nonatomic) NSInteger                     showIndex;
@property (nonatomic, weak)   ZHSimpleScrollContentView     *currentShowView;

@property (assign, nonatomic) CGRect                        scrollTagetFrame;

- (void)updateContentView;

/** 视图即将显示在中间 */
@property (nonatomic, copy)   void(^viewWillShow)(UIView *subView);
/** 视图已经显示在中间 */
@property (nonatomic, copy)   void(^viewDidShowAtIndex)(UIView *subView,NSInteger index);

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType;

- (void)nextWithAnimate:(BOOL)animate isauto:(BOOL)isAuto complete:(void (^)(BOOL))completeHandle;

@end
