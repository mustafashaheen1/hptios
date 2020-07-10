//
//  StarQualityViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "StarQualityViewController.h"
#import "Image.h"

#define heightForCell 220

@interface StarQualityViewController ()

@end

@implementation StarQualityViewController
@synthesize starRatingQualityImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setupNavBar];
}

- (void) setupNavBar {
    self.pageTitle = @"StarQualityViewController";
    [super setupNavBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addContentsToScrollView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addContentsToScrollView {
    int yaxis = 20;
    for (int i =0; i < [self.rating.content.star_items count]; i++) {

        StarRatingModel *starRatingModel = [self.rating.content.star_items objectAtIndex:i];
        
        Image *image = [[Image alloc] init];
        image.deviceUrl = [NSString stringWithFormat:@"starRating_%d_%d.jpg", self.rating.ratingID, starRatingModel.starRatingID];
        //image.deviceUrl = [NSString stringWithFormat:@"defect_1.jpg"];
        
        UIView *starQualityImageLocalView = [[UIView alloc] initWithFrame:CGRectMake(43, yaxis, 240, 223)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            starQualityImageLocalView.frame = CGRectMake(self.view.frame.size.width/2 + 100, yaxis, 240, 223);
        }
        starQualityImageLocalView.layer.cornerRadius = 5.0;
        starQualityImageLocalView.backgroundColor = [UIColor lightGrayColor];

        UIImageView *starDefectImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 53, 212, 158)];
        //starDefectImage.layer.cornerRadius = 5.0;
        starDefectImage.layer.borderWidth = 1.0;
        starDefectImage.layer.borderColor = [[UIColor grayColor] CGColor];
        UIImage *imageLocal = [image getImageFromDeviceUrl];
        CGFloat width = imageLocal.size.width;
        CGFloat height = imageLocal.size.height;
        //NSLog(@"%f %f", width, height);
        if (width == height) {
            starDefectImage.frame = CGRectMake(15, 53, 212, 212);
        }
        if (imageLocal) {
            [starDefectImage setImage:[image getImageFromDeviceUrl]];
        }
        starDefectImage.contentMode = UIViewContentModeScaleAspectFit;
        
        ASStarRatingView *starRatingView = [[ASStarRatingView alloc] initWithFrame:CGRectMake(10, 15, 212, 30)];
        starRatingView.rating = i+1;
        starRatingView.maxRating = i+1;
        starRatingView.canEdit = NO;
        starQualityImageLocalView.frame = CGRectMake(43, yaxis, 240, starDefectImage.frame.size.height + starRatingView.frame.size.height + 35);

        [starQualityImageLocalView addSubview:starRatingView];
        [starQualityImageLocalView addSubview:starDefectImage];
        [self.scrollView addSubview:starQualityImageLocalView];
        if (width == height) {
            yaxis = yaxis + heightForCell + 30 + 45;
        } else {
            yaxis = yaxis + heightForCell + 30;
        }
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, yaxis);
    }
}

@end
