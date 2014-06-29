//
//  PhotoEditingViewController.m
//  SuperpowersEditor
//
//  Created by Zakk Hoyt on 6/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "PhotoEditingViewController.h"
#import "VWW.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <CoreLocation/CoreLocation.h>
#import "PhotoEditorCollectionViewCell.h"
#import "SMMapClipController.h"


typedef enum {
    PhotoEditingViewControllerTypeMapOnImage = 0,
    PhotoEditingViewControllerTypeImageOnMap = 1,
    PhotoEditingViewControllerTypeTextOnImage = 2,
    PhotoEditingViewControllerTypeCoordinatesOnImage = 3,
    PhotoEditingViewControllerTypeTextAndCoordinatesOnImage = 4,
} PhotoEditingViewControllerType;

@interface PhotoEditingViewController () <PHContentEditingController>
@property (strong) PHContentEditingInput *input;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString *selectedFilterName;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@end

@implementation PhotoEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.backgroundColor = [UIColor blueColor];
    self.activityView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
//    BOOL result = [adjustmentData.formatIdentifier isEqualToString:@"com.vaporwarewolf.photofilter"];
//    result &= [adjustmentData.formatVersion isEqualToString:@"1.0"];
//    return result;
    return NO; // always get past edits baked in
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned NO, the contentEditingInput has past edits "baked in".
    self.input = contentEditingInput;
    self.imageView.image = placeholderImage;
    
    // Load adjustment data, if any
    @try {
        PHAdjustmentData *adjustmentData = self.input.adjustmentData;
        if (adjustmentData) {
            self.selectedFilterName = [NSKeyedUnarchiver unarchiveObjectWithData:adjustmentData.data];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception decoding adjustment data: %@", exception);
    }
    if (!self.selectedFilterName) {
        NSString *defaultFilterName = @"No Additions";
        self.selectedFilterName = defaultFilterName;
    }

}




- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
    PHContentEditingOutput *contentEditingOutput = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
    
    // Adjustment data
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self.selectedFilterName];
    PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:@"com.vaporwarewolf.photofilter"
                                                                            formatVersion:@"1.0"
                                                                                     data:archivedData];
    contentEditingOutput.adjustmentData = adjustmentData;
    NSData *renderedJPEGData = UIImageJPEGRepresentation(self.imageView.image, 0.9f);
    
    // Save JPEG data
    NSError *error = nil;
    BOOL success = [renderedJPEGData writeToURL:contentEditingOutput.renderedContentURL options:NSDataWritingAtomic error:&error];
    if (success) {
        completionHandler(contentEditingOutput);
    } else {
        NSLog(@"An error occured: %@", error);
        completionHandler(nil);
    }
}


- (void)cancelContentEditing {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
}



#pragma mark UICollectionViewDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)cv {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoEditorCollectionViewCell *cell = (PhotoEditorCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"PhotoEditorCollectionViewCell" forIndexPath:indexPath];
    
    if(indexPath.item == PhotoEditingViewControllerTypeMapOnImage){
        cell.title = @"Image on Map";
    } else if(indexPath.item == PhotoEditingViewControllerTypeImageOnMap) {
        cell.title = @"Map on Image";
    } else if(indexPath.item == PhotoEditingViewControllerTypeTextOnImage) {
        cell.title = @"Text on Image";
    } else if(indexPath.item == PhotoEditingViewControllerTypeCoordinatesOnImage) {
        cell.title = @"Coords on Image";
    } else if(indexPath.item == PhotoEditingViewControllerTypeTextAndCoordinatesOnImage) {
        cell.title = @"Text & Coords on Image";
    }
    

    cell.backgroundColor = [UIColor darkGrayColor];
    return cell;
}



- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(70, 70);
}


#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.activityView startAnimating];
    [UIView animateWithDuration:0.3 animations:^{
        self.activityView.hidden = NO;
    }];
    
    
    if(indexPath.item == 0){
        
        CGSize size = CGSizeMake(self.input.displaySizeImage.size.width, self.input.displaySizeImage.size.height);
        CGFloat width = size.width / 4.0;
        [[SMMapClipController sharedInstance] loadMapSnapshotAtCoordinate:self.input.location.coordinate size:size type:MKMapTypeStandard completionBlock:^(UIImage *mapImage) {
            
            if(mapImage){
                // Resize main image to a smaller one
                UIImage *resizedImage = [[SMMapClipController sharedInstance] resizeImage:self.input.displaySizeImage size:size];
                UIImage *mergedImage = [[SMMapClipController sharedInstance] renderImage:resizedImage onImage:mapImage atRect:CGRectMake(size.width - 1.25*width, size.height - 1.25*width, width, width)];
                self.imageView.image = mergedImage;
            }
            [UIView animateWithDuration:0.3 animations:^{
                self.activityView.hidden = YES;
            }];
            
            [self.activityView stopAnimating];
        }];
        
    } else if(indexPath.item == 1){
        CGFloat width = self.input.displaySizeImage.size.width / 4.0;
        [[SMMapClipController sharedInstance] loadMapSnapshotAtCoordinate:self.input.location.coordinate size:CGSizeMake(width, width) type:MKMapTypeStandard completionBlock:^(UIImage *mapImage) {
            UIImage *mergedImage = [[SMMapClipController sharedInstance] renderImage:mapImage onImage:self.input.displaySizeImage atRect:CGRectMake(self.input.displaySizeImage.size.width - 1.25*width, self.input.displaySizeImage.size.height - 1.25*width, width, width)];
            self.imageView.image = mergedImage;
            [UIView animateWithDuration:0.3 animations:^{
                self.activityView.hidden = YES;
            }];

            [self.activityView stopAnimating];
        }];
    } else if(indexPath.item == 2){
//        UILabel *label = [UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height);
    }
}


@end
