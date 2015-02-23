//
//  CRVScalableFrame.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//
//  Resizing mechanism made by Stephen Poletto ( http://stephenpoletto.com ). Improved by Patryk Kaczmarek.

#import "CRVScalableView.h"
#import "CRVAnchorPoint.h"
#import "CRVScalableView+Math.h"

@interface CRVScalableView ()

@property (strong, nonatomic) CRVAnchorPoint *anchorPoint;
@property (assign, nonatomic) CGPoint touchStart;
@property (strong, nonatomic) NSArray *anchorPoints;

@end

@implementation CRVScalableView

#pragma mark - Object lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    _borderView = [[CRVScalableBorder alloc] initWithFrame:frame];
    [self addSubview:_borderView];
    
    self.anchorPoints = [self anchorPointsMakeArray];
    self.ratioEnabled = NO;
    self.minSize = CGSizeMake(50.f, 50.f);
    self.maxSize = CGSizeMake(300.f, 300.f);
    self.animationDuration = 1.0f;
    self.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    self.springDamping = 0.9f;
    self.springVelocity = 13.f;
    self.active = YES;
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.borderView.frame = self.bounds;
    [self.borderView setNeedsDisplay];
}

#pragma mark - Public Methods

- (void)animateToFrame:(CGRect)frame completion:(void (^)(BOOL finished))completion {
    
    CGRect rect = CGRectMake(CGRectGetMinX(frame),
                             CGRectGetMinY(frame),
                             [self widthFromValue:CGRectGetWidth(frame)],
                             [self heightFromValue:CGRectGetHeight(frame)]);
    
    [self animateSelfToFrame:rect completion:completion];
}

- (void)animateToSize:(CGSize)size completion:(void (^)(BOOL finished))completion {
    
    CGSize aSize = CGSizeMake([self widthFromValue:size.width], [self heightFromValue:size.height]);
    CGPoint scale = CGPointMake(aSize.width/self.bounds.size.width, aSize.height/self.bounds.size.height);
    
    CGRect rect = CGRectMake(self.center.x - (self.bounds.size.width * scale.x) * 0.5f,
                             self.center.y - (self.bounds.size.height * scale.y) * 0.5f,
                             self.bounds.size.width * scale.x,
                             self.bounds.size.height * scale.y);
    
    [self animateSelfToFrame:rect completion:completion];
}

- (CGFloat)currentRatio {
    return CGRectGetWidth(self.bounds)/CGRectGetHeight(self.bounds);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];

    BOOL responds = [self.hitTestDelegate respondsToSelector:@selector(viewForHitTestInScalableView:)];
    if (self.isActive || !responds) {
        return view;
    }

    UIView *underneathView = [self.hitTestDelegate viewForHitTestInScalableView:self];
    CGPoint underneathViewPoint = [underneathView convertPoint:point fromView:self];
    return [underneathView pointInside:underneathViewPoint withEvent:event] ? underneathView : view;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.borderView.resizing = YES;
    UITouch *touch = [touches anyObject];
    self.anchorPoint = [self anchorPointForTouchLocation:[touch locationInView:self]];
    
    if ([self.anchorPoint isStretched]) {
        if ([self.delegate respondsToSelector:@selector(scalableViewDidBeginScaling:)]) {
            [self.delegate scalableViewDidBeginScaling:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(scalableViewDidBeginMoving:)]) {
            [self.delegate scalableViewDidBeginMoving:self];
            [self.borderView setNeedsDisplay];
        }
    }
    
    // When resizing, all calculations are done in the superview's coordinate space.
    // When translating, all calculations are done in the view's coordinate space.
    self.touchStart = [touch locationInView:[self.anchorPoint isStretched] ? self.superview : self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performDidEndDelegate];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performDidEndDelegate];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self.anchorPoint isStretched]) {
        [self resizeUsingTouchLocation:[[touches anyObject] locationInView:self.superview]];
        
        if ([self.delegate respondsToSelector:@selector(scalableViewDidScale:)]) {
            [self.delegate scalableViewDidScale:self];
        }
    } else {
        self.center = [self centerWithTouchLocation:[[touches anyObject] locationInView:self] touchStart:self.touchStart];
        
        if ([self.delegate respondsToSelector:@selector(scalableViewDidMove:)]) {
            [self.delegate scalableViewDidMove:self];
        }
    }
}

#pragma mark - Private Methods

- (void)performDidEndDelegate {
    self.borderView.resizing = NO;
    
    if ([self.anchorPoint isStretched]) {
        if ([self.delegate respondsToSelector:@selector(scalableViewDidEndScaling:)]) {
            [self.delegate scalableViewDidEndScaling:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(scalableViewDidEndMoving:)]) {
            [self.delegate scalableViewDidEndMoving:self];
        }
    }
}

