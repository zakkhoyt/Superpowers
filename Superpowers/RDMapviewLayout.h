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
-(CGSize)mapviewLayout:(RDMapviewLayout*)sender sizeIndexPath:(NSIndexPath*)indexPath;
-(CLLocationCoordinate2D)mapviewLayout:(RDMapviewLayout*)sender coodinateForIndexPath:(NSIndexPath*)indexPath;
-(CLLocationCoordinate2D)mapviewLayout:(RDMapviewLayout*)sender coodinateForSection:(NSUInteger)section;
-(void)mapviewLayout:(RDMapviewLayout*)sender withinLayout:(BOOL)withinLayout forIndexPath:(NSIndexPath*)indexPath;
@end

@interface RDMapviewLayout : UICollectionViewLayout

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic, weak) id <RDMapviewLayoutCoordinateDelegate> coorinateDelegate;

// TODO below heres
@property (nonatomic) BOOL keepAnnotationsOnMap;
-(void)isPointWithinBounds:(CGPoint)point
           completionBlock:(VWWBoolPointBlock)completionBlock;

@end

