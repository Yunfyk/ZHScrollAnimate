//
//  ZHSimpleAnimateView.m
//  ZHBCollectionView
//
//  Created by 朱三保 on 2017/12/29.
//  Copyright © 2017年 zhusanbao. All rights reserved.
//

#import "ZHSimpleAnimateView.h"
#import "ZHWeakTimer.h"
#import <objc/runtime.h>
#import "ZHSimpleContentWrapper.h"

@interface ZHSimpleAnimateView()<UIScrollViewDelegate>

@property (nonatomic, assign) kMSimpleAnimateType           scrollType;
@property (nonatomic, strong) UIScrollView                  *scrollView;//三个view的容器
@property (strong, nonatomic) ZHSimpleContentWrapper        *contentWrapper;
@property (nonatomic, weak)   ZHSimpleScrollContentView     *currentShowView;

@end

@implementation ZHSimpleAnimateView
@synthesize contentView=_contentView,backgroudImageView=_backgroudImageView;

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled = NO;
//        _scrollView.pagingEnabled = YES;
//        _scrollView.bounces       = NO;
//        _scrollView.decelerationRate = 0.01;
        _scrollView.delegate      = self;
    }
    return _scrollView;
}
- (ZHSimpleContentWrapper *)contentWrapper{
    if (!_contentWrapper) {
        _contentWrapper = [[ZHSimpleContentWrapper alloc] initWithScrollType:self.scrollType];
        __weak typeof(self)weak_self = self;
        _contentWrapper.viewForIndex = ^UIView *(NSInteger index){
            return weak_self.viewForIndex ? weak_self.viewForIndex(index):nil;
        };
    }
    return _contentWrapper;
}
- (UIView *)contentView{
    if (!_contentView) {
        _contentView                = [[UIView alloc] init];
        [self insertSubview:_contentView atIndex:0];
        [self addFillConstraintWithView:_contentView];
    }
    return _contentView;
}
- (UIImageView *)backgroudImageView{
    if (!_backgroudImageView) {
        _backgroudImageView                = [[UIImageView alloc] init];
        [self insertSubview:_backgroudImageView aboveSubview:self.contentView];
        [self addFillConstraintWithView:_backgroudImageView];
    }
    return _backgroudImageView;
}
- (void)addFillConstraintWithView:(UIView *)view{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *hvfl = [view isKindOfClass:[UIScrollView class]] ? @"H:|-0-[view(==self)]-0-|" : @"H:|-0-[view]-0-|";
    NSString *vvfl = [view isKindOfClass:[UIScrollView class]] ? @"V:|-0-[view(==self)]-0-|" : @"V:|-0-[view]-0-|";
    NSArray *HC = [NSLayoutConstraint constraintsWithVisualFormat:hvfl options:0 metrics:nil views:NSDictionaryOfVariableBindings(self,view)];
    NSArray *VC = [NSLayoutConstraint constraintsWithVisualFormat:vvfl options:0 metrics:nil views:NSDictionaryOfVariableBindings(self,view)];
    [self addConstraints:HC];
    [self addConstraints:VC];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initDataWithType:kMSimpleAnimateTypeB2T];
    }
    return self;
}

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 100, 20);
        [self initDataWithType:scrollType];
    }
    return self;
}
#pragma --mark--初始化--
- (void)initDataWithType:(kMSimpleAnimateType)scrollType{
//    self.clipsToBounds          = YES;
    self.scrollType             = scrollType;
    self.scrollView.clipsToBounds = NO;
    self.autoAnimate            = NO;
    self.timeInterval           = 3.0f;
    self.numberOfRows           = 3;

    [self addSubview:self.scrollView];
    [self addFillConstraintWithView:self.scrollView];
    
    [self.scrollView addSubview:self.contentWrapper];
}

- (void)setAutoAnimate:(BOOL)autoAnimate{
    self.contentWrapper.autoAnimate = autoAnimate;
}
- (BOOL)autoAnimate{
    return self.contentWrapper.autoAnimate;
}
- (void)setTimeInterval:(NSTimeInterval)timeInterval{
    self.contentWrapper.timeInterval = timeInterval;
}
- (NSTimeInterval)timeInterval{
    return self.contentWrapper.timeInterval;
}

