//
//  RDAggregateCollectionViewCell.m
//  MapCollectionViewLayout
//
//  Created by Zakk Hoyt on 6/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "RDAggregateCollectionViewCell.h"
//#import "SMAssetController.h"
//#import "SMCluster.h"

//#import "RDImageFilterController.h"

@interface RDAggregateCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *grayImageView;
@property (nonatomic, weak) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@end



@implementation RDAggregateCollectionViewCell

#pragma mark Public methods

- (id)initWithCoder:(NSCoder*)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        longPressGesture.minimumPressDuration = 2.0;
        [self addGestureRecognizer:longPressGesture];
        
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGesture];
    }
    return self;
}

-(void)setMoments:(NSArray *)moments{
    _moments = moments;
    if(_moments.count){
        
        self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)_moments.count];
        
        __weak RDAggregateCollectionViewCell *weakSelf = self;
        self.imageView.image = nil;
        self.grayImageView.alpha = 0;
        //    self.grayImageView.hidden = YES;

        PHAssetCollection *moment = _moments[0];
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:moment options:nil];
        
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if(idx == 0){
                PHAsset *asset = (PHAsset*)obj;
                [self.imageManager requestImageForAsset:asset
                                             targetSize:self.bounds.size
                                            contentMode:PHImageContentModeAspectFill
                                                options:nil
                                          resultHandler:^(UIImage *image, NSDictionary *info) {
                                              weakSelf.imageView.image = image;
                                          }];
                
            }
        }];
        
//        [result enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            PHAsset *asset = (PHAsset*)obj;
//            [self.imageManager requestImageForAsset:asset
//                                         targetSize:self.bounds.size
//                                        contentMode:PHImageContentModeAspectFill
//                                            options:nil
//                                      resultHandler:^(UIImage *image, NSDictionary *info) {
//                                          weakSelf.imageView.image = image;
//                                      }];
//        }];
        

    } else {
        self.countLabel.text = @"0";
        
    }
    
    self.debugLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)_moments.count];
    
    [self updateOffscreen];

}

//-(void)setClusters:(NSArray *)clusters{
//    _clusters = clusters;
//    
//    if(clusters.count){
//        
//        NSUInteger assetsCount = 0;
//        for(SMCluster *cluster in _clusters){
//            assetsCount += cluster.numAssets;
//        }
//        self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)assetsCount];
//        
//        __weak RDAggregateCollectionViewCell *weakSelf = self;
//        self.imageView.image = nil;
//        self.grayImageView.alpha = 0;
//        //    self.grayImageView.hidden = YES;
//        SMCluster *cluster = clusters[0];
//        [[SMAssetController sharedInstance] appleAssetForURL:cluster.coverAsset.uriLocal completion:^(ALAsset *asset) {
//            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
//            weakSelf.imageView.image = image;
//            
//            UIImage *grayImage = [[RDImageFilterController sharedInstance] processImageUsingGrayscaleEffect:self.imageView.image];
//            weakSelf.grayImageView.image = grayImage;
//        } errorBlock:^(NSError *error) {
//            SM_LOG_ERROR(@"Failed to find image for local asset");
//        }];
//    } else {
//        self.countLabel.text = @"0";
//        
//    }
//    
//    self.debugLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)clusters.count];
//
//    [self updateOffscreen];
//}
-(void)setWithinLayout:(BOOL)withinLayout{
    
    if(withinLayout == _withinLayout) return;
    
    _withinLayout = withinLayout;
    [self updateOffscreen];
}


#pragma mark Private methods


-(void)updateOffscreen{
    if(_withinLayout){
        [UIView animateWithDuration:0.3 animations:^{
            self.bubbleImageView.alpha = 1.0;
            self.countLabel.alpha = 1.0;
            self.grayImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            //            self.grayImageView.hidden = YES;
        }];
        
    } else {
        //        self.grayImageView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.bubbleImageView.alpha = 0.0;
            self.countLabel.alpha = 0.0;
            self.grayImageView.alpha = 1.0;
        }];
    }
}



-(void)longPress:(UILongPressGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        [self.delegate aggregateCollectionViewCellLongPress:self];
    }
}

-(void)doubleTap:(UITapGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateEnded){
        [self.delegate aggregateCollectionViewCellDoubleTapPress:self];
    }
    
}

@end
