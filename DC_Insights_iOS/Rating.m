//
//  Rating.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Rating.h"
#import "Defect.h"
#import "ParseJsonUtil.h"


@implementation Rating

@synthesize description;
@synthesize ratingID;
@synthesize name;
@synthesize type;
@synthesize content;
@synthesize contentPreProcessed;
@synthesize container_id;
@synthesize defect_family_id;
@synthesize defects;
@synthesize containerID;
@synthesize order_position;
@synthesize options;
@synthesize optionalSettingsPreProcessed;
@synthesize groupRatingID;
@synthesize ratingAnswerFromUI;
@synthesize defectsFromDefectAPI;
@synthesize order_data_field;
@synthesize displayName;
@synthesize default_star;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.defectsFromUI = [[NSMutableArray alloc] init];
        self.defects = [[NSMutableArray alloc] init];
        self.defectsIdList = [[NSMutableArray alloc] init];
    }
    return self;
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void) addDefect:(Defect *) defect {
    [self.defectsFromUI addObject:defect];
}

- (BOOL)isEqual:(id)object {
    Rating *copy = (Rating *) object;
//    if (self == copy)
//        return true;
//    if (![super isEqual:copy])
//        return false;
//    if ([self class] != [copy class])
//        return false;
    if(self.ratingID == copy.ratingID) {
        return true;
    }
    else
        return false;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    NSInteger copy = self.ratingID;
    result = prime * result + copy;
    return result;
}

/*------------------------------------------------------------------------------
 Get All The Defects
 -----------------------------------------------------------------------------*/

- (NSArray *) getAllDefects {
    NSMutableArray *defectsLocal = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveDataFromDBForDefects]];
    while ([results next]) {
        Defect *defect = [[Defect alloc] init];
        defect.defectID = [results intForColumn:COL_ID];
        if (![self.defectsIdList containsObject:[NSNumber numberWithInt:defect.defectID]]) {
            continue;
        }
        defect.name = [results stringForColumn:COL_NAME];
        defect.display = [results stringForColumn:COL_DISPLAY_NAME];
        defect.coverage_type = [results stringForColumn:COL_COVERAGE_TYPE];
        defect.description = [results stringForColumn:COL_DESCRIPTION];
        defect.image_url = [results stringForColumn:COL_IMAGE_URL_REMOTE];
        defect.order_position = [results intForColumn:COL_ORDER_POSITION];
        defect.defectGroupName = [results stringForColumn:COL_DEFECT_GROUP_NAME];
        defect.defectGroupID = [results intForColumn:COL_DEFECT_GROUP_ID];
        defect.enable_html_description = [results boolForColumn:COL_HTML_DESCRIPTION_ENABLED];
        defect.html_description_source = [results stringForColumn:COL_HTML_DESCRIPTION];
        if ([defect.defectGroupName isEqualToString:@""] || !defect.defectGroupName) {
            defect.defectGroupName = OtherDefectGroup;
        }
        NSMutableArray *severitiesArray = [[NSMutableArray alloc] init];
        NSArray *arrayThresholds = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_THRESHOLDS]];

        NSMutableArray *totalThreshold = [self getTotalThresholdValueForDefect:defect.defectID withDatabase:(FMDatabase*)database];
        defect.thresholdTotal = [[totalThreshold objectAtIndex:0] intValue];
        defect.thresholdAcceptWithIssues = [[totalThreshold objectAtIndex:1] intValue];
        
        for (NSDictionary *dictThreshold in arrayThresholds) {
            Severity *severity = [[Severity alloc] init];
            severity.id = [ParseJsonUtil parseIntegerFromJson:dictThreshold key:@"id"];
            severity.criteriaAcceptWithIssues = [ParseJsonUtil parseIntegerFromJson:dictThreshold key:@"accept_with_issues"];
            severity.name = [ParseJsonUtil parseStringFromJson:dictThreshold key:@"name"];
            severity.order_position = [ParseJsonUtil parseIntegerFromJson:dictThreshold key:@"order_position"];
            severity.criteriaReject = [ParseJsonUtil parseIntegerFromJson:dictThreshold key:@"reject"];
            severity.thresholdTotal = [[totalThreshold objectAtIndex:0] intValue];
            severity.thresholdAcceptWithIssues = [[totalThreshold objectAtIndex:1] intValue];
            [severitiesArray addObject:severity];
        }
        defect.severities = severitiesArray;
        if ([severitiesArray count] > 0 && [severitiesArray count] == 1) {
            Severity *sev = [severitiesArray objectAtIndex:0];
            defect.severityNameForSortingLater = sev.name;
        } else {
            defect.severityNameForSortingLater = @"A";
        }
        
        [defectsLocal addObject:defect];
    }
    [database close];
    NSArray *sortedDefects = [self getDefectsInSortedOrder:defectsLocal];
    self.defectsFromDefectAPI = sortedDefects;
    self.defects = [sortedDefects mutableCopy];
    return sortedDefects;
}


