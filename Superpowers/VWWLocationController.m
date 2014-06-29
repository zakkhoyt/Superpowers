//
//  VWWLocationController.m
//  SwiftObjC
//
//  Created by Zakk Hoyt on 6/6/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLocationController.h"

@interface VWWLocationController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) VWWEmptyBlock changeSettingsBlock;
@property (nonatomic, strong) VWWEmptyBlock accessAllowedBlock;
@end

@implementation VWWLocationController

+ (instancetype)sharedInstance{
    static VWWLocationController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VWWLocationController alloc]init];
    });
    return instance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _locations = [[NSMutableArray alloc]init];
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        
    }
    return self;
}


-(void)setChangeSettingsBlock:(VWWEmptyBlock)changeSettingsBlock{
    _changeSettingsBlock = [changeSettingsBlock copy];
}

-(void)setAccessAllowedBlock:(VWWEmptyBlock)accessAllowedBlock{
    _accessAllowedBlock = [accessAllowedBlock copy];
}
-(BOOL)verifyCoreLocationAccess{
    typedef enum {
        VWWCLStateUnknown = 0,
        VWWCLStateInitialPrompt,
        VWWCLStateUserNeedsToTakeAction,
        VWWCLStateOkay,
    } VWWCLState;
    
    VWWCLState state = VWWCLStateUnknown;
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        VWW_LOG_INFO(@"CoreLocation authorization state not determined");
        state = VWWCLStateInitialPrompt;
    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        VWW_LOG_INFO(@"CoreLocation authorization state denied or restricted");
        state = VWWCLStateUserNeedsToTakeAction;
    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        VWW_LOG_INFO(@"CoreLocation authorization state denied or denied");
        state = VWWCLStateUserNeedsToTakeAction;
    }/* else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized){
        VWW_LOG_INFO(@"CoreLocation authorization is authorized");
        state = VWWCLStateOkay;
    }*/ else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways){
        VWW_LOG_INFO(@"CoreLocation authorization is authorized always");
        state = VWWCLStateOkay;
    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        VWW_LOG_INFO(@"CoreLocation authorization is authorized when in use");
        state = VWWCLStateUserNeedsToTakeAction;
    }
    
    switch (state) {
        case VWWCLStateOkay:
            [self start];
            return YES;
            break;
        case VWWCLStateInitialPrompt:
            [self promptForPermission];
            return NO;
            break;
        case VWWCLStateUnknown:
        case VWWCLStateUserNeedsToTakeAction:
        default:{
            if(self.changeSettingsBlock){
                self.changeSettingsBlock();
            }
            return NO;
        }
            break;
    }
}



-(void)promptForPermission{
    [_locationManager requestAlwaysAuthorization];
//    [_locationManager requestWhenInUseAuthorization];
}
-(void)start{
    [_locationManager startUpdatingLocation];
}
-(void)stop{
    [_locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    VWW_LOG_TRACE;
    [self.locations addObjectsFromArray:locations];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    VWW_LOG_INFO(@"authorization status changed");
    if(status == kCLAuthorizationStatusAuthorizedAlways ||
       status == kCLAuthorizationStatusAuthorizedWhenInUse){
        if(self.accessAllowedBlock){
            self.accessAllowedBlock();
        }
    }

    [self start];
}



@end
