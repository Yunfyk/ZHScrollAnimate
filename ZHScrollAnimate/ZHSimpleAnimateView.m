//
//  ZHSimpleAnimateView.m
//  ZHBCollectionView
//
//  Created by 朱三保 on 2017/12/29.
//  Copyright © 2017年 zhusanbao. All rights reserved.
//

#import "ZHSimpleAnimateView.h"
#import "ZHWeakTimer.h"

@interface ZHSimpleScrollContentView : UIView
{
@public
    NSInteger      *_index;
}
@property (nonatomic, assign) kMSimpleAnimateType           scrollType;
@property (nonatomic, weak)   UIView                        *tmpView;
@property (nonatomic, assign) CGRect                        nextFrame;

@property (nonatomic, copy)   viewForIndexBlock             viewForIndex;

@end

@implementation ZHSimpleScrollContentView

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType{
    if (self = [super init]) {
        self.scrollType = scrollType;
    }
    return self;
}

- (void)contentAddSubView:(UIView *)aView{
    if (aView) {
        [self contentRemoveView];
        self.tmpView = aView;
        aView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:aView];
        NSString *hvfl = @"H:|-0-[aView]-0-|";
        NSString *vvfl = @"V:|-0-[aView]-0-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(aView);
        NSArray *Hconstrains = [NSLayoutConstraint constraintsWithVisualFormat:hvfl options:0 metrics:nil views:views];
        NSArray *Vconstrains = [NSLayoutConstraint constraintsWithVisualFormat:vvfl options:0 metrics:nil views:views];
        [self addConstraints:Hconstrains];
        [self addConstraints:Vconstrains];
    }
}
- (void)contentRemoveView{
    if (self.tmpView) {
        [self.tmpView removeFromSuperview];
    }
}

- (void)nextFrameRecord{
    if (self.scrollType == kMSimpleAnimateTypeR2L || self.scrollType == kMSimpleAnimateTypeL2R) {
        CGFloat mutipValue = self.scrollType == kMSimpleAnimateTypeR2L ? 1.0 : -1.0;
        if (self.frame.origin.x == -mutipValue * self.frame.size.width) {
            self.nextFrame = (CGRect){(CGPoint){mutipValue * self.frame.size.width,0},self.frame.size};
        }else if (self.frame.origin.x == 0){
            self.nextFrame = (CGRect){(CGPoint){-mutipValue * self.frame.size.width,0},self.frame.size};
        }else if (self.frame.origin.x == mutipValue * self.frame.size.width){
            self.nextFrame = (CGRect){(CGPoint){0,0},self.frame.size};
        }
    }else if (self.scrollType == kMSimpleAnimateTypeB2T || self.scrollType == kMSimpleAnimateTypeT2B){
        CGFloat mutipValue = self.scrollType == kMSimpleAnimateTypeB2T ? 1.0 : -1.0;
        if (self.frame.origin.y == -mutipValue * self.frame.size.height) {
            self.nextFrame = (CGRect){(CGPoint){0,mutipValue * self.frame.size.height},self.frame.size};
        }else if (self.frame.origin.y == 0){
            self.nextFrame = (CGRect){(CGPoint){0,-mutipValue * self.frame.size.height},self.frame.size};
        }else if (self.frame.origin.y == mutipValue * self.frame.size.height){
            self.nextFrame = (CGRect){(CGPoint){0,0},self.frame.size};
        }
    }
}

- (void)finishAnimation{
    [self nextFrameRecord];
    if (self.scrollType == kMSimpleAnimateTypeR2L || self.scrollType == kMSimpleAnimateTypeL2R) {
        CGFloat mutipValue = self.scrollType == kMSimpleAnimateTypeR2L ? 1.0 : -1.0;
        if (self.frame.origin.x == -mutipValue * self.frame.size.width) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }else if (self.scrollType == kMSimpleAnimateTypeB2T || self.scrollType == kMSimpleAnimateTypeT2B){
        CGFloat mutipValue = self.scrollType == kMSimpleAnimateTypeB2T ? 1.0 : -1.0;
        if (self.frame.origin.y == -mutipValue * self.frame.size.height) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }
}

- (void)getNewContentView{
    if (self.viewForIndex) {
        UIView *aView = self.viewForIndex(*_index);
        if (aView) {
            [self contentAddSubView:aView];
            *_index = *_index + 1;
        }
    }
}

@end

@interface ZHSimpleAnimateView()

@property (nonatomic, assign) kMSimpleAnimateType           scrollType;
@property (nonatomic, strong) ZHSimpleScrollContentView     *view1;
@property (nonatomic, strong) ZHSimpleScrollContentView     *view2;
@property (nonatomic, assign) BOOL                          isAminating;

@property (weak, nonatomic)   ZHSimpleScrollContentView     *tmpView1;
@property (weak, nonatomic)   ZHSimpleScrollContentView     *tmpView2;

@property (strong, nonatomic) ZHWeakTimer                   *timer;

@end

@implementation ZHSimpleAnimateView{
    NSInteger _index;
}
@synthesize contentView=_contentView,backgroudImageView=_backgroudImageView;

