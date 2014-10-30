//
//  Beacons.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 20..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beacons : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSNumber * enable;

@end
