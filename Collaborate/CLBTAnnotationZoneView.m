//
//  CLBTAnnotationView.m
//  Collaborate
//
//  Created by Andrew Chun on 11/25/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTAnnotationZoneView.h"
#import "CLBTAnnotationView.h"

@interface CLBTAnnotationZoneView ()

@property (strong, nonatomic) UILongPressGestureRecognizer  *longPressGR;
@property (strong, nonatomic) UIPanGestureRecognizer        *panGR;

@property (strong, nonatomic) NSMutableDictionary           *annotations;
@property (strong, nonatomic) CLBTAnnotationView            *currentAnnotation;
@property (assign, nonatomic) CGPoint                       currentStartPoint;

@property (strong, nonatomic) UIButton                      *dismissButton;

@end

@implementation CLBTAnnotationZoneView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestures:)];
        self.longPressGR.minimumPressDuration = 0.00;
        self.longPressGR.enabled = YES;
        self.longPressGR.delegate = self;
        
        self.panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestures:)];
        self.panGR.enabled = NO;
        self.panGR.delegate = self;
        
        [self addGestureRecognizer:self.longPressGR];
        [self addGestureRecognizer:self.panGR];
        
        self.annotations = [[NSMutableDictionary alloc]init];
        
        self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.dismissButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 100, 0, 100, 50);
        [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        [self.dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.dismissButton];
    }
    
    return self;
}

- (void)dismissButtonPressed:(UIButton *)button
{
    if (button == self.dismissButton) {
        [self removeFromSuperview];
    }
}

- (void)handleGestures:(UIGestureRecognizer *)gesture
{
    if (gesture == self.longPressGR) {
        self.longPressGR.enabled = NO;
        self.panGR.enabled = YES;
        self.currentStartPoint = [self.longPressGR locationInView:self];
        self.currentAnnotation = [[CLBTAnnotationView alloc]initWithFrame:CGRectMake(self.currentStartPoint.x, self.currentStartPoint.y, 0, 0)];
        self.currentAnnotation.backgroundColor = [UIColor purpleColor];
        self.currentAnnotation.alpha = 10.00;
        self.currentAnnotation.layer.cornerRadius = 7.50;
        [self addSubview:self.currentAnnotation];
        NSLog(@"Double Tap Recognized");
    } else if (gesture == self.panGR) {
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                NSLog(@"Pan Began");
                break;
            }
            case UIGestureRecognizerStateChanged: {
                CGPoint currentPoint = [self.panGR locationInView:self];
                self.currentAnnotation.frame = CGRectMake(self.currentStartPoint.x, self.currentStartPoint.y, currentPoint.x - self.currentStartPoint.x, currentPoint.y - self.currentStartPoint.y);
                break;
            }
            case UIGestureRecognizerStateEnded: {
                self.longPressGR.enabled = YES;
                self.panGR.enabled = NO;
                [self.annotations setObject:self.currentAnnotation forKey:[NSValue valueWithCGPoint:self.currentStartPoint]];
                NSLog(@"Pan Ended");
                break;
            }
            default: {
                NSLog(@"Unidentifiable Gesture State");
                break;
            }
        }
    } else {
        NSLog(@"Unidentifiable Gesture");
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