- (CRVAnchorPoint *)anchorPointForTouchLocation:(CGPoint)touchPoint {
    
    __block CRVAnchorPoint *closestAnchorPoint;
    [self.anchorPoints enumerateObjectsUsingBlock:^(CRVAnchorPoint *anchorPoint, NSUInteger idx, BOOL *stop) {
        [anchorPoint setReferencePointWithSize:self.bounds.size];
        if (anchorPoint.location == CRVAnchorPointLocationCenter) closestAnchorPoint = anchorPoint;
    }];
    
    __block CGFloat minDistance = MAXFLOAT;
    [self.anchorPoints enumerateObjectsUsingBlock:^(CRVAnchorPoint *anchorPoint, NSUInteger idx, BOOL *stop) {
        CGFloat distance = [anchorPoint distanceFromReferencePointToPoint:touchPoint];
        if (distance < minDistance) {
            closestAnchorPoint = anchorPoint;
            minDistance = distance;
        }
    }];
    return closestAnchorPoint;
}

- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    
    touchPoint = [self pointByUpdateTouchPointIfOutsideOfSuperview:touchPoint];
    
    // Calculate the deltas using the current anchor point.
    CGFloat deltaW = self.anchorPoint.adjustsW * (self.touchStart.x - touchPoint.x);
    CGFloat deltaH = self.anchorPoint.adjustsH * (CGFloat)(touchPoint.y - self.touchStart.y);
    CGFloat deltaX = self.anchorPoint.adjustsX * (CGFloat)(-1.0 * deltaW);
    CGFloat deltaY = self.anchorPoint.adjustsY * (CGFloat)(-1.0 * deltaH);
    
    // Calculate the new frame.
    CGFloat newX = self.frame.origin.x + deltaX;
    CGFloat newY = self.frame.origin.y + deltaY;
    CGFloat newWidth = self.frame.size.width + deltaW;
    CGFloat newHeight = self.frame.size.height + deltaH;
    
    CGFloat ratio = CGRectGetWidth(self.bounds)/CGRectGetHeight(self.bounds);

    if (self.isRatioEnabled) {
        
        if (self.anchorPoint.ratioX1 != 0.f || self.anchorPoint.ratioX2 != 0.f) {
            newX += (deltaW * self.anchorPoint.ratioX1) + (deltaH * ratio * self.anchorPoint.ratioX2) - deltaX;
        }
        if (self.anchorPoint.ratioY1 != 0.f || self.anchorPoint.ratioY2 != 0.f) {
            newY += (deltaW/ratio * self.anchorPoint.ratioY1) + (deltaH * self.anchorPoint.ratioY2) - deltaY;
        }
        if (self.anchorPoint.ratioW != 0.f) {
            newWidth += (deltaH * ratio * self.anchorPoint.ratioW) - deltaW;
        }
        if (self.anchorPoint.ratioH != 0.f) {
            newHeight += (deltaW/ratio * self.anchorPoint.ratioH) - deltaH;
        }
    }
    
    [self validateFrameSizeWithX:&newX y:&newY width:&newWidth height:&newHeight];
    [self validateFramePositionWithX:&newX y:&newY width:&newWidth height:&newHeight deltaW:&deltaW deltaH:&deltaH];

    self.frame = CGRectMake(newX, newY, newWidth, newHeight);
    self.touchStart = touchPoint;
}

- (NSArray *)anchorPointsMakeArray {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < CRVAnchorPointLocationPointsCount; i ++) {
        [array addObject:[[CRVAnchorPoint alloc] initWithLocation:i]];
    }
    return [array copy];
}

- (void)animateSelfToFrame:(CGRect)frame completion:(void (^)(BOOL finished))completion {
    frame = [self frameByCheckingBoundaries:frame];
    
    [UIView animateWithDuration:self.animationDuration delay:0.f usingSpringWithDamping:self.springDamping initialSpringVelocity:self.springVelocity options:self.animationCurve animations:^{
        [self setFrame:frame];
    } completion:completion];
}

#pragma mark Accessors

- (void)setMinSize:(CGSize)minSize {
    NSAssert(minSize.width > 0, @"Min width cannot be smaller or equal to 0!");
    NSAssert(minSize.height > 0, @"Min height cannot be smaller or equal to 0!");
    _minSize = minSize;
}

- (void)setMaxSize:(CGSize)maxSize {
    NSAssert(maxSize.width > 0, @"Max width cannot be smaller or equal to 0!");
    NSAssert(maxSize.height > 0, @"Max height cannot be smaller or equal to 0!");
    _maxSize = CGSizeMake(MAX(self.minSize.width, maxSize.width), MAX(self.minSize.height, maxSize.height));
}

@end
