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
#import "RDCollectionView.h"
#import "RDMapviewLayout.h"
#import "RDGridviewFlowLayout.h"

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


@interface ViewController () <PHPhotoLibraryChangeObserver,
VWWLibraryViewControllerDelegate,
VWWAssetCollectionViewCellDelegate,
RDMapviewLayoutCoordinateDelegate>

@property (nonatomic) BOOL hasLoaded;

@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;
@property (strong) PHCachingImageManager *imageManager;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet RDCollectionView *collectionView;
@property (nonatomic, strong) RDMapviewLayout *mapviewLayout;
@property (nonatomic, strong) RDGridviewFlowLayout *gridLayout;
@property (nonatomic) BOOL mapviewLayoutNeedsUpdate;
@property (nonatomic, copy) PHFetchOptions *options;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *organizeButton;
@property (nonatomic, strong) UIBarButtonItem *toggleButton;

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
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.searchTolerance = [VWWUserDefaults searchTolerance];
    self.searchDay = [VWWUserDefaults searchDay];
    self.searchMonth = [VWWUserDefaults searchMonth];
    self.searchYear = [VWWUserDefaults searchYear];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    [self fetchResults];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self setupSliders];
    
    
    self.toggleButton = [[UIBarButtonItem alloc]initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(toggleButtonTouchUpInside:)];
    [self.navigationItem setLeftBarButtonItem:self.toggleButton animated:NO];

    
    
    
    self.mapviewLayout = [[RDMapviewLayout alloc]init];
    self.mapviewLayout.mapView = self.mapView;
    self.mapviewLayout.coorinateDelegate = self;
    
    self.gridLayout = [[RDGridviewFlowLayout alloc]init];
//    self.collectionView.collectionViewLayout = self.mapviewLayout;
//    self.collectionView.mapMode = YES;
    self.collectionView.collectionViewLayout = self.gridLayout;
    self.collectionView.mapMode = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];

    self.collectionView.alwaysBounceVertical = YES;
    
    self.mapView.showsUserLocation = YES;
    self.mapView.pitchEnabled = YES;
    

    
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateViewsBasedOnMapRegion:)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if(self.hasLoaded == NO){
        self.hasLoaded = YES;
        self.dateView.backgroundColor = [UIColor clearColor];
//        self.dateView.backgroundColor = [UIColor greenColor ];
        UIVisualEffect *visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:visualEffect];
        visualEffectView.frame = self.dateView.bounds;
        visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        visualEffectView.constraints =
        [self.dateView addSubview:visualEffectView];

        [self.dateView bringSubviewToFront:self.toleranceSlider];
        [self.dateView bringSubviewToFront:self.daySlider];
        [self.dateView bringSubviewToFront:self.monthSlider];
        [self.dateView bringSubviewToFront:self.yearSlider];

        [self.dateView bringSubviewToFront:self.toleranceLabel];
        [self.dateView bringSubviewToFront:self.dayLabel];
        [self.dateView bringSubviewToFront:self.monthLabel];
        [self.dateView bringSubviewToFront:self.yearLabel];
        
        [self.dateView bringSubviewToFront:self.libraryButton];
        self.mapviewLayout.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height, 0, self.dateView.frame.size.height, 0);
    }
    
    [self.view layoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBActions

-(void)toggleButtonTouchUpInside:(id)sender{
    if(self.assetsFetchResults.count >= 100 &&
       self.collectionView.collectionViewLayout == self.gridLayout){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"You have more than 100 photos. This can cause performance problems" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yep, do it", nil];
        [alertView show];
    } else {
        [self toggleLayout];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:VWWSegueCollectionToFull]){
        NSIndexPath *indexPath = sender;
        VWWFullScreenViewController *vc = segue.destinationViewController;
        vc.asset = self.assetsFetchResults[indexPath.item];
        vc.assetCollection = self.assetCollection;
    } else if([segue.identifier isEqualToString:VWWSegueGridToLibrary]){
        VWWLibraryViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

- (IBAction)organizeButtonTouchUpInside:(id)sender {
    self.organizeButton.enabled = NO;
    if(self.dateView.hidden){
        self.dateView.hidden = NO;
        CGRect frame = self.dateView.frame;
        frame.origin.y = self.view.bounds.size.height - frame.size.height;
        frame.origin.x = 0;
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dateView.frame = frame;
            self.mapviewLayout.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height, 0, self.view.bounds.size.height - self.dateView.frame.origin.y, 0);
            self.mapviewLayoutNeedsUpdate = YES;

        } completion:^(BOOL finished) {
            self.organizeButton.enabled = YES;
        }];
    } else {
        
        CGRect frame = self.dateView.frame;
        frame.origin.y = self.view.bounds.size.height;
        frame.origin.x = 0;
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dateView.frame = frame;
            self.mapviewLayout.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height, 0, self.view.bounds.size.height - self.dateView.frame.origin.y, 0);
            self.mapviewLayoutNeedsUpdate = YES;

        } completion:^(BOOL finished) {
            self.dateView.hidden = YES;
            self.organizeButton.enabled = YES;
        }];
        
    }
}


