//
//  VWWUtility.m
//  Imgur
//
//  Created by Zakk Hoyt on 4/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWUtility.h"

@import CoreLocation;

@interface VWWUtility  () {
    NSDateFormatter *internetDateFormatter;
}
@end


@implementation VWWUtility (NSDate)

+(NSDateComponents*)dateComponentsForNow{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
}

@end

@implementation VWWUtility

+(VWWUtility*)sharedUtility{
    static dispatch_once_t onceToken;
    static VWWUtility *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VWWUtility alloc] init];
    });
    return sharedInstance;
}
-(id)init{
    self = [super init];
    if (self) {
        // Date formatter setup
        internetDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [internetDateFormatter setLocale:enUSPOSIXLocale];
        [internetDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
        
        
        
        
        [internetDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return self;
}

- (NSString *)stringFromDate:(NSDate *)date usingFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

- (NSDate *)internetFormattedDateFromString:(NSString *)dateString {
    @synchronized(internetDateFormatter) {
        return [internetDateFormatter dateFromString:dateString];
    }
}

@end

@implementation VWWUtility (NSDictionary)

+(NSString*)stringForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    if([value isKindOfClass:[NSString class]]){
        NSString *rString = value;
        if ([rString rangeOfString:@"null"].location != NSNotFound) {
            return @"";
        }
        return rString;
    }
    else{
        return nil;
    }
    
}

+(NSURL*)urlForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    return [value isKindOfClass:[NSString class]] ? [NSURL URLWithString:value] : nil;
}

+(NSDate*)dateForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    if([value isKindOfClass:[NSString class]]){
        NSDate *date = [[VWWUtility sharedUtility] internetFormattedDateFromString:value];
        return date;
    }
    else{
        return nil;
    }
}

+(BOOL)boolForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    return [value isKindOfClass:[NSNumber class]] ? [value boolValue] : NO;
}

+(NSInteger)integerForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    return [value isKindOfClass:[NSNumber class]] ? [value integerValue] : 0;
}

+(NSUInteger)unsignedIntegerForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    return [value isKindOfClass:[NSNumber class]] ? [value unsignedIntegerValue] : 0;
}

+(float)floatForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    return [value isKindOfClass:[NSNumber class]] ? [value floatValue] : 0.0f;
}
+(NSDictionary*)dictionaryForKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
    
}
+(NSArray*)arrayForKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary{
    id value = dictionary[key];
    return [value isKindOfClass:[NSArray class]] ? value : nil;
    
}


@end


@implementation VWWUtility (NSString)
+(NSString*)stringFromMonth:(NSUInteger)month{
    if(month == 1){
        return @"January";
    } else if(month == 2){
        return @"February";
    } else if(month == 3){
        return @"March";
    } else if(month == 4){
        return @"April";
    } else if(month == 5){
        return @"May";
    } else if(month == 6){
        return @"June";
    } else if(month == 7){
        return @"July";
    } else if(month == 8){
        return @"August";
    } else if(month == 9){
        return @"September";
    } else if(month == 10){
        return @"October";
    } else if(month == 11){
        return @"November";
    } else if(month == 12){
        return @"December";
    }
    return [NSString stringWithFormat:@"Error: %lu", (unsigned long)month];
}

+(NSString*)stringPostfixForDay:(NSUInteger)day{
    if(day % 10 == 0){
        return @"th";
    } else if(day % 10 == 1){
        return @"st";
    } else if(day % 10 == 2){
        return @"nd";
    } else if(day % 10 == 3){
        return @"rd";
    } else if(day % 10 == 4){
        return @"th";
    } else if(day % 10 == 5){
        return @"th";
    } else if(day % 10 == 6){
        return @"th";
    } else if(day % 10 == 7){
        return @"th";
    } else if(day % 10 == 8){
        return @"th";
    } else if(day % 10 == 9){
        return @"th";
    }
    return [NSString stringWithFormat:@"Error: %lu", (unsigned long)day];
}



