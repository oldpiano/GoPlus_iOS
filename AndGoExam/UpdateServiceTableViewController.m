//
//  UpdateServiceTableViewController.m
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 21..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import "UpdateServiceTableViewController.h"
#import "UpdateScanTableViewController.h"
#import "Utility.h"
#import "BeaconDatabase.h"

@interface UpdateServiceTableViewController () <UITextFieldDelegate>

@property UIBarButtonItem *doneButton;
@property UIBarButtonItem *saveButton;
@property (strong, nonatomic) CBPeripheral *beaconPeripheral;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic)CBUUID *beaconServiceUUID;
@property (strong, nonatomic)CBUUID *majorCharacteristicUUID;
@property (strong, nonatomic)CBUUID *minorCharacteristicUUID;
@property (strong, nonatomic)CBUUID *rssiCharacteristicUUID;
@property (strong, nonatomic)CBUUID *txintervalCharacteristicUUID;
@property (strong, nonatomic)CBUUID *txpowerCharacteristicUUID;

@property (strong, nonatomic)CBCharacteristic *majorCharacteristic;
@property (strong, nonatomic)CBCharacteristic *minorCharacteristic;
@property (strong, nonatomic)CBCharacteristic *rssiCharacteristic;
@property (strong, nonatomic)CBCharacteristic *txintervalCharacteristic;
@property (strong, nonatomic)CBCharacteristic *txpowerCharacteristic;
@property (strong, nonatomic) BeaconDatabase *database;

@end

@implementation UpdateServiceTableViewController

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
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self action:@selector(doneEditing:)];
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self action:@selector(doneSaving:)];
    self.beaconPeripheral = nil;
    self.centralManager = nil;
    
    self.beaconServiceUUID = [CBUUID UUIDWithString:@"2A588020-4FB2-40F5-8204-85315DEF11C5"];
    self.majorCharacteristicUUID = [CBUUID UUIDWithString:@"2A588021-4FB2-40F5-8204-85315DEF11C5"];
    self.minorCharacteristicUUID = [CBUUID UUIDWithString:@"2A588022-4FB2-40F5-8204-85315DEF11C5"];
    self.rssiCharacteristicUUID = [CBUUID UUIDWithString:@"2A588023-4FB2-40F5-8204-85315DEF11C5"];
    self.txintervalCharacteristicUUID = [CBUUID UUIDWithString:@"2A588024-4FB2-40F5-8204-85315DEF11C5"];
    self.txpowerCharacteristicUUID = [CBUUID UUIDWithString:@"2A588025-4FB2-40F5-8204-85315DEF11C5"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"scan"]) {
        NSLog(@"prepareForSegue UpdateServiceController");
        UINavigationController *navController = segue.destinationViewController;
        UpdateScanTableViewController *scanVC = (UpdateScanTableViewController *)navController.topViewController;
        scanVC.scanDelegate = self;
    }
    else {
        self.beaconMajor = [NSNumber numberWithInt:[self.majorText.text intValue]];
        self.beaconMinor = [NSNumber numberWithInt:[self.minorText.text intValue]];
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    if ([identifier isEqualToString:@"scan"] && self.beaconPeripheral == nil) {
        return YES;
    }
    return NO;
}


