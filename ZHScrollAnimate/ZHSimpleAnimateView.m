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

@interface ZHSimpleAnimateView()<UIScrollViewDelegate>

@property (nonatomic, assign) kMSimpleAnimateType           scrollType;
@property (nonatomic, strong) UIScrollView                  *scrollView;
@property (nonatomic, strong) ZHSimpleScrollContentView     *view1;
@property (nonatomic, strong) ZHSimpleScrollContentView     *view2;
@property (nonatomic, readonly)ZHSimpleScrollContentView    *view3;
@property (nonatomic, weak)   ZHSimpleScrollContentView     *currentShowView;
@property (nonatomic, assign) BOOL                          isAminating;

@property (weak, nonatomic)   ZHSimpleScrollContentView     *tmpView1;
@property (weak, nonatomic)   ZHSimpleScrollContentView     *tmpView2;

@property (strong, nonatomic) ZHWeakTimer                   *timer;

@end

@implementation ZHSimpleAnimateView{
    NSInteger _index;
    NSInteger _showIndex;
}
@synthesize contentView=_contentView,backgroudImageView=_backgroudImageView;
@synthesize view3=_view3;

- (ZHSimpleScrollContentView *)view1{
    if (!_view1) {
        _view1 = [[ZHSimpleScrollContentView alloc] initWithScrollType:self.scrollType];
        _view1.frame = self.bounds;
        [self commonViewConfigure:_view1];
    }
    return _view1;
}
- (ZHSimpleScrollContentView *)view2{
    if (!_view2) {
        _view2 = [[ZHSimpleScrollContentView alloc] initWithScrollType:self.scrollType];
        _view2.frame = CGRectMake(10, 10, 10, 10);
        if (self.scrollType >= (1 << 20)) {
            _view2.hidden = YES;
        }
        [self commonViewConfigure:_view2];
    }
    return _view2;
}
- (void)initView3{
    if (!_view3) {
        _view3 = [[ZHSimpleScrollContentView alloc] initWithScrollType:self.scrollType];
        [self commonViewConfigure:_view3];
        [self.scrollView addSubview:_view3];
    }
}
- (void)commonViewConfigure:(ZHSimpleScrollContentView *)view{
    view->_index = &_index;
    view->_showIndex = &_showIndex;
    view.numberOfRows= self.numberOfRows;
    __weak typeof(self)weak_self = self;
    view.viewForIndex = ^UIView *(NSInteger index){
        return weak_self.viewForIndex ? weak_self.viewForIndex(index):nil;
    };
}

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
- (ZHWeakTimer *)timer{
    if (!_timer) {
        _timer = [ZHWeakTimer weakTimerWithTimeInterval:self.timeInterval target:self selector:@selector(autoAnimateDispatch) userInfo:nil repeats:YES];
    }
    return _timer;
}
- (void)invaliadTimer{
    if (_timer) {
        [_timer invaliadTimer];
        _timer = nil;
    }
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
- (void)initDataWithType:(kMSimpleAnimateType)scrollType{
    _index = -1;
//    self.clipsToBounds          = YES;
    self.scrollView.clipsToBounds = NO;
    self.autoAnimate            = NO;
    self.timeInterval           = 3.0f;
    self.scrollType             = scrollType;
    self.numberOfRows           = 3;
    [self addSubview:self.scrollView];
    [self addFillConstraintWithView:self.scrollView];
    if (self.scrollType < 20) {
        [self initView3];
    }
    [self.scrollView addSubview:self.view2];
    [self.scrollView addSubview:self.view1];
    self.tmpView1 = self.view1;
    self.tmpView2 = self.view2;
    self.currentShowView = self.view1;
}

- (NSInteger)showIndex{
    return _showIndex;
}
- (UIView *)showView{
    return self.currentShowView.tmpView;
}
- (BOOL)isHorizontalDirect{
    return (kMSimpleAnimateTypeL2R == self.scrollType || kMSimpleAnimateTypeR2L == self.scrollType);
}
- (BOOL)isVerticalDirect{
    return (kMSimpleAnimateTypeT2B == self.scrollType || kMSimpleAnimateTypeB2T == self.scrollType);
}
- (void)didMoveToWindow{
    if (_index == -1) {
        _index = 0;
        [self.view1 getNewContentView];
        [self.view2 getNewContentView];
        if (self.autoAnimate) {
            [self.timer fireTimer];
        }
        if (self.viewWillShow) {
            self.viewWillShow(self.currentShowView.tmpView);
        }
    }
    [super didMoveToWindow];
}

- (void)next{
    [self nextWithAnimate:YES complete:nil];
}
- (void)autoAnimateDispatch{
    [self nextWithAnimate:YES isauto:YES complete:nil];
}
- (void)nextWithAnimate:(BOOL)animate complete:(void (^)(BOOL))completeHandle{
    [self nextWithAnimate:animate isauto:NO complete:completeHandle];
}
- (void)nextWithAnimate:(BOOL)animate isauto:(BOOL)isAuto  complete:(void (^)(BOOL))completeHandle{
    if (!self.view1.tmpView || !self.view2.tmpView) {//资源少于两个直接返回
        NSLog(@"至少传入两个子view");
        return;
    }
    if (self.isAminating) {
        [self.view1.layer removeAllAnimations];
        [self.view2.layer removeAllAnimations];
    }
    if (self.autoAnimate && !isAuto) {
        [self invaliadTimer];
    }
    if ([self isHorizontalDirect] || [self isVerticalDirect]) {
        self.isAminating = YES;
        if (CGRectEqualToRect(self.view1.nextFrame, self.bounds)) {
            self.currentShowView = self.view1;
        }else if (CGRectEqualToRect(self.view2.nextFrame, self.bounds)){
            self.currentShowView = self.view2;
        }else if (CGRectEqualToRect(self.view3.nextFrame, self.bounds)){
            self.currentShowView = self.view3;
        }
        if (self.viewWillShow) {
            self.viewWillShow(self.currentShowView.tmpView);
        }
        if (animate) {
            [UIView animateWithDuration:0.6 animations:^{
                [self.view1 setFrame:self.view1.nextFrame];
                [self.view2 setFrame:self.view2.nextFrame];
                [self.view3 setFrame:self.view3.nextFrame];
            } completion:^(BOOL finished) {
                [self.view1 finishAnimation];
                [self.view2 finishAnimation];
                [self.view3 finishAnimation];
                self.isAminating = NO;
                if (self.autoAnimate && !isAuto) {
                    [self.timer fireTimer];
                }
                if (self.viewDidShowAtIndex) {
                    self.viewDidShowAtIndex(self.currentShowView.tmpView, self.showIndex);
                }
                if (completeHandle) {
                    completeHandle(finished);
                }
            }];
        }else{
            [self.view1 setFrame:self.view1.nextFrame];
            [self.view2 setFrame:self.view2.nextFrame];
            [self.view1 finishAnimation];
            [self.view2 finishAnimation];
            if (self.autoAnimate && !isAuto) {
                [self.timer fireTimer];
            }
            if (self.viewDidShowAtIndex) {
                self.viewDidShowAtIndex(self.currentShowView.tmpView, self.showIndex);
            }
            if (completeHandle) {
                completeHandle(YES);
            }
        }
    }else if (self.scrollType >= (1 << 20)){
        self.isAminating = YES;
        NSTimeInterval duration     = animate ? 0.5 : 0;
        UIViewAnimationOptions ops  = animate ? (self.scrollType|UIViewAnimationOptionShowHideTransitionViews):UIViewAnimationOptionShowHideTransitionViews;
        self.currentShowView = self.tmpView2;
        if (self.viewWillShow) {
            self.viewWillShow(self.currentShowView);
        }
        [UIView transitionFromView:self.tmpView1 toView:self.tmpView2 duration:duration options:ops completion:^(BOOL finished) {
            if (self.viewDidShowAtIndex) {
                self.viewDidShowAtIndex(self.currentShowView.tmpView, self.showIndex);
            }
            [self.tmpView1 getNewContentView];
            ZHSimpleScrollContentView *tmp     = self.tmpView1;
            self.tmpView1  = self.tmpView2;
            self.tmpView2  = tmp;
            self.isAminating= NO;
            if (self.autoAnimate && !isAuto) {
                [self.timer fireTimer];
            }
            if (completeHandle) {
                completeHandle(finished);
            }
        }];
    }
}

- (void)layoutSubviews{
    if (self.view1.frame.size.width != self.frame.size.width || self.view1.frame.size.height != self.frame.size.height) {
        [self resetScrollViewContentSize];
        [self.view1 setFrame:self.bounds];
        [self.view1 nextFrameRecord];
        [self.view1 layoutIfNeeded];
        if (self.viewDidShowAtIndex) {
            self.viewDidShowAtIndex(self.currentShowView.tmpView, self.showIndex);
        }
        if (kMSimpleAnimateTypeR2L == self.scrollType) {
            [self.view2 setFrame:(CGRect){(CGPoint){self.frame.size.width,0},self.frame.size}];
            [self.view2 nextFrameRecord];
            [self.view3 setFrame:(CGRect){(CGPoint){-self.frame.size.width,0},self.frame.size}];
            [self.view3 nextFrameRecord];
        }else if (kMSimpleAnimateTypeL2R == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){-self.frame.size.width,0},self.frame.size}];
            [self.view2 nextFrameRecord];
            [self.view3 setFrame:(CGRect){(CGPoint){self.frame.size.width,0},self.frame.size}];
            [self.view3 nextFrameRecord];
        }else if (kMSimpleAnimateTypeB2T == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){0,self.frame.size.height},self.frame.size}];
            [self.view2 nextFrameRecord];
            [self.view3 setFrame:(CGRect){(CGPoint){0,-self.frame.size.height},self.frame.size}];
            [self.view3 nextFrameRecord];
        }else if (kMSimpleAnimateTypeT2B == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){0,-self.frame.size.height},self.frame.size}];
            [self.view2 nextFrameRecord];
            [self.view3 setFrame:(CGRect){(CGPoint){0,self.frame.size.height},self.frame.size}];
            [self.view3 nextFrameRecord];
        }else if (self.scrollType >= (1 << 20)){
            self.view2.frame = self.view1.frame;
        }
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
    NSLog(@"%@|%@",NSStringFromCGRect([self.scrollView convertRect:self.view1.frame toView:self]),NSStringFromCGPoint(scrollView.contentOffset));
    if ([self isHorizontalDirect]) {
        CGFloat width = self.frame.size.width;
        CGFloat offset = scrollView.contentOffset.x;
        _showIndex = MAX(0, ((offset + 0.5*width)/width));
        if (offset + width*0.5 < 0 ||  offset + width > width * self.numberOfRows) {return;}
    }else if ([self isVerticalDirect]){
        CGFloat height = self.frame.size.height;
        CGFloat offset = scrollView.contentOffset.y;
        _showIndex = MAX(0, ((offset + 0.5*height)/height));
        if (offset + height*0.5 < 0 || offset + height > height * self.numberOfRows) {return;}
    }
    self.view1.realTimeRelativeFrame = [self.scrollView convertRect:self.view1.frame toView:self];
    self.view2.realTimeRelativeFrame = [self.scrollView convertRect:self.view2.frame toView:self];
    self.view3.realTimeRelativeFrame = [self.scrollView convertRect:self.view3.frame toView:self];
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
    [_timer invaliadTimer];
    NSLog(@"%s",__func__);
}

@end

@implementation ZHSimpleAnimateView (ZHSimpleAnimateScroll)
- (void)scrollToIndex:(NSInteger)index animate:(BOOL)animated{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * index, 0)];
}

- (void)setNumberOfRows:(NSUInteger)numberOfRows{
    if (numberOfRows > 0) {
        self.view1.numberOfRows = self.view2.numberOfRows = self.view3.numberOfRows = numberOfRows;
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

