//
//  Container.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"

@interface ContainerAPI : DCBaseEntity

@property (nonatomic, retain) NSArray *sqlRowArray;

- (void)containerCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;

/*------------------------------------------------------------------------------
 Class Methods
 -----------------------------------------------------------------------------*/

+ (NSString *) getTableCreateStatmentForContainer;
+ (NSString *) getTableCreateStatmentForContainerRatingConditions;

@end

