//
//  ImageArray.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/28/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "Image.h"

@interface ImageArray : JSONModel

@property (nonatomic, strong) NSArray<Image> *images;

@end
