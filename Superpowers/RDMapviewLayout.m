//
//  RDMapviewLayout.m
//  CollectionViewLayouts
//
//  Created by Zakk Hoyt on 6/17/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//
//  Apple documents: https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS/CreatingCustomLayouts/CreatingCustomLayouts.html
//  Tutorial http://skeuo.com/uicollectionview-custom-layout-tutorial

#import "RDMapviewLayout.h"
//#import "RDCluster.h"
//#import "RDClusterCollectionViewCell.h"



@interface RDMapviewLayout ()
@property (nonatomic, strong) NSArray *updateItems;
@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;
@property (nonatomic, strong) NSMutableArray *moveIndexPaths;
@end

@implementation RDMapviewLayout

#pragma mark UICollectionViewLayout stuff

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)prepareLayout{
    [super prepareLayout];
}

-(CGSize) collectionViewContentSize{
    return [self collectionView].frame.size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems{
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    UICollectionViewUpdateItem *item;
    if(updateItems.count){
        item = updateItems[0];
    }
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems) {
        if (update.updateAction == UICollectionUpdateActionDelete) {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        } else if (update.updateAction == UICollectionUpdateActionInsert) {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        } else if (update.updateAction == UICollectionUpdateActionMove){
            //            [self.moveIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
    
    
}

- (void)finalizeCollectionViewUpdates{
    [super finalizeCollectionViewUpdates];
    // release the insert and delete index paths
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect{
    // All cells will always be within the collection view
    NSMutableArray *attributes = [@[]mutableCopy];
    for(NSInteger s = 0; s < [self.collectionView numberOfSections]; s++){
        for(NSUInteger i = 0; i < [self.collectionView numberOfItemsInSection:s]; i++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:s];
            UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if(cellAttributes){
                [attributes addObject:cellAttributes];
            }
        }
    }
    
    return attributes;
}

-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGPoint point = [self.mapView convertCoordinate:[self coordinateForSection:indexPath.section] toPointToView:self.mapView];
    attributes.size = [self.coorinateDelegate mapviewLayout:self sizeIndexPath:indexPath];
    [self isPointWithinBounds:point completionBlock:^(BOOL withinLayout, CGPoint point) {
        
        
        
        attributes.center = point;
        attributes.hidden = NO;
        
        // Make a stack of up to the first three, slightly rotated
        if(indexPath.item == 0){
            attributes.transform = CGAffineTransformIdentity;
            attributes.zIndex = 2;
            attributes.alpha = 1.0;
            /*} else if(indexPath.item == 1){
             attributes.transform = CGAffineTransformMakeRotation(-M_PI / 8.0);
             attributes.zIndex = 1;
             attributes.alpha = 0.7;
             } else if(indexPath.item == 2){
             attributes.transform = CGAffineTransformMakeRotation(M_PI / 8.0);
             attributes.zIndex = 0;
             attributes.alpha = 0.7;*/
        } else {
            attributes.hidden = YES;
        }
        
        if(withinLayout == YES){
            attributes.zIndex = 100;
        }
        [self.coorinateDelegate mapviewLayout:self withinLayout:withinLayout forIndexPath:indexPath];
    }];
    
    return attributes;
    
    
    
    
    
    //    CGPoint point = [self pointForCoordinate:[self coordinateForSection:indexPath.section]];
    //    attributes.center = point;
    //    attributes.size = [self.coorinateDelegate mapviewLayout:self sizeIndexPath:indexPath];
    //    attributes.hidden = NO;
    //
    //    // Make a stack of up to the first three, slightly rotated
    //    if(indexPath.item == 0){
    //        attributes.transform = CGAffineTransformIdentity;
    //        attributes.zIndex = 2;
    //        attributes.alpha = 1.0;
    //        /*} else if(indexPath.item == 1){
    //         attributes.transform = CGAffineTransformMakeRotation(-M_PI / 8.0);
    //         attributes.zIndex = 1;
    //         attributes.alpha = 0.7;
    //         } else if(indexPath.item == 2){
    //         attributes.transform = CGAffineTransformMakeRotation(M_PI / 8.0);
    //         attributes.zIndex = 0;
    //         attributes.alpha = 0.7;*/
    //    } else {
    //        attributes.hidden = YES;
    //    }
    //
    //
    //    return attributes;
}


//-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
//
//    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    attributes.size = CGSizeMake(SM_IPHONE_SIZE_3, SM_IPHONE_SIZE_3);
//
//    CGPoint point = [self pointForCoordinate:[self coordinateForIndexPath:indexPath]];
//
//    [self isPointWithinBounds:point completionBlock:^(BOOL withinLayout, CGPoint point) {
//        RDClusterCollectionViewCell *cell = (RDClusterCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
//        cell.withinLayout = withinLayout;
//        attributes.center = point;
//        if(withinLayout == YES){
//            attributes.zIndex = 100;
//        }
//    }];
//
//    return attributes;
//}


- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
    return attributes;
}

