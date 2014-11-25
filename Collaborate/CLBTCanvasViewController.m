//
//  ViewController.m
//  Collaborate
//
//  Created by Andrew Chun on 10/8/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTCanvasViewController.h"
#import "ACEDrawingView.h"
#import <Firebase/Firebase.h>
#import "ACEDrawingTools.h"

#define PATH_INFO @"PATH_INFO"
#define PATH_USED @"PATH_USED"

@interface CLBTCanvasViewController ()

@property (assign, nonatomic) NSInteger                     roomNumber;
@property (weak, nonatomic) IBOutlet ACEDrawingView         *canvas;
@property (strong, nonatomic) Firebase                      *firebase;
@property (nonatomic) FirebaseHandle                        childAddedHandle;
@property (nonatomic) FirebaseHandle                        childChangedHandle;
@property (nonatomic) FirebaseHandle                        childRemovedHandle;
@property (strong, nonatomic) UITapGestureRecognizer        *tapGR;
@property (strong, nonatomic) UILongPressGestureRecognizer  *longPressGR;

@property (strong, nonatomic) NSMutableDictionary   *cache;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end

@implementation CLBTCanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.cache = [[NSMutableDictionary alloc]init];
    
    self.canvas.delegate = self;
    self.canvas.lineWidth = 2.00;
    
//    self.firebase = [[Firebase alloc]initWithUrl:@"https://collaborateios.firebaseio.com/"];
    self.firebase =  [[Firebase alloc]initWithUrl:@"https://shining-fire-4147.firebaseio.com/"];

    self.roomNumber = 1;
    
    self.tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestures:)];
    self.tapGR.numberOfTapsRequired = 2;
    self.tapGR.enabled = YES;
    
    self.longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestures:)];
    self.longPressGR.minimumPressDuration = 0.00;
    self.longPressGR.enabled = NO;
    
    self.childAddedHandle = [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self pullFirebase:snapshot];
    }];
    self.childChangedHandle = [self.firebase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [self pullFirebase:snapshot];
    }];
    self.childRemovedHandle = [self.firebase observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [self.canvas clear];
        [self.cache removeAllObjects];
    }];
}

- (void)pullFirebase:(FDataSnapshot *)snapshot
{
    //Insert Core Graphics decoder and renderer here
    NSLog(@"==========Decoding==========");
    NSDictionary *paths = (NSDictionary *)snapshot.value;

    NSMutableArray *pathList = [[NSMutableArray alloc]init];
    for (NSString *pathKey in paths) {
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
    
    [self.firebase setValue:room withCompletionBlock:^(NSError *error, Firebase *ref) {
        NSLog(@"Finished saving to Firebase");
    }];
}

- (IBAction)clearButtonPressed:(id)sender {

    //Change to clear rendered set as well
    [self.cache removeAllObjects];
    [self.canvas clear];
    
    [self.firebase setValue:nil withCompletionBlock:^(NSError *error, Firebase *ref) {
        NSLog(@"Finished saving to Firebase");
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)handleGestures:(UIGestureRecognizer *)gesture
{
    if (gesture == self.tapGR) {
        self.canvas.userInteractionEnabled = NO;
        self.tapGR.enabled = NO;
        self.longPressGR.enabled = YES;
    } else if (gesture == self.longPressGR) {
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                break;
            case UIGestureRecognizerStateChanged:
                break;
            case UIGestureRecognizerStateEnded:
                self.canvas.userInteractionEnabled = YES;
                self.tapGR.enabled = YES;
                self.longPressGR.enabled = NO;
                break;
            default:
                NSLog(@"Unidentifiable Gesture State");
                break;
        }
    } else {
        NSLog(@"Unidentifiable Gesture");
    }
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
    
    tool.isCompleted = NO;
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

@end
