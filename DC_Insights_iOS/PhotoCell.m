//
//  PhotoCell.m
//  OverPicker
//
//  Created by Brandon Trebitowski on 7/24/13.
//  Copyright (c) 2013 Brandon Trebitowski. All rights reserved.
//

#import "PhotoCell.h"

@interface PhotoCell ()
@end

@implementation PhotoCell

- (void) setAsset:(ALAsset *)asset
{
    _asset = asset;
    [self.photoImageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
}

@end