- (NSArray *) getDefectsInSortedOrder: (NSArray *) sortRatingsArray {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order_position" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    NSArray *sortedArray = [sortRatingsArray sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

- (NSArray*) getTotalThresholdValueForDefect:(int) defectId withDatabase:(FMDatabase *) databaseLocal{
    NSMutableArray *totalThreshold = [[NSMutableArray alloc] init];
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_DEFECT_FAMILIES];
    //resuse database connection to avoid crashes
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    FMResultSet *results;
    //[database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        NSArray *defectsList = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_DEFECTS]];
        int total = [results intForColumn:COL_TOTAL];
        int acceptTotal = [results intForColumn:COL_ACCEPT_ISSUES_TOTAL];
        for(NSString *stringValue in defectsList) {
            int defectIdLocal = [stringValue integerValue];
            if(defectIdLocal == defectId) {
                [totalThreshold addObject:[NSNumber numberWithInt:total]];
                [totalThreshold addObject:[NSNumber numberWithInt:acceptTotal]];
                break;
            }
        }
    }
    if (!databaseLocal) {
        [database close];
    }
    return totalThreshold;
}

- (NSArray*) getGlobalThresholds:(int) defectFamilyId withDatabase:(FMDatabase *) databaseLocal{
    NSMutableArray *totalThreshold = [[NSMutableArray alloc] init];
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_DEFECT_FAMILIES, COL_ID, defectFamilyId];
    //resuse database connection to avoid crashes
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    FMResultSet *results;
    //[database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        int total = [results intForColumn:COL_TOTAL];
        int acceptTotal = [results intForColumn:COL_ACCEPT_ISSUES_TOTAL];
                [totalThreshold addObject:[NSNumber numberWithInt:total]];
                [totalThreshold addObject:[NSNumber numberWithInt:acceptTotal]];
    }
    if (!databaseLocal) {
        [database close];
    }
    return totalThreshold;
}
-(int) getDefectFamilyId:(NSInteger) productId withGroupId:(NSInteger) groupId withRatingId:(NSInteger) ratingId withDatabase:(FMDatabase *) databaseLocal{
    int defectFamilyId = [self getDefectFamilyIdForProductSpecified:productId withGroupId:groupId withRatingId:ratingId withDatabase:databaseLocal];
    if(defectFamilyId == 0)
        defectFamilyId = [self getDefectFamilyIdFromGroupRatings:groupId withRatingId:ratingId withDatabase:databaseLocal];

    return defectFamilyId;
}

-(int) getDefectFamilyIdForProductSpecified:(NSInteger) productId withGroupId:(NSInteger) groupId withRatingId:(NSInteger) ratingId withDatabase:(FMDatabase *) databaseLocal {
    int defectFamilyId = 0;
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%d AND %@=%d", COL_RATING_DEFECTS, TBL_PRODUCTS, COL_GROUP_ID, groupId, COL_ID, productId];
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    FMResultSet *results;
    //[database open];
    results = [database executeQuery:retrieveStatement];
    NSArray *rating_defects;
    while ([results next]) {
        rating_defects = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_RATING_DEFECTS]];
        for(NSDictionary *rating_defect in rating_defects){
            id temp = [rating_defect objectForKey:@"rating_id"];
            if([temp isKindOfClass:[NSNull class]])
                continue;
            NSInteger ratId = [[rating_defect objectForKey:@"rating_id"] integerValue];
            if(ratId == ratingID){
                defectFamilyId = [[rating_defect objectForKey:@"defect_family_id"] intValue];
            }
        }
        NSLog(@"Rating Defects");
    }
    if (!databaseLocal) {
        [database close];
    }
    return defectFamilyId;
}