- (NSInteger)showIndex{
    return self.contentWrapper.showIndex;
}
- (UIView *)showView{
    return self.contentWrapper.currentShowView.tmpView;
}
- (BOOL)isHorizontalDirect{
    return (kMSimpleAnimateTypeL2R == self.scrollType || kMSimpleAnimateTypeR2L == self.scrollType);
}
- (BOOL)isVerticalDirect{
    return (kMSimpleAnimateTypeT2B == self.scrollType || kMSimpleAnimateTypeB2T == self.scrollType);
}

- (void)next{
    [self nextWithAnimate:YES complete:nil];
}

- (void)nextWithAnimate:(BOOL)animate complete:(void (^)(BOOL))completeHandle{
    [self nextWithAnimate:animate isauto:NO complete:completeHandle];
}
- (void)nextWithAnimate:(BOOL)animate isauto:(BOOL)isAuto  complete:(void (^)(BOOL))completeHandle{
    if (self.scrollEnable) {NSLog(@"滚动模式下(scrollEnable = YES)不支持next 方法, 请使用scrollToIndex:animate:"); return;}
    [self.contentWrapper nextWithAnimate:animate isauto:isAuto complete:completeHandle];
}

- (void)layoutSubviews{
    if (self.contentWrapper.frame.size.width != self.frame.size.width) {
        self.contentWrapper.frame = self.bounds;
        [self resetScrollViewContentSize];
    }
    [super layoutSubviews];
}

- (void)resetScrollViewContentSize{
    if (self.scrollEnable) {
        if ([self isHorizontalDirect]) {
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame)*self.numberOfRows, CGRectGetHeight(self.frame));
            if (kMSimpleAnimateTypeL2R == self.scrollType) {
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*(self.numberOfRows-1), 0) animated:NO];
            }
        }else if ([self isVerticalDirect]){
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)*self.numberOfRows);
            if (kMSimpleAnimateTypeT2B == self.scrollType) {
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.frame.size.height*(self.numberOfRows-1)) animated:NO];
            }
        }else{
            self.scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        }
    }else{
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
}

