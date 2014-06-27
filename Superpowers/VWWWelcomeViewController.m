//
//  VWWWelcomeViewController.m
//  Superpowers
//
//  Created by Zakk Hoyt on 6/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWWelcomeViewController.h"
@import Photos;

@interface VWWWelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UIButton *promptButton;
@property (strong) PHCachingImageManager *imageManager;
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
//    self.promptButton.hidden = YES;
//    self.startButton.hidden = YES;
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

- (IBAction)startButtonTouchUpInside:(id)sender {
    
}


- (IBAction)promptButtonTouchUpInside:(id)sender {
    self.imageManager = [[PHCachingImageManager alloc] init];
}


@end
