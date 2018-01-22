//
//  ZHSimpleScrollContentView.h
//  ZHScrollAnimate
//
//  Created by 朱三保 on 2018/1/16.
//  Copyright © 2018年 zhusanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kMSimpleAnimateTypeR2L  = 10,       //右向左动画
    kMSimpleAnimateTypeL2R,             //左向右动画
    kMSimpleAnimateTypeB2T,             //下向上动画
    kMSimpleAnimateTypeT2B,             //上向下动画
    kMSimpleAnimateTypeManualScroll,    //手动滑动
    
    kMSimpleAnimateTypeFlipFromLeft = UIViewAnimationOptionTransitionFlipFromLeft,     //左向右翻转
    kMSimpleAnimateTypeFlipFromRight= UIViewAnimationOptionTransitionFlipFromRight,    //右向左翻转
    kMSimpleAnimateTypeCurlUp       = UIViewAnimationOptionTransitionCurlUp,           //上翻页
    kMSimpleAnimateTypeCurlDown     = UIViewAnimationOptionTransitionCurlDown,         //下翻页
    kMSimpleAnimateTypeDissolve     = UIViewAnimationOptionTransitionCrossDissolve,    //渐隐
    kMSimpleAnimateTypeFlipFromTop  = UIViewAnimationOptionTransitionFlipFromTop,      //下向上翻转
    kMSimpleAnimateTypeFlipFromBottom= UIViewAnimationOptionTransitionFlipFromBottom   //上向下翻转
} kMSimpleAnimateType;

typedef UIView *(^viewForIndexBlock)(NSInteger index);

@interface ZHSimpleScrollContentView : UIView
{
@public
    NSInteger      *_index;
    NSInteger      *_showIndex;
}
@property (nonatomic, assign) kMSimpleAnimateType           scrollType;
@property (nonatomic, weak)   UIView                        *tmpView;
@property (nonatomic, assign) CGRect                        nextFrame;

@property (nonatomic, assign) NSInteger                     numberOfRows;

@property (nonatomic, copy)   viewForIndexBlock             viewForIndex;

@property (nonatomic, assign) CGFloat                       offset;

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType;

- (void)getNewContentView;

- (void)updateContentView;

- (void)nextFrameRecord;

//animate finished and condition for record next frame
- (void)finishAnimation;

@end
