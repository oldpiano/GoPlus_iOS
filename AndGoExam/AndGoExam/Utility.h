//
//  Utility.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 20..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Utility : NSObject
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define ROW_HEIGHT_FOR_CONNECT_BUTTON 160;

+ (NSArray *)getBeaconsUUIDS;

+ (CLBeaconRegion *) getRegionAtIndex:(int)regionIndex;

extern NSString* const EventImmidiate;
extern NSString* const EventNear;
extern NSString* const EventExit;
extern NSString* const EventEnter;


typedef enum {
    DUPLICATE_IN_UPDATE,
    UPDATED_SUCCESSFULLY,
    ERROR_IN_UPDATE,
    BEACON_NOT_FOUND_IN_UPDATE,
    
}BeaconUpdateStatus;

typedef enum {
    DUPLICATE_IN_ADD,
    ADDED_SUCCESSFULLY,
    ERROR_IN_ADD,
    
}BeaconAddStatus;

typedef enum {
    DELETED_SUCCESSFULLY,
    ERROR_IN_DELETE,
    
}BeaconDeleteStatus;

typedef enum {
    IMMIDIATE,
    NEAR,
    FAR,
    UNKNOWN,
    NO_BEACON_FOUND,
}BeaconRangeStatus;



@end
