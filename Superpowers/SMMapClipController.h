//
//  SMMapClipController.h
//  Radius-iOS
//
//  Created by Zakk Hoyt on 4/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

@import UIKit;
@import MapKit;
@import CoreLocation;
#import "VWW.h"

@interface SMMapClipController : NSObject
+(SMMapClipController*)sharedInstance;
-(void)loadMapSnapshotAtCoordinate:(CLLocationCoordinate2D)coordinate size:(CGSize)size type:(MKMapType)type completionBlock:(VWWUIImageBlock)completionBlock;
-(void)clearCache;
-(UIImage*)renderImage:(UIImage*)smallImage onImage:(UIImage*)mainImage atRect:(CGRect)rect;
-(UIImage*)resizeImage:(UIImage *)image size:(CGSize)newSize;
@end
