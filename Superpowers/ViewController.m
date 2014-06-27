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
#import "VWWLibraryViewController.h"
#import "VWW.h"
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


@interface ViewController () <PHPhotoLibraryChangeObserver, VWWLibraryViewControllerDelegate>
@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;

@property (strong) PHCachingImageManager *imageManager;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, copy) PHFetchOptions *options;

@property (weak, nonatomic) IBOutlet UISlider *toleranceSlider;
@property (weak, nonatomic) IBOutlet UISlider *daySlider;
@property (weak, nonatomic) IBOutlet UISlider *yearSlider;
@property (weak, nonatomic) IBOutlet UISlider *monthSlider;

@property (weak, nonatomic) IBOutlet UILabel *toleranceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;

@property (nonatomic) NSUInteger searchTolerance;
@property (nonatomic) NSUInteger searchDay;
@property (nonatomic) NSUInteger searchMonth;
@property (nonatomic) NSUInteger searchYear;
@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchTolerance = [VWWUserDefaults searchTolerance];
    self.searchDay = [VWWUserDefaults searchDay];
    self.searchMonth = [VWWUserDefaults searchMonth];
    self.searchYear = [VWWUserDefaults searchYear];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    [self fetchResults];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self setupSliders];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES animated:NO];
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
        VWWFullScreenViewController *vc = segue.destinationViewController;
        vc.asset = self.assetsFetchResults[indexPath.item];
        vc.assetCollection = self.assetCollection;
    } else if([segue.identifier isEqualToString:VWWSegueGridToLibrary]){
        VWWLibraryViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}



-(IBAction)libraryButtonTouchUpInside:(id)sender{
    [self performSegueWithIdentifier:VWWSegueGridToLibrary sender:self];
}


- (IBAction)toleranceSliderValueChanged:(UISlider *)sender {
    self.searchTolerance = sender.value;
    self.toleranceLabel.text = [NSString stringWithFormat:@"%ld", (long)self.searchTolerance];

}

- (IBAction)daySliderValueChanged:(UISlider *)sender {
    self.searchDay = sender.value;
    self.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)sender.value];
}

- (IBAction)monthSliderValueChanged:(UISlider *)sender {
    self.searchMonth = sender.value;
    self.monthLabel.text = [NSString stringWithFormat:@"%ld", (long)sender.value];
}

- (IBAction)yearSliderValueChanged:(UISlider *)sender {
    self.searchYear = sender.value;
    self.yearLabel.text = [NSString stringWithFormat:@"%ld", (long)sender.value];
}



- (IBAction)toleranceSliderTouchUpInside:(UISlider*)sender {
    [self toleranceSliderValueChanged:sender];
    [VWWUserDefaults setSearchTolerance:self.searchTolerance];
    [self fetchResults];
}

- (IBAction)daySliderTouchUpInside:(UISlider*)sender {
    [self daySliderValueChanged:sender];
    [VWWUserDefaults setSearchDay:self.searchDay];
    [self fetchResults];
}

- (IBAction)monthSliderTouchUpInside:(UISlider*)sender {
    [self monthSliderValueChanged:sender];
    [VWWUserDefaults setSearchMonth:sender.value];
    [self fetchResults];
}

- (IBAction)yearSliderTouchUpInside:(UISlider*)sender {
    [self yearSliderValueChanged:sender];
    [VWWUserDefaults setSearchYear:sender.value];
    [self fetchResults];
}


#pragma mark Private methods

-(void)setupSliders{
    self.toleranceSlider.value = self.searchTolerance;
    self.daySlider.value = self.searchDay;
    self.monthSlider.value = self.searchMonth;
    self.yearSlider.value = self.searchYear;
    self.toleranceLabel.text = [NSString stringWithFormat:@"%ld", (long)self.searchTolerance];
    self.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)self.searchDay];
    self.monthLabel.text = [NSString stringWithFormat:@"%ld", (long)self.searchMonth];
    self.yearLabel.text = [NSString stringWithFormat:@"%ld", (long)self.searchYear];
}
-(void)fetchResults{
    VWW_LOG_INFO(@"Refreshing photos");
    [self applyDateContstraintsToOptions];
    if(self.assetCollection){
        self.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:nil];
    } else {
        self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:self.options];
    }
    
    [self.collectionView reloadData];

}

-(void)applyDateContstraintsToOptions{
    // Fetch all assets, sorted by date created.
    if(self.options == nil){
        self.options = [[PHFetchOptions alloc] init];
    } else {
        
    }
    self.options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];

    
    
    // Calculate start and end dates. Create date with day, month, year
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    components.year = self.searchYear;
    components.month = self.searchMonth;
    components.day = self.searchDay;
    NSDate *searchDate = [calendar dateFromComponents:components];
    VWW_LOG_INFO(@"searchDate: %@", searchDate);
    
    
    // Subtract tolerance / 2
    NSUInteger halfTolerance = self.searchTolerance / 2;
    NSTimeInterval offset = 60 * 60 * 24 * halfTolerance;
    NSDate *startDate = [searchDate dateByAddingTimeInterval:-offset];
    VWW_LOG_INFO(@"startDate: %@", startDate);
    
    // Add tolerance / 2
    NSDate *endDate = [searchDate dateByAddingTimeInterval:offset];
    VWW_LOG_INFO(@"endDate: %@", endDate);
    
    
    self.options.predicate = [NSPredicate predicateWithFormat:@"dateCreated >= %@ AND dateCreated  <= %@", startDate, endDate];
    
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


#pragma mark VWWLibraryViewControllerDelegate
-(void)libraryViewController:(VWWLibraryViewController*)sender fetchAssetsWithOptions:(PHFetchOptions*)options{
    self.options = options;
    self.assetCollection = nil;
    [self fetchResults];
}
-(void)libraryViewController:(VWWLibraryViewController*)sender fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection options:(PHFetchOptions *)options{
    self.options = options;
    self.assetCollection = assetCollection;
    [self fetchResults];
}



@end
