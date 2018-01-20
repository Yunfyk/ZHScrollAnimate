//
//  ZHSimpleScrollContentView.m
//  ZHScrollAnimate
//
//  Created by 朱三保 on 2018/1/16.
//  Copyright © 2018年 zhusanbao. All rights reserved.
//

#import "ZHSimpleScrollContentView.h"

@implementation ZHSimpleScrollContentView

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType{
    if (self = [super init]) {
        self.scrollType = scrollType;
    }
    return self;
}

- (void)setRealTimeRelativeFrame:(CGRect)realTimeRelativeFrame{
    _realTimeRelativeFrame = realTimeRelativeFrame;
    if (_realTimeRelativeFrame.origin.x < -self.frame.size.width * 1.5) {
        self.center = CGPointMake(self.center.x + self.frame.size.width*3, self.center.y);
        [self scrollToNewWithPlusValue:1];
    }else if (_realTimeRelativeFrame.origin.x > self.frame.size.width * 1.5){
        self.center = CGPointMake(self.center.x - self.frame.size.width*3, self.center.y);
        [self scrollToNewWithPlusValue:-1];
    }else if (_realTimeRelativeFrame.origin.y < -self.frame.size.height * 1.5){
        self.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height*3);
        [self scrollToNewWithPlusValue:1];
    }else if (_realTimeRelativeFrame.origin.y > self.frame.size.height * 1.5){
        self.center = CGPointMake(self.center.x, self.center.y - self.frame.size.height*3);
        [self scrollToNewWithPlusValue:-1];
    }
}

- (void)scrollToNewWithPlusValue:(NSInteger)plusValue{
//    if (*_showIndex <= 0) {return;}
    if (*_showIndex + plusValue < 0 || *_showIndex + plusValue > self.numberOfRows - 1) {
        [self.tmpView removeFromSuperview];return;
    }
    if (self.hidden) {self.hidden = NO;}
    *_index = *_showIndex + plusValue;
    if (self.viewForIndex) {
        UIView *aView = self.viewForIndex(*_index);
        if (aView) {
            [self contentAddSubView:aView];
        }
    }
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
        CGFloat multipValue = self.scrollType == kMSimpleAnimateTypeR2L ? 1.0 : -1.0;
        if (self.frame.origin.x == -2 * multipValue * self.frame.size.width) {
            self.nextFrame = (CGRect){(CGPoint){multipValue * self.frame.size.width,0},self.frame.size};
        }else if (self.frame.origin.x == -multipValue * self.frame.size.width){
            self.nextFrame = (CGRect){(CGPoint){-2 * multipValue * self.frame.size.width,0},self.frame.size};
        }else if (self.frame.origin.x == 0){
            self.nextFrame = (CGRect){(CGPoint){-multipValue * self.frame.size.width,0},self.frame.size};
        }else if (self.frame.origin.x == multipValue * self.frame.size.width){
            self.nextFrame = (CGRect){(CGPoint){0,0},self.frame.size};
        }else if (self.frame.origin.x == 2 * multipValue * self.frame.size.width){
            self.nextFrame = (CGRect){(CGPoint){-multipValue * self.frame.size.width,0},self.frame.size};
        }
    }else if (self.scrollType == kMSimpleAnimateTypeB2T || self.scrollType == kMSimpleAnimateTypeT2B){
        CGFloat multipValue = self.scrollType == kMSimpleAnimateTypeB2T ? 1.0 : -1.0;
        if (self.frame.origin.y == -2 * multipValue * self.frame.size.height) {
            self.nextFrame = (CGRect){(CGPoint){0,multipValue * self.frame.size.height},self.frame.size};
        }else if (self.frame.origin.y == -multipValue * self.frame.size.height){
            self.nextFrame = (CGRect){(CGPoint){0,-2 * multipValue * self.frame.size.height},self.frame.size};
        }else if (self.frame.origin.y == 0){
            self.nextFrame = (CGRect){(CGPoint){0,-multipValue * self.frame.size.height},self.frame.size};
        }else if (self.frame.origin.y == multipValue * self.frame.size.height){
            self.nextFrame = (CGRect){(CGPoint){0,0},self.frame.size};
        }else if (self.frame.origin.y == 2 * multipValue * self.frame.size.height){
            self.nextFrame = (CGRect){(CGPoint){0,-multipValue * self.frame.size.height},self.frame.size};
        }
    }
}

- (void)finishAnimation{
    [self nextFrameRecord];
    if (self.scrollType == kMSimpleAnimateTypeR2L) {
        if (self.frame.origin.x == -2 * self.frame.size.width) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }else if (kMSimpleAnimateTypeL2R == self.scrollType){
        if (self.frame.origin.x == 2 * self.frame.size.width) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }else if (self.scrollType == kMSimpleAnimateTypeB2T){
        if (self.frame.origin.y == -2 * self.frame.size.height) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }else if (self.scrollType == kMSimpleAnimateTypeT2B){
        if (self.frame.origin.y == 2 * self.frame.size.height) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }
}

- (void)getNewContentView{
    if (self.viewForIndex) {
        if (self.scrollType < (1 << 20)) {
            if (CGRectEqualToRect(self.frame, self.superview.bounds)) {
                *_showIndex = *_index;
            }else{
                *_showIndex = MAX(0, *_index - 1);
            }
        }else{
            *_showIndex      = *_index < 1 ? 0 : *_index - 1;
        }
        UIView *aView = self.viewForIndex(*_index);
        if (aView) {
            [self contentAddSubView:aView];
            *_index = *_index + 1;
        }
    }
}

@end
