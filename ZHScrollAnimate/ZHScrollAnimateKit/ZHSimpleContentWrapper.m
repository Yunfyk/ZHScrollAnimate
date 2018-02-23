//
//  ZHSimpleContentWrapper.m
//  ZHScrollAnimate
//
//  Created by zhusanbao on 2018/1/21.
//  Copyright © 2018年 zhusanbao. All rights reserved.
//

#import "ZHSimpleContentWrapper.h"
#import "ZHWeakTimer.h"
#import <objc/runtime.h>

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
        _view1.frame = self.bounds;_view1.tag = 1;
        [self commonViewConfigure:_view1];
    }
    return _view1;
}
- (ZHSimpleScrollContentView *)view2{
    if (!_view2) {
        _view2 = [[ZHSimpleScrollContentView alloc] initWithScrollType:self.scrollType];
        _view2.frame = CGRectMake(10, 10, 10, 10);
        if (self.scrollType >= (1 << 20) && kMSimpleAnimateTypeShuffle != self.scrollType) {
            _view2.hidden = YES;
        }
        _view2.tag = 2;
        [self commonViewConfigure:_view2];
    }
    return _view2;
}
- (void)initView3{
    if (!_view3) {
        _view3 = [[ZHSimpleScrollContentView alloc] initWithScrollType:self.scrollType];
        [self commonViewConfigure:_view3];_view3.tag = 3;
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
//        [self bindViews];
        self.tmpView1 = self.view1;
        self.tmpView2 = self.view2;
        self.currentShowView = self.view1;
//        self.backgroundColor = [UIColor magentaColor];
//        _view1.backgroundColor = [UIColor blueColor];
//        _view2.backgroundColor = [UIColor brownColor];
//        _view3.backgroundColor = [UIColor cyanColor];
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
    CGFloat offset = frame.origin.x;
    if ([self isHorizontalDirect]) {
        if (frame.origin.x < 0) {
            CGRect frame = self.frame;frame.origin.x = 0;//self.frame = frame;
        }else if (frame.origin.x > self.frame.size.width*(self.numberOfRows-1)){
            CGRect frame = self.frame;frame.origin.x = self.frame.size.width*(self.numberOfRows-1);//self.frame = frame;
        }
    }else if ([self isVerticalDirect]){
        offset = frame.origin.y;
        if (frame.origin.y < 0 || (frame.origin.y > self.frame.size.height*(self.numberOfRows-1))) {return;}
    }
//    CGRect primitFrame = self.frame;
    [super setFrame:frame];
//    if ([self isHorizontalDirect]) {
//        offset  = primitFrame.origin.x - frame.origin.x;
//    }else if ([self isVerticalDirect]){
//        offset  = primitFrame.origin.y - frame.origin.y;
//    }
    if (offset < -frame.size.width*0.4 || offset > frame.size.width*(self.numberOfRows-1)+frame.size.width*0.4) {
        return;
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

- (void)resetContentFrame{
    if (_view1.hidden) {_view1.hidden = NO;}
    if (_view2.hidden) {_view2.hidden = NO;}
    if (_view3.hidden) {_view3.hidden = NO;}
    _view1.frame = _view1.nextFrame;
    _view2.frame = _view2.nextFrame;
    _view3.frame = _view3.nextFrame;
}

- (void)adjustFrameSize{
    [_view1 adjustFrameSize];
    [_view2 adjustFrameSize];
    [_view3 adjustFrameSize];
}

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
        if (CGRectContainsRect(self.bounds, self.view1.nextFrame)) {
            self.currentShowView = self.view1;
        }else if (CGRectContainsRect(self.bounds, self.view2.nextFrame)){
            self.currentShowView = self.view2;
        }else if (CGRectContainsRect(self.bounds, self.view3.nextFrame)){
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
        if (kMSimpleAnimateTypeShuffle == self.scrollType) {
            [self shuffleWithView1:self.tmpView1 view2:self.tmpView2 complete:^(BOOL finished) {
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
        }else{
            [UIView transitionFromView:self.tmpView1 toView:self.tmpView2 duration:duration options:ops completion:^(BOOL finished) {
                if (self.viewDidShowAtIndex) {
                    self.viewDidShowAtIndex(self.currentShowView.tmpView, _showIndex);
                }
                ZHSimpleScrollContentView *tmp     = self.tmpView1;
                self.tmpView1  = self.tmpView2;
                self.tmpView2  = tmp;
                [self.tmpView2 getNewContentView];
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
}

- (void)layoutSubviews{
    CGFloat width  = self.frame.size.width;//floor(self.frame.size.width);
    CGFloat height = self.frame.size.height;//floor(self.frame.size.height);
    CGFloat vwidth  = self.view1.frame.size.width;//floor(self.view1.frame.size.width);
    CGFloat vheight = self.view1.frame.size.height;//floor(self.view1.frame.size.height);
    if (vwidth != width || vheight != height) {
        CGSize itemSize = CGSizeMake(width, height);
        [self.view1 setFrame:(CGRect){0,0,itemSize}];
        [self.view1 nextFrameRecord];
        [self.view1 layoutIfNeeded];
        if (self.viewDidShowAtIndex) {
            self.viewDidShowAtIndex(self.currentShowView.tmpView, self.showIndex);
        }
        if (kMSimpleAnimateTypeR2L == self.scrollType) {
            [self.view2 setFrame:(CGRect){(CGPoint){width,0},itemSize}];
            [self.view2 nextFrameRecord];
            [self.view3 setFrame:(CGRect){(CGPoint){-width,0},itemSize}];
            [self.view3 nextFrameRecord];
        }else if (kMSimpleAnimateTypeL2R == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){-width,0},itemSize}];
            [self.view2 nextFrameRecord];
            [self.view3 setFrame:(CGRect){(CGPoint){width,0},itemSize}];
            [self.view3 nextFrameRecord];
        }else if (kMSimpleAnimateTypeB2T == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){0,height},itemSize}];
            [self.view2 nextFrameRecord];
            [self.view3 setFrame:(CGRect){(CGPoint){0,-height},itemSize}];
            [self.view3 nextFrameRecord];
        }else if (kMSimpleAnimateTypeT2B == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){0,-height},itemSize}];
            [self.view2 nextFrameRecord];
            [self.view3 setFrame:(CGRect){(CGPoint){0,height},itemSize}];
            [self.view3 nextFrameRecord];
        }else if (self.scrollType >= (1 << 20)){
            self.view2.frame = self.view1.frame;
        }
    }
    [super layoutSubviews];
}

