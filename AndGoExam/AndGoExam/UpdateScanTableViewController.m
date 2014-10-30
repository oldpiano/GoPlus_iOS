//
//  UpdateScanTableViewController.m
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 21..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import "UpdateScanTableViewController.h"

@interface UpdateScanTableViewController ()

@property (strong, nonatomic)NSMutableArray *beaconPeripherals;
@property (strong, nonatomic)NSArray *beacons;
@property (strong, nonatomic)CBUUID *beaconServiceUUID;
@property (strong,nonatomic)CBCentralManager *bluetoothManager;
@end

@implementation UpdateScanTableViewController

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
    
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.beaconPeripherals = [[NSMutableArray alloc]init];
    self.beacons = [[NSArray alloc]init];
    self.beaconServiceUUID = [CBUUID UUIDWithString:@"2A588020-4FB2-40F5-8204-85315DEF11C5"];
    
    
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

    return [self.beacons count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scanCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.beacons objectAtIndex:indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row selected");
    [self.bluetoothManager stopScan];
    [self.scanDelegate selectedPeripheral:[self.beacons objectAtIndex:indexPath.row] centralManager:self.bluetoothManager];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelBarButtonPressed:(UIBarButtonItem *)sender {
    NSLog(@"Cancel bar button pressed");
    [self.bluetoothManager stopScan];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState");
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [self.bluetoothManager scanForPeripheralsWithServices:[NSArray arrayWithObject:self.beaconServiceUUID] options:nil];
    }
    else
    {
        return;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"didDiscoverPeripheral %@",peripheral.name);
    [self.beaconPeripherals addObject:peripheral];
    self.beacons = [NSArray arrayWithArray:self.beaconPeripherals];
    [self.tableView reloadData];
}

@end
