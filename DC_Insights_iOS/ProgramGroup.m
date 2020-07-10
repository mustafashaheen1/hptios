//
//  ProgramGroup.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/25/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ProgramGroup.h"
#import "Product.h"

@implementation ProgramGroup

@synthesize audit_count;
@synthesize programGroupID;
@synthesize name;
@synthesize program_id;
@synthesize ratings;
@synthesize ratingsPreProcessed;
@synthesize products;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.audit_count = 0;
        self.programGroupID = 0;
        self.name = @"";
        self.program_id = 0;
        self.ratings = [[NSArray alloc] init];
        self.products = [[NSArray alloc] init];
        self.savedAudits = [[NSArray alloc] init];
        self.inspectionMinimumId = -1;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    ProgramGroup *copy = (ProgramGroup *) object;
    if (self.programGroupID == copy.programGroupID) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [[NSString stringWithFormat:@"%d", self.programGroupID] hash];
    return result;
}

/*------------------------------------------------------------------------------
 Get All The Products
 -----------------------------------------------------------------------------*/

- (NSArray *) getAllProducts {
    NSMutableArray *productsLocal = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveDataFromDBForProducts]];
    while ([results next]) {
        Product *product = [[Product alloc] init];
        product.product_id = [results intForColumn:COL_ID];
       
        product.group_id = [results intForColumn:COL_GROUP_ID];
        product.program_id = [results intForColumn:COL_PROGRAM_ID];
        product.program_version = [self getProgramVersionNumberFromProgramId:product.program_id withDatabaseOpen:database];
        product.auditsCount = [self getAuditsCountNumberFromProgramId:product.program_id withDatabaseOpen:database];
        product.product_name = [results stringForColumn:COL_PRODUCT_NAME];
        product.name = [results stringForColumn:COL_PRODUCT_NAME];
        product.commodity = [results stringForColumn:COL_COMMODITY];
        product.variety = [results stringForColumn:COL_VARIETY];
        product.containers = self.containers;
        //NSString* daysRemainingString = [results stringForColumn:COL_DAYS_REMAINING];
        //product.daysRemaining = [daysRemainingString intValue];
        product.daysRemaining = [results intForColumn:COL_DAYS_REMAINING];
        product.daysRemainingMax = [results intForColumn:COL_DAYS_REMAINING_MAX];
        NSArray *arrayUPC;
        if ([results dataForColumn:COL_UPC]) {
            arrayUPC = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_UPC]];
        }
        product.upcs = arrayUPC;
        
        NSArray *arrayPLU;
        if ([results dataForColumn:COL_PLU]) {
            arrayPLU = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_PLU]];
        }
        product.plus = arrayPLU;
        
        NSArray *arraySKUS;
        if ([results dataForColumn:COL_SKUS]) {
            arraySKUS = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_SKUS]];
        }
        product.skus = arraySKUS;
        
        NSArray *rating_defects;
        if ([results dataForColumn:COL_RATING_DEFECTS]) {
            rating_defects = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_RATING_DEFECTS]];
        }
        product.rating_defects = rating_defects;
        
        product.insights_product = [results intForColumn:COL_INSIGHTS_PRODUCT];
        product.require_hm_code = [results intForColumn:COL_REQUIRE_HM_CODE];
        QualityManual *qualityManual = [[QualityManual alloc] init];
        if ([results stringForColumn:COL_QUALITY_MANUAL_CONTENT]) {
            qualityManual.updated_at = [self parseDateFromJson:@{COL_QUALITY_MANUAL_CONTENT : [results stringForColumn:COL_QUALITY_MANUAL_CONTENT]} key:COL_QUALITY_MANUAL_CONTENT];
        }
        qualityManual.pdf = [results stringForColumn:COL_QUALITY_MANUAL_URL];
        product.qualityManual = qualityManual;
        [productsLocal addObject:product];
    }
    [database close];
    NSArray *sortedArray = [self sortListOfProductsForTheProgramGroup:productsLocal];
    return sortedArray;
}

- (NSArray *) sortListOfProductsForTheProgramGroup: (NSArray *) groupsArray {
    NSArray *sortedArray = [[NSArray alloc] init];
    if ([groupsArray count] > 0) {
        /*NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"group_id" ascending:YES];*/
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sort];
        sortedArray = [groupsArray sortedArrayUsingDescriptors:sortDescriptors];
    }
    return sortedArray;
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveDataFromDBForProducts {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_PRODUCTS, COL_GROUP_ID, self.programGroupID];
    return retrieveStatement;
}

- (NSString *) getProgramVersionNumberFromProgramId: (int) programId withDatabaseOpen: (FMDatabase *) database {
    NSString *programVersionNumber = @"";
    FMResultSet *results;
    results = [database executeQuery:[self retrieveVersionNumberFromId:programId]];
    while ([results next]) {
        programVersionNumber = [results stringForColumn:COL_VERSION];
    }
    return programVersionNumber;
}

- (int) getAuditsCountNumberFromProgramId: (int) programId withDatabaseOpen: (FMDatabase *) database {
    int auditsCount = 0;
    FMResultSet *results;
    results = [database executeQuery:[self retrieveAuditCountNumberFromId:programId]];
    while ([results next]) {
        auditsCount = [results intForColumn:COL_AUDIT_COUNT];
    }
    return auditsCount;
}

- (NSString *) retrieveVersionNumberFromId:(int) programId {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id=%d", TBL_PROGRAMS, programId];
    return retrieveStatement;
}

- (NSString *) retrieveAuditCountNumberFromId:(int) programId {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE program_id=%d", TBL_GROUPS, programId];
    return retrieveStatement;
}

-(id) mutableCopyWithZone: (NSZone *) zone {
    ProgramGroup *programGroup = [[ProgramGroup alloc]init];
    programGroup.audit_count = self.audit_count;
    programGroup.inspectionMinimumId = self.inspectionMinimumId;
    programGroup.programGroupID = self.programGroupID;
    programGroup.name = self.name;
    programGroup.program_id = self.program_id;
    programGroup.containers = [self.containers copy];
    programGroup.ratings = [self.ratings copy];
    programGroup.ratingsPreProcessed = [self.ratingsPreProcessed copy];
    programGroup.products = [self.products copy];
    programGroup.savedAudits = self.savedAudits;
    programGroup.audit_count_data = self.audit_count_data;
    programGroup.auditMinimumsBy = self.auditMinimumsBy;
    programGroup.acceptRequired = self.acceptRequired;
    programGroup.acceptRecommended = self.acceptRecommended;
    programGroup.acceptIssuesRequired = self.acceptIssuesRequired;
    programGroup.acceptIssuesRecommended = self.acceptIssuesRecommended;
    programGroup.rejectRequired = self.rejectRequired;
    programGroup.rejectRecommended = self.rejectRecommended;
    return programGroup;
}

@end
