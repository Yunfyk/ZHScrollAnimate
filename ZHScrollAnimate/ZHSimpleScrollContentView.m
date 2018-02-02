//
//  ZHSimpleScrollContentView.m
//  ZHScrollAnimate
//
//  Created by 朱三保 on 2018/1/16.
//  Copyright © 2018年 zhusanbao. All rights reserved.
//

#import "ZHSimpleScrollContentView.h"

@interface ZHSimpleScrollContentView ()

@property (assign, nonatomic) NSInteger bindIndex;

@property (nonatomic, assign) CGFloat   z_x;
@property (nonatomic, assign) CGFloat   z_y;
@property (nonatomic, assign) CGFloat   z_width;
@property (nonatomic, assign) CGFloat   z_height;
//目标位置位置
@property (nonatomic, assign) CGRect    targetFrame;

@end

@implementation ZHSimpleScrollContentView

- (instancetype)initWithScrollType:(kMSimpleAnimateType)scrollType{
    if (self = [super init]) {
        self.scrollType = scrollType;
    }
    return self;
}

- (BOOL)isHorizontalDirect{
    return (kMSimpleAnimateTypeL2R == self.scrollType || kMSimpleAnimateTypeR2L == self.scrollType);
}
- (BOOL)isVerticalDirect{
    return (kMSimpleAnimateTypeT2B == self.scrollType || kMSimpleAnimateTypeB2T == self.scrollType);
}
- (CGFloat)z_x{     return      self.frame.origin.x;}
- (CGFloat)z_y{     return      self.frame.origin.y;}
- (CGFloat)z_width{ return      self.frame.size.width;}
- (CGFloat)z_height{return      self.frame.size.height;};

- (void)setZ_x:(CGFloat)z_x{CGRect frame = self.frame;frame.origin.x = z_x;self.frame = frame;}
- (void)setZ_y:(CGFloat)z_y{CGRect frame = self.frame;frame.origin.y = z_y;self.frame = frame;}
- (void)setZ_width:(CGFloat)z_width{CGRect frame = self.frame;frame.size.width = z_width;self.frame = frame;}
- (void)setZ_height:(CGFloat)z_height{CGRect frame = self.frame;frame.size.height = z_height;self.frame = frame;}

//- (BOOL)isInLeftOrTopSide{      return (self.z_x < 0 || self.z_y < 0);}
//- (BOOL)isInMiddleSide{         return (self.z_x == 0 && self.z_y == 0);}
//- (BOOL)isInRightOrBottomSide{  return (self.z_x > 0 || self.z_y > 0);}
//- (BOOL)isLeftReativeForView:(ZHSimpleScrollContentView *)view{
//    if (view.z_x < self.z_x) {return YES;}else{return NO;}
//}
//- (BOOL)isRightReativeForView:(ZHSimpleScrollContentView *)view{
//    if (view.z_x > self.z_x) {return YES;}else{return NO;}
//}
- (BOOL)isInLeftSide{
    CGPoint centerl = (CGPoint){-self.z_width*0.5,self.z_height*0.5};return CGRectContainsPoint(self.frame, centerl);
}
- (BOOL)isInTopSide{
    CGPoint centert = (CGPoint){self.z_width*0.5,-self.z_height*0.5};return CGRectContainsPoint(self.frame, centert);
}
- (BOOL)isInLeftOrTopSide{return [self isInLeftSide] || [self isInTopSide];}

- (BOOL)isInMiddleSide{
    CGPoint center = (CGPoint){self.z_width*0.5,self.z_height*0.5};return CGRectContainsPoint(self.frame, center);
}
- (BOOL)isInRightSide{
    CGPoint centerr = (CGPoint){self.z_width*1.5,self.z_height*0.5};
    return CGRectContainsPoint(self.frame, centerr);
}
- (BOOL)isInBottomSide{
    CGPoint centerb = (CGPoint){self.z_width*0.5,self.z_height*1.5};
    return CGRectContainsPoint(self.frame, centerb);
}
- (BOOL)isInRightOrBottomSide{return [self isInRightSide] || [self isInBottomSide];}

