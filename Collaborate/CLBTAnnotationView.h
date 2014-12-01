//
//  CLBTAnnotationView.h
//  Collaborate
//
//  Created by Andrew Chun on 11/30/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLBTAnnotationViewDelegate <NSObject>

- (void)dismissAnnotationView;

@end

@interface CLBTAnnotationView : UIView

@property (weak, nonatomic) id<CLBTAnnotationViewDelegate> delegate;

@end