-(IBAction)libraryButtonTouchUpInside:(id)sender{
    [self performSegueWithIdentifier:VWWSegueGridToLibrary sender:self];
}


- (IBAction)toleranceSliderValueChanged:(UISlider *)sender {
    self.searchTolerance = sender.value;
    self.toleranceLabel.text = [NSString stringWithFormat:@"+/- %.1f days", (long)self.searchTolerance / 2.0];
}

- (IBAction)daySliderValueChanged:(UISlider *)sender {
    self.searchDay = sender.value;
    self.dayLabel.text = [NSString stringWithFormat:@"%ld%@", (long)self.searchDay, [VWWUtility stringPostfixForDay:self.searchDay]];
}

- (IBAction)monthSliderValueChanged:(UISlider *)sender {
    self.searchMonth = sender.value;
    self.monthLabel.text = [NSString stringWithFormat:@"%@", [VWWUtility stringFromMonth:self.searchMonth]];
}

- (IBAction)yearSliderValueChanged:(UISlider *)sender {
    self.searchYear = sender.value;
    self.yearLabel.text = [NSString stringWithFormat:@"%ld", (long)self.searchYear];
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
    [self updateDaysSliderForMonthAndYear];
    [VWWUserDefaults setSearchMonth:sender.value];
    [self fetchResults];
}

- (IBAction)yearSliderTouchUpInside:(UISlider*)sender {
    [self yearSliderValueChanged:sender];
    [VWWUserDefaults setSearchYear:sender.value];
    [self fetchResults];
}


#pragma mark Private methods


