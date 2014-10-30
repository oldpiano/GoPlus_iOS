//
//  BeaconDatabase.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 20..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoPlusData.h"
#import "Beacons.h"
#import "Utility.h"


@interface BeaconDatabase : NSObject


- (BeaconUpdateStatus) updateBeacon:(Beacons *)beacon;
- (NSArray *) readAllBeacons;
- (void) deleteBeacon:(Beacons *)beacon;
- (BeaconAddStatus) addNewBeacon:(GoPlusData *)beacon;

@end
