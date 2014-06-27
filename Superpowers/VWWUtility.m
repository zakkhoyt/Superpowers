//
//  VWWUtility.m
//  Imgur
//
//  Created by Zakk Hoyt on 4/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWUtility.h"


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