- (ZHSimpleScrollContentView *)view1{
    if (!_view1) {
        _view1 = [[ZHSimpleScrollContentView alloc] initWithScrollType:self.scrollType];
        _view1->_index = &_index;
        __weak typeof(self)weak_self = self;
        _view1.viewForIndex = ^UIView *(NSInteger index){
            return weak_self.viewForIndex ? weak_self.viewForIndex(index):nil;
        };
    }
    return _view1;
}
- (ZHSimpleScrollContentView *)view2{
    if (!_view2) {
        _view2 = [[ZHSimpleScrollContentView alloc] initWithScrollType:self.scrollType];
        _view2->_index = &_index;
        if (self.scrollType >= (1 << 20)) {
            _view2.hidden = YES;
        }
        __weak typeof(self)weak_self = self;
        _view2.viewForIndex = ^UIView *(NSInteger index){
            return weak_self.viewForIndex ? weak_self.viewForIndex(index):nil;
        };
    }
    return _view2;
}
- (UIView *)contentView{
    if (!_contentView) {
        _contentView                = [[UIView alloc] init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:_contentView atIndex:0];
        NSArray *HC = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)];
        NSArray *VC = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)];
        [self addConstraints:HC];
        [self addConstraints:VC];
    }
    return _contentView;
}
- (UIImageView *)backgroudImageView{
    if (!_backgroudImageView) {
        _backgroudImageView                = [[UIImageView alloc] init];
        _backgroudImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:_backgroudImageView aboveSubview:self.contentView];
        NSArray *HC = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_backgroudImageView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self,_backgroudImageView)];
        NSArray *VC = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_backgroudImageView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self,_backgroudImageView)];
        [self addConstraints:HC];
        [self addConstraints:VC];
    }
    return _backgroudImageView;
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
        [self initDataWithType:scrollType];
    }
    return self;
}
- (void)initDataWithType:(kMSimpleAnimateType)scrollType{
    _index = -1;
    self.clipsToBounds          = YES;
    self.autoAnimate            = NO;
    self.timeInterval           = 3.0f;
    self.scrollType             = scrollType;
    [self addSubview:self.view2];
    [self addSubview:self.view1];
    self.tmpView1 = self.view1;
    self.tmpView2 = self.view2;
}

- (void)didMoveToWindow{
    if (_index == -1) {
        _index = 0;
        [self.view1 getNewContentView];
        [self.view2 getNewContentView];
        if (self.autoAnimate) {
            [self.timer fireTimer];
        }
    }
    [super didMoveToWindow];
}

- (void)next{
    [self nextWithAnimate:YES];
}
- (void)autoAnimateDispatch{
    [self nextWithAnimate:YES isauto:YES];
}
- (void)nextWithAnimate:(BOOL)animate{
    [self nextWithAnimate:animate isauto:NO];
}
- (void)nextWithAnimate:(BOOL)animate isauto:(BOOL)isAuto{
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
    if (kMSimpleAnimateTypeB2T == self.scrollType || kMSimpleAnimateTypeR2L == self.scrollType || kMSimpleAnimateTypeT2B == self.scrollType || kMSimpleAnimateTypeL2R == self.scrollType) {
        self.isAminating = YES;
        if (animate) {
            [UIView animateWithDuration:0.6 animations:^{
                [self.view1 setFrame:self.view1.nextFrame];
                [self.view2 setFrame:self.view2.nextFrame];
            } completion:^(BOOL finished) {
                [self.view1 finishAnimation];
                [self.view2 finishAnimation];
                self.isAminating = NO;
                if (self.autoAnimate && !isAuto) {
                    [self.timer fireTimer];
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
        }
    }else if (self.scrollType >= (1 << 20)){
        self.isAminating = YES;
        NSTimeInterval duration     = animate ? 0.5 : 0;
        UIViewAnimationOptions ops  = animate ? (self.scrollType|UIViewAnimationOptionShowHideTransitionViews):UIViewAnimationOptionShowHideTransitionViews;
        [UIView transitionFromView:self.tmpView1 toView:self.tmpView2 duration:duration options:ops completion:^(BOOL finished) {
            [self.tmpView1 getNewContentView];
            ZHSimpleScrollContentView *tmp     = self.tmpView1;
            self.tmpView1  = self.tmpView2;
            self.tmpView2  = tmp;
            self.isAminating= NO;
            if (self.autoAnimate && !isAuto) {
                [self.timer fireTimer];
            }
        }];
    }
}

- (void)layoutSubviews{
    if (self.view1.frame.size.width != self.frame.size.width || self.view1.frame.size.height != self.frame.size.height) {
        [self.view1 setFrame:self.bounds];
        [self.view1 nextFrameRecord];
        if (kMSimpleAnimateTypeR2L == self.scrollType) {
            [self.view2 setFrame:(CGRect){(CGPoint){self.frame.size.width,0},self.frame.size}];
            [self.view2 nextFrameRecord];
        }else if (kMSimpleAnimateTypeL2R == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){-self.frame.size.width,0},self.frame.size}];
            [self.view2 nextFrameRecord];
        }else if (kMSimpleAnimateTypeB2T == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){0,self.frame.size.height},self.frame.size}];
            [self.view2 nextFrameRecord];
        }else if (kMSimpleAnimateTypeT2B == self.scrollType){
            [self.view2 setFrame:(CGRect){(CGPoint){0,-self.frame.size.height},self.frame.size}];
            [self.view2 nextFrameRecord];
        }else if (self.scrollType >= (1 << 20)){
            self.view2.frame = self.view1.frame;
        }
    }
    [super layoutSubviews];
}

- (void)dealloc
{
    [self.timer invaliadTimer];
    NSLog(@"%s",__func__);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
