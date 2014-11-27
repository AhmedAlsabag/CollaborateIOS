//
//  CLBTAnnotationView.m
//  Collaborate
//
//  Created by Andrew Chun on 11/26/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTAnnotationView.h"

#define INFORMATION_ICON @"ⓘ"

@interface CLBTAnnotationView ()

@property (strong, nonatomic) UIButton      *informationButton;
@property (assign, nonatomic) BOOL          flag;

@end


@implementation CLBTAnnotationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.informationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.informationButton.frame = CGRectMake(0, 0, 25, 25);
        [self.informationButton setTitle:INFORMATION_ICON forState:UIControlStateNormal];
        self.informationButton.titleLabel.textColor = [UIColor redColor];
        [self.informationButton addTarget:self action:@selector(handlePopUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.informationButton];
        
        self.flag = false;
    }
    
    return self;
}

- (void)handlePopUp:(UIButton *)button
{
    if (button == self.informationButton) {
        if (!self.flag) {
            
            self.flag = YES;
        }
        
    }
}

@end
