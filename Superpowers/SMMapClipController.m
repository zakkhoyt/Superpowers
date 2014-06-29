//
//  SMMapClipController.m
//  Radius-iOS
//
//  Created by Zakk Hoyt on 4/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "SMMapClipController.h"
#import <MapKit/MapKit.h>



@interface SMMapClipController ()
@property (nonatomic, strong) NSMutableDictionary *mapStore;
@end
@implementation SMMapClipController


+(SMMapClipController*)sharedInstance{
    static SMMapClipController *instance;
    if(instance == nil){
        instance = [[SMMapClipController alloc]init];
    };
    return instance;
}


-(id)init{
    self = [super init];
    if(self){
        _mapStore = [@{}mutableCopy];
    }
    return self;
}


// Create a key from lat,long,width,height. Lat and lon are clipped to 4 decimal places
-(NSString*)keyFromCoordinate:(CLLocationCoordinate2D)coordinate size:(CGSize)size{
    NSString *latitudeString = [NSString stringWithFormat:@"%.4f", coordinate.latitude];
    NSString *longitudeString = [NSString stringWithFormat:@"%.4f", coordinate.longitude];
    NSString *sizeString = [NSString stringWithFormat:@"%ld,%ld", (long)size.width, (long)size.height];
    NSString *keyString = [NSString stringWithFormat:@"%@,%@,%@", latitudeString, longitudeString, sizeString];
    return keyString;
}



#pragma mark Public methods
-(void)clearCache{
    [self.mapStore removeAllObjects];
}

-(void)loadMapSnapshotAtCoordinate:(CLLocationCoordinate2D)coordinate size:(CGSize)size type:(MKMapType)type completionBlock:(VWWUIImageBlock)completionBlock{
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    
    NSString *keyString = [self keyFromCoordinate:coordinate size:size];
    MKMapSnapshot *cachedSnapshot = self.mapStore[keyString];
    if(cachedSnapshot){
        return completionBlock(cachedSnapshot.image);
    }
    
    if(type == 0){
        options.mapType = MKMapTypeStandard;
    } else if(type == 1){
        options.mapType = MKMapTypeSatellite;
    } else if(type == 2){
        options.mapType = MKMapTypeHybrid;
    }

    options.scale = [[UIScreen mainScreen] scale];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    CLLocationCoordinate2D coordinate2d = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate2d, span);
    
    options.region = region;
    options.size = size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler: ^(MKMapSnapshot *snapshot, NSError *error) {
        if (!error) {
            // Insert in store
            if(snapshot.image){
                self.mapStore[keyString] = snapshot;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(snapshot.image);
            });
        } else {
            VWW_LOG_ERROR(@"Error getting map snapshot");
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil);
            });
            
        }
    }];
}


-(UIImage*)renderImage:(UIImage*)smallImage onImage:(UIImage*)mainImage atRect:(CGRect)rect{


    // create a new bitmap image context at the device resolution (retina/non-retina)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(mainImage.size.width, mainImage.size.height), YES, 0.0);
    
    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // push context to make it current
    // (need to do this manually because we are not drawing in a UIView)
    UIGraphicsPushContext(context);
    
    // drawing code comes here- look at CGContext reference
    // for available operations
    // this example draws the inputImage into the context
    [mainImage drawInRect:CGRectMake(0, 0, mainImage.size.width, mainImage.size.height)];
    [smallImage drawInRect:rect];
    
    // pop context
    UIGraphicsPopContext();
    
    // get a UIImage from the image context- enjoy!!!
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    return outputImage;
}

-(UIImage*)renderView:(UIView*)view onImage:(UIImage*)mainImage{
    
    
    // create a new bitmap image context at the device resolution (retina/non-retina)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(mainImage.size.width, mainImage.size.height), YES, 0.0);

    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // push context to make it current
    // (need to do this manually because we are not drawing in a UIView)
    UIGraphicsPushContext(context);
    
    // drawing code comes here- look at CGContext reference
    // for available operations
    // this example draws the inputImage into the context
    [mainImage drawInRect:CGRectMake(0, 0, mainImage.size.width, mainImage.size.height)];
    [view.layer renderInContext:context];
    
    // pop context
    UIGraphicsPopContext();
    
    // get a UIImage from the image context- enjoy!!!
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    return outputImage;
}


-(UIImage *)resizeImage:(UIImage *)image size:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
