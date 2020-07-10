//
//  Program.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"

@interface ProgramAPI : DCBaseEntity

@property (nonatomic, strong) NSArray *programArray;

- (void)programsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;
- (void)programsCallForChecking:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;

/*------------------------------------------------------------------------------
 Class Methods
 -----------------------------------------------------------------------------*/

+ (NSString *) getTableCreateStatmentForPrograms;

@end
