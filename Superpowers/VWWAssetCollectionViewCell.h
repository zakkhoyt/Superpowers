//
//  VWWAssetCollectionViewCell.h
//  Superpowers
//
//  Created by Zakk Hoyt on 6/26/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VWWAssetCollectionViewCell;

@protocol VWWAssetCollectionViewCellDelegate <NSObject>
-(void)assetCollectionViewCellTouchBegan:(VWWAssetCollectionViewCell*)sender;
-(void)assetCollectionViewCellTouchEnded:(VWWAssetCollectionViewCell*)sender;
-(void)assetCollectionViewCellLongPress:(VWWAssetCollectionViewCell*)sender;
-(void)assetCollectionViewCellDoubleTap:(VWWAssetCollectionViewCell*)sender;
@end



@interface VWWAssetCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) BOOL withinLayout;
@property (nonatomic, weak) id <VWWAssetCollectionViewCellDelegate> delegate;
@end