+(NSString*)stringFromAssetSource:(PHAssetSource)assetSource{
    switch (assetSource) {
        case PHAssetSourceUnknown:
            return @"?";
            break;
        case PHAssetSourcePhotoBooth:
            return @"photoBooth";
            break;
        case PHAssetSourcePhotoStream:
            return @"photoStream";
            break;
        case PHAssetSourceCamera:
            return @"camera";
            break;
        case PHAssetSourceCloudShared:
            return @"cloudShared";
            break;
        case PHAssetSourceCameraConnectionKit:
            return @"camConnKit";
            break;
        case PHAssetSourceCloudPhotoLibrary:
            return @"cloudPhotoLib";
            break;
        case PHAssetSourceiTunesSync:
            return @"iTunes";
            break;
        default:
            break;
    }
}
@end



@implementation VWWUtility (Location)

+(void)placemarksFromLocation:(CLLocation*)location completionBlock:(VWWArrayBlock)completionBlock{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if(placemarks.count){
                           completionBlock(placemarks);
                       }
                   }];
}


+(void)stringFromLocation:(CLLocation*)location completionBlock:(VWWStringBlock)completionBlock{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if(placemarks.count){
                           CLPlacemark *placemark = placemarks[0];
                           if(placemark.name)
                               return completionBlock(placemark.name);
                           if(placemark.thoroughfare)
                               return completionBlock(placemark.thoroughfare);
                           if(placemark.subThoroughfare)
                               return completionBlock(placemark.subThoroughfare);
                           if(placemark.locality)
                               return completionBlock(placemark.locality);
                           if(placemark.subLocality)
                               return completionBlock(placemark.subLocality);
                           if(placemark.administrativeArea)
                               return completionBlock(placemark.administrativeArea);
                           if(placemark.subAdministrativeArea)
                               return completionBlock(placemark.subAdministrativeArea);
                           if(placemark.postalCode)
                               return completionBlock(placemark.postalCode);
                           if(placemark.ISOcountryCode)
                               return completionBlock(placemark.ISOcountryCode);
                           if(placemark.country)
                               return completionBlock(placemark.country);
                           if(placemark.inlandWater)
                               return completionBlock(placemark.inlandWater);
                           if(placemark.ocean)
                               return completionBlock(placemark.ocean);
                           if(placemark.areasOfInterest.count){
                               return completionBlock(placemark.areasOfInterest[0]);
                           }
                       }
                   }];
}


+(void)stringFromLocation2:(CLLocation*)location completionBlock:(VWWStringBlock)completionBlock{
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if(placemarks.count){
                           CLPlacemark *placemark = placemarks[0];
                           if(placemark.locality)
                               return completionBlock(placemark.locality);
                           if(placemark.subAdministrativeArea)
                               return completionBlock(placemark.subAdministrativeArea);
                           if(placemark.name)
                               return completionBlock(placemark.name);
                           if(placemark.thoroughfare)
                               return completionBlock(placemark.thoroughfare);
                           if(placemark.subThoroughfare)
                               return completionBlock(placemark.subThoroughfare);
                           if(placemark.subLocality)
                               return completionBlock(placemark.subLocality);
                           if(placemark.administrativeArea)
                               return completionBlock(placemark.administrativeArea);
                           if(placemark.postalCode)
                               return completionBlock(placemark.postalCode);
                           if(placemark.ISOcountryCode)
                               return completionBlock(placemark.ISOcountryCode);
                           if(placemark.country)
                               return completionBlock(placemark.country);
                           if(placemark.inlandWater)
                               return completionBlock(placemark.inlandWater);
                           if(placemark.ocean)
                               return completionBlock(placemark.ocean);
                           if(placemark.areasOfInterest.count){
                               return completionBlock(placemark.areasOfInterest[0]);
                           }
                       }
                   }];
}
@end
