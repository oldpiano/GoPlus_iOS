//
//  UpdateScanTableViewController.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 21..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol scanPeripheral <NSObject>
-(void) selectedPeripheral:(CBPeripheral *)peripheral centralManager:(CBCentralManager *)centralManager;
@end

@interface UpdateScanTableViewController : UITableViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

- (IBAction)cancelBarButtonPressed:(UIBarButtonItem *)sender;
@property (retain)id <scanPeripheral> scanDelegate;



@end
