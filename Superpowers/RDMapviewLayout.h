//
//  RDMapviewLayout.h
//  CollectionViewLayouts
//
//  Created by Zakk Hoyt on 6/17/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VWW.h"
@import MapKit;

@class RDMapviewLayout;

@protocol RDMapviewLayoutCoordinateDelegate <NSObject>
-(CLLocationCoordinate2D)mapviewLayoutCoodinateForIndexPath:(NSIndexPath*)indexPath;
-(CLLocationCoordinate2D)mapviewLayoutCoodinateForSection:(NSUInteger)section;
@end


@interface RDMapviewLayout : UICollectionViewLayout
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic, weak) id <RDMapviewLayoutCoordinateDelegate> coorinateDelegate;
-(void)showAssetsForClusters:(NSIndexSet*)indexSet;
-(void)isPointWithinBounds:(CGPoint)point completionBlock:(VWWBoolPointBlock)completionBlock;

@end
