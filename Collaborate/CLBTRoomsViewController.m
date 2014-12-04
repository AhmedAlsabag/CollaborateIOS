//
//  CLBTRoomsViewController.m
//  Collaborate
//
//  Created by Andrew Chun on 12/3/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "CLBTRoomsViewController.h"
#import <Firebase/Firebase.h>
#import "CLBTCanvasViewController.h"

@interface CLBTRoomsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) Firebase *firebase;
@property (assign, nonatomic) __block NSInteger numRooms;
@property (strong, nonatomic) __block NSMutableArray *roomNames;
@property (strong, nonatomic) __block NSDictionary *firebaseInfo;
@property (assign, nonatomic) BOOL firstTime;

@end

@implementation CLBTRoomsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.firstTime) {
        self.numRooms = 0;
        
        self.firebase = [[Firebase alloc]initWithUrl:@"https://collaborateios.firebaseio.com/"];
        
        [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            if (![snapshot.value isKindOfClass:[NSNull class]]) {
                self.firebaseInfo = snapshot.value;
                self.numRooms = [snapshot.value[@"Rooms"] count];
            } else {
                self.firebaseInfo = [[NSMutableDictionary alloc]init];
            }
            
            self.roomNames = [[NSMutableArray alloc]init];
            
            for (NSInteger i = 0; i < self.numRooms; i++) {
                [self.roomNames addObject:[NSString stringWithFormat:@"Room: %ld", i + 1]];
            }
            
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }];
        
        [((UINavigationController *)[self parentViewController]) setNavigationBarHidden:NO animated:YES];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.firstTime = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [((UINavigationController *)[self parentViewController]) setNavigationBarHidden:YES animated:YES];
}

- (IBAction)addRoom:(id)sender {
    
    self.numRooms++;
    
    [self.roomNames addObject:[NSString stringWithFormat:@"Room: %ld", self.numRooms]];
    [self.tableView reloadData];
    
    NSLog(@"FirebaseInfo: %@", self.firebaseInfo);
    
    if (self.firebaseInfo[@"Rooms"]) {
        self.firebaseInfo[@"Rooms"][[NSString stringWithFormat:@"Room: %ld", self.numRooms]] = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"Nothing", @"Nothing", nil];
    } else {
        [self.firebaseInfo setValue:[[NSMutableDictionary alloc]init] forKey:@"Rooms"];
        
        [((NSMutableDictionary *)self.firebaseInfo[@"Rooms"]) setObject:[[NSMutableDictionary alloc]init] forKey:@"Room: 1"];
        [((NSMutableDictionary *)self.firebaseInfo[@"Rooms"])[@"Room: 1"] setObject:@"Nothing" forKey:@"Nothing"];
    }
    
    [self.firebase setValue:self.firebaseInfo withCompletionBlock:^(NSError *error, Firebase *ref) {
        NSLog(@"Added a room to Firebase!");
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numRooms;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomCell"];
    
    cell.textLabel.text = self.roomNames[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    
    CLBTCanvasViewController *canvasViewController = (CLBTCanvasViewController *)segue.destinationViewController;
    
    canvasViewController.roomNumber = [[cell.textLabel.text componentsSeparatedByString:@" "][1] integerValue];
}

@end
