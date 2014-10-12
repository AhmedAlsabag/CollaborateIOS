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

@property (strong, nonatomic) UIButton              *syncButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.canvas = [[ACEDrawingView alloc]initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) * 0.95 - (CGRectGetHeight(self.view.bounds) * 0.05))];
    self.canvas.lineWidth = 2.00;
    
    [self.view addSubview:self.canvas];
    
    self.firebase = [[Firebase alloc]initWithUrl:@"https://collaborateios.firebaseio.com/"];
    
    self.syncButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.syncButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) * 0.10);
    self.syncButton.center = CGPointMake(CGRectGetWidth(self.view.bounds) * 0.50, CGRectGetHeight(self.view.bounds) * 0.95);
//    self.syncButton.backgroundColor = [UIColor blackColor];
    [self.syncButton setTitle:@"Sync to Firebase" forState:UIControlStateNormal];
    [self.syncButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.syncButton];
    
    self.roomNumber = 1;
    
    self.childAddedHandle = [self.firebase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        //Insert Core Graphics decoder and renderer here
        NSLog(@"==========Decoding==========");
        NSDictionary *paths = (NSDictionary *)snapshot.value;
        NSLog(@"%@", snapshot.name);
        
        NSArray *setMembers = [self.pathSet allObjects];
        for (NSString *pathName in setMembers) {
            NSString *path = [paths objectForKey:pathName];
            NSLog(@"%@: %@", pathName, path);
        }
    }];
    
}
- (void)buttonPressed:(id)sender {
    
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
