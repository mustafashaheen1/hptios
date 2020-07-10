//
//  GalleryView.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/28/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "GalleryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoCell.h"
#import "Constants.h"
#import "Image.h"

@interface GalleryViewController ()
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

@implementation GalleryViewController

@synthesize assets;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"GalleryViewController";
    [self setupNavBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.assetGroups = [[NSMutableArray alloc] init];
    self.assets = [[NSMutableArray alloc] init];
    //[self setupAssetsLibraryWithPhotos];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
}

//- (void) setupAssetsLibraryWithPhotos {
////    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
////    // Enumerate Albums
////    ALAssetsLibrary *assetsLibrary = [GalleryViewController defaultAssetsLibrary];
////    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
////        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
////            if(result)
////            {
////                // 3
////                [tmpAssets addObject:result];
////            }
////        }];
////        
////        // 4
////        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
////        //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
////        self.assets = tmpAssets;
////        
////        // 5
////        [self.collectionView reloadData];
////    } failureBlock:^(NSError *error) {
////        NSLog(@"Error loading images %@", error);
////    }];
//
//    dispatch_async(dispatch_get_main_queue(), ^
//                   {
//                       void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
//                       {
//                           if (group == nil)
//                           {
//                               return;
//                           }
//                           if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:ALBUMNAME]) {
//                               [self.assetGroups addObject:group];
//                               [self loadImages];
//                               return;
//                           }
//                           
//                           if (stop) {
//                               return;
//                           }
//                           
//                       };
//                       
//                       // Group Enumerator Failure Block
//                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
//                           
//                           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"No Albums Available"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                           [alert show];
//                       };
//                       
//                       // Enumerate Albums
//                       ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
//                                              [assetslibrary enumerateGroupsWithTypes:ALAssetsGroupAll
//                                                                     usingBlock:assetGroupEnumerator
//                                                                   failureBlock:assetGroupEnumberatorFailure];
//                       
//                       
//                   });
//}
//
//- (void) loadImages {
//    ALAssetsGroup *assetGroup = [self.assetGroups objectAtIndex:0];
//    NSLog(@"ALBUM NAME:;%@",[assetGroup valueForProperty:ALAssetsGroupPropertyName]);
//    [assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
//     {
//         if(result == nil)
//         {
//             [self.collectionView reloadData];
//             return;
//         } else {
//             UIImage *img = [UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage] scale:1.0 orientation:(UIImageOrientation)[[result valueForProperty:@"ALAssetPropertyOrientation"] intValue]];
//             NSLog(@"images %@", img);
//             [self.assets addObject:img];
//         }
//     }];
//}


#pragma mark - assets

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imagesArray count]; //self.assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 104, 104)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    Image *image = [self.imagesArray objectAtIndex:indexPath.row];
    imageView.image = [image getImageFromDeviceUrl];
    [cell addSubview:imageView];
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

#pragma mark - collection view delegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    ALAsset *asset = self.assets[indexPath.row];
//    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
//    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
    // Do something with the image
}

#pragma mark - Actions

- (IBAction)takePhotoButtonTapped:(id)sender
{
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;

}



@end
