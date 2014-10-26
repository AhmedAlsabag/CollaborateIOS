//
//  ViewController.m
//  Collaborate
//
//  Created by Andrew Chun on 10/8/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "ViewController.h"
#import "ACEDrawingView.h"
#import <Firebase/Firebase.h>
#import "ACEDrawingTools.h"

@interface ViewController ()

@property (assign, nonatomic) NSInteger             roomNumber;
@property (strong, nonatomic) ACEDrawingView        *canvas;
@property (strong, nonatomic) Firebase              *firebase;
@property (strong, nonatomic) NSMutableSet          *pathSet;
@property (nonatomic) FirebaseHandle                childAddedHandle;
@property (nonatomic) FirebaseHandle                childChangedHandle;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.pathSet = [[NSMutableSet alloc]init];
    
    self.canvas = [[ACEDrawingView alloc]initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    self.canvas.delegate = self;
    self.canvas.lineWidth = 2.00;
    
    [self.view addSubview:self.canvas];
    
    [self.view addSubview:self.clearButton];
    
    self.firebase = [[Firebase alloc]initWithUrl:@"https://collaborateios.firebaseio.com/"];
    
    self.roomNumber = 1;
    
    self.childAddedHandle = [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        //Insert Core Graphics decoder and renderer here
        NSLog(@"==========Decoding==========");
        NSDictionary *paths = (NSDictionary *)snapshot.value;
        NSLog(@"%@\n", snapshot.name);
        
        for (NSString *pathKey in paths) {
            NSLog(@"Path Key: %@", pathKey);
            [self.pathSet addObject:pathKey];
        }
        NSLog(@"\n");
        
        NSMutableArray *pathList = [[NSMutableArray alloc]init];
        
        NSArray *setMembers = [self.pathSet allObjects];
        for (NSString *pathName in setMembers) {
            NSArray *pathComponentsArray = [paths objectForKey:pathName];
            
            CGMutablePathRef path = CGPathCreateMutable();
            NSLog(@"Name: %@", pathName);
            for (NSString *currentPathElement in pathComponentsArray) {
                NSLog(@"%@", currentPathElement);
                
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
            NSLog(@"\n");
            
            ACEDrawingPenTool *penTool = [[ACEDrawingPenTool alloc]init];
            penTool.lineAlpha = 1.00;
            penTool.lineColor = [UIColor blackColor];
            penTool.lineWidth = 2.00;
            
            [penTool setPath:path];
            [pathList addObject:penTool];
        }
        
        self.canvas.pathArray = pathList;
        [self.canvas setNeedsDisplay];
        
        NSLog(@"Number of Paths: %ld", [pathList count]);
    }];
    
    self.childChangedHandle = [self.firebase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        //Insert Core Graphics decoder and renderer here
        NSLog(@"==========Decoding==========");
        NSDictionary *paths = (NSDictionary *)snapshot.value;
        NSLog(@"%@\n", snapshot.name);
        self.pathSet = [[NSMutableSet alloc]init];
        
        for (NSString *pathKey in paths) {
            NSLog(@"Path Key: %@", pathKey);
            [self.pathSet addObject:pathKey];
        }
        NSLog(@"\n");
        
        NSMutableArray *pathList = [[NSMutableArray alloc]init];
        
        NSArray *setMembers = [self.pathSet allObjects];
        for (NSString *pathName in setMembers) {
            NSArray *pathComponentsArray = [paths objectForKey:pathName];
            
            CGMutablePathRef path = CGPathCreateMutable();
            NSLog(@"Name: %@", pathName);
            for (NSString *currentPathElement in pathComponentsArray) {
                NSLog(@"%@", currentPathElement);
                
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
            NSLog(@"\n");
            
            ACEDrawingPenTool *penTool = [[ACEDrawingPenTool alloc]init];
            penTool.lineAlpha = 1.00;
            penTool.lineColor = [UIColor blackColor];
            penTool.lineWidth = 2.00;
            
            [penTool setPath:path];
            [pathList addObject:penTool];
        }
        
        self.canvas.pathArray = pathList;
        [self.canvas setNeedsDisplay];
        
        NSLog(@"Number of Paths: %ld", [pathList count]);
    }];
}

- (IBAction)clearButtonPressed:(id)sender {

    [self.canvas clear];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)drawingView:(ACEDrawingView *)view willBeginDrawUsingTool:(id<ACEDrawingTool>)tool
{
    NSLog(@"Drawing Path Began");
}

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool
{
    NSLog(@"Drawing Path Ended");
    
    NSMutableDictionary *paths = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *room = [[NSMutableDictionary alloc]init];
    self.pathSet = [[NSMutableSet alloc]init];
    
    NSLog(@"==========Serializing==========");
    for (ACEDrawingPenTool *p in self.canvas.pathArray) {
        Firebase *firebaseReference = [self.firebase childByAutoId];
        NSString *name = firebaseReference.name;
        NSArray *points = [p serialize];
        
        [paths setObject:points forKey:name];
        [self.pathSet addObject:name];
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
