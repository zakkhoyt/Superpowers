//
//  VWWLibraryViewController.h
//  Superpowers
//
//  Created by Zakk Hoyt on 6/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@class VWWLibraryViewController;

@protocol VWWLibraryViewControllerDelegate <NSObject>
-(void)libraryViewController:(VWWLibraryViewController*)sender fetchAssetsWithOptions:(PHFetchOptions*)options;
-(void)libraryViewController:(VWWLibraryViewController*)sender fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection options:(PHFetchOptions *)options;
@end

@interface VWWLibraryViewController : UIViewController
@property (nonatomic, weak) id <VWWLibraryViewControllerDelegate> delegate;
@end