-(int) getDefectFamilyIdFromGroupRatings:(NSInteger) groupId withRatingId:(NSInteger) ratingId withDatabase:(FMDatabase *) databaseLocal {
    int defectFamilyId = 0;
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%d AND %@=%d", COL_DEFECT_FAMILY_ID, TBL_GROUP_RATINGS, COL_GROUP_ID, groupId, COL_ID, ratingId];
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    FMResultSet *results;
    //[database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        defectFamilyId = [results intForColumn:COL_DEFECT_FAMILY_ID];
    }
    if (!databaseLocal) {
        [database close];
    }
    return defectFamilyId;
}
- (NSArray*) getSeverityTotals:(int) defectFamilyId withDatabase:(FMDatabase *) databaseLocal{
    NSArray *severityTotalArray = [[NSArray alloc]init];
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_DEFECT_FAMILIES, COL_ID, defectFamilyId];
    //resuse database connection to avoid crashes
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    FMResultSet *results;
    //[database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
         severityTotalArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_SEVERITY_TOTALS]];
        
        }
        
    if (!databaseLocal) {
        [database close];
    }
    return severityTotalArray;
}
- (void) populateThresholdsForRating:(int) containerId withProgramId: (int) programId withDatabase: (FMDatabase *) database {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d AND %@=%d AND %@=%d", TBL_CONTAINER_RATING_CONDITIONS, COL_CONTAINER_ID, containerId, COL_PROGRAM_ID, programId, COL_RATING_ID, self.ratingID];
    //NSLog(@"retrwe %@", retrieveStatement);
    FMResultSet *results;
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        NSDictionary *optionalSettingsDict = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_OPTIONAL_SETTINGS]];
        OptionalSettings *optionalSettings = [[OptionalSettings alloc] init];
        optionalSettings.optional = [ParseJsonUtil parseBoolFromJson:optionalSettingsDict key:@"optional"];
        optionalSettings.persistent = [ParseJsonUtil parseBoolFromJson:optionalSettingsDict key:@"persistent"];
        optionalSettings.defects = [ParseJsonUtil parseBoolFromJson:optionalSettingsDict key:@"defects"];
        optionalSettings.picture = [ParseJsonUtil parseBoolFromJson:optionalSettingsDict key:@"picture"];
        optionalSettings.scannable = [ParseJsonUtil parseBoolFromJson:optionalSettingsDict key:@"scannable"];
        optionalSettings.rating = [ParseJsonUtil parseBoolFromJson:optionalSettingsDict key:@"rating"];
        self.optionalSettings = optionalSettings;
        
        NSDictionary *thresholdsDict = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_THRESHOLDS]];
        PictureAndDefectThresholds *pictureAndDefectThresholdsLocal = [[PictureAndDefectThresholds alloc] init];
        pictureAndDefectThresholdsLocal.picture = [ParseJsonUtil parseIntegerFromJson:thresholdsDict key:@"picture"];
        pictureAndDefectThresholdsLocal.defects = [ParseJsonUtil parseIntegerFromJson:thresholdsDict key:@"defects"];
        self.pictureAndDefectThresholds = pictureAndDefectThresholdsLocal;
    }
}

//// for each rating go to TBL_CONTAINER_RATING_CONDITONS and get thresolds and conditions
//public void populateThresholdsForRating(Rating rating, Context context) {
//    int ratingId = rating.id;
//    String queryAllDefects = DBManager.buildQueryString(Constants.TBL_CONTAINER_RATING_CONDITIONS, null, Constants.COL_CONTAINER_ID+"="+this.id+" AND "+Constants.COL_PROGRAM_ID+"="+this.programId+" AND "+Constants.COL_RATING_ID+"="+ratingId, null, null, null, null);
//    InsightsDBHelper dbHelper = InsightsDBHelper.getInstance(context);
//    Cursor defectCursor = DBManager.executeRawSqlQuery(dbHelper, queryAllDefects);
//    Gson gson = new Gson();
//    if(defectCursor!=null) {
//        if (defectCursor.moveToFirst()) {
//            String thresholds = defectCursor.getString(defectCursor.getColumnIndex(Constants.COL_THRESHOLDS));
//            String optionalSettings = defectCursor.getString(defectCursor.getColumnIndex(Constants.COL_OPTIONAL_SETTINGS));
//            PictureAndDefectThresholds defectThresholds = gson.fromJson(thresholds, PictureAndDefectThresholds.class);
//            OptionalSettings optSettings = gson.fromJson(optionalSettings, OptionalSettings.class);
//            rating.optionalSettings = optSettings;
//            rating.pictureAndDefectThresholds = defectThresholds;
//        } 
//        defectCursor.close();
//    }
//}

-(QualityManual*)getQualityManual{
    NSLog(@"self.defect fam id is: %ld", self.defect_family_id);
    int defectFamilyId = (int)self.defect_family_id;
    if(defectFamilyId == 0)
        return nil;
    
    NSDictionary* qualityManualContent = [[NSDictionary alloc]init];
    QualityManual *qualityManual = nil;
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_DEFECT_FAMILIES, COL_ID,(int)defectFamilyId];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        qualityManualContent = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_QUALITY_MANUAL_CONTENT]];
        if(qualityManualContent){
            qualityManual = [[QualityManual alloc] init];
            qualityManual.pdf = [ParseJsonUtil parseStringFromJson:qualityManualContent key:@"pdf"];
            qualityManual.html = [ParseJsonUtil parseStringFromJson:qualityManualContent key:@"html"];
            qualityManual.updated_at = [ParseJsonUtil parseStringFromJson:qualityManualContent key:@"updated_at"];
        }
    }
    [database close];
    if(!qualityManual.pdf && !qualityManual.html)
        return nil;
    
    return qualityManual;
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveDataFromDBForDefects {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_DEFECT_FAMILY_DEFECTS];
    return retrieveStatement;
}


@end
