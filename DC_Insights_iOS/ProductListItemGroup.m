//
//  ProductListItemGroup.m
//  Insights
//
//  Created by Vineet Pareek on 15/3/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "ProductListItemGroup.h"

@implementation ProductListItemGroup
-(id)mutableCopyWithZone:(NSZone *)zone
{
  // We'll ignore the zone for now
  ProductListItemGroup *another = [[ProductListItemGroup alloc] init];
    another.name = self.name;
    another.productListItemArray = [self.productListItemArray copyWithZone:zone];

  return another;
}
@end