//- (void)resetLeftBindViewFrame{
//    if ([self isLeftReativeForView:self.bindViewA]) {
//        self.bindViewA.z_x = CGRectGetMaxX(self.bindViewB.frame);
//    }else if ([self isLeftReativeForView:self.bindViewB]){
//        self.bindViewB.z_x = CGRectGetMaxX(self.bindViewA.frame);
//    }
//}
//- (void)resetRightBindViewFrame{
//    if ([self isRightReativeForView:self.bindViewA]) {
//        self.bindViewA.z_x = self.bindViewB.z_x - self.bindViewA.z_width;
//    }else if ([self isRightReativeForView:self.bindViewB]){
//        self.bindViewB.z_x = self.bindViewA.z_x - self.bindViewB.z_width;
//    }
//}

- (void)setOffset:(CGFloat)offset{
    CGRect frame = self.frame;
    if (self.z_width == 0 || self.z_height == 0) {return;}
    if ([self isHorizontalDirect]) {
        self.scrollIndex = MAX(0, ((offset + 0.5*self.z_width)/self.z_width));
        CGFloat ww = 3*self.z_width;
        int factor = floor(offset/ww);
        CGFloat rel = offset - (factor * ww);
        CGFloat w = self.z_width;
//        NSInteger off = round(offset);
//        NSInteger rel = off%(3 * w);
        if (self.tag == 2) {
            rel -= self.z_width;
        }else if (self.tag == 3){
            rel += self.z_width;
        }
        CGFloat ox = self.z_x;
        if (rel < 1.5 * w) {
            self.z_x = -rel;
            if (ox > w && self.z_x < w * 0.5) {
                self.scrollIndex -= 1;
                [self setupNewViewWithIndex:self.scrollIndex];
            }
        }else{
            self.z_x = 3 * w - rel;
            if (ox < w*0.5 && self.z_x > w * 0.5) {
                self.scrollIndex += 1;
                [self setupNewViewWithIndex:self.scrollIndex];
            }
        }

        
        NSLog(@"%@    %ld",NSStringFromCGRect([self convertRect:self.frame toView:self.superview.superview]),self.scrollIndex);
//        NSLog(@"%@",self);
//        frame.origin.x  += offset;
//        if (frame.origin.x < -self.z_width * 1.5) {
//            frame.origin.x += self.z_width * 3;
//            self.hidden = YES;
////            [self scrollToNewWithPlusValue:1];
//        }else if (frame.origin.x > self.z_width * 1.5){
//            frame.origin.x -= self.z_width * 3;
//            self.hidden = YES;
////            [self scrollToNewWithPlusValue:-1];
//        }else{if (self.hidden) {
//            self.hidden = NO;
//        }}
    }else if ([self isVerticalDirect]){
        frame.origin.y  += offset;
        if (frame.origin.y < -self.z_height * 1.5) {
            frame.origin.y += self.z_height * 3;
            self.hidden = YES;
//            [self scrollToNewWithPlusValue:1];
        }else if (frame.origin.y > self.z_height * 1.5){
            frame.origin.y -= self.z_height * 3;
            self.hidden = YES;
//            [self scrollToNewWithPlusValue:-1];
        }else{if (self.hidden) {self.hidden = NO;}}
    }
//    self.frame = frame;
}
- (void)updateContentView{
    if ([self isInLeftOrTopSide]) {
        if (self.bindIndex != *_showIndex - 1) {
            [self setupNewViewWithIndex:*_showIndex - 1];
        }
    }else if ([self isInRightOrBottomSide]){
        if (self.bindIndex != *_showIndex + 1) {
            [self setupNewViewWithIndex:*_showIndex + 1];
        }
    }else{
        if ([self isInMiddleSide]) {
            if (*_showIndex != self.bindIndex) {
                [self setupNewViewWithIndex:*_showIndex];
            }
        }
    }
}
- (void)adjustFrameSize{
    if ([self isInLeftSide]) {
        self.z_x = -self.z_width;
    }else if ([self isInTopSide]){
        self.z_y = -self.z_height;
    }else if ([self isInMiddleSide]){
        self.z_x = self.z_y = 0;
    }else if ([self isInRightSide]){
        self.z_x = self.z_width;
    }else if ([self isInBottomSide]){
        self.z_y = self.z_height;
    }
    if (self.hidden) {self.hidden = NO;}
}

- (void)scrollToNewWithPlusValue:(NSInteger)plusValue{
    if (*_showIndex >= self.numberOfRows || *_showIndex < 0) {return;}
    if (self.superview) {[self.superview sendSubviewToBack:self];}
    if (*_showIndex + plusValue < 0 || *_showIndex + plusValue > self.numberOfRows - 1) {
        [self.tmpView removeFromSuperview];self.bindIndex = -10;return;
    }
    *_index = *_showIndex + plusValue;
    [self setupNewViewWithIndex:*_index];
}