#pragma --mark --scroolView delegate --
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect contentFrame = self.contentWrapper.frame;
    if ([self isHorizontalDirect]) {
        CGFloat width = scrollView.frame.size.width;
        CGFloat offset = scrollView.contentOffset.x;
//        self.contentWrapper.showIndex = MAX(0, ((offset + 0.5*width)/width));
        NSInteger currentPage = MAX(0, ((offset + 0.5*width)/width));
        self.contentWrapper.frame = (CGRect){offset,contentFrame.origin.y,contentFrame.size};
        if (self.contentWrapper.showIndex != currentPage) {
            self.contentWrapper.showIndex = currentPage;
            [self.contentWrapper updateContentView];
        }
//        NSLog(@"%ld",(long)self.contentWrapper.showIndex);
        if (offset + width*0.5 < 0 ||  offset + width > width * self.numberOfRows) {return;}
    }else if ([self isVerticalDirect]){
        CGFloat height = self.frame.size.height;
        CGFloat offset = scrollView.contentOffset.y;
        self.contentWrapper.showIndex = MAX(0, ((offset + 0.5*height)/height));
        self.contentWrapper.frame = (CGRect){contentFrame.origin.x,offset,contentFrame.size};
        if (offset + height*0.5 < 0 || offset + height > height * self.numberOfRows) {return;}
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat kMaxIndex = self.numberOfRows - 1;//self.dataSource.count - 1;
    if ([self isVerticalDirect]) {
        CGFloat cellwidth = self.frame.size.height;
        CGFloat targetY = scrollView.contentOffset.y + velocity.y * cellwidth/2;
        CGFloat targetIndex = round(targetY / cellwidth);
        if (targetIndex < 0)
            targetIndex = 0;
        if (targetIndex > kMaxIndex)
            targetIndex = kMaxIndex;
        targetContentOffset->y = targetIndex * (cellwidth);
    }else{
        CGFloat cellwidth = self.frame.size.width;
        CGFloat targetX = scrollView.contentOffset.x + velocity.x * cellwidth/2;
        CGFloat targetIndex = round(targetX / cellwidth);
        if (targetIndex < 0)
            targetIndex = 0;
        if (targetIndex > kMaxIndex)
            targetIndex = kMaxIndex;
        targetContentOffset->x = targetIndex * (cellwidth);
    }
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    [self.contentWrapper adjustFrameSize];
//}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end

@implementation ZHSimpleAnimateView (ZHSimpleAnimateScroll)
- (void)scrollToIndex:(NSInteger)index animate:(BOOL)animated{
    if (!self.scrollEnable) {NSLog(@"scrollEnable not valiad");return;}
//    if (self.scrollView.dragging || self.scrollView.decelerating || self.scrollView.tracking) {return;}
    if (self.contentWrapper.showIndex == index) {return;}
    CGRect frame = self.contentWrapper.frame;
    NSInteger loopIndex = self.contentWrapper.showIndex < index ? index - 1 : index + 1;
    CGPoint previousOffset = CGPointZero;
    CGPoint targetOffset   = CGPointZero;
    if ([self isHorizontalDirect]) {
        frame.origin.x = MAX(0, self.scrollView.frame.size.width * (loopIndex));
        previousOffset = CGPointMake(frame.origin.x, 0);
        targetOffset   = CGPointMake(self.scrollView.frame.size.width * index, 0);
    }else if([self isVerticalDirect]){
        frame.origin.y = MAX(0, self.scrollView.frame.size.height * (loopIndex));
        previousOffset = CGPointMake(0, frame.origin.y);
        targetOffset   = CGPointMake(0, self.scrollView.frame.size.height * index);
    }
    self.scrollView.scrollEnabled = NO;
    self.contentWrapper.scrollTagetFrame = frame;
    [self.scrollView setContentOffset:previousOffset animated:NO];
    [self.contentWrapper updateContentView];
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.scrollView setContentOffset:targetOffset];
        } completion:^(BOOL finished) {
            [self.contentWrapper adjustFrameSize];
            self.scrollView.scrollEnabled = YES;
        }];
    }else{
        [self.scrollView setContentOffset:targetOffset];
        [self.contentWrapper adjustFrameSize];
        self.scrollView.scrollEnabled = YES;
    }
}

- (void)setNumberOfRows:(NSUInteger)numberOfRows{
    if (numberOfRows > 0) {
        self.contentWrapper.numberOfRows = numberOfRows;
    }
    objc_setAssociatedObject(self, _cmd, [NSNumber numberWithUnsignedInteger:numberOfRows], OBJC_ASSOCIATION_ASSIGN);
}
- (NSUInteger)numberOfRows{
    return [objc_getAssociatedObject(self, @selector(setNumberOfRows:)) unsignedIntegerValue];
}
- (void)setScrollEnable:(BOOL)scrollEnable{
    if (scrollEnable && (![self isHorizontalDirect] && ![self isVerticalDirect])) {
        NSLog(@"assigned scroll type not valiad");return;
    }
    self.scrollView.scrollEnabled = scrollEnable;
    [self resetScrollViewContentSize];
}
- (BOOL)scrollEnable{
    return self.scrollView.scrollEnabled;
}

- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator{
    self.scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
}
- (BOOL)showsVerticalScrollIndicator{
    return self.scrollView.showsVerticalScrollIndicator;
}
- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator{
    self.scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
}
- (BOOL)showsHorizontalScrollIndicator{
    return self.scrollView.showsHorizontalScrollIndicator;
}
- (void)setBounces:(BOOL)bounces{
    self.scrollView.bounces = bounces;
}
- (BOOL)bounces{
    return self.scrollView.bounces;
}
@end

