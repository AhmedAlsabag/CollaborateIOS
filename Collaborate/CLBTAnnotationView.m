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
@property (strong, nonatomic) MMPopLabel    *popLabel;
@property (assign, nonatomic) BOOL          flag;

@end


@implementation CLBTAnnotationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.informationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.informationButton.frame = CGRectMake(0, 0, 50, 50);
        [self.informationButton setTitle:INFORMATION_ICON forState:UIControlStateNormal];
        [self.informationButton addTarget:self action:@selector(handlePopUp:) forControlEvents:UIControlEventTouchUpInside];
        self.informationButton.backgroundColor = [UIColor blackColor];
        [self addSubview:self.informationButton];
        
        self.backgroundColor = [UIColor blackColor];
        
        self.flag = false;
    }
    
    return self;
}

- (void)handlePopUp:(UIButton *)button
{
    if (button == self.informationButton) {
        if (!self.flag) {
        
            [[MMPopLabel appearance] setLabelColor:[UIColor colorWithRed: 0.89 green: 0.6 blue: 0 alpha: 1]];
            [[MMPopLabel appearance] setLabelTextColor:[UIColor whiteColor]];
            [[MMPopLabel appearance] setLabelTextHighlightColor:[UIColor greenColor]];
            [[MMPopLabel appearance] setLabelFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
            [[MMPopLabel appearance] setButtonFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
            
            self.popLabel = [MMPopLabel popLabelWithText:
                      @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                      "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."];
            
            self.popLabel.delegate = self;
            
            UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [skipButton setTitle:NSLocalizedString(@"Skip Tutorial", @"Skip Tutorial Button") forState:UIControlStateNormal];
            [self.popLabel addButton:skipButton];
            
            UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [okButton setTitle:NSLocalizedString(@"OK, Got It!", @"Dismiss Button") forState:UIControlStateNormal];
            [self.popLabel addButton:okButton];
            
            [self addSubview:self.popLabel];
            
            self.flag = YES;
        }
        
        [self.popLabel popAtView:self];
    }
}

- (void)dismissedPopLabel:(MMPopLabel *)popLabel
{
    
}

- (void)didPressButtonForPopLabel:(MMPopLabel *)popLabel atIndex:(NSInteger)index
{
    
}

@end