-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)indexPath{
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:indexPath];
    
    // only change attributes on inserted cells
    if ([self.insertIndexPaths containsObject:indexPath]) {
        if (attributes == nil){
            attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        }
        
        CLLocationCoordinate2D coordinate = [self coordinateForIndexPath:indexPath];
        CGPoint point = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];
        attributes.center = point;
        attributes.alpha = 0.0;
        attributes.transform = CGAffineTransformMakeRotation(3*M_PI);
        attributes.transform = CGAffineTransformScale(attributes.transform, 0.01, 0.01);
    }
    
    return attributes;
}


-(UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath*)indexPath{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:indexPath];
    
    // only change attributes on deleted cells
    if ([self.deleteIndexPaths containsObject:indexPath]) {
        if (!attributes){
            attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        }
        attributes.alpha = 0.0;
        attributes.transform = CGAffineTransformMakeRotation(3*M_PI);
        attributes.transform = CGAffineTransformScale(attributes.transform, 0.01, 0.01);
    }
    
    return attributes;
}

#pragma mark Private custom methods

-(CLLocationCoordinate2D)coordinateForIndexPath:(NSIndexPath*)indexPath{
    CLLocationCoordinate2D coordinate = [self.coorinateDelegate mapviewLayout:self coodinateForIndexPath:indexPath];
    return coordinate;
}

-(CLLocationCoordinate2D)coordinateForSection:(NSUInteger)section{
    CLLocationCoordinate2D coordinate = [self.coorinateDelegate mapviewLayout:self coodinateForSection:section];
    return coordinate;
}

//-(CGPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate{
//    CGPoint point = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];
//
//    // If cell is outside of our content insets, cap them there.
//    if(point.x < self.contentInset.left){
//        point.x = self.contentInset.left;
//    }
//    if(point.x >= self.mapView.frame.size.width - self.contentInset.right){
//        point.x = self.mapView.frame.size.width - self.contentInset.right;
//    }
//    if(point.y < self.contentInset.top){
//        point.y = self.contentInset.top;
//    }
//    if(point.y >= self.mapView.frame.size.height - self.contentInset.bottom){
//        point.y = self.mapView.frame.size.height - self.contentInset.bottom;
//    }
//    return point;
//}

#pragma mark Public methods
-(void)isPointWithinBounds:(CGPoint)point
           completionBlock:(VWWBoolPointBlock)completionBlock{
    
    BOOL withinLayout = YES;
    
    if(point.x < self.contentInset.left){
        point.x = self.contentInset.left;
        withinLayout = NO;
    }
    if(point.x >= self.mapView.frame.size.width - self.contentInset.right){
        point.x = self.mapView.frame.size.width - self.contentInset.right;
        withinLayout = NO;
    }
    if(point.y < self.contentInset.top){
        point.y = self.contentInset.top;
        withinLayout = NO;
    }
    if(point.y >= self.mapView.frame.size.height - self.contentInset.bottom){
        point.y = self.mapView.frame.size.height - self.contentInset.bottom;
        withinLayout = NO;
    }
    
    completionBlock(withinLayout, point);
}

@end