-(MKCoordinateRegion)calculateRegionFromAssets{

    // If no coordinates, do nothing
    if(self.assetsFetchResults.count == 0){
        return self.mapView.region;
    }
    
    
    float minLatitude = 180.0, minLongitude = 180.0, maxLatitude = -180.0, maxLongitude = -180.0;

    for(PHAsset *asset in self.assetsFetchResults){
        if(asset.location == nil) continue;
        CLLocationCoordinate2D coordinate = asset.location.coordinate;
        if(coordinate.latitude < minLatitude){
            minLatitude = coordinate.latitude;
        }
        if(coordinate.latitude > maxLatitude){
            maxLatitude = coordinate.latitude;
        }
        
        if(coordinate.longitude < minLongitude){
            minLongitude = coordinate.longitude;
        }
        if(coordinate.longitude > maxLongitude){
            maxLongitude = coordinate.longitude;
        }
    }
    
    float deltaLatitude = maxLatitude - minLatitude;
    float deltaLongitude = maxLongitude - minLongitude;
    MKCoordinateSpan span = MKCoordinateSpanMake(deltaLatitude * 1.1, deltaLongitude * 1.1);
    float centerLatitude = minLatitude + ((maxLatitude - minLatitude) / 2.0);
    float centerLongitude = minLongitude + ((maxLongitude - minLongitude) / 2.0);
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(centerLatitude, centerLongitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    return region;
}


-(void)updateDaysSliderForMonthAndYear{
//
//    if(self.searchMonth == 1){
//        self.daySlider.maximumValue = 31;
//    } else if(self.searchMonth == 2){
//        self.daySlider.maximumValue = 28;
//    } else if(self.searchMonth == 3){
//        self.daySlider.maximumValue = 31;
//    } else if(self.searchMonth == 4){
//        self.daySlider.maximumValue = 30;
//    } else if(self.searchMonth == 5){
//        self.daySlider.maximumValue = 31;
//    } else if(self.searchMonth == 6){
//        self.daySlider.maximumValue = 30;
//    } else if(self.searchMonth == 7){
//        self.daySlider.maximumValue = 31;
//    } else if(self.searchMonth == 8){
//        self.daySlider.maximumValue = 31;
//    } else if(self.searchMonth == 9){
//        self.daySlider.maximumValue = 30;
//    } else if(self.searchMonth == 10){
//        self.daySlider.maximumValue = 31;
//    } else if(self.searchMonth == 11){
//        self.daySlider.maximumValue = 30;
//    } else if(self.searchMonth == 12){
//        self.daySlider.maximumValue = 31;
//    }
//    if(self.daySlider.value > self.daySlider.maximumValue){
//        self.daySlider.value = self.daySlider.maximumValue;
//        self.searchDay = self.daySlider.maximumValue;
//    }
//
//    self.dayLabel.text = [NSString stringWithFormat:@"%ld%@", (long)self.searchDay, [VWWUtility stringPostfixForDay:self.searchDay]];
}



-(void)toggleLayout{
    self.toggleButton.enabled = NO;
    if(self.collectionView.collectionViewLayout == self.gridLayout){
        [self.collectionView performBatchUpdates:^{
            self.collectionView.mapMode = YES;
            self.collectionView.alpha = 1.0;
            self.collectionView.contentInset = UIEdgeInsetsZero;
            [self.collectionView setCollectionViewLayout:self.mapviewLayout animated:YES];
        } completion:^(BOOL finished) {
            [self.toggleButton setTitle:@"Grid"];
            self.toggleButton.enabled = YES;
        }];
        [UIView animateWithDuration:0.3 animations:^{
            self.collectionView.backgroundColor = [UIColor clearColor];
        }];

    } else {
        [self.collectionView performBatchUpdates:^{
            self.collectionView.mapMode = NO;
            self.collectionView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height, 0, 0, 0);
            [self.collectionView setCollectionViewLayout:self.gridLayout animated:YES];
        } completion:^(BOOL finished) {
            [self.toggleButton setTitle:@"Map"];
        }];
        [UIView animateWithDuration:0.3 animations:^{
            self.collectionView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            self.toggleButton.enabled = YES;
        }];
    }
    
    
}

- (void)updateViewsBasedOnMapRegion:(CADisplayLink *)link
{
    static MKCoordinateRegion lastRegion;
    // Only re-render the layover if region has changed
    if(lastRegion.center.latitude != self.mapView.region.center.latitude ||
       lastRegion.center.longitude != self.mapView.region.center.longitude ||
       lastRegion.span.latitudeDelta != self.mapView.region.span.latitudeDelta  ||
       lastRegion.span.longitudeDelta != self.mapView.region.span.longitudeDelta ||
       self.mapviewLayoutNeedsUpdate){
        self.mapviewLayoutNeedsUpdate = NO;
        [self.collectionView.collectionViewLayout invalidateLayout];
        lastRegion = self.mapView.region;
    }
}


-(void)setupSliders{
    self.toleranceSlider.value = self.searchTolerance;
    self.daySlider.value = self.searchDay;
    self.monthSlider.value = self.searchMonth;
    self.yearSlider.value = self.searchYear;
    self.toleranceLabel.text = [NSString stringWithFormat:@"+/- %.1f days", (long)self.searchTolerance / 2.0];
    self.dayLabel.text = [NSString stringWithFormat:@"%ld%@", (long)self.searchDay, [VWWUtility stringPostfixForDay:self.searchDay]];
    self.monthLabel.text = [NSString stringWithFormat:@"%@", [VWWUtility stringFromMonth:self.searchMonth]];
    self.yearLabel.text = [NSString stringWithFormat:@"%ld", (long)self.searchYear];
}
-(void)fetchResults{
    VWW_LOG_INFO(@"Refreshing photos");
    [self applyDateContstraintsToOptions];
    if(self.assetCollection){
        self.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:self.options];
    } else {
        self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:self.options];
    }
    
    // Update UI
    NSString *libraryName = self.assetCollection.localizedTitle ? self.assetCollection.localizedTitle : @"All Photos";
    NSString *libraryButtonTitle = [NSString stringWithFormat:@"Library (%@)", libraryName];
    [self.libraryButton setTitle:libraryButtonTitle forState:UIControlStateNormal];
    self.title = [NSString stringWithFormat:@"%lu", (unsigned long)(unsigned long)self.assetsFetchResults.count];
    [self.collectionView reloadData];
    
    MKCoordinateRegion region = [self calculateRegionFromAssets];
    [self.mapView setRegion:region animated:YES];

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
    cell.delegate = self;
    
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(ViewControllerCellSize * scale, ViewControllerCellSize * scale);

    [self.imageManager requestImageForAsset:asset
                                 targetSize:size
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *image, NSDictionary *info) {
                                  NSLog(@"info: %@", info);
                                  cell.image = image;
                              }];
    
    
    cell.title = [VWWUtility stringFromAssetSource:asset.assetSource];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{\
    return CGSizeMake(106, 106);
}




