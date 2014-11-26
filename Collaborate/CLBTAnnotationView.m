//
//  CLBTAnnotationView.m
//  Collaborate
//
//  Created by Andrew Chun on 11/25/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTAnnotationView.h"

@interface CLBTAnnotationView ()

@property (strong, nonatomic) UITapGestureRecognizer        *tapGR;
@property (strong, nonatomic) UILongPressGestureRecognizer  *longPressGR;

@end

@implementation CLBTAnnotationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.alpha = 0.40;
        
        self.tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestures:)];
        self.tapGR.numberOfTapsRequired = 1;
        self.tapGR.enabled = YES;
        self.tapGR.delegate = self;
        
        self.longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestures:)];
        self.longPressGR.minimumPressDuration = 0.00;
        self.longPressGR.enabled = NO;
        self.longPressGR.delegate = self;
        
        [self addGestureRecognizer:self.tapGR];
        [self addGestureRecognizer:self.longPressGR];
    }
    
    return self;
}

- (void)handleGestures:(UIGestureRecognizer *)gesture
{
    if (gesture == self.tapGR) {
        self.tapGR.enabled = NO;
        self.longPressGR.enabled = YES;
        NSLog(@"Double Tap Recognized");
    } else if (gesture == self.longPressGR) {
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                NSLog(@"Long Press Began");
                break;
            case UIGestureRecognizerStateChanged:
                break;
            case UIGestureRecognizerStateEnded:
                self.tapGR.enabled = YES;
                self.longPressGR.enabled = NO;
                [self removeFromSuperview];
                NSLog(@"Long Press Ended");
                break;
            default:
                NSLog(@"Unidentifiable Gesture State");
                break;
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
