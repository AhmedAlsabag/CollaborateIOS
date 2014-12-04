//
//  ViewController.m
//  Collaborate
//
//  Created by Andrew Chun on 10/8/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTCanvasViewController.h"
#import "ACEDrawingView.h"
#import "CLBTAnnotationZoneView.h"
#import <Firebase/Firebase.h>
#import "ACEDrawingTools.h"
#import "KLCPopUp.h"
#import "FlatUIKit.h"


#define PATH_INFO @"PATH_INFO"
#define PATH_USED @"PATH_USED"

@interface CLBTCanvasViewController ()

@property (strong, nonatomic) IBOutlet __block ACEDrawingView         *canvas;
@property (strong, nonatomic) Firebase                      *firebase;
@property (strong, nonatomic) NSMutableDictionary           *firebaseInfo;
@property (nonatomic) FirebaseHandle                        childAddedHandle;
@property (nonatomic) FirebaseHandle                        childChangedHandle;
@property (nonatomic) FirebaseHandle                        childRemovedHandle;

@property (strong, nonatomic) __block NSMutableDictionary   *cache;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *drawButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *colorPickerButton;

@property (strong, nonatomic) CLBTAnnotationZoneView            *annotationZoneView;

@property (strong, nonatomic) KLCPopup                          *currentPopUp;

@property (strong, nonatomic) UISlider                          *brushWidthSlider;
@property (strong, nonatomic) KLCPopup                          *brushWidthPopup;

@end

@implementation CLBTCanvasViewController
{
    //side bar array of cell objects, jesus
    NSMutableArray *array;
    KLCPopup* popup;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.menuButton setBackgroundColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]];

    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    self.menuButton.layer.cornerRadius = 10; // this value vary as per your desire
    self.menuButton.clipsToBounds = YES;
 
    // Do any additional setup after loading the view, typically from a nib.
    self.cache = [[NSMutableDictionary alloc]init];

    self.canvas.delegate = self;
    self.canvas.lineWidth = 2.00;
    
    self.firebase = [[Firebase alloc]initWithUrl:@"https://collaborateios.firebaseio.com/"];
//    self.firebase =  [[Firebase alloc]initWithUrl:@"https://shining-fire-4147.firebaseio.com/"];
    
    self.childAddedHandle = [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self pullFirebase:snapshot];
    }];
    self.childChangedHandle = [self.firebase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [self pullFirebase:snapshot];
    }];
    self.childRemovedHandle = [self.firebase observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [self.cache removeAllObjects];
        [self.canvas clear];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [((UINavigationController *)[self parentViewController]) setNavigationBarHidden:NO animated:NO];
}

- (void)pullFirebase:(FDataSnapshot *)snapshot
{
    //Insert Core Graphics decoder and renderer here
    NSLog(@"==========Decoding==========");
    self.firebaseInfo = snapshot.value;
    [self.cache removeAllObjects];
    
    NSDictionary *rooms = (NSDictionary *)snapshot.value;
    NSDictionary *paths = rooms[[NSString stringWithFormat:@"Room: %ld", self.roomNumber]];

    NSMutableArray *pathList = [[NSMutableArray alloc]init];
    for (NSString *pathKey in paths) {
        if ([pathKey isEqualToString:@"Nothing"]) {
            break;
        }
        
        if (![self.cache objectForKey:pathKey]) {
            [self.cache setObject:[paths objectForKey:pathKey] forKey:pathKey];
            NSLog(@"Caching: %@", pathKey);
        }
        
        NSDictionary *currPath = [paths objectForKey:pathKey];
        NSString *toolType = [currPath objectForKey:@"toolType"];
        
        if ([toolType isEqualToString:@"Pen"]) {
            ACEDrawingPenTool *pen = [[ACEDrawingPenTool alloc]init];
            [pen deserializePath:pathKey withInfo:currPath];
            [pathList addObject:pen];
        }
    }

    self.canvas.pathArray = pathList;
    [self.canvas.layer setNeedsDisplay];
}

