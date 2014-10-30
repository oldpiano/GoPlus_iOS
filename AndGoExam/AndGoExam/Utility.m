//
//  Utility.m
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 20..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import "Utility.h"

@implementation Utility


+ (CLBeaconRegion *) getRegionAtIndex:(int)regionIndex
{
    switch(regionIndex) {
        case 0:
            return [[CLBeaconRegion alloc] initWithProximityUUID:[[Utility getBeaconsUUIDS]objectAtIndex:0]
                                                      identifier:[NSString stringWithFormat:@"AndGo Region 1"]];

       
       default:
            return nil;
            
    }
}

+ (NSArray *) getBeaconsUUIDS
{
    static NSArray *uuids;
    if (uuids == nil) {
        
        uuids = @[[[NSUUID alloc] initWithUUIDString:@"F7A3E806-F5BB-43F8-BA87-0783669EBEB1"]];
        
    }
    return uuids;
}



@end
