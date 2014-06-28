//
//  VWWUtility.h
//  Imgur
//
//  Created by Zakk Hoyt on 4/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWW.h"

@import Photos;
@import CoreLocation;

@interface VWWUtility : NSObject

@end

@interface VWWUtility (NSDate)
+(NSDateComponents*)dateComponentsForNow;
@end


@interface VWWUtility (NSDictionary)
+(NSString*)stringForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary;
+(NSURL*)urlForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary;
+(NSDate*)dateForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary;
+(BOOL)boolForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary;
+(NSInteger)integerForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary;
+(NSUInteger)unsignedIntegerForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary;
+(float)floatForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary;
+(NSDictionary*)dictionaryForKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary;
+(NSArray*)arrayForKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary;
@end

@interface VWWUtility (NSString)
+(NSString*)stringFromMonth:(NSUInteger)month;
+(NSString*)stringPostfixForDay:(NSUInteger)day;
+(NSString*)stringFromAssetSource:(PHAssetSource)assetSource;
@end


@interface VWWUtility (Location)
+(void)placemarksFromLocation:(CLLocation*)location completionBlock:(VWWArrayBlock)completionBlock;
+(void)stringFromLocation:(CLLocation*)location completionBlock:(VWWStringBlock)completionBlock;
+(void)stringFromLocation2:(CLLocation*)location completionBlock:(VWWStringBlock)completionBlock;
@end