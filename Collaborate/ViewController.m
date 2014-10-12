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

//Object object;
@property (strong, nonatomic) ACEDrawingView        *canvas;
@property (strong, nonatomic) Firebase              *firebase;
@property (weak, nonatomic) IBOutlet UIButton       *button;
@property (strong, nonatomic) NSMutableSet          *pathSet;
@property (nonatomic) FirebaseHandle                childAddedHandle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.canvas = [[ACEDrawingView alloc]initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    self.canvas.lineWidth = 2.00;
    
    [self.view addSubview:self.canvas];
    
    self.firebase = [[Firebase alloc]initWithUrl:@"https://collaborateios.firebaseio.com/"];
//    [self.firebase setValue:@"Do you have data? You'll love Firebase."];
    
    [self.view addSubview:self.button];
    
    self.pathSet = [[NSMutableSet alloc]init];
    
    self.childAddedHandle = [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        
    }];
    
}
- (IBAction)buttonPressed:(id)sender {
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObject:[[NSMutableArray alloc]init]];
    [array[0] addObject:@"Hello"];
    Firebase *pathRef = [self.firebase childByAutoId];
    [pathRef setValue:array withCompletionBlock:^(NSError *error, Firebase *ref) {
        // The path was successfully saved and can now be removed from the outstanding paths
        NSLog(@"Finished saving to Firebase");
    }];
    
//    NSLog(@"%@", self.canvas.pathArray);
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
//    for (ACEDrawingPenTool *p in self.canvas.pathArray) {
//        CGMutablePathRef path = [p getPath];
//        NSLog(@"Path: %@", path);
//        
//        Firebase *pathRef = [self.firebase childByAutoId];
//        
//        NSString *name = pathRef.name;
//        
//        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path];
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bezierPath];
//        [dictionary setObject:data forKey:name];
//        
//        // save the path to Firebase
////        [pathRef setValue:dictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
////            // The path was successfully saved and can now be removed from the outstanding paths
////            NSLog(@"Finished saving to Firebase");
////        }];
//        
//        CGPathApply(path, nil, processPathElement);
//    }
}

void processPathElement(void* info, const CGPathElement* element) {
    
    switch (element->type) {
        case kCGPathElementMoveToPoint: {
            CGPoint point = element ->points[0];
            printf("%f %f %s\n", point.x, point.y, "moveto");
            break;
        }
        case kCGPathElementAddLineToPoint: {
            CGPoint point = element ->points[0];
            printf("%f %f %s\n", point.x, point.y, "lineto");
            break;
        }
        case kCGPathElementAddQuadCurveToPoint: {
            CGPoint point1 = element->points[0];
            CGPoint point2 = element->points[1];
            printf("%f %f %f %f %s\n", point1.x, point1.y, point2.x, point2.y, "quadcurveto");
            break;
        }
        case kCGPathElementAddCurveToPoint: {
            CGPoint point1 = element->points[0];
            CGPoint point2 = element->points[1];
            CGPoint point3 = element->points[2];
            printf("%f %f %f %f %f %f %s\n", point1.x, point1.y, point2.x, point2.y, point3.x, point3.y, "curveto");
            break;
        }
        case kCGPathElementCloseSubpath: {
            printf("closepath");
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
