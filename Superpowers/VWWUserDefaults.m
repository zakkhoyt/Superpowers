//
//  VWWUserDefaults.m
//  Imgur
//
//  Created by Zakk Hoyt on 4/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWUserDefaults.h"
#import "VWWUtility.h"

static NSString *VWWUserDefaultsSearchToleranceKey = @"searchTolerance";
static NSString *VWWUserDefaultsSearchDayKey = @"searchDay";
static NSString *VWWUserDefaultsSearchMonthKey = @"searchMonth";
static NSString *VWWUserDefaultsSearchYearKey = @"searchYear";

@implementation VWWUserDefaults

@end

@implementation VWWUserDefaults (Account)

#pragma mark Public methods
+(void)setSearchTolerance:(NSUInteger)searchTolerance{
    [[NSUserDefaults standardUserDefaults] setObject:@(searchTolerance) forKey:VWWUserDefaultsSearchToleranceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSUInteger)searchTolerance{
    NSNumber *searchToleranceNumber = [[NSUserDefaults standardUserDefaults] objectForKey:VWWUserDefaultsSearchToleranceKey];
    if(searchToleranceNumber == nil){
        return 30;
    }
    return searchToleranceNumber.unsignedIntegerValue;
}


+(void)setSearchDay:(NSUInteger)searchDay{
    [[NSUserDefaults standardUserDefaults] setObject:@(searchDay) forKey:VWWUserDefaultsSearchDayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSUInteger)searchDay{
    NSNumber *searchDayNumber = [[NSUserDefaults standardUserDefaults] objectForKey:VWWUserDefaultsSearchDayKey];
    if(searchDayNumber == nil){
        NSDateComponents *components = [VWWUtility dateComponentsForNow];
        return components.day;
    }
    return searchDayNumber.unsignedIntegerValue;
}

+(void)setSearchMonth:(NSUInteger)searchMonth{
    [[NSUserDefaults standardUserDefaults] setObject:@(searchMonth) forKey:VWWUserDefaultsSearchMonthKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSUInteger)searchMonth{
    NSNumber *searchMonthNumber = [[NSUserDefaults standardUserDefaults] objectForKey:VWWUserDefaultsSearchMonthKey];
    if(searchMonthNumber == nil){
        NSDateComponents *components = [VWWUtility dateComponentsForNow];
        return components.month;
    }
    return searchMonthNumber.unsignedIntegerValue;
}

+(void)setSearchYear:(NSUInteger)searchYear{
    [[NSUserDefaults standardUserDefaults] setObject:@(searchYear) forKey:VWWUserDefaultsSearchYearKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSUInteger)searchYear{
    NSNumber *searchYearNumber = [[NSUserDefaults standardUserDefaults] objectForKey:VWWUserDefaultsSearchYearKey];
    if(searchYearNumber == nil){
        NSDateComponents *components = [VWWUtility dateComponentsForNow];
        return components.year;
    }
    return searchYearNumber.unsignedIntegerValue;
}


#pragma mark Private methods





@end
