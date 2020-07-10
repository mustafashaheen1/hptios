//
//  ProgramGroupAPI.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"

@interface ProgramGroupAPI : DCBaseEntity

@property (nonatomic, strong) NSArray *programArray;

- (void) programsGroupsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;

/*------------------------------------------------------------------------------
 Class Methods
 -----------------------------------------------------------------------------*/

+ (NSString *) getTableCreateStatmentForProgramsGroups;
+ (NSString *) getTableCreateStatmentForProgramsGroupsRatings;

@end
