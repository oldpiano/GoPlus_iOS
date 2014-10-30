//
//  ConfigTableViewController.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 20..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoPlusData.h"
#import "Beacons.h"

@interface ConfigTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UITextField *majorText;
@property (weak, nonatomic) IBOutlet UITextField *minorText;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;


@property(strong, nonatomic) Beacons *selectedBeacon;
@property(strong, nonatomic) GoPlusData *existingBeacon;
@property(nonatomic) BOOL isAddView;


@end