#pragma --mark data source --
- (void)reloadDataWithItems:(void (^)(UIView *))enumBlock{
    if (enumBlock) {
        if (_view1.tmpView) {enumBlock(_view1.tmpView);}
        if (_view2.tmpView) {enumBlock(_view2.tmpView);}
        if (_view3.tmpView) {enumBlock(_view3.tmpView);}
    }
}
- (void)reloadDataAtIndex:(NSInteger)index forItem:(void (^)(UIView *))enumBlock{
    if (enumBlock) {
        if (_view1.bindIndex == index) {
            enumBlock(_view1.tmpView);
        }else if (_view2.bindIndex == index){
            enumBlock(_view2.tmpView);
        }else if (_view3.bindIndex == index){
            enumBlock(_view3.tmpView);
        }
    }
}

- (void)dealloc
{
    [_timer invaliadTimer];
    NSLog(@"%s",__func__);
}

@end

@interface UIView ()

@property (nonatomic, copy) void(^shuffleFinished)(BOOL finished);

@end

@implementation UIView (ZHShuffleAnimate)

- (void)setShuffleFinished:(void (^)(BOOL))shuffleFinished{
    objc_setAssociatedObject(self, _cmd, shuffleFinished, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(BOOL))shuffleFinished{
    return objc_getAssociatedObject(self, @selector(setShuffleFinished:));
}

- (void)shuffleWithView1:(UIView *)view1 view2:(UIView *)view2 complete:(void(^)(BOOL finished))completeHandler{
    if (view1.superview != view2.superview) {return;}
    if ([view1.layer.animationKeys containsObject:@"zhb_shuffle"] && [view2.layer.animationKeys containsObject:@"zhb_shuffle"]) {
        [view1.layer removeAnimationForKey:@"zhb_shuffle"];
        [view2.layer removeAnimationForKey:@"zhb_shuffle"];
    }
    self.shuffleFinished = completeHandler;
    [view1.superview bringSubviewToFront:view2];
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0f/500;
    transform = CATransform3DTranslate(transform, CGRectGetWidth(view1.frame)*2, 0, 0);
    transform = CATransform3DTranslate(transform, 0, 0, CGRectGetWidth(view1.frame));
    transform = CATransform3DRotate(transform, M_PI_4*0.6, 0, 0, 1);
    transform = CATransform3DRotate(transform, M_PI_2*0.8, 0, 1, 0);
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],[NSValue valueWithCATransform3D:transform],[NSValue valueWithCATransform3D:CATransform3DIdentity]] ;
    animate.duration = 1.0;
    animate.delegate = self;
    [view1.layer addAnimation:animate forKey:@"zhb_shuffle"];
    
    CAKeyframeAnimation *animate2 = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform2 = CATransform3DIdentity;
    transform2 = CATransform3DTranslate(transform2, 0, 0, CGRectGetWidth(view1.frame)*2);
    animate2.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],[NSValue valueWithCATransform3D:CATransform3DIdentity],[NSValue valueWithCATransform3D:transform2]];
    animate2.duration = 1.0;
    [view2.layer addAnimation:animate2 forKey:@"zhb_shuffle"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.shuffleFinished) {
        self.shuffleFinished(flag);
    }
}

@end
