//
//  RDAggregateCollectionViewCell.h
//  MapCollectionViewLayout
//
//  Created by Zakk Hoyt on 6/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@class RDAggregateCollectionViewCell;

@protocol RDAggregateCollectionViewCellDelegate <NSObject>
-(void)aggregateCollectionViewCellLongPress:(RDAggregateCollectionViewCell*)sender;
-(void)aggregateCollectionViewCellDoubleTapPress:(RDAggregateCollectionViewCell*)sender;
@end

@interface RDAggregateCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) NSArray *moments;
@property (nonatomic) BOOL withinLayout;
@property (nonatomic, weak) id <RDAggregateCollectionViewCellDelegate> delegate;
@property (strong) PHCachingImageManager *imageManager;
@end
