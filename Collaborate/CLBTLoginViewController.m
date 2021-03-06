//
//  CLBTLoginViewController.m
//  Collaborate
//
//  Created by Andrew Chun on 12/3/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTLoginViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldHMargin = 10.0f;

const static CGFloat kJVFieldFontSize = 16.0f;

const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

@implementation CLBTLoginViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Floating Label Demo", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"Hello!");
    [((UINavigationController *)[self parentViewController]) setNavigationBarHidden:YES];
    
    CGFloat topOffset = 0;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self.view setTintColor:[UIColor blueColor]];
    
    topOffset = ([[UIApplication sharedApplication] statusBarFrame].size.height
                 + self.navigationController.navigationBar.frame.size.height);
#endif
    
    UIColor *floatingLabelColor = [UIColor brownColor];
    
    JVFloatLabeledTextField *titleField = [[JVFloatLabeledTextField alloc] initWithFrame:
                                           CGRectMake(kJVFieldHMargin,
                                                      topOffset+100,
                                                      self.view.frame.size.width - 2 * kJVFieldHMargin,
                                                      kJVFieldHeight)];
    titleField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Username", @"")
                                    attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    titleField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    titleField.floatingLabel.font = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    titleField.floatingLabelTextColor = floatingLabelColor;
    titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    //    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    //    titleField.leftView = leftView;
    //    titleField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:titleField];
    
    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(kJVFieldHMargin, titleField.frame.origin.y + titleField.frame.size.height,
                            self.view.frame.size.width - 2 * kJVFieldHMargin, 1.0f);
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];
    
//    JVFloatLabeledTextField *priceField = [[JVFloatLabeledTextField alloc] initWithFrame:
//                                           CGRectMake(kJVFieldHMargin,
//                                                      div1.frame.origin.y + div1.frame.size.height,
//                                                      80.0f,
//                                                      kJVFieldHeight)];
//    priceField.attributedPlaceholder =
//    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Price", @"")
//                                    attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
//    priceField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
//    priceField.floatingLabel.font = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
//    priceField.floatingLabelTextColor = floatingLabelColor;
//    [self.view addSubview:priceField];
//    
//    UIView *div2 = [UIView new];
//    div2.frame = CGRectMake(kJVFieldHMargin + priceField.frame.size.width,
//                            titleField.frame.origin.y + titleField.frame.size.height,
//                            1.0f, kJVFieldHeight);
//    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
//    [self.view addSubview:div2];
//    
//    JVFloatLabeledTextField *locationField =
//    [[JVFloatLabeledTextField alloc] initWithFrame:
//     CGRectMake(kJVFieldHMargin + kJVFieldHMargin + priceField.frame.size.width + 1.0f,
//                div1.frame.origin.y + div1.frame.size.height,
//                self.view.frame.size.width - 3*kJVFieldHMargin - priceField.frame.size.width - 1.0f,
//                kJVFieldHeight)];
//    
//    locationField.attributedPlaceholder =
//    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Specific Location (optional)", @"")
//                                    attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
//    locationField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
//    locationField.floatingLabel.font = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
//    locationField.floatingLabelTextColor = floatingLabelColor;
//    [self.view addSubview:locationField];
//    
    UIView *div3 = [UIView new];
    
    div3.frame = CGRectMake(kJVFieldHMargin, titleField.frame.origin.y + titleField.frame.size.height,
                            self.view.frame.size.width - 2*kJVFieldHMargin, 1.0f);
    div3.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div3];
    
    JVFloatLabeledTextView *descriptionField =
    [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(kJVFieldHMargin,
                                                             div3.frame.origin.y + div3.frame.size.height,
                                                             self.view.frame.size.width - 2*kJVFieldHMargin,
                                                             kJVFieldHeight)];
    descriptionField.placeholder = NSLocalizedString(@"Password", @"");
    descriptionField.placeholderTextColor = [UIColor darkGrayColor];
    descriptionField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    descriptionField.floatingLabel.font = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    descriptionField.floatingLabelTextColor = floatingLabelColor;
    [self.view addSubview:descriptionField];
    
    [titleField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
