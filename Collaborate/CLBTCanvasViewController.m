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
    self.canvas.clearsContextBeforeDrawing = NO;
    
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
        [self pullFirebase:snapshot];
        [self.canvas clear];
    }];
}

- (void)pullFirebase:(FDataSnapshot *)snapshot
{
    //Insert Core Graphics decoder and renderer here
    NSLog(@"==========Decoding==========");
    NSDictionary *paths = (NSDictionary *)snapshot.value;
    NSLog(@"%@\n", snapshot.name);
    
    for (NSString *pathKey in paths) {
        if (![self.cache objectForKey:pathKey]) {
            [self.cache setObject:[paths objectForKey:pathKey] forKey:pathKey];
        }
    }
    
    NSMutableArray *pathList = [[NSMutableArray alloc]init];
    
    for (NSString *pathName in self.cache) {
        NSArray *pathComponentsArray = [paths objectForKey:pathName];
        
        CGMutablePathRef path = CGPathCreateMutable();
        for (NSString *currentPathElement in pathComponentsArray) {
            
            NSArray *elements = [currentPathElement componentsSeparatedByString:@" "];
            if ([elements[0] isEqualToString:@"MoveTo"]) {
                CGPathMoveToPoint(path, NULL, [elements[1] floatValue], [elements[2] floatValue]);
            } else if ([elements[0] isEqualToString:@"LineTo"]) {
                CGPathAddLineToPoint(path, NULL, [elements[1] floatValue], [elements[2] floatValue]);
            } else if ([elements[0] isEqualToString:@"QuadCurveTo"]) {
                CGPathAddQuadCurveToPoint(path, NULL, [elements[1] floatValue], [elements[2] floatValue], [elements[3] floatValue], [elements[4] floatValue]);
            } else if ([elements[0] isEqualToString:@"CurveTo"]) {
                CGPathAddCurveToPoint(path, NULL, [elements[1] floatValue], [elements[2] floatValue], [elements[3] floatValue], [elements[4] floatValue], [elements[5] floatValue], [elements[6] floatValue]);
            } else {
                NSLog(@"Error: Core Graphics Path Identifier.");
            }
        }
        
        ACEDrawingPenTool *penTool = [[ACEDrawingPenTool alloc]init];
        penTool.identifier = pathName;
        penTool.isCompleted = YES;
        penTool.lineAlpha = 1.00;
        penTool.lineColor = [UIColor blackColor];
        penTool.lineWidth = 2.00;
        
        [penTool setPath:path];
        [pathList addObject:penTool];
    }
    
    self.canvas.pathArray = pathList;
    [self.canvas setNeedsDisplay];
    
    NSLog(@"Number of Paths: %ld", [pathList count]);
}

- (IBAction)clearButtonPressed:(id)sender {

    //Change to clear rendered set as well
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
    tool.isCompleted = NO;
    NSLog(@"Drawing Path Began");
}

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool
{
    NSLog(@"Drawing Path Ended");
    tool.isCompleted = YES;
    
    NSMutableDictionary *paths = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *room = [[NSMutableDictionary alloc]init];
    
    BOOL contains = NO;
    NSLog(@"==========Serializing==========");
    for (ACEDrawingPenTool *p in self.canvas.pathArray) {
        if (!p.identifier) {
            Firebase *firebaseReference = [self.firebase childByAutoId];
            p.identifier = firebaseReference.name;
        }
        
        if (p == tool) {
            contains = YES;
        }
        
        NSArray *points = [p serialize];
        NSString *name = p.identifier;
        
        [paths setObject:points forKey:name];
        NSLog(@"Putting %@", name);
    }
    
    if (!contains && tool) {
        Firebase *firebaseReference = [self.firebase childByAutoId];
        tool.identifier = firebaseReference.name;
        NSArray *points = [(ACEDrawingPenTool *)tool serialize];
        NSString *name = tool.identifier;
        
        [paths setObject:points forKey:name];
    }
    
    [room setObject:paths forKey:[NSString stringWithFormat:@"Room: %ld", self.roomNumber]];
    
    [self.firebase setValue:room withCompletionBlock:^(NSError *error, Firebase *ref) {
        NSLog(@"Finished saving to Firebase");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end