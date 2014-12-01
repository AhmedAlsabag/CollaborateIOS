//
//  CLBTAnnotationView.m
//  Collaborate
//
//  Created by Andrew Chun on 11/30/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTAnnotationView.h"
@interface CLBTAnnotationView ()

@property(strong, nonatomic) UITextView         *textView;
@property (strong, nonatomic) UIButton          *dismissButton;

@end

@implementation CLBTAnnotationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width - 25.00, frame.size.height - 25.00)];
        self.textView.center = CGPointMake(self.center.x, self.center.y + 5);
        self.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.textView];
        
        self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.dismissButton setTitle:@"Save" forState:UIControlStateNormal];
        self.dismissButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 75, 5, 75, 25);
        [self.dismissButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.dismissButton];
    }
    
    return self;
}

- (void)buttonPressed:(UIButton *)button
{
    if (button == self.dismissButton) {
        [self.delegate dismissAnnotationView];
    }
}

@end
