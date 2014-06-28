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
#import "VWWAssetCollectionViewCell.h"



@interface RDMapviewLayout ()
@property (nonatomic, strong) NSArray *updateItems;
@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;
@property (nonatomic) NSUInteger sectionsCount;
@property (nonatomic, strong) NSIndexSet *expandedIndexSet;
@end

@implementation RDMapviewLayout
- (instancetype)init{
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)prepareLayout
{
    [super prepareLayout];
    _sectionsCount = [self.collectionView numberOfSections];
}

-(CGSize) collectionViewContentSize{
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    return [self collectionView].frame.size;
}

// return YES to cause the collection view to requery the layout for geometry information
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    return YES;
}



- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems{
    
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
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
            //            [self printIndexPath:update.indexPathBeforeUpdate];
        } else if (update.updateAction == UICollectionUpdateActionInsert) {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
            //            [self printIndexPath:update.indexPathAfterUpdate];
        } else if (update.updateAction == UICollectionUpdateActionMove) {
            VWW_LOG_DEBUG(@"Move action");
        } else if (update.updateAction == UICollectionUpdateActionReload) {
            VWW_LOG_DEBUG(@"Reload action");
        }
    }
    
    
}

-(void)printIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"indexPath: %ld:%ld", (long)indexPath.item, (long)indexPath.section);
}

- (void)finalizeCollectionViewUpdates
{
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    [super finalizeCollectionViewUpdates];
    // release the insert and delete index paths
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}


-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect{
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    
    // All cells will always be within the collection view
    NSMutableArray *attributes = [@[]mutableCopy];
    for(NSInteger s = 0; s < self.sectionsCount; s++){
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
    
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = CGSizeMake(70, 70);
    
    CLLocationCoordinate2D coordinate = [self coordinateForIndexPath:indexPath];
    if(coordinate.latitude == 0 && coordinate.longitude == 0){
        attributes.hidden = YES;
    } else {
        CGPoint point = [self pointForCoordinate:coordinate];
        attributes.hidden = NO;
        [self isPointWithinBounds:point completionBlock:^(BOOL withinLayout, CGPoint point) {
            VWWAssetCollectionViewCell *cell = (VWWAssetCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.withinLayout = withinLayout;
            attributes.center = point;
            if(withinLayout == YES){
                attributes.zIndex = 100;
            }
        }];
    }
    return attributes;
}


//- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind
//                                                                     atIndexPath:(NSIndexPath *)indexPath{
//    //    NSLog(@"%s:%d kind:%@", __PRETTY_FUNCTION__, __LINE__, elementKind);
//    
//    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
//    CGPoint point = [self pointForCoordinate:[self coordinateForSection:indexPath.section]];
//    attributes.size = CGSizeMake(RDMapviewLayoutItemSize, RDMapviewLayoutItemSize);
//    
//    // Don't let the cell or view or whatever move out of the frame
//    if(point.x < 0){
//        point.x = 0;
//        attributes.alpha = 0.5;
//    }
//    if(point.x >= self.mapView.frame.size.width){
//        point.x = self.mapView.frame.size.width;
//        attributes.alpha = 0.5;
//    }
//    if(point.y < self.contentInset.top){
//        point.y = self.contentInset.top;
//        attributes.alpha = 0.5;
//    }
//    if(point.y >= self.mapView.frame.size.height - self.contentInset.bottom){
//        point.y = self.mapView.frame.size.height - self.contentInset.bottom;
//        attributes.alpha = 0.5;
//    }
//    
//    attributes.center = point;
//    
//    return attributes;
//    
//}



-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:indexPath];
    NSLog(@"inserting indexPath:%ld:%ld", (long)indexPath.item, (long)indexPath.section);
    if ([self.insertIndexPaths containsObject:indexPath]) {
        // only change attributes on inserted cells
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
    
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    
    
    // So far, calling super hasn't been strictly necessary here, but leaving it in
    // for good measure
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:indexPath];
    NSLog(@"deleting indexPath:%ld:%ld", (long)indexPath.item, (long)indexPath.section);
    if ([self.deleteIndexPaths containsObject:indexPath]) {
        // only change attributes on deleted cells
        if (!attributes){
            attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            NSLog(@"YES");
        }
        
        NSUInteger index = [self.deleteIndexPaths indexOfObject:indexPath];
        NSIndexPath *deletedIndexPath = self.deleteIndexPaths[index];
        NSLog(@"deletedIndexPath: %ld:%ld", deletedIndexPath.item, deletedIndexPath.section);
        
        attributes.alpha = 0.0;
        attributes.transform = CGAffineTransformMakeRotation(3*M_PI);
        attributes.transform = CGAffineTransformScale(attributes.transform, 0.01, 0.01);
        
    }
    
    return attributes;
}

#pragma mark Custom methods
-(CLLocationCoordinate2D)coordinateForIndexPath:(NSIndexPath*)indexPath{
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    
    CLLocationCoordinate2D coordinate = [self.coorinateDelegate mapviewLayoutCoodinateForIndexPath:indexPath];
    return coordinate;
}

-(CLLocationCoordinate2D)coordinateForSection:(NSUInteger)section{
    //    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    CLLocationCoordinate2D coordinate = [self.coorinateDelegate mapviewLayoutCoodinateForSection:section];
    return coordinate;
}

-(CGPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate{
    CGPoint point = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];
    return point;
}


#pragma mark Public methods

-(void)showAssetsForClusters:(NSIndexSet*)indexSet{
    _expandedIndexSet = indexSet;
}


-(void)isPointWithinBounds:(CGPoint)point
           completionBlock:(VWWBoolPointBlock)completionBlock{
    
    BOOL withinLayout = YES;
    // If cell is off the screen, cap it at the edge of the screen (minus contentInset)
    if(point.x < 0){
        point.x = 0;
        withinLayout = NO;
    }
    if(point.x >= self.mapView.frame.size.width){
        point.x = self.mapView.frame.size.width;
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
