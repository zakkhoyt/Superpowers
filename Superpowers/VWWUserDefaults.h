//
//  VWWUserDefaults.h
//  Imgur
//
//  Created by Zakk Hoyt on 4/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWWUserDefaults : NSObject

@end

@interface VWWUserDefaults (Account)

+(void)setSearchTolerance:(NSUInteger)searchTolerance;
+(NSUInteger)searchTolerance;

+(void)setSearchDay:(NSUInteger)searchDay;
+(NSUInteger)searchDay;

+(void)setSearchMonth:(NSUInteger)searchMonth;
+(NSUInteger)searchMonth;

+(void)setSearchYear:(NSUInteger)searchYear;
+(NSUInteger)searchYear;
@end