#pragma mark - TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.rssiText && [self.rssiText.text intValue] > 0) {
        self.rssiText.text = [NSString stringWithFormat:@"-%@",self.rssiText.text];
    }
    if (self.beaconPeripheral) {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (IBAction)doneEditing:(id)sender
{
    NSLog(@"doneEditing");
    [self.majorText resignFirstResponder];
    [self.minorText resignFirstResponder];
    [self.rssiText resignFirstResponder];
    [self.txintervalText resignFirstResponder];
    [self.txpowerText resignFirstResponder];

}

- (IBAction)doneSaving:(id)sender
{
    NSLog(@"doneSaving");
    int major = [self.majorText.text intValue];
    int minor = [self.minorText.text intValue];
    int rssi = [self.rssiText.text intValue];
    int txpower = [self.txpowerText.text intValue];
    int txinterval = [self.txintervalText.text intValue];
    
    
    if (major > 65535 || minor > 65535) {
        [self showAlert:@"Beacon Major,Minor must be less than 65536" title:@"Error"];
        return;
    }
    
    if (rssi < -128) {
        [self showAlert:@"Beacon RSSI must be under -129" title:@"Error"];
        return;
    }
    
    if(txpower > 8)
    {
        [self showAlert:@"Beacon TxPower must be under 8" title:@"Error"];
        return;
    }
    
    if(txinterval < 70 || txpower > 2000)
    {
        
        [self showAlert:@"Beacon TxInterval must be 70 ~ 2000 microsecond" title:@"Error"];
        return;
        
    }
    
    [self saveMajor];
    [self saveMinor];
    [self saveRSSI];
    [self saveTxIntval];
    [self saveTxPower];
    
    [self showAlert:@"Beacon updated successfully!" title:@"Success"];
}

-(void)saveMajor
{
    uint16_t major = (uint16_t)[self.majorText.text intValue];
   
    uint8_t majorID[2];
    
    
    majorID[0] = ((major >> 8) & 0xFF);
    majorID[1] = (major & 0xFF);
    NSData *data = [NSData dataWithBytes:majorID length:2];
    [self.beaconPeripheral writeValue:data forCharacteristic:self.majorCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)saveMinor
{
    uint16_t minor = (uint16_t)[self.minorText.text intValue];
    
    uint8_t minorID[2];
    
    minorID[0] = ((minor >> 8) & 0xFF);
    minorID[1] = (minor & 0xFF);
    NSData *data = [NSData dataWithBytes:minorID length:2];
    [self.beaconPeripheral writeValue:data forCharacteristic:self.minorCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)saveRSSI
{
    int8_t rssi = (int8_t)[self.rssiText.text intValue];
    NSLog(@"rssi before save: %hhd",rssi);
    NSData *data = [NSData dataWithBytes:&rssi length:1];
    [self.beaconPeripheral writeValue:data forCharacteristic:self.rssiCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)saveTxIntval
{
    uint16_t txinterval = (uint16_t)[self.txintervalText.text intValue];
    
    uint8_t IntervalValue[2];
    
    
    IntervalValue[0] = ((txinterval >> 8) & 0xFF);
    IntervalValue[1] = (txinterval & 0xFF);
    NSData *data = [NSData dataWithBytes:IntervalValue length:2];
    [self.beaconPeripheral writeValue:data forCharacteristic:self.txintervalCharacteristic type:CBCharacteristicWriteWithResponse];
}


-(void)saveTxPower
{
    int8_t txpower = (int8_t)[self.txpowerText.text intValue];
    NSData *data = [NSData dataWithBytes:&txpower length:1];
    [self.beaconPeripheral writeValue:data forCharacteristic:self.txpowerCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void) showAlert:(NSString *)message title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
    [alert show];
}



#pragma mark - Scanner delegate

-(void) selectedPeripheral:(CBPeripheral *)peripheral centralManager:(CBCentralManager *)centralManager
{
    NSLog(@"selected peripheral: %@",peripheral.name);
    self.beaconPeripheral = peripheral;
    self.centralManager = centralManager;
    self.centralManager.delegate = self;
    self.beaconPeripheral.delegate = self;
    [self.centralManager connectPeripheral:self.beaconPeripheral options:nil];
}

#pragma mark - CBCentralManager delagates

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"didUpdateState");
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral %@",peripheral.name);
    [self.connectButton setTitle:@"DISCONNECT" forState:UIControlStateNormal];
    [self.beaconPeripheral discoverServices:[NSArray arrayWithObject:self.beaconServiceUUID]];
    self.navigationItem.rightBarButtonItem = self.saveButton;
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral %@",peripheral.name);
    [self.connectButton setTitle:@"CONNECT" forState:UIControlStateNormal];
    self.beaconPeripheral = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral %@",peripheral.name);
}


#pragma mark - CBPeripheral delegates

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDiscoverServices %@",peripheral.name);
    for(CBService *service in peripheral.services)
    {
        if ([service.UUID isEqual:self.beaconServiceUUID]) {
            NSLog(@"Beacon Config service found");
            [self.beaconPeripheral discoverCharacteristics:nil forService:service];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didDiscoverCharacteristics");
    if ([service.UUID isEqual:self.beaconServiceUUID]) {
        for(CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID isEqual:self.majorCharacteristicUUID]) {
                NSLog(@"Major characteristic found: %@",characteristic.UUID);
                self.majorCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
 
            else if ([characteristic.UUID isEqual:self.minorCharacteristicUUID]) {
                NSLog(@"Minor characteristic found: %@",characteristic.UUID);
                self.minorCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:self.rssiCharacteristicUUID]) {
                NSLog(@"RSSI characteristic found: %@",characteristic.UUID);
                self.rssiCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:self.txintervalCharacteristicUUID]) {
                NSLog(@"Tx Interval characteristic found: %@",characteristic.UUID);
                self.txintervalCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:self.txpowerCharacteristicUUID]) {
                NSLog(@"Tx Power characteristic found: %@",characteristic.UUID);
                self.txpowerCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }

            
            
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateValueForCharacteristic");

    if ([characteristic.UUID isEqual:self.majorCharacteristicUUID]) {
        NSString *major = [NSString stringWithFormat:@"%hu",[self decode2Byte:characteristic.value]];
        NSLog(@"Major characteristic Value: %@",major);
        self.majorText.text = major;
        
    }
    else if ([characteristic.UUID isEqual:self.minorCharacteristicUUID]) {
        NSString *minor = [NSString stringWithFormat:@"%hu",[self decode2Byte:characteristic.value]];
        NSLog(@"Minor characteristic Value: %@",minor);
        self.minorText.text = minor;
    }
    
    else if ([characteristic.UUID isEqual:self.rssiCharacteristicUUID]) {
        NSString *rssi = [NSString stringWithFormat:@"%hhd",[self decodeRSSI:characteristic.value]];
        NSLog(@"RSSI characteristic Value: %@",rssi);
        self.rssiText.text = rssi;
    }
    else if ([characteristic.UUID isEqual:self.txintervalCharacteristicUUID]) {
        NSString *txinterval = [NSString stringWithFormat:@"%hu",[self decode2Byte:characteristic.value]];
        NSLog(@"Minor characteristic Value: %@",txinterval);
        self.txintervalText.text = txinterval;
    }
    else if ([characteristic.UUID isEqual:self.txpowerCharacteristicUUID]) {
        NSString *txpower = [NSString stringWithFormat:@"%hhd",[self decodeTxPower:characteristic.value]];
        NSLog(@"RSSI characteristic Value: %@",txpower);
        self.txpowerText.text = txpower;
    }
    
    
}


-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error in writing characteristic %@",characteristic.UUID);
        [self showAlert:[error localizedDescription] title:@"Error"];
    }
    else {
        NSLog(@"success characteristic written %@",characteristic.UUID);
    }
}


