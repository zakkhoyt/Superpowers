//
//  ViewController.m
//  Superpowers
//
//  Created by Zakk Hoyt on 6/26/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "ViewController.h"
#import "VWWAssetCollectionViewCell.h"

@import Photos;

static CGFloat ViewControllerCellSize = 106;

@interface ViewController ()
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
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)sliderTouchUpInside:(id)sender {
    //    AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
    // Fetch all assets, sorted by date created.
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [[NSDateComponents alloc]init];
    startComponents.year = 2014;
    startComponents.month = 1;
    startComponents.day = 1;
    NSDate *startDate = [calendar dateFromComponents:startComponents];
    
    NSDateComponents *endComponents = [[NSDateComponents alloc]init];
    endComponents.year = 2014;
    endComponents.month = 2;
    endComponents.day = 1;
    NSDate *endDate = [calendar dateFromComponents:endComponents];
    
    options.predicate = [NSPredicate predicateWithFormat:@"dateCreated >= %@ AND dateCreated  <= %@", startDate, endDate];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    [self.collectionView reloadData];

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








@end