- (void)pushFirebaseWithTool:(id<ACEDrawingTool>)tool
{
    NSMutableDictionary *paths = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *room = [[NSMutableDictionary alloc]init];
    
    NSLog(@"==========Serializing==========");
    if (tool) {
        
        if (![self.cache objectForKey:tool.identifier]) {
            Firebase *firebaseReference = [self.firebase childByAutoId];
            tool.identifier = firebaseReference.name;
        }
        
        NSDictionary *pathInfo = [(ACEDrawingPenTool *)tool serialize];
        [self.cache setObject:pathInfo forKey:tool.identifier];
    }
    
    for (NSString *toolKey in self.cache) {
        [paths setObject:[self.cache objectForKey:toolKey] forKey:toolKey];
    }
    
    [room setObject:paths forKey:[NSString stringWithFormat:@"Room: %ld", self.roomNumber]];
    
    if (self.firebaseInfo[[NSString stringWithFormat:@"Room: %ld", self.roomNumber]][@"Nothing"]) {
        self.firebaseInfo[[NSString stringWithFormat:@"Room: %ld", self.roomNumber]] = [[NSMutableDictionary alloc]init];
    }
    
    [self.firebaseInfo setObject:paths forKey:[NSString stringWithFormat:@"Room: %ld", self.roomNumber]];
    
    if ([self.firebaseInfo[[NSString stringWithFormat:@"Room: %ld", self.roomNumber]] count] == 0) {
        [self.firebaseInfo[[NSString stringWithFormat:@"Room: %ld", self.roomNumber]] setObject:@"Nothing" forKey:@"Nothing"];
    }
    
    NSMutableDictionary *root = [[NSMutableDictionary alloc]init];
    [root setObject:self.firebaseInfo forKey:@"Rooms"];
    
    [self.firebase setValue:root withCompletionBlock:^(NSError *error, Firebase *ref) {
        NSLog(@"Finished saving to Firebase");
    }];
}

- (IBAction)buttonPressed:(id)sender {


    if (sender == self.menuButton)
    {
        //creating popup, jesus
        NSLog(@"menu button pressed");
        UIView* contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.frame = CGRectMake(0.0, 0.0, 350.0, 250.0);
        contentView.layer.cornerRadius = 12.0;
       
        //creating settings button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [button addTarget:self
                   action:@selector(settingsMethod:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Settings" forState:UIControlStateNormal];
        button.frame = CGRectMake(20.0, 50.0, 150.0, 40.0);
        [button setBackgroundColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        button.layer.cornerRadius = 10; // this value vary as per your desire
        button.clipsToBounds = YES;
        [contentView addSubview: button];

       //brush button
        UIButton *b_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [b_button addTarget:self
                   action:@selector(brushMethod:)
         forControlEvents:UIControlEventTouchUpInside];
        [b_button setTitle:@"Brush" forState:UIControlStateNormal];
        b_button.frame = CGRectMake(20.0, 100.0, 150.0, 40.0);
        [b_button setBackgroundColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]];
        //b_button.backgroundColor = [UIColor blueColor];
        [b_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        b_button.layer.cornerRadius = 10; // this value vary as per your desire
        b_button.clipsToBounds = YES;
        [contentView addSubview:b_button];
        //color button
        UIButton *c_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [c_button addTarget:self
                     action:@selector(colorMethod:)
           forControlEvents:UIControlEventTouchUpInside];
        [c_button setTitle:@"Color" forState:UIControlStateNormal];
        c_button.frame = CGRectMake(20.0, 150.0, 150.0, 40.0);
        [c_button setBackgroundColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]];
        //c_button.backgroundColor = [UIColor blueColor];
        [c_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        c_button.layer.cornerRadius = 10; // this value vary as per your desire
        c_button.clipsToBounds = YES;
        [contentView addSubview:c_button];
        //draw button
        UIButton *d_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [d_button addTarget:self
                     action:@selector(drawMethod:)
           forControlEvents:UIControlEventTouchUpInside];
        [d_button setTitle:@"Draw" forState:UIControlStateNormal];
        d_button.frame = CGRectMake(180.0, 50.0, 150.0, 40.0);
        [d_button setBackgroundColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]
];
        //d_button.backgroundColor = [UIColor blueColor];
        [d_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        d_button.layer.cornerRadius = 10; // this value vary as per your desire
        d_button.clipsToBounds = YES;
        [contentView addSubview:d_button];
        //comment button
        UIButton *cm_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cm_button addTarget:self
                     action:@selector(commentMethod:)
           forControlEvents:UIControlEventTouchUpInside];
        [cm_button setTitle:@"Comment" forState:UIControlStateNormal];
        cm_button.frame = CGRectMake(180.0, 100.0, 150.0, 40.0);
        [cm_button setBackgroundColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]
];
        //cm_button.backgroundColor = [UIColor blueColor];
        [cm_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        cm_button.layer.cornerRadius = 10; // this value vary as per your desire
        cm_button.clipsToBounds = YES;
        [contentView addSubview:cm_button];
        //clear button
        UIButton *cl_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cl_button addTarget:self
                      action:@selector(clearMethod:)
            forControlEvents:UIControlEventTouchUpInside];
        [cl_button setTitle:@"Clear" forState:UIControlStateNormal];
        cl_button.frame = CGRectMake(180.0, 150.0, 150.0, 40.0);
        [cl_button setBackgroundColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]
];
        //cl_button.backgroundColor = [UIColor blueColor];
        [cl_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        cl_button.layer.cornerRadius = 10; // this value vary as per your desire
        cl_button.clipsToBounds = YES;
        [contentView addSubview:cl_button];
        
        //add the 
        popup = [KLCPopup popupWithContentView:contentView];
        [popup show];
        
    }

    else {
        NSLog(@"Unidentified button pressed");
    }
}

