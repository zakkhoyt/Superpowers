//
//  ViewController.m
//  Superpowers
//
//  Created by Zakk Hoyt on 6/26/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "ViewController.h"
#import "VWWAssetCollectionViewCell.h"
#import "VWWFullScreenViewController.h"
@import Photos;

static NSString *VWWSegueCollectionToFull = @"VWWSegueCollectionToFull";
static NSString *VWWSegueGridToLibrary = @"VWWSegueGridToLibrary";

static CGFloat ViewControllerCellSize = 106;



@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end


@interface ViewController () <PHPhotoLibraryChangeObserver>
@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (strong) PHCachingImageManager *imageManager;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    [self sliderTouchUpInside:nil];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:VWWSegueCollectionToFull]){
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        VWWFullScreenViewController *assetViewController = segue.destinationViewController;
        assetViewController.asset = self.assetsFetchResults[indexPath.item];
        assetViewController.assetCollection = self.assetCollection;
    }
}


- (IBAction)sliderTouchUpInside:(id)sender {
    //    AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
    // Fetch all assets, sorted by date created.
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [[NSDateComponents alloc]init];
    startComponents.year = 2014;
    startComponents.month = 5;
    startComponents.day = 1;
    NSDate *startDate = [calendar dateFromComponents:startComponents];
    
    NSDateComponents *endComponents = [[NSDateComponents alloc]init];
    endComponents.year = 2014;
    endComponents.month = 7;
    endComponents.day = 1;
    NSDate *endDate = [calendar dateFromComponents:endComponents];
    
    options.predicate = [NSPredicate predicateWithFormat:@"dateCreated >= %@ AND dateCreated  <= %@", startDate, endDate];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    [self.collectionView reloadData];

}

-(IBAction)libraryButtonTouchUpInside:(id)sender{
    [self performSegueWithIdentifier:VWWSegueGridToLibrary sender:self];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.assetsFetchResults.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VWWAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VWWAssetCollectionViewCell" forIndexPath:indexPath];

    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(ViewControllerCellSize * scale, ViewControllerCellSize * scale);
    [self.imageManager requestImageForAsset:asset
                                 targetSize:size
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *image, NSDictionary *info) {
                                  
//                                  // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
//                                  if (cell.tag == currentTag) {
                                      cell.image = image;
//                                  }
                                  
                              }];
    
    
    cell.title = [self stringFromAssetSource:asset.assetSource];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{\
    return CGSizeMake(106, 106);
}

-(NSString*)stringFromAssetSource:(PHAssetSource)assetSource{
    switch (assetSource) {
        case PHAssetSourceUnknown:
            return @"?";
            break;
        case PHAssetSourcePhotoBooth:
            return @"photoBooth";
            break;
        case PHAssetSourcePhotoStream:
            return @"photoStream";
            break;
        case PHAssetSourceCamera:
            return @"camera";
            break;
        case PHAssetSourceCloudShared:
            return @"cloudShared";
            break;
        case PHAssetSourceCameraConnectionKit:
            return @"camConnKit";
            break;
        case PHAssetSourceCloudPhotoLibrary:
            return @"cloudPhotoLib";
            break;
        case PHAssetSourceiTunesSync:
            return @"iTunes";
            break;
        default:
            break;
    }
}

#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
//    self.previousPreheatRect = CGRectZero;
}

//- (void)updateCachedAssets
//{
//    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
//    if (!isViewVisible) { return; }
//    
//    // The preheat window is twice the height of the visible rect
//    CGRect preheatRect = self.collectionView.bounds;
//    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
//    
//    // If scrolled by a "reasonable" amount...
//    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
//    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
//        
//        // Compute the assets to start caching and to stop caching.
//        NSMutableArray *addedIndexPaths = [NSMutableArray array];
//        NSMutableArray *removedIndexPaths = [NSMutableArray array];
//        
//        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
//            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
//            [removedIndexPaths addObjectsFromArray:indexPaths];
//        } addedHandler:^(CGRect addedRect) {
//            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
//            [addedIndexPaths addObjectsFromArray:indexPaths];
//        }];
//        
//        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
//        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
//        
//        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
//                                            targetSize:AssetGridThumbnailSize
//                                           contentMode:PHImageContentModeAspectFill
//                                               options:nil];
//        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
//                                           targetSize:AssetGridThumbnailSize
//                                          contentMode:PHImageContentModeAspectFill
//                                              options:nil];
//        
//        self.previousPreheatRect = preheatRect;
//    }
//}



#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        if (collectionChanges) {
            
            // get the new fetch result
            self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.collectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
                
            } else {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}





@end
