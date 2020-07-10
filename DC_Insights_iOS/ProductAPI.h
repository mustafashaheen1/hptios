//
//  ProductAPI.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"

@interface ProductAPI : DCBaseEntity

@property (nonatomic, strong) NSArray *sqlRowArray;

- (void) programsProductsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;

/*------------------------------------------------------------------------------
 Class Methods
 -----------------------------------------------------------------------------*/

+ (NSString *) getTableCreateStatmentForProgramsProducts;
+ (NSString *) getTableCreateStatmentForProductQualityManual;

@end
