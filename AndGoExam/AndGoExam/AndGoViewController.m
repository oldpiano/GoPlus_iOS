//
//  AndGoViewController.m
//  AndGoExam
//
//  Created by Woohyuk Kwak on 2014. 8. 13..
//  Copyright (c) 2014년 IFFU.Co.,Ltd. All rights reserved.
//

#import "AndGoViewController.h"
#import "BeaconDatabase.h"
#import "Beacons.h"
#import "AndGoTableViewCell.h"
#import "ConfigTableViewController.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface AndGoViewController ()
{
    BOOL isAppInBackground;
}

@property (nonatomic, strong) NSArray *goPlusDevices;
@property (nonatomic, strong) BeaconDatabase *database;
@property (nonatomic, strong) NSUUID *goPlusUUID;
@property (strong, nonatomic) NSMutableArray *regions;
@property (strong, nonatomic) NSMutableArray *beaconsRange;
@property (strong, nonatomic) NSMutableArray *beaconsAcc;

@end

@implementation AndGoViewController

@synthesize locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewDidLoad Beacons");
    self.goplusTableView.dataSource = self;
    self.database = [[BeaconDatabase alloc]init];

    
    // New iOS 8 request for Always Authorization, required for iBeacons to work!
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
  
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    
    isAppInBackground = NO;
    
    self.regions = [[NSMutableArray alloc]initWithCapacity:[[Utility getBeaconsUUIDS] count]];
    for (int index = 0; index < [[Utility getBeaconsUUIDS] count]; index++)
    {
        [self.regions addObject:[NSNull null]];
    }
    
    [self.goplusTableView setTableFooterView:[UIView new]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear Beacons");
    
    self.goPlusDevices = [self.database readAllBeacons];
    
    [self.goplusTableView reloadData];
    self.beaconsRange = [[NSMutableArray alloc] initWithCapacity:[self.goPlusDevices count]];
    self.beaconsAcc = [[NSMutableArray alloc] initWithCapacity:[self.goPlusDevices count]];
    for (int index = 0; index < [self.goPlusDevices  count]; index++)
    {
        [self.beaconsRange addObject:[NSNull null]];
        [self.beaconsAcc addObject:[NSNull null]];
    }
    /*
     * Create Regions for each unique Beacon UUID provided in the app and these should be fixed and known
     * and assign each region unique identifier
     * if Beacon is saved with one of these provided UUIDs then register Region having that UUID
     * Unregister Region if there is not any saved or enabled Beacon found having that UUID
     */
    
    for(int regionIndex = 0; regionIndex < [[Utility getBeaconsUUIDS]count]; regionIndex++ )
    {
        BOOL isBeaconFound = NO;
        BOOL isBeaconEnable = NO;
        
        for(int beaconIndex = 0; beaconIndex < [self.goPlusDevices count]; beaconIndex++)
        {
            if ([[[[Utility getBeaconsUUIDS] objectAtIndex:regionIndex] UUIDString]
                 caseInsensitiveCompare:[[self.goPlusDevices objectAtIndex:beaconIndex]uuid]]==NSOrderedSame) {
                isBeaconFound = YES;
                if ([[[self.goPlusDevices objectAtIndex:beaconIndex]enable]boolValue]) {
                    isBeaconEnable = YES;
                }
            }
        }
        //if Beacon/Beacons Found in Region (regionIndex) and
        //atleast one Beacon is enabled in that Region then check the corresponding Region
        // if Region is not exist already then create Region and start Monitoring and Ranging
        if (isBeaconFound && isBeaconEnable) {
            NSLog(@"Atleast one Beacon is enable in Region %d with UUID %@",regionIndex, [[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            if ([[self.regions objectAtIndex:regionIndex] isEqual:[NSNull null]]) {
                NSLog(@"Creating Region %d with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
                [self.regions replaceObjectAtIndex:regionIndex withObject:[Utility getRegionAtIndex:regionIndex]];
                [locationManager startMonitoringForRegion:[self.regions objectAtIndex:regionIndex]];
                [locationManager startRangingBeaconsInRegion:[self.regions objectAtIndex:regionIndex]];
            }
            else {
                NSLog(@"Region %d already exist with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            }
            
        }
        // if NO Beacon found or No Beacon is enable in Region (regionIndex) then check the corresponding Region
        // if Region exist already then stop Monitoring and Ranging and assign nil to Region
        else {
            NSLog(@"No beacon is found or enable in Region %d with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            
            if (![[self.regions objectAtIndex:regionIndex] isEqual:[NSNull null]]) {
                NSLog(@"Region %d with UUID %@ already exist and now removing it",regionIndex, [[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
                [locationManager stopMonitoringForRegion:[self.regions objectAtIndex:regionIndex]];
                [locationManager stopRangingBeaconsInRegion:[self.regions objectAtIndex:regionIndex]];
                [self.regions replaceObjectAtIndex:regionIndex withObject:[NSNull null]];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appDidEnterBackground:(NSNotification *)_notification
{
    isAppInBackground = YES;
    NSLog(@"App is in background");
}

-(void)appDidBecomeActiveBackground:(NSNotification *)_notification
{
    isAppInBackground = NO;
    NSLog(@"App is in foreground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSections");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberofRows: %lu",(unsigned long)self.goPlusDevices.count);
    return self.goPlusDevices.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.hidden = NO;
    AndGoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoPlusCell" forIndexPath:indexPath];
    Beacons *beacon = [self.goPlusDevices objectAtIndex:indexPath.row];
    // Configure the cell...

    
    if ([beacon.enable boolValue]) {
        [cell.beaconRange setTextColor:[UIColor blackColor]];
        [cell.beaconName setTextColor:[UIColor blackColor]];
        cell.beaconName.text = [NSString stringWithFormat:@"%@",beacon.name];
         cell.beaconRange.text = [self getBeaconRange:[self.beaconsRange objectAtIndex:indexPath.row]];
        
        if( ([self.beaconsRange objectAtIndex:indexPath.row] == [NSNull null])
           || ([[self.beaconsRange objectAtIndex:indexPath.row] intValue ] >3))
        {
             cell.beaconAcc.text = @"-";
        }
        else
        {
            NSString *accString = [NSString stringWithFormat:@"%@", [self.beaconsAcc objectAtIndex:indexPath.row]];
            
            if([accString length] > 5)
                cell.beaconAcc.text = [accString substringWithRange:NSMakeRange(0, 5)];
            else
                cell.beaconAcc.text = accString;
        }
    }
    else {
        [cell.beaconName setTextColor:[UIColor lightGrayColor]];
        cell.beaconName.text = [NSString stringWithFormat:@"%@",beacon.name];
        [cell.beaconRange setTextColor:[UIColor lightGrayColor]];
        cell.beaconRange.text = @"OFF";
        [cell.beaconAcc setTextColor:[UIColor lightGrayColor]];
        cell.beaconAcc.text = @"-";

    }
    return cell;
}

-(NSString *)getBeaconRange:(NSNumber *)range
{
    if ([range isEqual:[NSNull null]]) {
        return @"N/A";
    }
    switch([range intValue]) {
        case 0:
            return @"Immediate";
        case 1:
            return @"Near";
        case 2:
            return @"Far";
        case 3:
            return @"Unknown";
        default:
            return @"Invalid Location";
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Edit"]) {
        NSIndexPath * selectionIndexPath = [self.goplusTableView indexPathForSelectedRow];
        Beacons *beacon = [self.goPlusDevices objectAtIndex:selectionIndexPath.row];
        ConfigTableViewController *configVC = [segue destinationViewController];
        configVC.selectedBeacon = beacon;
        configVC.isAddView = NO;
    }
    else if ([segue.identifier isEqualToString:@"Add"]) {
        ConfigTableViewController *configVC = [segue destinationViewController];
        configVC.isAddView = YES;
    }
}

- (NSString *) getRegionUUIDFromIdentifier:(NSString *)regionIdentifier
{
    if ([regionIdentifier isEqualToString:@"AndGo Region 1"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:0]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"AndGo Region 2"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:1]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"AndGo Region 3"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:2]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"AndGo Region 4"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:3]UUIDString];
    }
    return nil;
}



#pragma mark - CLLocationManager delegates

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
    NSLog(@"didEnterRegion");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
    NSLog(@"didExitRegion");
}


- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    
      NSLog(@"didStartMonitoringForRegion");
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    
    NSLog(@"rangingBeaconsDidFailForRegion");
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    
     NSLog(@"monitoringDidFailForRegion");
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLRegion *)region
{
    
    NSLog(@"didRangeBeacons");
    if ([beacons count] > 0) {
        NSLog(@"beacons founds: %lu",(unsigned long)[beacons count]);
        CLBeacon *beacon = [beacons objectAtIndex:0];
        
        NSLog(@"Beacons UUID: %@",beacon.proximityUUID);
        NSLog(@"Beacons Major: %@",beacon.major);
        NSLog(@"Beacons Minor: %@",beacon.minor);
        
        for(int i = 0; i < [beacons count]; i++) //scanned beacons in Ranging
        {
            for(int j=0; j<[self.goPlusDevices count]; j++) //stored beacons in database
            {
                if (([[[beacons[i] proximityUUID] UUIDString] caseInsensitiveCompare:[self.goPlusDevices[j] uuid]]==NSOrderedSame) &&
                    ([[beacons[i] major] unsignedShortValue] == [[self.goPlusDevices[j] major] unsignedShortValue]) &&
                    ([[beacons[i] minor] unsignedShortValue] == [[self.goPlusDevices[j] minor] unsignedShortValue]) &&
                    ([[self.goPlusDevices[j] enable]boolValue]))
                {
                    NSLog(@"Found Beacon and enabled");
                    NSLog(@"Beacon UUID: %@",[beacons[i] proximityUUID]);
                    NSLog(@"Beacon Major: %@",[beacons[i] major]);
                    NSLog(@"Beacon Minor: %@",[beacons[i] minor]);

                    //Finding Scanned Beacon Proximity and converting it to the Event of stored Beacon
                    if ([beacons[i] proximity] == CLProximityImmediate) {
                        NSLog(@"Immidiate Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:IMMIDIATE]];
                        [self.beaconsAcc replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:[beacons[i] accuracy]]];
                         
                        [self.goplusTableView reloadData];
    
                    }
                    else if ([beacons[i] proximity] == CLProximityNear) {
                        NSLog(@"Near Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:NEAR]];
                        [self.beaconsAcc replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:[beacons[i] accuracy]]];
                        NSLog(@"Near Accuracy : %@",[NSNumber numberWithDouble:[beacons[i] accuracy]]);
                        [self.goplusTableView reloadData];
                        
                    }
                    else if ([beacons[i] proximity] == CLProximityFar) {
                        NSLog(@"Far Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:FAR]];
                        [self.beaconsAcc replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:[beacons[i] accuracy]]];

                        [self.goplusTableView reloadData];
                    }
                    else if ([beacons[i] proximity] == CLProximityUnknown) {
                        NSLog(@"Unknown Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:UNKNOWN]];
                        [self.beaconsAcc replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:[beacons[i] accuracy]]];

                        [self.goplusTableView reloadData];
                        
                    }
                    
                    
                    
                }
            }
        }
        
    }
    else {
        NSLog(@"No beacon found!");
    }
    
}

@end
