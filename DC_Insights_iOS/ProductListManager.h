//
//  DCInspection.h
//  Insights
//
//  Created by Vineet Pareek on 15/3/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductListManager : NSObject

-(NSMutableArray*)getProductsList:(BOOL)allProducts;
-(NSMutableArray*)populateCollaborativeInspectionDataInProductList:(NSMutableArray*)productList;
//-(NSArray*)getFlattenedProductsList:(BOOL)allProducts;
//-(NSArray*)getSkusForProductsList:(BOOL)allProducts;

@end
