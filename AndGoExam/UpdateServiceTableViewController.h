//
//  UpdateServiceTableViewController.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 21..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateScanTableViewController.h"

@interface UpdateServiceTableViewController : UITableViewController <scanPeripheral, CBCentralManagerDelegate, CBPeripheralDelegate>


@property (weak, nonatomic) IBOutlet UITextField *majorText;
@property (weak, nonatomic) IBOutlet UITextField *minorText;
@property (weak, nonatomic) IBOutlet UITextField *rssiText;
@property (weak, nonatomic) IBOutlet UITextField *txintervalText;
@property (weak, nonatomic) IBOutlet UITextField *txpowerText;
@property (weak, nonatomic) IBOutlet UITextField *uuidText;


@property (strong, nonatomic) NSNumber *beaconMajor;
@property (strong, nonatomic) NSNumber *beaconMinor;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
- (IBAction)connectButtonPressed:(UIButton *)sender;
- (IBAction)AddButtonPressed:(UIBarButtonItem *)sender;


@end
