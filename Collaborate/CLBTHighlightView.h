//
//  CLBTHighlightView.h
//  Collaborate
//
//  Created by Andrew Chun on 11/30/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLBTHighlightViewDelegate <NSObject>

- (void)touchedHighlightViewWithIdentifier:(NSString *)identifier;

@end

@interface CLBTHighlightView : UIView

@property (strong, nonatomic) id<CLBTHighlightViewDelegate> delegate;
@property (strong, nonatomic) NSString *identifier;

@end
