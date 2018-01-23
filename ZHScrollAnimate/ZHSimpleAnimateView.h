//
//  NBExerciseCollectionView.h
//  ZHBCollectionView
//
//  Created by 朱三保 on 2017/12/29.
//  Copyright © 2017年 zhusanbao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHSimpleScrollContentView.h"

@interface ZHSimpleAnimateView : UIView
/** 底层视图 */
@property (strong, readonly)  UIView            *contentView;
/** 背景图片 */
@property (strong, readonly)  UIImageView       *backgroudImageView;
/** 获取子视图，大小与本视图大小一致，填充整个区域 */
@property (nonatomic, copy)   viewForIndexBlock viewForIndex;
/** 是否开始自动动画/滚动 ,在开启手势滚动的情况下自动滚动不起作用, 自动滚动请手动调用scrollToIndex:*/
@property (assign, nonatomic) BOOL              autoAnimate;
/** 动画间隔,默认3s */
@property (assign, nonatomic) NSTimeInterval    timeInterval;
/** 当前显示的index */
@property (nonatomic, readonly) NSInteger       showIndex;
/** 当前显示的View */
@property (nonatomic, readonly) UIView          *showView;
/** 视图即将显示在中间 */
@property (nonatomic, copy)   void(^viewWillShow)(UIView *subView);
/** 视图已经显示在中间 */
@property (nonatomic, copy)   void(^viewDidShowAtIndex)(UIView *subView,NSInteger index);

/** next with animate YES ,if set the scrollEnable for YES ,this method will be disabled*/
- (void)next;
//下一个
/**
 next page with animate ops and complete handler,if set the scrollEnable for YES ,this method will be disabled
 
 @param animate YES or NO for animate
 @param completeHandle animate complete callback
 */
- (void)nextWithAnimate:(BOOL)animate complete:(void(^)(BOOL finished))completeHandle;

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType;

@end

@interface ZHSimpleAnimateView (ZHSimpleAnimateScroll)

/** scroll Enable only for R2L,L2R,B2T,T2B types */
@property (nonatomic, assign) BOOL          scrollEnable;
/** count of rows */
@property (nonatomic, assign) NSUInteger    numberOfRows;
/** scroll to assigned index */
- (void)scrollToIndex:(NSInteger)index animate:(BOOL)animated;

@end