#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{


    if(self.collectionView.collectionViewLayout == self.gridLayout){
        [self performSegueWithIdentifier:VWWSegueCollectionToFull sender:indexPath];
    } else if(self.collectionView.collectionViewLayout == self.mapviewLayout){
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
//        if(asset.location.coordinate.latitude != 0 &&
//           asset.location.coordinate.longitude != 0){
//            CGPoint point =[self.mapView convertCoordinate:asset.location.coordinate toPointToView:self.mapView];
//            if(CGRectContainsPoint(self.mapView.frame, point)){
//            } else {
                // Center in screen
                CLLocationCoordinate2D coordinate = asset.location.coordinate;
                [self.mapView setCenterCoordinate:coordinate animated:YES];
//            }
//
//        }

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

#pragma mark VWWAssetCollectionViewCellDelegate
-(void)assetCollectionViewCellTouchBegan:(VWWAssetCollectionViewCell*)sender{
    [UIView animateWithDuration:0.1 animations:^{
        sender.alpha = 0.5;
        sender.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }];

}
-(void)assetCollectionViewCellTouchEnded:(VWWAssetCollectionViewCell*)sender{
    [UIView animateWithDuration:0.1 animations:^{
        sender.alpha = 1.0;
        sender.transform = CGAffineTransformIdentity;
    }];

//    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
//    PHAsset *asset = self.assetsFetchResults[indexPath.item];
//    if(asset.location.coordinate.latitude != 0 &&
//       asset.location.coordinate.longitude != 0){
//        CGPoint point =[self.mapView convertCoordinate:asset.location.coordinate toPointToView:self.mapView];
//        if(CGRectContainsPoint(self.mapView.frame, point)){
//            if(self.collectionView.collectionViewLayout == self.gridLayout){
//                [self performSegueWithIdentifier:VWWSegueCollectionToFull sender:sender];
//            }
//        } else {
//        // Center in screen
//        CLLocationCoordinate2D coordinate = asset.location.coordinate;
//        [self.mapView setCenterCoordinate:coordinate animated:YES];
//        }
//    }

}
-(void)assetCollectionViewCellLongPress:(VWWAssetCollectionViewCell*)sender{
//    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
//    [self performSegueWithIdentifier:VWWSegueCollectionToFull sender:indexPath];
}

-(void)assetCollectionViewCellDoubleTap:(VWWAssetCollectionViewCell*)sender{
//    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
//    PHAsset *asset = self.assetsFetchResults[indexPath.item];
//    if(asset.location.coordinate.latitude != 0 &&
//       asset.location.coordinate.longitude != 0){
//        //        CGPoint point =[self.mapView convertCoordinate:asset.location.coordinate toPointToView:self.mapView];
//        //        if(CGRectContainsPoint(self.mapView.frame, point)){
//        //            //        [self performSegueWithIdentifier:RDSegueRadiusNearByToDetail sender:cluster];
//        //        } else {
//        // Center in screen
//        CLLocationCoordinate2D coordinate = asset.location.coordinate;
//        [self.mapView setCenterCoordinate:coordinate animated:YES];
//        //        }
//    }
}



#pragma mark RDMapviewLayoutCoordinateDelegate
-(CLLocationCoordinate2D)mapviewLayoutCoodinateForIndexPath:(NSIndexPath*)indexPath{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    return asset.location.coordinate;
}


-(CLLocationCoordinate2D)mapviewLayoutCoodinateForSection:(NSUInteger)section{
    return CLLocationCoordinate2DMake(37.5, -121.0);

}


#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        
    } else if(buttonIndex == 1){
        [self toggleLayout];
    }
}

@end
