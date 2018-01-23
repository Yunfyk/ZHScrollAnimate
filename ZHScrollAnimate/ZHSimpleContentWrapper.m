//
//  ZHSimpleContentWrapper.m
//  ZHScrollAnimate
//
//  Created by zhusanbao on 2018/1/21.
//  Copyright © 2018年 zhusanbao. All rights reserved.
//

#import "ZHSimpleContentWrapper.h"
#import "ZHWeakTimer.h"

@interface ZHSimpleContentWrapper ()

@property (nonatomic, strong) ZHSimpleScrollContentView     *view1;
@property (nonatomic, strong) ZHSimpleScrollContentView     *view2;
@property (nonatomic, readonly)ZHSimpleScrollContentView    *view3;

@property (nonatomic, assign) kMSimpleAnimateType           scrollType;

@property (weak, nonatomic)   ZHSimpleScrollContentView     *tmpView1;
@property (weak, nonatomic)   ZHSimpleScrollContentView     *tmpView2;

@property (strong, nonatomic) ZHWeakTimer                   *timer;
@property (nonatomic, assign) BOOL                          isAminating;

@end

@implementation ZHSimpleContentWrapper
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
        [self addSubview:_view3];
    }
}

- (void)commonViewConfigure:(ZHSimpleScrollContentView *)view{
    view->_index = &_index;
    view->_showIndex = &_showIndex;
    __weak typeof(self)weak_self = self;
    view.viewForIndex = ^UIView *(NSInteger index){
        return weak_self.viewForIndex ? weak_self.viewForIndex(index):nil;
    };
}

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType{
    if (self = [super init]) {
        _index      = -1;
        self.scrollType = scrollType;
        if (self.scrollType < 20) {
            [self initView3];
        }
        [self addSubview:self.view2];
        [self addSubview:self.view1];
        self.tmpView1 = self.view1;
        self.tmpView2 = self.view2;
        self.currentShowView = self.view1;
    }
    return self;
}

- (void)setNumberOfRows:(NSUInteger)numberOfRows{
    _numberOfRows       = numberOfRows;
    _view1.numberOfRows = numberOfRows;
    _view2.numberOfRows = numberOfRows;
    _view3.numberOfRows = numberOfRows;
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

- (void)setFrame:(CGRect)frame{
    CGRect primitFrame = self.frame;
    [super setFrame:frame];
    CGFloat offset = 0;
    if ([self isHorizontalDirect]) {
        offset  = primitFrame.origin.x - frame.origin.x;
    }else if ([self isVerticalDirect]){
        offset  = primitFrame.origin.y - frame.origin.y;
    }
    _view1.offset   = offset;
    _view2.offset   = offset;
    if (_view3) {_view3.offset = offset;}
}
- (void)setScrollTagetFrame:(CGRect)scrollTagetFrame{
    [super setFrame:scrollTagetFrame];
}

- (void)updateContentView{
    [_view1 updateContentView];
    [_view2 updateContentView];
    [_view3 updateContentView];
}

//- (void)adjustFrameSize{
//    
//}

- (void)autoAnimateDispatch{
    [self nextWithAnimate:YES isauto:YES complete:nil];
}

- (void)nextWithAnimate:(BOOL)animate isauto:(BOOL)isAuto complete:(void (^)(BOOL))completeHandle{
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
                self.viewDidShowAtIndex(self.currentShowView.tmpView, _showIndex);
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
                self.viewDidShowAtIndex(self.currentShowView.tmpView, _showIndex);
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

- (void)dealloc
{
    [_timer invaliadTimer];
    NSLog(@"%s",__func__);
}

@end
