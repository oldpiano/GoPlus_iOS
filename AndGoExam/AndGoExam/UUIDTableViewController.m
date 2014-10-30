//
//  UUIDTableViewController.m
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 20..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import "UUIDTableViewController.h"
#import "ConfigTableViewController.h"
#import "Utility.h"


@interface UUIDTableViewController ()

@end

@implementation UUIDTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[Utility getBeaconsUUIDS] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UuidCell" forIndexPath:indexPath];
    
    
    // Configure the cell...
    if ([[[Utility getBeaconsUUIDS] objectAtIndex:indexPath.row] isEqual:self.chosenUUID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.textLabel.text = [[[Utility getBeaconsUUIDS] objectAtIndex:indexPath.row] UUIDString];
    
    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath * selectionIndexPath = [self.tableView indexPathForSelectedRow];
    NSUUID *uuid = [[Utility getBeaconsUUIDS] objectAtIndex:selectionIndexPath.row];
    self.chosenUUID = uuid;


}



@end
