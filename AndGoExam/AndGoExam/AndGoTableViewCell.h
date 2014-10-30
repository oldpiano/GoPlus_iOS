//
//  AndGoTableViewCell.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 20..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AndGoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *beaconName;
@property (weak, nonatomic) IBOutlet UILabel *beaconRange;
@property (weak, nonatomic) IBOutlet UILabel *beaconAcc;

@end
