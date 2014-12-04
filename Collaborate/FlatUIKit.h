//
//  FlatUIKit.h
//  FlatUI
//
//  Created by Keisuke Kimura on 6/8/13.
//  Copyright (c) 2013 Keisuke Kimura. All rights reserved.
//

#ifndef FlatUI_FlatUIKit_h
#define FlatUI_FlatUIKit_h

#ifndef __IPHONE_5_0
#error "FlatUIKit uses features only available in iOS SDK 5.0 and later."
#endif

#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif

#endif

#import "classes/ios/FUIAlertView.h"
#import "classes/ios/FUIButton.h"
#import "classes/ios/FUITextField.h"
#import "classes/ios/FUICellBackgroundView.h"
#import "classes/ios/FUISegmentedControl.h"
#import "classes/ios/FUISwitch.h"
#import "classes/ios/UIBarButtonItem+FlatUI.h"
#import "classes/ios/UIColor+FlatUI.h"
#import "classes/ios/UIFont+FlatUI.h"
#import "classes/ios/UIImage+FlatUI.h"
#import "classes/ios/UINavigationBar+FlatUI.h"
#import "classes/ios/UIProgressView+FlatUI.h"
#import "classes/ios/UIStepper+FlatUI.h"
#import "classes/ios/UISlider+FlatUI.h"
#import "classes/ios/UITabBar+FlatUI.h"
#import "classes/ios/UITableViewCell+FlatUI.h"
#import "classes/ios/UIToolbar+FlatUI.h"
