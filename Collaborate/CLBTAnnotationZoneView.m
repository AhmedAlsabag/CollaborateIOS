//
//  CLBTAnnotationView.m
//  Collaborate
//
//  Created by Andrew Chun on 11/25/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTAnnotationZoneView.h"
#import "CLBTAnnotationView.h"
#import "KLCPopup.h"
#import <Firebase/Firebase.h>
#import "CLBTHighlightView.h"

@interface CLBTAnnotationZoneView ()

@property (strong, nonatomic) Firebase                      *firebase;

@property (strong, nonatomic) UILongPressGestureRecognizer  *longPressGR;

@property (strong, nonatomic) NSMutableSet                  *highlightViewSet;
@property (strong, nonatomic) NSMutableDictionary           *annotations;
@property (assign, nonatomic) CGPoint                       currentStartPoint;
@property (strong, nonatomic) KLCPopup                      *currentAnnotationModal;
@property (strong, nonatomic) CLBTHighlightView             *currentHighlightView;

@property (strong, nonatomic) UIButton                      *dismissButton;

@end

@implementation CLBTAnnotationZoneView

- (instancetype)initWithFrame:(CGRect)frame andFirebase:(Firebase *)firebase {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestures:)];
        self.longPressGR.minimumPressDuration = 0.00;
        self.longPressGR.enabled = YES;
        self.longPressGR.delegate = self;
        [self addGestureRecognizer:self.longPressGR];
        
        self.annotations = [[NSMutableDictionary alloc]init];
        self.highlightViewSet = [[NSMutableSet alloc]init];
        
        self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.dismissButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 100, CGRectGetHeight(self.bounds) - 50, 100, 50);
        [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        [self.dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.dismissButton];
        
        self.firebase = firebase;
    }
    
    return self;
}

- (void)dismissButtonPressed:(UIButton *)button
{
    if (button == self.dismissButton) {
        NSLog(@"Dismiss!");
        [self removeFromSuperview];
    }
}

- (void)handleGestures:(UIGestureRecognizer *)gesture
{
    if (gesture == self.longPressGR) {
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                NSLog(@"LongPress Began");
                
                break;
            }
            case UIGestureRecognizerStateChanged: {
                if (!self.currentHighlightView) {
                    self.currentStartPoint = [self.longPressGR locationInView:self];
                    self.currentHighlightView = [[CLBTHighlightView alloc]initWithFrame:CGRectMake(self.currentStartPoint.x, self.currentStartPoint.y, 0, 0)];
                    self.currentHighlightView.backgroundColor = [UIColor lightGrayColor];
                    self.currentHighlightView.layer.cornerRadius = 5.00;
                    self.currentHighlightView.delegate = self;
                    [self addSubview:self.currentHighlightView];
                } else {
                    CGPoint currPoint = [self.longPressGR locationInView:self];
                    self.currentHighlightView.frame = CGRectMake(self.currentStartPoint.x, self.currentStartPoint.y, currPoint.x - self.currentStartPoint.x, currPoint.y - self.currentStartPoint.y);
                }
                break;
            }
            case UIGestureRecognizerStateEnded: {
                if (self.currentHighlightView) {
                    CLBTAnnotationView *annotationView = [[CLBTAnnotationView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
                    annotationView.backgroundColor = [UIColor whiteColor];
                    annotationView.layer.cornerRadius = 5.00;
                    annotationView.delegate = self;
                    
                    self.currentAnnotationModal = [KLCPopup popupWithContentView:annotationView showType:KLCPopupShowTypeBounceInFromRight dismissType:KLCPopupDismissTypeBounceOutToLeft maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
                    [self.currentAnnotationModal show];
                }
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

- (void)dismissAnnotationView {
    
    if (![self.highlightViewSet containsObject:self.currentHighlightView]) {
        Firebase *firebaseReference = [self.firebase childByAutoId];
        
        self.currentHighlightView.identifier = firebaseReference.name;
    }
    
    [self.highlightViewSet addObject:self.currentHighlightView];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:self.currentHighlightView forKey:@"HighlightView"];
    [dict setObject:self.currentAnnotationModal forKey:@"AnnotationViewModal"];
    
    [self.annotations setObject:dict forKey:self.currentHighlightView.identifier];
    
    [self.currentAnnotationModal dismiss:YES];
    self.currentAnnotationModal = nil;
    self.currentHighlightView = nil;
    [self.delegate annotationZoneHasBeenUpdated:self.annotations];
}

- (void)touchedHighlightViewWithIdentifier:(NSString *)identifier
{
    NSDictionary *dict = [self.annotations objectForKey:identifier];
    
    self.currentHighlightView = dict[@"HighlightView"];
    self.currentAnnotationModal = dict[@"AnnotationViewModal"];
    
    [((KLCPopup *)dict[@"AnnotationViewModal"]) show];
}

//- (NSMutableDictionary *)serialize
//{
//    
//}
//
//- (NSMutableDictionary *)deserialize
//{
//    
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if ([touch.view isDescendantOfView:self.dismissButton] || [self.highlightViewSet containsObject:touch.view]) {
        // we touched our control surface
        return NO; // ignore the touch
    }
    
    return YES; // handle the touch
}

@end
