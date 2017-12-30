//
//  NBExerciseCollectionView.h
//  ZHBCollectionView
//
//  Created by 朱三保 on 2017/12/29.
//  Copyright © 2017年 zhusanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kMSimpleAnimateTypeR2L  = 10,       //右向左动画
    kMSimpleAnimateTypeL2R,             //左向右动画
    kMSimpleAnimateTypeB2T,             //下向上动画
    kMSimpleAnimateTypeT2B,             //上向下动画
    
    kMSimpleAnimateTypeFlipFromLeft = UIViewAnimationOptionTransitionFlipFromLeft,     //左向右翻转
    kMSimpleAnimateTypeFlipFromRight= UIViewAnimationOptionTransitionFlipFromRight,    //右向左翻转
    kMSimpleAnimateTypeCurlUp       = UIViewAnimationOptionTransitionCurlUp,           //上翻页
    kMSimpleAnimateTypeCurlDown     = UIViewAnimationOptionTransitionCurlDown,         //下翻页
    kMSimpleAnimateTypeDissolve     = UIViewAnimationOptionTransitionCrossDissolve,    //渐隐
    kMSimpleAnimateTypeFlipFromTop  = UIViewAnimationOptionTransitionFlipFromTop,      //下向上翻转
    kMSimpleAnimateTypeFlipFromBottom= UIViewAnimationOptionTransitionFlipFromBottom   //上向下翻转
} kMSimpleAnimateType;

typedef UIView *(^viewForIndexBlock)(NSInteger index);

@interface ZHSimpleAnimateView : UIView
//获取子视图，大小与本视图大小一致，填充整个区域
@property (nonatomic, copy)   viewForIndexBlock viewForIndex;
//自动开始动画/滚动
@property (assign, nonatomic) BOOL              autoAnimate;
//动画间隔,默认3s
@property (assign, nonatomic) NSTimeInterval    timeInterval;

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType;

//next with animate YES
- (void)next;
//下一个
- (void)nextWithAnimate:(BOOL)animate;

@end
