//
//  VWWLocationController.h
//  SwiftObjC
//
//  Created by Zakk Hoyt on 6/6/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "VWW.h"

@interface VWWLocationController : NSObject
+ (instancetype)sharedInstance;

-(void)promptForPermission;
-(void)start;
-(void)stop;

-(void)setChangeSettingsBlock:(VWWEmptyBlock)changeSettingsBlock;
-(void)setAccessAllowedBlock:(VWWEmptyBlock)accessAllowedBlock;
-(BOOL)verifyCoreLocationAccess;
@end
