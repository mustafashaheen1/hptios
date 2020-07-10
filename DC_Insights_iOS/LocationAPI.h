//
//  LocationAPI.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/30/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"



@interface LocationAPI : DCBaseEntity
@property (nonatomic, strong) NSDictionary *locations;
@property (nonatomic, strong) NSArray *locationObjectsGlobal;
@property (nonatomic, strong) NSArray *locationsSQLRowArray;

- (void)locationCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;

/*------------------------------------------------------------------------------
 Class Methods
 -----------------------------------------------------------------------------*/

+ (NSString *) getTableCreateStatmentForLocations;
@end


