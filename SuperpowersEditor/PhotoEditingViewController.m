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


typedef enum {
    PhotoEditingViewControllerTypeMapOnImage = 0,
    PhotoEditingViewControllerTypeImageOnMap = 1,
    PhotoEditingViewControllerTypeTextOnImage = 2,
} PhotoEditingViewControllerType;

@interface PhotoEditingViewController () <PHContentEditingController>
@property (strong) PHContentEditingInput *input;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;

@end

@implementation PhotoEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
//    // Inspect the adjustmentData to determine whether your extension can work with past edits.
//    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
//    return NO;

    BOOL result = [adjustmentData.formatIdentifier isEqualToString:@"com.example.apple-samplecode.photofilter"];
    result &= [adjustmentData.formatVersion isEqualToString:@"1.0"];
    return result;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned NO, the contentEditingInput has past edits "baked in".
    self.input = contentEditingInput;
    self.imageView.image = placeholderImage;
    self.locationLabel.text = [NSString stringWithFormat:@"%.4f,%.4f", contentEditingInput.location.coordinate.latitude, contentEditingInput.location.coordinate.longitude];
    [VWWUtility stringFromLocation:contentEditingInput.location completionBlock:^(NSString *name) {
        self.locationNameLabel.text = name;
    }];
    
}
- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
    // Update UI to reflect that editing has finished and output is being rendered.
    
    // Render and provide output on a background queue.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Create editing output from the editing input.
        PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
        
        // Provide new adjustments and render output to given location.
        // output.adjustmentData = <#new adjustment data#>;
        // NSData *renderedJPEGData = <#output JPEG#>;
        // [renderedJPEGData writeToURL:output.renderedContentURL atomically:YES];
        
        // Call completion handler to commit edit to Photos.
        completionHandler(output);
        
        // Clean up temporary files, etc.
    });
}

- (void)cancelContentEditing {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
}


#pragma mark Private methods
- (IBAction)buttonTouchUpInside:(id)sender {
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(indexPath.row == PhotoEditingViewControllerTypeImageOnMap){
        cell.textLabel.text = @"Image on Map";
    } else if(indexPath.row == PhotoEditingViewControllerTypeMapOnImage){
        cell.textLabel.text = @"Map on Image";
    } else if(indexPath.row == PhotoEditingViewControllerTypeTextOnImage){
        cell.textLabel.text = @"Text on Image";
    }
    return cell;
}



@end
