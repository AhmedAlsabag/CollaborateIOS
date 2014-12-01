//
//  CLBTAnnotationView.h
//  Collaborate
//
//  Created by Andrew Chun on 11/25/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLBTAnnotationView.h"
#import <Firebase/Firebase.h>
#import "CLBTHighlightView.h"

@protocol CLBTAnnotationZoneViewDelegate <NSObject>

- (void)annotationZoneHasBeenUpdated:(NSDictionary *)annotations;

@end

@interface CLBTAnnotationZoneView : UIView <UIGestureRecognizerDelegate, CLBTAnnotationViewDelegate, CLBTHighlightViewDelegate>

@property (weak, nonatomic) id<CLBTAnnotationZoneViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andFirebase:(Firebase *)firebase;

@end
