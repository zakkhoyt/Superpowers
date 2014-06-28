//
//  PhotoEditingViewController.h
//  SuperpowersEditor
//
//  Created by Zakk Hoyt on 6/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface PhotoEditingViewController : UIViewController
@property (nonatomic, strong) UIImage *devImage;
@property (nonatomic, strong) CLLocation *devLocation;
@end
