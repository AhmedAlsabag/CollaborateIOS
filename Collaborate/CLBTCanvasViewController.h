//
//  ViewController.h
//  Collaborate
//
//  Created by Andrew Chun on 10/8/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACEDrawingVIew.h"
#import "FCColorPickerViewController.h"
#import "FlatUIKit.h"

@interface CLBTCanvasViewController : UIViewController <ACEDrawingViewDelegate, UIGestureRecognizerDelegate, FCColorPickerViewControllerDelegate,UIPopoverControllerDelegate, UIActionSheetDelegate, FUIAlertViewDelegate>

@property (assign, nonatomic) NSInteger                     roomNumber;

@end