#pragma mark - Connect Button action

- (IBAction)connectButtonPressed:(UIButton *)sender {
    NSLog(@"connect button pressed");
    if (self.beaconPeripheral != nil) {
        [self.centralManager cancelPeripheralConnection:self.beaconPeripheral];
    }
}

- (IBAction)AddButtonPressed:(UIBarButtonItem *)sender {
    NSLog(@"Add button pressed on Navigation bar");
    int major = [self.majorText.text intValue];
    int minor = [self.minorText.text intValue];
 
    if (major > 65535 || minor > 65535) {
        [self showAlert:@"Beacon Major,Minor must be less than 65536" title:@"Error"];
        return;
    }
    GoPlusData *newBeacon = [[GoPlusData alloc]init];
    newBeacon.name = @"GoPlus Beacon";
    newBeacon.uuid = @"F7A3E806-F5BB-43F8-BA87-0783669EBEB1";
    newBeacon.major = [NSNumber numberWithInt:major];
    newBeacon.minor = [NSNumber numberWithInt:minor];
    newBeacon.enable = [NSNumber numberWithBool:YES];
    
    self.database = [[BeaconDatabase alloc]init];
    BeaconAddStatus addStatus = [self.database addNewBeacon:newBeacon];
    if (addStatus == DUPLICATE_IN_ADD) {
        [self showAlert:@"OOPS! Another beacon with same UUID+Major+Minor combination already exist." title:@"Beacon Duplication"];
    }
    else {
        [self showAlert:@"New Beacon is successfully added!" title:@"Beacon Add"];
    }
}

#pragma mark - Beacon Decoders

-(int8_t)decodeRSSI:(NSData *)data
{
    NSLog(@"decodeRSSI");
    const uint8_t *value = [data bytes];
    return (int8_t)value[0];
}

-(int8_t)decodeTxPower:(NSData *)data
{
    NSLog(@"decodeTxPower");
    const uint8_t *value = [data bytes];
    return (uint8_t)value[0];
}


-(uint16_t)decode2Byte:(NSData *)data
{
    NSLog(@"decodeMajorMinor");
    const uint8_t *value = [data bytes];
    return CFSwapInt16BigToHost(*(uint16_t *)(&value[0]));
}


#pragma mark - Tableview delegates

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5 && indexPath.row == 7) {
        return ROW_HEIGHT_FOR_CONNECT_BUTTON;
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, tableView.bounds.size.width, 30)];
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, tableView.bounds.size.width-40, 25)];
    sectionLabel.text = @"Configure GoPlus Device";
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:15.0];
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.85 alpha:1.0];
    [headerView addSubview:sectionLabel];
    return headerView;
}





@end
