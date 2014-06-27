//
//  VWWLibraryViewController.h
//  Superpowers
//
//  Created by Zakk Hoyt on 6/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VWWLibraryViewController;

@protocol VWWLibraryViewControllerDelegate <NSObject>
-(void)libraryViewController:(VWWLibraryViewController*)sender fetchResult:(PHFetchResult*)fetchResult;
@end

@interface VWWLibraryViewController : UIViewController
@property (nonatomic, weak) id <VWWLibraryViewControllerDelegate> delegate;
@end
