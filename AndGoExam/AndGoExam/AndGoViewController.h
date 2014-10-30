//
//  AndGoViewController.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 13..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AndGoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *goplusTableView;

@end
