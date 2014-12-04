//
//  CLBTLoginViewController.m
//  Collaborate
//
//  Created by Andrew Chun on 12/3/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTLoginViewController.h"

@implementation CLBTLoginViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"Hello!");
    [((UINavigationController *)[self parentViewController]) setNavigationBarHidden:YES];
}

@end
