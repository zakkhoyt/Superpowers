//
//  VWWLibraryViewController.m
//  Superpowers
//
//  Created by Zakk Hoyt on 6/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLibraryViewController.h"
@import Photos;


@interface VWWLibraryViewController () <PHPhotoLibraryChangeObserver>
@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation VWWLibraryViewController

static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

-(void)viewDidLoad{
    [super viewDidLoad];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.collectionsFetchResults = @[smartAlbums, topLevelUserCollections];
    self.collectionsLocalizedTitles = @[NSLocalizedString(@"Smart Albums", @""), NSLocalizedString(@"Albums", @"")];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + self.collectionsFetchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 1; // "All Photos" section
    } else {
        PHFetchResult *fetchResult = self.collectionsFetchResults[section - 1];
        numberOfRows = fetchResult.count;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *localizedTitle = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:AllPhotosReuseIdentifier forIndexPath:indexPath];
        localizedTitle = NSLocalizedString(@"All Photos", @"");
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
        PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section - 1];
        PHCollection *collection = fetchResult[indexPath.row];
        localizedTitle = collection.localizedTitle;
    }
    cell.textLabel.text = localizedTitle;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section > 0) {
        title = self.collectionsLocalizedTitles[section - 1];
    }
    return title;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
////    if ([segue.identifier isEqualToString:AllPhotosSegue]) {
//    if(indexPath.section == 0){
////        AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
//        // Fetch all assets, sorted by date created.
//        PHFetchOptions *options = [[PHFetchOptions alloc] init];
//        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
//
////        NSCalendar *calendar = [NSCalendar currentCalendar];
////        NSDateComponents *startComponents = [[NSDateComponents alloc]init];
////        startComponents.year = 2014;
////        startComponents.month = 1;
////        startComponents.day = 1;
////        NSDate *startDate = [calendar dateFromComponents:startComponents];
////
////        NSDateComponents *endComponents = [[NSDateComponents alloc]init];
////        endComponents.year = 2014;
////        endComponents.month = 2;
////        endComponents.day = 1;
////        NSDate *endDate = [calendar dateFromComponents:endComponents];
////
////        options.predicate = [NSPredicate predicateWithFormat:@"dateCreated >= %@ AND dateCreated  <= %@", startDate, endDate];
////        assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
//        
//        
//    } else if (indexPath.section > 0) {
//        AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
//
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//        PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section - 1];
//        PHCollection *collection = fetchResult[indexPath.row];
//        if ([collection isKindOfClass:[PHAssetCollection class]]) {
//            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
//            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
//            assetGridViewController.assetsFetchResults = assetsFetchResult;
//            assetGridViewController.assetCollection = assetCollection;
//        }
//    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
            [self.tableView reloadData];
        }
        
    });
}

#pragma mark - Actions

- (IBAction)handleAddButtonItem:(id)sender
{
    // Prompt user from new album title.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Album", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Album Name", @"");
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSString *title = textField.text;
        
        // Create new album.
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error creating album: %@", error);
            }
        }];
    }]];
    
    [self presentViewController:alertController animated:YES completion:NULL];
}


@end
