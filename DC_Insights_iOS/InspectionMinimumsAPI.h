//
//  InspectionMinimumsAPI.h
//  Insights
//
//  Created by Vineet on 2/27/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"
#import "InspectionMinimums.h"

@interface InspectionMinimumsAPI : DCBaseEntity

@property (nonatomic, strong) NSArray* inspectionMinimumsArray;

//- (void)apiCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;
-(InspectionMinimums*)getMinimumInspectionForGroup:(int)productGroupId;

+ (NSString *) getTableCreateStatment;

@end
