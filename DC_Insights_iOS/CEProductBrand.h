//
//  CEProductBrand.h
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "CEProductBrandCompany.h"

@interface CEProductBrand : JSONModel

@property NSString* name;
@property NSString* image_url;
@property CEProductBrandCompany* company;
@end
