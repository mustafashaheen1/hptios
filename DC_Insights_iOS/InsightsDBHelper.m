//
//  InsightsDBHelper.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/25/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "InsightsDBHelper.h"
#import "ContainerAPI.h"
#import "ContainerRatingsAPI.h"
#import "DBManager.h"
#import "DBConstants.h"
#import "StoreAPI.h"
#import "LocationAPI.h"
#import "DefectAPI.h"
#import "DefectFamiliesAPI.h"
#import "ProgramAPI.h"
#import "ProductAPI.h"
#import "ProgramGroupAPI.h"
#import "RatingAPI.h"
#import "Container.h"
#import "InspectionMinimumsAPI.h"

@implementation InsightsDBHelper

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) createAllTables {
    //create default Api Mapping tables
    NSMutableArray *createStatements = [[NSMutableArray alloc] init];
    [createStatements addObject:[ContainerAPI getTableCreateStatmentForContainer]];
    [createStatements addObject:[ContainerAPI getTableCreateStatmentForContainerRatingConditions]];
    [createStatements addObject:[ContainerRatingsAPI getTableCreateStatmentForContainerRatings]];
    [createStatements addObject:[DefectAPI getTableCreateStatmentForDefects]];
    [createStatements addObject:[DefectFamiliesAPI getTableCreateStatmentForDefectsFamilies]];
    [createStatements addObject:[ProgramAPI getTableCreateStatmentForPrograms]];
    [createStatements addObject:[ProgramGroupAPI getTableCreateStatmentForProgramsGroups]];
    [createStatements addObject:[ProgramGroupAPI getTableCreateStatmentForProgramsGroupsRatings]];
    [createStatements addObject:[ProductAPI getTableCreateStatmentForProgramsProducts]];
    [createStatements addObject:[RatingAPI getTableCreateStatmentForRatings]];
    [createStatements addObject:[StoreAPI getTableCreateStatmentForStores]];
    [createStatements addObject:[LocationAPI getTableCreateStatmentForLocations]];
    [createStatements addObject:[InspectionMinimumsAPI getTableCreateStatment]];

    //image tables
    [createStatements addObject:[DefectAPI getTableCreateStatmentForDefectsImages]];
    [createStatements addObject:[RatingAPI getTableCreateStatmentForRatingImages]];
    [createStatements addObject:[ProductAPI getTableCreateStatmentForProductQualityManual]];
    [createStatements addObject:[InspectionMinimumsAPI getTableCreateStatment]];

    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_INSIGHTS_DATA];
}

- (void) deleteAllTables {
    NSMutableArray *deleteStatements = [[NSMutableArray alloc] init];

    [deleteStatements addObject:TBL_CONTAINERS];
    [deleteStatements addObject:TBL_CONTAINER_RATING_CONDITIONS];
    [deleteStatements addObject:TBL_CONTAINER_RATINGS];
    [deleteStatements addObject:TBL_DEFECT_FAMILIES];
    [deleteStatements addObject:TBL_DEFECT_FAMILY_DEFECTS];
    [deleteStatements addObject:TBL_PROGRAMS];
    [deleteStatements addObject:TBL_PRODUCTS];
    [deleteStatements addObject:TBL_GROUPS];
    [deleteStatements addObject:TBL_GROUP_RATINGS];
    [deleteStatements addObject:TBL_RATINGS];
    [deleteStatements addObject:TBL_STORES];
    [deleteStatements addObject:TBL_DEFECT_IMAGES];
    [deleteStatements addObject:TBL_STAR_RATING_IMAGES];
    [deleteStatements addObject:TBL_PRODUCT_QUALITY_MANUAL];
    [deleteStatements addObject:TBL_INSPECTION_MINIMUMS];

    [[DBManager sharedDBManager] deleteTableUsingFMDataBase:[deleteStatements copy] withDatabasePath:DB_INSIGHTS_DATA];
}


@end
