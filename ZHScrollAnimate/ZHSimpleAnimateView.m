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
#import "ZHSimpleAnimateContent.h"

@interface ZHSimpleAnimateView()<UIScrollViewDelegate>

@property (nonatomic, assign) kMSimpleAnimateType           scrollType;
@property (nonatomic, strong) UIScrollView                  *scrollView;//三个view的容器
@property (strong, nonatomic) ZHSimpleAnimateContent        *scrollContainerView;
@property (nonatomic, weak)   ZHSimpleScrollContentView     *currentShowView;

@end

@implementation ZHSimpleAnimateView
@synthesize contentView=_contentView,backgroudImageView=_backgroudImageView;

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled = YES;
//        _scrollView.pagingEnabled = YES;
//        _scrollView.bounces       = NO;
//        _scrollView.decelerationRate = 0.01;
        _scrollView.delegate      = self;
    }
    return _scrollView;
}
- (ZHSimpleAnimateContent *)scrollContainerView{
    if (!_scrollContainerView) {
        _scrollContainerView = [[ZHSimpleAnimateContent alloc] initWithScrollType:self.scrollType];
        __weak typeof(self)weak_self = self;
        _scrollContainerView.viewForIndex = ^UIView *(NSInteger index){
            return weak_self.viewForIndex ? weak_self.viewForIndex(index):nil;
        };
    }
    return _scrollContainerView;
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
    self.scrollView.clipsToBounds = NO;
    self.autoAnimate            = NO;
    self.timeInterval           = 3.0f;
    self.scrollType             = scrollType;
    self.numberOfRows           = 3;

    [self addSubview:self.scrollView];
    [self addFillConstraintWithView:self.scrollView];
    
    [self.scrollView addSubview:self.scrollContainerView];
    _scrollContainerView.backgroundColor = [UIColor purpleColor];
}

- (NSInteger)showIndex{
    return self.scrollContainerView.showIndex;
}
- (UIView *)showView{
    return self.scrollContainerView.currentShowView.tmpView;
}
- (BOOL)isHorizontalDirect{
    return (kMSimpleAnimateTypeL2R == self.scrollType || kMSimpleAnimateTypeR2L == self.scrollType || kMSimpleAnimateTypeManualScroll == self.scrollType);
}
- (BOOL)isVerticalDirect{
    return (kMSimpleAnimateTypeT2B == self.scrollType || kMSimpleAnimateTypeB2T == self.scrollType || kMSimpleAnimateTypeManualScroll == self.scrollType);
}

- (void)next{
    [self nextWithAnimate:YES complete:nil];
}

- (void)nextWithAnimate:(BOOL)animate complete:(void (^)(BOOL))completeHandle{
    [self nextWithAnimate:animate isauto:NO complete:completeHandle];
}
- (void)nextWithAnimate:(BOOL)animate isauto:(BOOL)isAuto  complete:(void (^)(BOOL))completeHandle{
    [self.scrollContainerView nextWithAnimate:animate isauto:isAuto complete:completeHandle];
}

- (void)layoutSubviews{
    if (self.scrollContainerView.frame.size.width != self.frame.size.width) {
        self.scrollContainerView.frame = self.bounds;
        [self resetScrollViewContentSize];
    }
    [super layoutSubviews];
}

- (void)resetScrollViewContentSize{
    if (self.scrollEnable) {
        if ([self isHorizontalDirect]) {
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame)*self.numberOfRows, CGRectGetHeight(self.frame));
        }else if ([self isVerticalDirect]){
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)*self.numberOfRows);
        }else{
            self.scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        }
    }else{
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
}

#pragma --mark --scroolView delegate --
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"%@|%@",NSStringFromCGRect([self.scrollView convertRect:self.view1.frame toView:self]),NSStringFromCGPoint(scrollView.contentOffset));
    CGRect contentFrame = self.scrollContainerView.frame;
    if ([self isHorizontalDirect]) {
        CGFloat width = self.frame.size.width;
        CGFloat offset = scrollView.contentOffset.x;
        self.scrollContainerView.showIndex = MAX(0, ((offset + 0.5*width)/width));
        self.scrollContainerView.frame = (CGRect){offset,contentFrame.origin.y,contentFrame.size};
        if (offset + width*0.5 < 0 ||  offset + width > width * self.numberOfRows) {return;}
    }else if ([self isVerticalDirect]){
        CGFloat height = self.frame.size.height;
        CGFloat offset = scrollView.contentOffset.y;
        self.scrollContainerView.showIndex = MAX(0, ((offset + 0.5*height)/height));
        self.scrollContainerView.frame = (CGRect){contentFrame.origin.x,offset,contentFrame.size};
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

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end

@implementation ZHSimpleAnimateView (ZHSimpleAnimateScroll)
- (void)scrollToIndex:(NSInteger)index animate:(BOOL)animated{
//    if (self.scrollView.dragging || self.scrollView.decelerating || self.scrollView.tracking) {return;}
    if (self.scrollContainerView.showIndex == index) {return;}
    CGRect frame = self.scrollContainerView.frame;
    NSInteger loopIndex = self.scrollContainerView.showIndex < index ? index - 1 : index + 1;
    frame.origin.x = MAX(0, self.scrollView.frame.size.width * (loopIndex));
    self.scrollContainerView.scrollTagetFrame = frame;
    [self.scrollView setContentOffset:CGPointMake(frame.origin.x, 0) animated:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * index, 0)];
    } completion:^(BOOL finished) {
        [self.scrollContainerView updateContentView];
    }];
//    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * index, 0) animated:animated];
}

- (void)setNumberOfRows:(NSUInteger)numberOfRows{
    if (numberOfRows > 0) {
        self.scrollContainerView.numberOfRows = numberOfRows;
    }
    objc_setAssociatedObject(self, _cmd, [NSNumber numberWithUnsignedInteger:numberOfRows], OBJC_ASSOCIATION_ASSIGN);
}
- (NSUInteger)numberOfRows{
    return [objc_getAssociatedObject(self, @selector(setNumberOfRows:)) unsignedIntegerValue];
}
- (void)setScrollEnable:(BOOL)scrollEnable{
    self.scrollView.scrollEnabled = scrollEnable;
    [self resetScrollViewContentSize];
}
- (BOOL)scrollEnable{
    return self.scrollView.scrollEnabled;
}

@end

