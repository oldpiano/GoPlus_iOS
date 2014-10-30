//
//  AndGoAppDelegate.h
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 13..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AndGoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
