//
//  ApplyToAllViewController.m
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 1/27/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "ApplyToAllViewController.h"
#import "HomeScreenViewController.h"
@interface ApplyToAllViewController ()

@end

@implementation ApplyToAllViewController
@synthesize productRatingView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated
{
    self.pageTitle = @"ApplyToAllViewController";
    [self setupNavBar];
    [self initViewModel];
    [self addRatingView];
}

- (void) setupNavBar {
    [super setupNavBar];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initViewModel];
    }
    return self;
}

-(void)initViewModel {
    self.viewModel = [[ApplyToAllViewModel alloc]init];
    [self.viewModel getAllRatings];
}
- (void) addRatingView
{
    ProductRatingViewController *productRatingViewLocal = [[ProductRatingViewController alloc] initWithNibName:kProductRatingViewNIBName bundle:nil];
    productRatingViewLocal.view.frame = CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height);
    productRatingViewLocal.delegate = self;
    productRatingViewLocal.ratingsGlobal = self.viewModel.ratings;
    [productRatingViewLocal.ratingsTableView reloadData];
    productRatingViewLocal.parentView = @"ApplyToAllViewController";
    self.productRatingView = productRatingViewLocal;
    [self.view addSubview:productRatingViewLocal.view];
}
- (void) saveButtonTouched {
    
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Finish Inspection?" message:@"Finishing the inspection will prevent further modifications."
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Ok", nil];
        [alert setTag:1];
        [alert show];
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
       if(alertView.tag==1) {
           if (buttonIndex == alertView.cancelButtonIndex) {
               
           }
           if (buttonIndex == alertView.firstOtherButtonIndex) {
               [self.productRatingView submitAnswersTouched:self];
               
           }
       }
       
   }
- (void) proceedToNextGroup:(NSDictionary *) ratingsReponses withSuccess:(BOOL)success {
    
    if(success){
        if ([ratingsReponses count] > 0) {
            for (Rating *rating in ratingsReponses) {
                [self.viewModel.ratings addObject:rating];
                
            }
        }
    [self finishInspection];
    }else{
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
    }
    
}
   -(void) finishInspection {
       [self showLoadingScreenWithText:@"Saving..."];
       //return rating answers to parent screen
       [self.viewModel completeApplyToAll];
       
       HomeScreenViewController *homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
       [self.navigationController pushViewController:homeScreenViewController animated:YES];

   }

- (void) cameraButtonTouched {
}
@end
