//
//  GalleryView.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/28/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"

@interface GalleryViewController : ParentNavigationViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) NSMutableArray *assets;
@property(nonatomic, strong) NSMutableArray *assetGroups;
@property(nonatomic, strong) NSArray *imagesArray;

@end
