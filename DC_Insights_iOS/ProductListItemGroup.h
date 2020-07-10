//
//  ProductListItemGroup.h
//  Insights
//
//  Created by Vineet Pareek on 15/3/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductListItem.h"

@interface ProductListItemGroup : NSObject

@property NSString* name;
@property NSMutableArray<ProductListItem *> *productListItemArray;

@end
