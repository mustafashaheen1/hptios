//
//  CEProduct.h
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "CEProductBrand.h"

@interface CEProduct : JSONModel

@property NSString* name;
@property NSString* image_url;
@property NSString* upc;
@property NSString* commodity;
@property CEProductBrand* brand;

@end
