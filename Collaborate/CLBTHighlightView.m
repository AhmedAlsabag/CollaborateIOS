//
//  CLBTHighlightView.m
//  Collaborate
//
//  Created by Andrew Chun on 11/30/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTHighlightView.h"

@implementation CLBTHighlightView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.layer.opacity = 0.40;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.delegate touchedHighlightViewWithIdentifier:self.identifier];
}

@end