- (void)setupNewViewWithIndex:(NSInteger)index{
    if (index < 0 || index > self.numberOfRows - 1) {
        [self.tmpView removeFromSuperview];self.bindIndex = -10;
        return;
    }
    if (self.bindIndex == index) {return;}
    if (self.viewForIndex) {
        UIView *aView = self.viewForIndex(index);
        if (aView) {
            [self contentAddSubView:aView];
            self.bindIndex = index;
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
    if ([self isHorizontalDirect]) {
        CGFloat multipValue = self.scrollType == kMSimpleAnimateTypeR2L ? 1.0 : -1.0;
        if (self.z_x == -2 * multipValue * self.z_width) {
            self.nextFrame = (CGRect){(CGPoint){multipValue * self.z_width,0},self.frame.size};
        }else if (self.z_x == -multipValue * self.z_width){
            self.nextFrame = (CGRect){(CGPoint){-2 * multipValue * self.z_width,0},self.frame.size};
        }else if (self.z_x == 0){
            self.nextFrame = (CGRect){(CGPoint){-multipValue * self.z_width,0},self.frame.size};
        }else if (self.z_x == multipValue * self.z_width){
            self.nextFrame = (CGRect){(CGPoint){0,0},self.frame.size};
        }else if (self.z_x == 2 * multipValue * self.z_width){
            self.nextFrame = (CGRect){(CGPoint){-multipValue * self.z_width,0},self.frame.size};
        }
    }else if ([self isVerticalDirect]){
        CGFloat multipValue = self.scrollType == kMSimpleAnimateTypeB2T ? 1.0 : -1.0;
        if (self.z_y == -2 * multipValue * self.z_height) {
            self.nextFrame = (CGRect){(CGPoint){0,multipValue * self.z_height},self.frame.size};
        }else if (self.z_y == -multipValue * self.z_height){
            self.nextFrame = (CGRect){(CGPoint){0,-2 * multipValue * self.z_height},self.frame.size};
        }else if (self.z_y == 0){
            self.nextFrame = (CGRect){(CGPoint){0,-multipValue * self.z_height},self.frame.size};
        }else if (self.z_y == multipValue * self.z_height){
            self.nextFrame = (CGRect){(CGPoint){0,0},self.frame.size};
        }else if (self.z_y == 2 * multipValue * self.z_height){
            self.nextFrame = (CGRect){(CGPoint){0,-multipValue * self.z_height},self.frame.size};
        }
    }
}

- (void)finishAnimation{
    [self nextFrameRecord];
    if (self.scrollType == kMSimpleAnimateTypeR2L) {
        if (self.z_x == -2 * self.z_width) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }else if (kMSimpleAnimateTypeL2R == self.scrollType){
        if (self.z_x == 2 * self.z_width) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }else if (self.scrollType == kMSimpleAnimateTypeB2T){
        if (self.z_y == -2 * self.z_height) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }else if (self.scrollType == kMSimpleAnimateTypeT2B){
        if (self.z_y == 2 * self.z_height) {
            [self setFrame:self.nextFrame];
            [self getNewContentView];
            [self nextFrameRecord];
        }
    }
}

- (void)getNewContentView{
    if (self.viewForIndex) {
        if (self.scrollType < (1 << 20)) {
            if (CGRectContainsRect(self.superview.bounds, self.frame)) {
                *_showIndex = *_index;
            }else{
                if (*_index == 0 && *_showIndex > 0) {
                    *_showIndex = self.numberOfRows - 1;
                }else{
                    *_showIndex = MAX(0, *_index - 1);
                }
            }
        }else{
            if (*_index == 0 && *_showIndex > 0) {
                *_showIndex = self.numberOfRows - 1;
            }else{
                *_showIndex      = *_index < 1 ? 0 : *_index - 1;
            }
        }
        UIView *aView = self.viewForIndex(*_index);
        if (aView) {
            [self contentAddSubView:aView];
            self.bindIndex = *_index;
            if (self.numberOfRows > 0 && *_index >= self.numberOfRows - 1) {
                *_index = 0;
            }else{
                *_index = *_index + 1;
            }
        }
    }
}

@end
