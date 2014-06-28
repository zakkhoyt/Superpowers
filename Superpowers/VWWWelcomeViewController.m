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
//    self.imageManager = [[PHCachingImageManager alloc] init];
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                        @"Share on Facebook",
                        @"Share on Twitter",
                        @"Share via E-mail",
                        @"Save to Camera Roll",
                        @"Rate this App",
                        nil];
    [self.actionSheet showFromRect:sender.frame inView:self.view animated:YES];
}


#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [NSTimer scheduledTimerWithTimeInterval:0.1 block:^{
        self.alertView = nil;
        VWW_LOG_INFO(@"Oxpening app's settings page");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } repeats:NO];
    
}

@end
