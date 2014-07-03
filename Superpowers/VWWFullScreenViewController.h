//
//  VWWFullScreenViewController.h
//  Superpowers
//
//  Created by Zakk Hoyt on 6/26/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

@import UIKit;
@import Photos;

#import "VWWViewController.h"

@interface VWWFullScreenViewController : VWWViewController
@property (strong) PHAsset *asset;
@property (strong) PHAssetCollection *assetCollection;
@end