-(void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    self.canvas.lineColor = color;
    [colorPicker dismissViewControllerAnimated:YES completion:nil];
//    [self.currentPopUp dismiss:YES];
}

-(void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
    [colorPicker dismissViewControllerAnimated:YES completion:nil];
//    [self.currentPopUp dismiss:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark ACEDrawingViewDelegate Methods
- (void)drawingView:(ACEDrawingView *)view willBeginDrawUsingTool:(id<ACEDrawingTool>)tool
{
    NSLog(@"Drawing Path Began");
}

- (void)drawingView:(ACEDrawingView *)view didChangeDrawUsingTool:(id<ACEDrawingTool>)tool
{
    NSLog(@"Drawing Path Changed");
}

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool
{
    NSLog(@"Drawing Path Ended");
    
    tool.isCompleted = YES;
    [self pushFirebaseWithTool:tool];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingsMethod:(UIButton*)button
{
    NSLog(@"settings Button clicked.");
    [popup dismissPresentingPopup];
}
- (void)brushMethod:(UIButton*)button
{
    NSLog(@"brush Button clicked.");
    
    UIView *brushView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    brushView.backgroundColor = [UIColor whiteColor];
    brushView.layer.cornerRadius = 5.00;
    
    self.brushWidthSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, 180, 30)];
    self.brushWidthSlider.center = CGPointMake(CGRectGetWidth(brushView.bounds) / 2, CGRectGetHeight(brushView.bounds) / 2);
    self.brushWidthSlider.minimumValue = 1.0;
    self.brushWidthSlider.maximumValue = 10.0;
    self.brushWidthSlider.value = self.canvas.lineWidth;
    [brushView addSubview:self.brushWidthSlider];
    
    UIButton *saveBrushWidthButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBrushWidthButton setTitle:@"Save" forState:UIControlStateNormal];
    saveBrushWidthButton.frame = CGRectMake(CGRectGetWidth(brushView.bounds) - 75, 5, 75, 25);
    [saveBrushWidthButton addTarget:self action:@selector(saveBrushWidthButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [brushView addSubview:saveBrushWidthButton];
    
    self.brushWidthPopup = [KLCPopup popupWithContentView:brushView showType:KLCPopupShowTypeFadeIn dismissType:KLCPopupDismissTypeFadeOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    [self.brushWidthPopup show];
    [popup dismissPresentingPopup];
}

- (void)saveBrushWidthButtonPressed:(UIButton *)button
{
    self.canvas.lineWidth = self.brushWidthSlider.value;
    [self.brushWidthPopup dismiss:YES];
}
- (void)colorMethod:(UIButton*)button
{
    NSLog(@"color Button clicked.");
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPicker];
    colorPicker.view.layer.cornerRadius = 5.00;
    colorPicker.color = self.canvas.lineColor;
    colorPicker.delegate = self;
    
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker animated:YES completion:nil];
    [popup dismissPresentingPopup];
}
- (void)drawMethod:(UIButton*)button
{
    NSLog(@"draw Button clicked.");
    [popup dismissPresentingPopup];
}

- (void)commentMethod:(UIButton*)button
{
    NSLog(@"comment Button clicked.");
    if (!self.annotationZoneView)
    {
        self.annotationZoneView = [[CLBTAnnotationZoneView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) andFirebase:self.firebase];
    }
    [self.view addSubview:self.annotationZoneView];
    [popup dismissPresentingPopup];
}
- (void)clearMethod:(UIButton*)button
{
    NSLog(@"something Button clicked.");
    
    [self.cache removeAllObjects];
    [self.canvas clear];
    
    [popup dismissPresentingPopup];
}
@end
