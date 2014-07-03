//
//  VWWWelcomeViewController.m
//  Superpowers
//
//  Created by Zakk Hoyt on 6/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWWelcomeViewController.h"
#import "VWWLocationController.h"
#import "VWW.h"
#import "NSTimer+Blocks.h"

@import Photos;

@interface VWWWelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UIButton *promptButton;
@property (strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) VWWLocationController *locationController;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIActionSheet *actionSheet;


#pragma mark PhotoCollection research
@property (nonatomic, copy) PHFetchOptions *options;
@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;

@end

@implementation VWWWelcomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.promptButton.hidden = NO;
//    self.startButton.hidden = YES;
        self.locationController = [VWWLocationController sharedInstance];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.startButton.alpha = 0.0;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    VWW_LOG_TRACE;
    [self verifyCoreLocationAccess];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Private methods

-(void)verifyCoreLocationAccess{
    __weak VWWWelcomeViewController *weakSelf = self;
    [self.locationController setAccessAllowedBlock:^{
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.startButton.alpha = 1.0;
        }];
    }];
    
    [self.locationController setChangeSettingsBlock:^{
        if(weakSelf.alertView == nil){
            weakSelf.alertView = [[UIAlertView alloc]initWithTitle:@"Permission problem"
                                                           message:@"In order for this app to work you must allow access to your location at all times. Press okay to go to the settings page. Navigate to \'Privacy -> Location Services\', then select Always. Return to this app afterwards"
                                                          delegate:weakSelf
                                                 cancelButtonTitle:@"Okay"
                                                 otherButtonTitles:nil, nil];
            [weakSelf.alertView show];
        }
    }];
    
    if([self.locationController verifyCoreLocationAccess] == YES){
        [UIView animateWithDuration:0.2 animations:^{
            self.startButton.alpha = 1.0;
        }];
    }
}







#pragma mark IBActions
- (IBAction)startButtonTouchUpInside:(id)sender {
    
}


- (IBAction)promptButtonTouchUpInside:(UIButton*)sender {
    [self fetchResults];
}


#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [NSTimer scheduledTimerWithTimeInterval:0.1 block:^{
        self.alertView = nil;
        VWW_LOG_INFO(@"Oxpening app's settings page");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } repeats:NO];
    
}


#pragma mark - PhotoCollection research

-(void)applyDateContstraintsToOptions{
    // Fetch all assets, sorted by date created.
    if(self.options == nil){
        self.options = [[PHFetchOptions alloc] init];
    } else {
        
    }
//    self.options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];
    
//    // Calculate start and end dates. Create date with day, month, year
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [[NSDateComponents alloc]init];
//    components.year = self.searchYear;
//    components.month = self.searchMonth;
//    components.day = self.searchDay;
//    NSDate *searchDate = [calendar dateFromComponents:components];
//    VWW_LOG_INFO(@"searchDate: %@", searchDate);
//    
//    
//    // Subtract tolerance / 2
//    NSUInteger halfTolerance = self.searchTolerance / 2;
//    NSTimeInterval offset = 60 * 60 * 24 * halfTolerance;
//    NSDate *startDate = [searchDate dateByAddingTimeInterval:-offset];
//    VWW_LOG_INFO(@"startDate: %@", startDate);
//    
//    // Add tolerance / 2
//    NSDate *endDate = [searchDate dateByAddingTimeInterval:offset];
//    VWW_LOG_INFO(@"endDate: %@", endDate);
//    
//    
//    self.options.predicate = [NSPredicate predicateWithFormat:@"dateCreated >= %@ AND dateCreated  <= %@", startDate, endDate];
}

-(void)fetchResults{
    VWW_LOG_INFO(@"Refreshing photos");
    [self applyDateContstraintsToOptions];
    self.imageManager = [[PHCachingImageManager alloc] init];


    // *************************************************************************
    // Fetch moments and then fetch assets of first moment
    
//    + (PHFetchResult *)fetchAssetCollectionsWithType:(PHAssetCollectionType)type subtype:(PHAssetCollectionSubtype)subtype options:(PHFetchOptions *)options;
    PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAny options:self.options];
    VWW_LOG_INFO(@"Foudn %ld results", results.count);
    
    
    // PHMoment
    NSLog(@"Moments");
    __block NSUInteger totalCount = 0;
    __block NSUInteger momentsCount = 0;
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = (PHAssetCollection*)obj;
        momentsCount++;
        if(idx == 0){
            self.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.options];
            [self.assetsFetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PHAsset *asset = (PHAsset*)obj;
                [self.imageManager requestImageForAsset:asset
                                             targetSize:CGSizeMake(100,100)
                                            contentMode:PHImageContentModeAspectFill
                                                options:nil
                                          resultHandler:^(UIImage *image, NSDictionary *info) {
                                              image = image;
                                          }];

            }];
        }
        
        CLLocation *location = assetCollection.approximateLocation;
        
        NSLog(@"c:%@ #:%ld t:%@ l:%@ d:%@-%@ L:%@",
                     [obj class],
                     (long)assetCollection.estimatedAssetCount,
                     assetCollection.localizedTitle,
                     assetCollection.localizedLocationNames,
                     assetCollection.startDate.description,
                     assetCollection.endDate.description,
                    location.description);
        totalCount += assetCollection.estimatedAssetCount;
//        PHMoment *moment = (PHMoment*)obj;
    }];
    NSLog(@"MomentsCount: %ld, totalAssetCount: %ld", (long)momentsCount, (long)totalCount);
  
    
    
////    + (PHFetchResult *)fetchMomentListsWithType:(PHCollectionListType)momentListType options:(PHFetchOptions *)options;
//    PHFetchResult *results = [PHCollectionList fetchMomentListsWithType:PHCollectionListTypeFolder options:self.options];
//    VWW_LOG_INFO(@"Foudn %ld results", results.count);
//    
//    // PHMoment
//    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        VWW_LOG_INFO(@"obj class: %@", [obj class]);
//        //        PHMoment *moment = (PHMoment*)obj;
//    }];

    
//    PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:self.options];
//    VWW_LOG_INFO(@"Foudn %ld results", results.count);
//
//
//    // PHMoment
//    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        VWW_LOG_INFO(@"obj class: %@", [obj class]);
////        PHMoment *moment = (PHMoment*)obj;
//    }];
    
    
    
    
    
//    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
//    [topLevelUserCollections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        PHAssetCollection *assetCollection = (PHAssetCollection*)obj;
//        VWW_LOG_INFO(@"TopLevel: obj class: %@ - %@ %@", [obj class], assetCollection.localizedTitle, assetCollection.localizedLocationNames);
//    }];
//    
//    
//    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//    [smartAlbums enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        PHAssetCollection *assetCollection = (PHAssetCollection*)obj;
//        VWW_LOG_INFO(@"SmartAlbums: obj class: %@ - %@ %@", [obj class], assetCollection.localizedTitle, assetCollection.localizedLocationNames);
//    }];

}

















@end
