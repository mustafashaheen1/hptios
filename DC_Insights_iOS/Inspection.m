//
//  Inspection.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Inspection.h"
#import "DBConstants.h"
#import "AuditApiContainerRating.h"
#import "AuditApiContainerParent.h"
#import "SavedAudit.h"
#import "SavedInspection.h"
#import "ImageArray.h"
#import "Summary.h"
#import "OrderData.h"
#import "ProgramGroup.h"
#import "Product.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "CollabLocalUpdatesDB.h"
#import "CollaborativeInspection.h"

static Inspection *_sharedDCInspection = nil;

// destroys sharedInstance after main exits.. REQUIRED for unit tests
// to work correclty, otherwse the FIRST shared object gets used for ALL
// tests, resulting in KVO problems

__attribute__((destructor)) static void destroy_singleton() {
	@autoreleasepool {
		_sharedDCInspection = nil;
	}
}

@implementation Inspection

@synthesize auditMasterId;
@synthesize currentAuditGroupId;
@synthesize trackingKey;
@synthesize currentProgram;
@synthesize selectedContainer;
@synthesize allInspectionProducts;
@synthesize currentAudit;
@synthesize isInspectionActive;
@synthesize containerImages;
@synthesize poNumberGlobal;
@synthesize grnGlobal;
@synthesize collobarativeInspection;
@synthesize currentSplitGroupId;
@synthesize nonOrderDataInspectionValues;

/*------------------------------------------------------------------------------
 METHOD: sharedInspection
 
 PURPOSE:
 Gets the shared Inspection instance object and creates it if
 necessary.
 
 RETURN VALUE:
 The shared Inspection.
 
 -----------------------------------------------------------------------------*/
+ (Inspection *) sharedInspection
{
	if (_sharedDCInspection == nil)
		[Inspection initialize] ;
    
	return _sharedDCInspection ;
}

/*------------------------------------------------------------------------------
 Singleton Methods.. Generic to any Singleton
 -----------------------------------------------------------------------------*/
#pragma mark - Singleton Methods

+ (void)initialize
{
    if (_sharedDCInspection == nil)
        _sharedDCInspection = [[self alloc] init];
}

- (void) initInspection {
    self.removeBackFromProductSelect = NO;
    [self initiateAuditMasterId];
    [NSUserDefaultsManager saveObjectToUserDefaults:self.auditMasterId withKey:PREF_AUDIT_MASTER_ID];
    [self setIsInspectionActive:true];
    //NSLog(@"%@", [NSUserDefaultsManager getObjectFromUserDeafults:VendorNameSelected]);
    if((![self.poNumberGlobal  isEqual: @""]) && (self.poNumberGlobal != nil))
        [self checkForPONumberAndSaveItInUserDefaults];
    else
        [self checkForGRNAndSaveItInUserDefaults];
    [self checkForContainerIdAndSaveItInUserDefaults];
    [self checkForDateTimeAndSaveItInUserDefaults];
    [self checkForVendorNameAndSaveItInUserDefaults];
    //init collaborative inspection
    //self.collobarativeInspection = [[CollobarativeInspection alloc]init];
}

- (void) initInspectionWithMasterId: (NSString *) auditMasterIdLocal {
    self.auditMasterId = auditMasterIdLocal;
    [NSUserDefaultsManager saveObjectToUserDefaults:self.auditMasterId withKey:PREF_AUDIT_MASTER_ID];
    [self setIsInspectionActive:true];
    //self.collobarativeInspection = [[CollobarativeInspection alloc]init];
}

- (BOOL) isInspectionExistsInDB {
    BOOL exists = NO;
    NSString *queryAllContainerRating = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@", TBL_SAVED_CONTAINERS, COL_AUDIT_MASTER_ID, self.auditMasterId];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAllContainerRating];
    while ([resultsGroupRatings next]) {
        exists = YES;
    }
    [databaseGroupRatings close];
    return exists;
}

- (void) setupProgram: (Program *) selectedProgram {
    self.currentProgram = selectedProgram;
    if (isInspectionActive) {
        
    }
}
- (BOOL)isNoneSelectedForPOSupplier
{
    if([[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"]
       && [[User sharedUser].userSelectedVendorName isEqualToString:@"None"]){
        return YES;
    }
    return NO;
}
- (BOOL)isNoneSelectedForGRNSupplier
{
    if([[Inspection sharedInspection].grnGlobal isEqualToString:@"None"]
       && [[User sharedUser].userSelectedVendorName isEqualToString:@"None"]){
        return YES;
    }
    return NO;
}
// save inspection in TBL_CONTAINERS
// For "Save" action

- (void) saveInspection: (NSString *) inspectionName {
    NSString *queryAllContainerRating = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@=%@;", TBL_SAVED_CONTAINERS, COL_INSPECTION_NAME, inspectionName, COL_AUDIT_MASTER_ID, self.auditMasterId];
    
    //to resume inspection correctly
    //DI-1921
    [self checkForDateTimeAndSaveItInUserDefaults];
    //DI-1922
    [self checkForVendorNameAndSaveItInUserDefaults];
    
    if((![self.poNumberGlobal  isEqual: @""]) && (self.poNumberGlobal != nil))
        [self checkForPONumberAndSaveItInUserDefaults];
    else
        [self checkForGRNAndSaveItInUserDefaults];
    
    //cleanup
    [self setInspectiveInactive];
    
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [databaseGroupRatings open];
    [databaseGroupRatings executeUpdate:queryAllContainerRating];
    [databaseGroupRatings close];
}

// sets the currentAuditMasterId and active -> true
// For "Resume" from home screen

- (void) resumeSavedInspection: (NSString *) auditMasterIdLocal {
    self.removeBackFromProductSelect = YES;
    [NSUserDefaultsManager saveObjectToUserDefaults:auditMasterIdLocal withKey:PREF_AUDIT_MASTER_ID];
    self.auditMasterId = auditMasterIdLocal;
    //NSLog(@"fdf d %@", [NSUserDefaultsManager getObjectFromUserDeafults:VendorNameSelected]);
    [User sharedUser].userSelectedVendorName = [NSUserDefaultsManager getObjectFromUserDeafults:VendorNameSelected];
       [User sharedUser].userSelectedCustomerName = [NSUserDefaultsManager getObjectFromUserDeafults:CustomerNameSelected];
    [self findPONumberForTheSession];
    [self findGRNForTheSession];
    [self findOtherForTheSession];
    [self findContainerIdForTheSession];
    [self findDateTimeForTheSession];
    [self findVendorNameForTheSession];
    [self setIsInspectionActive:true];
    
    NSLog(@"RESUME - PO is %@ and VendorName is %@",self.poNumberGlobal, [User sharedUser].userSelectedVendorName);
}

- (void) findPONumberForTheSession {
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:PONUMBER_DICT];
    if (dictionaryFromDefaultsManager) {
        NSArray *keys = [dictionaryFromDefaultsManager allKeys];
        NSString *PONumberFromUserDefaults = @"";
        for (NSString *key in keys) {
            if ([key isEqualToString:self.auditMasterId]) {
                PONumberFromUserDefaults = [dictionaryFromDefaultsManager objectForKey:key];
            }
        }
        self.poNumberGlobal = PONumberFromUserDefaults;
    }
}
- (void) findGRNForTheSession {
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:GRN_DICT];
    if (dictionaryFromDefaultsManager) {
        NSArray *keys = [dictionaryFromDefaultsManager allKeys];
        NSString *GRNFromUserDefaults = @"";
        for (NSString *key in keys) {
            if ([key isEqualToString:self.auditMasterId]) {
                GRNFromUserDefaults = [dictionaryFromDefaultsManager objectForKey:key];
            }
        }
        self.grnGlobal = GRNFromUserDefaults;
    }
}
- (void) findOtherForTheSession {
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:OTHER_DICT];
    if (dictionaryFromDefaultsManager) {
        NSArray *keys = [dictionaryFromDefaultsManager allKeys];
        BOOL otherSelected = NO;
        for (NSString *key in keys) {
            if ([key isEqualToString:self.auditMasterId]) {
                NSNumber *number = [dictionaryFromDefaultsManager objectForKey:key];
                otherSelected = [number boolValue];
            }
            self.isOtherSelected = otherSelected;
        }
        self.isOtherSelected = otherSelected;
    }
}

- (void) findContainerIdForTheSession {
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:containerIdForProductsFiltering];
    if (dictionaryFromDefaultsManager) {
        NSArray *keys = [dictionaryFromDefaultsManager allKeys];
        NSString *ContainerIdFromUserDefaults = @"";
        for (NSString *key in keys) {
            if ([key isEqualToString:self.auditMasterId]) {
                ContainerIdFromUserDefaults = [dictionaryFromDefaultsManager objectForKey:key];
            }
        }
        self.containerId = ContainerIdFromUserDefaults;
    }
}

- (void) findVendorNameForTheSession {
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:VENDORNAME_DICT];
    if (dictionaryFromDefaultsManager) {
        NSArray *keys = [dictionaryFromDefaultsManager allKeys];
        NSString *VendorNameFromUserDefaults = @"";
        for (NSString *key in keys) {
            if ([key isEqualToString:self.auditMasterId]) {
                VendorNameFromUserDefaults = [dictionaryFromDefaultsManager objectForKey:key];
            }
        }
        [User sharedUser].userSelectedVendorName = VendorNameFromUserDefaults;
    }
}

- (void) findDateTimeForTheSession {
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:DATETIME_DICT];
    if (dictionaryFromDefaultsManager) {
        NSArray *keys = [dictionaryFromDefaultsManager allKeys];
        NSString *DateTimeFromUserDefaults = @"";
        for (NSString *key in keys) {
            if ([key isEqualToString:self.auditMasterId]) {
                DateTimeFromUserDefaults = [dictionaryFromDefaultsManager objectForKey:key];
            }
        }
        self.dateTimeForOrderData = DateTimeFromUserDefaults;
    }
}

-(void) deleteAuditWithId:(NSString*)productGroupId forAuditCount:(int)auditCount {

    int prodGroupIdInt = [productGroupId intValue];
   
    NSString *deleteQuery =[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=%d AND %@=%d AND %@=%@ AND %@=%@", TBL_SAVED_AUDITS, COL_PRODUCT_GROUP_ID, prodGroupIdInt , COL_AUDIT_COUNT, auditCount, COL_AUDIT_MASTER_ID, self.auditMasterId,COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
    
    NSString* updateQuery =[NSString stringWithFormat:@"UPDATE %@ SET %@= %@-1 WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@>%d",TBL_SAVED_AUDITS,COL_AUDIT_COUNT,COL_AUDIT_COUNT,COL_AUDIT_MASTER_ID,self.auditMasterId,COL_PRODUCT_GROUP_ID,productGroupId,COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId, COL_AUDIT_COUNT,auditCount];
    
    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[NSArray arrayWithObjects:deleteQuery, nil] withDatabasePath:DB_APP_DATA];
    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[NSArray arrayWithObjects:updateQuery, nil] withDatabasePath:DB_APP_DATA];
}

-(NSSet*)getAllGroupIdsForInspection{
    //save unique groupIds in an array (splitGroupIds)
    NSMutableSet* allGroupIds = [[NSMutableSet alloc]init];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId]];
    BOOL savedAuditPresent = NO;
    while ([resultsGroupRatings next]) {
        savedAuditPresent = YES;
        NSString* splitGroupId =[resultsGroupRatings stringForColumn:COL_SPLIT_GROUP_ID];
        [allGroupIds addObject:splitGroupId];
    }
    return [allGroupIds copy];
}

//"Finish" inspection action.  Saves inspection to local db and prevents editing or resuming.
- (void) finishInspection {
    NSArray<AuditApiContainerRating> *containerRatings;
    NSMutableArray* auditTransactionIds = [[NSMutableArray alloc]init]; //to track duplicate auditTransactionIds
    containerRatings = [self getContainerRatingsForInspection:self.auditMasterId];
    if ([containerRatings count] == 0) {
        //send empty container ratings array when no container
        //otherwise no email notification
        containerRatings = nil; //[self containerMissing];
    }
    NSSet* allGroupIds = [self getAllGroupIdsForInspection];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId]];
    BOOL savedAuditPresent = NO;
    while ([resultsGroupRatings next]) {
        savedAuditPresent = YES;
        NSError* err = nil;
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_AUDIT_JSON];
        NSString *groupId = [resultsGroupRatings stringForColumn:COL_AUDIT_GROUP_ID];
        NSString *productId = [resultsGroupRatings stringForColumn:COL_AUDIT_PRODUCT_ID];
        NSString *productGroupId = [resultsGroupRatings stringForColumn:COL_PRODUCT_GROUP_ID];
        NSString* splitGroupId =[resultsGroupRatings stringForColumn:COL_SPLIT_GROUP_ID];
        NSString *jsonString = [resultsGroupRatings stringForColumn:COL_IMAGES];
        jsonString = [self getImagesForContainerAndProducts:jsonString];
        Audit *ratingsJsons = [[Audit alloc] init];
        
        Audit *ratingsJson = [[Audit alloc] initWithString:ratings error:&err];
        if (!ratingsJson) {
            ratingsJson = [[Audit alloc] init];
        }
        
        
        //NSLog(@"RATINGS_AFTER_TOJSON %@", [ratingsJsons toJSONString]);
        NSMutableArray *imagesTemporaryArray = [[NSMutableArray alloc] init];
        [imagesTemporaryArray addObjectsFromArray:ratingsJson.auditData.images];
        for (Image *image in [self getContainerImageJsonForInspection]) {
            [imagesTemporaryArray addObject:image.remoteUrl];
        }
        ratingsJson.auditData.images = [imagesTemporaryArray copy];
        ratingsJson.auditData.submittedInfo.containerRatings = containerRatings;
        
        AuditApiSummary *summary = [self populateSummaryWithDataBase:databaseGroupRatings withProductGroupId:productGroupId withProductId:[resultsGroupRatings stringForColumn:COL_AUDIT_PRODUCT_ID] withGroupId:groupId withSplitGroupId:splitGroupId];
       // NSLog(@"productGroupId:%@ \nproductId:%@\n groupId:%@\n splitGroupId:%@\n Summary: %@",productGroupId,productId,groupId,splitGroupId,summary);
        if (!summary) {
            summary = [[AuditApiSummary alloc] init];
            Product *productObject = [self getProductForProductIdFromProductGroups:[[resultsGroupRatings stringForColumn:COL_AUDIT_PRODUCT_ID] integerValue] withGroupId:[productGroupId integerValue]];
            summary.totalCases = [self getCountOfCasesForProduct:productObject withDatabase:databaseGroupRatings];
        }
        if (!summary) {
            summary = [[AuditApiSummary alloc] init];
            summary.inspectionStatus = @"Accept";
        }
        
        NSString* originalItemNumber =ratingsJson.auditData.submittedInfo.product.itemNumber;
        //NSLog(@"original itemNumber is %@ ", originalItemNumber);
        //if selectedSku is empty
        if(!originalItemNumber || originalItemNumber==nil || [originalItemNumber isEqualToString:@""]){
            Product *productObject = [self getProductForProductIdFromProductGroups:[[resultsGroupRatings stringForColumn:COL_AUDIT_PRODUCT_ID] integerValue] withGroupId:[productGroupId integerValue]];
            ratingsJson.auditData.submittedInfo.product.itemNumber = productObject.selectedSku;
           
            NSString* itemNumberFromJSON =ratingsJson.auditData.submittedInfo.product.itemNumber;
             NSLog(@"itemNumber fallback1 is %@ ", itemNumberFromJSON);
            //if the itemNumber is still empty - then fetch the item number directly from DB using productID
            if(!itemNumberFromJSON || itemNumberFromJSON == nil || [itemNumberFromJSON isEqualToString:@""]){
                NSString* itemNumberFromDB =[self getItemNumberForProduct:[productId integerValue]];
                ratingsJson.auditData.submittedInfo.product.itemNumber =itemNumberFromDB;
                NSLog(@"itemNumber fallback2 is %@ ", itemNumberFromDB);
            }
        }
        //NSLog(@"FinishInspection - PO is %@ and VendorName is %@",[Inspection sharedInspection].poNumberGlobal, [User sharedUser].userSelectedVendorName);
        
        //if PONumber is blank - try to get PO from the ratings
        if(![Inspection sharedInspection].poNumberGlobal || [[Inspection sharedInspection].poNumberGlobal isEqualToString:@""]){
            NSLog(@"PONumber is blank - calculating from INsightsDB");
            [Inspection sharedInspection].poNumberGlobal = [self getPONumberFromRatingsJSON:ratingsJson];
            NSLog(@"PONumber is %@",[Inspection sharedInspection].poNumberGlobal);
        }
        
        if(![Inspection sharedInspection].grnGlobal || [[Inspection sharedInspection].grnGlobal isEqualToString:@""]){
            NSLog(@"GRN is blank - calculating from INsightsDB");
            [Inspection sharedInspection].grnGlobal = [self getGRNFromRatingsJSON:ratingsJson];
            NSLog(@"GRN is %@",[Inspection sharedInspection].grnGlobal);
        }
        //if VendorName is blank - try to get VendorName from the ratings
        if(![User sharedUser].userSelectedVendorName || [[User sharedUser].userSelectedVendorName isEqualToString:@""]){
            NSLog(@"VendorName is blank - calculating from INsightsDB");
            [User sharedUser].userSelectedVendorName = [self getVendorNameFromRatingsJSON:ratingsJson];
            NSLog(@"VendorName is %@",[User sharedUser].userSelectedVendorName);
        }
        
        //get orderdata id from DB
        long orderDataid = [OrderData getOrderDataIdForItem:ratingsJson.auditData.submittedInfo.product.itemNumber];

        ratingsJson.auditData.submittedInfo.product.orderDataId = orderDataid;
        //NSLog(@"original orderDataId is %ld ", orderDataid);
        //if still 0 then try to get directly from DB
        if(orderDataid <=0){
           orderDataid = [self getOrderDataIdForProduct:[productId integerValue]];
            NSLog(@"orderDataId fallback1 is %ld ", orderDataid);
        }
        if(orderDataid <= 0){
            orderDataid = [self getOrderDataIdFromSavedAudit:[productId integerValue]];
        }
        ratingsJson.auditData.submittedInfo.product.orderDataId = orderDataid;
        
        //DI-2015 for DCInsights replace the AuditGroupId with SplitGroupId throughout the JSON
        if([[User sharedUser] checkForDCInsights] && splitGroupId && ![splitGroupId isEqualToString:@""]){
            //NSLog(@"Relacing AuditGroupId %@ with SplitGroupId %@",groupId,splitGroupId);
            //modify the auditId
            ratingsJson.auditData.audit.id = [self getModifiedAuditIdWithSplitGroupId:splitGroupId auditGroupId:groupId ratingsJson:ratingsJson];
            //modify all the imagesIds
            ratingsJson.auditData.images =[self getModifiedImagesUrlWithSplitGroupId:splitGroupId auditGroupId:groupId ratingsJson:ratingsJson];
            //modify also the json for Images which is stored in offline table
            //only modify the remote url / path - but not the device url
            NSError *error;
            ImageArray *imageArray = [[ImageArray alloc] initWithString:jsonString error:&error];
            NSMutableArray<Image> *images = [self getModifiedImagesJsonWithSplitGroupId:splitGroupId auditGroupId:groupId imagesJson:jsonString];
            imageArray.images = images;
            jsonString = [imageArray toJSONString];
        }

        // DI-2077 - if transactionIds for audits are same, replace with new Ids
        if([[User sharedUser] checkForDCInsights]){
            NSString* transactionId = [ratingsJson.auditData.audit getTransactionId];
            NSLog(@"Original TransactionId is: %@",transactionId);
            if(transactionId && ![transactionId isEqualToString:@""]){
                //duplicate transactionID found - replace with new ID
                if([auditTransactionIds containsObject:transactionId]){
                    NSLog(@"Found duplicate transactionID: %@",transactionId);
                    [NSThread sleepForTimeInterval:0.3f];
                    NSString* newTransactionId = [DeviceManager getCurrentTimeString];
                    [ratingsJson.auditData.audit updateTransacationIdWithId:newTransactionId];
                    //modify all the imagesIds
                    ratingsJson.auditData.images =[self getModifiedImagesUrlWithNewTransactionId:newTransactionId oldTransactionId:transactionId ratingsJson:ratingsJson];
                    //modify also the json for Images which is stored in offline table
                    //only modify the remote url / path - but not the device url
                    NSError *error;
                    ImageArray *imageArray = [[ImageArray alloc] initWithString:jsonString error:&error];
                    NSMutableArray<Image> *images = [self getModifiedImagesJsonWithNewTransactionId:newTransactionId oldTransactionId:transactionId imagesJson:jsonString];
                    imageArray.images = images;
                    jsonString = [imageArray toJSONString];
                    NSLog(@"Replace the oldTransactionId %@ with newTransactionId: %@",transactionId, newTransactionId);
                }else{ //just add the transactionId for tracking
                    [auditTransactionIds addObject:transactionId];
                }
            }
        }
        
        //catch situation where status is Null
        if(summary.inspectionStatus == nil || [summary.inspectionStatus isEqualToString:@""])
             summary.inspectionStatus = @"Accept";
        
        summary.percentageOfCases = [[NSString stringWithFormat:@"%.2f", summary.percentageOfCases] floatValue];
        if ([[User sharedUser] checkForRetailInsights]) {
            summary.totalCases = 0;
            summary.percentageOfCases = 0.0;
            summary.inspectionStatus = nil;
            summary.totals = nil;
            summary.defectsSummary = nil;
        }
        
        //DI-2436 - add all the groupIds for the inspection
        NSArray *allGroupIdArray = [allGroupIds allObjects];
        summary.auditGroupIds = allGroupIdArray;
        
        ratingsJson.auditData.summary = summary;
        if (ratingsJson) {
            ratingsJson = [self checkForValidAuditsAndGenerateOne:ratingsJson];
        }
     
        
        [self saveAuditInOfflineTable:ratingsJson withImages:jsonString];
    }
    // do not create and save fake audits/inspections - DI-1571
    // except for scanout since the product rating is never present
    if (!savedAuditPresent) {
        if([[User sharedUser] checkForScanOut])
        [self createEmptyAuditAndSaveInOfflineTable:databaseGroupRatings];
    }
    
    [databaseGroupRatings close];
    [self cleanupCollaborativeInspections];
    [self cancelInspection];
    [self startBackgroundUpload];
}
    

//cleanup collaborative updates
-(void)cleanupCollaborativeInspections {
    if([CollobarativeInspection isCollaborativeInspectionsEnabled])
        [CollabLocalUpdatesDB cleanupInspectionsForPO:self.poNumberGlobal];
    [CollabLocalUpdatesDB cleanupInspectionsForGRN:self.grnGlobal];
}

-(void)startBackgroundUpload {
    [[User sharedUser] initBackgroundUpload];
}

-(NSString*)getPONumberFromRatingsJSON:(Audit*)ratingsJson{
    //go thru containers ratings - check if its PO Number rating
    NSString* poNumber = @"";
    NSArray* poNumberRatingIds = [self getPONumberRatingIds];
    NSArray* containerRatings = ratingsJson.auditData.submittedInfo.containerRatings;
    for(AuditApiContainerRating* rating in containerRatings){
        if([poNumberRatingIds containsObject:[NSNumber numberWithInteger:rating.id]] && rating.value && ![rating.value isEqualToString:@""] && ![rating.value isEqualToString:@"None"])
            poNumber = rating.value;
    }
    //if PO not found - check product ratings
    if(!poNumber || [poNumber isEqualToString:@""]){
        NSArray* productRatings = ratingsJson.auditData.submittedInfo.productRatings;
        for(AuditApiRating* rating in productRatings){
            if([poNumberRatingIds containsObject:[NSNumber numberWithInteger:rating.id]] && rating.value && ![rating.value isEqualToString:@""] && ![rating.value isEqualToString:@"None"])
                poNumber = rating.value;
        }
    }
    return poNumber;
}
-(NSString*)getGRNFromRatingsJSON:(Audit*)ratingsJson{
    //go thru containers ratings - check if its PO Number rating
    NSString* grn = @"";
    NSArray* grnRatingIds = [self getGRNRatingIds];
    NSArray* containerRatings = ratingsJson.auditData.submittedInfo.containerRatings;
    for(AuditApiContainerRating* rating in containerRatings){
        if([grnRatingIds containsObject:[NSNumber numberWithInteger:rating.id]] && rating.value && ![rating.value isEqualToString:@""] && ![rating.value isEqualToString:@"None"])
            grn = rating.value;
    }
    //if PO not found - check product ratings
    if(!grn || [grn isEqualToString:@""]){
        NSArray* productRatings = ratingsJson.auditData.submittedInfo.productRatings;
        for(AuditApiRating* rating in productRatings){
            if([grnRatingIds containsObject:[NSNumber numberWithInteger:rating.id]] && rating.value && ![rating.value isEqualToString:@""] && ![rating.value isEqualToString:@"None"])
                grn = rating.value;
        }
    }
    return grn;
}
//find ratingId of PONumber rating type
-(NSArray*)getPONumberRatingIds{
    NSMutableArray* poRatingIds = [[NSMutableArray alloc]init];
    NSString* poNumberString = @"PONumber";
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_RATINGS, COL_ORDER_DATA_FIELD, poNumberString];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        int ratingId = [results intForColumn:COL_ID];
        [poRatingIds addObject:[NSNumber numberWithInt:ratingId ]];
    }
    return [poRatingIds copy];
}

-(NSArray*)getGRNRatingIds{
    NSMutableArray* grnRatingIds = [[NSMutableArray alloc]init];
    NSString* grnString = @"GRN";
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_RATINGS, COL_ORDER_DATA_FIELD, grnString];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        int ratingId = [results intForColumn:COL_ID];
        [grnRatingIds addObject:[NSNumber numberWithInt:ratingId ]];
    }
    return [grnRatingIds copy];
}
-(NSString*)getVendorNameFromRatingsJSON:(Audit*)ratingsJson{
    //go thru containers ratings - check if its vendorName rating
    NSString* vendorName = @"";
    NSArray* vendorNameRatingIds = [self getVendorNameRatingIds];
    NSArray* containerRatings = ratingsJson.auditData.submittedInfo.containerRatings;
    for(AuditApiContainerRating* rating in containerRatings){
        if([vendorNameRatingIds containsObject:[NSNumber numberWithInteger:rating.id]] && rating.value && ![rating.value isEqualToString:@""] && ![rating.value isEqualToString:@"None"])
            vendorName = rating.value;
    }
    //if PO not found - check product ratings
    if(!vendorName || [vendorName isEqualToString:@""]){
        NSArray* productRatings = ratingsJson.auditData.submittedInfo.productRatings;
        for(AuditApiRating* rating in productRatings){
            if([vendorNameRatingIds containsObject:[NSNumber numberWithInteger:rating.id]] && rating.value && ![rating.value isEqualToString:@""] && ![rating.value isEqualToString:@"None"])
                vendorName = rating.value;
        }
    }
    return vendorName;
}

//find ratingId of VendorName rating type
-(NSArray*)getVendorNameRatingIds{
    NSMutableArray* vendorNameRatingIds = [[NSMutableArray alloc]init];
    NSString* vendorNameString = @"VendorName";
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_RATINGS, COL_ORDER_DATA_FIELD, vendorNameString];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        int ratingId = [results intForColumn:COL_ID];
        [vendorNameRatingIds addObject:[NSNumber numberWithInt:ratingId ]];
    }
    return [vendorNameRatingIds copy];
}

/*Update the TransactionId */
-(NSString*)getModifiedAuditIdWithNewTransactionId:(NSString*)newTransactionId oldTransactionId:(NSString*)oldTransactionId ratingsJson:(Audit*)ratingsJson{
    NSString *originalId = ratingsJson.auditData.audit.id;
    NSString* newAuditId = [originalId stringByReplacingOccurrencesOfString:oldTransactionId withString:newTransactionId];
    return newAuditId;
}

-(NSMutableArray*)getModifiedImagesUrlWithNewTransactionId:(NSString*)newTransactionId oldTransactionId:(NSString*)oldTransactionId ratingsJson:(Audit*)ratingsJson{
    NSArray* imagesArrayOriginal =  ratingsJson.auditData.images;
    NSMutableArray* imagesArrayNew =  [[NSMutableArray alloc]init];
    if(imagesArrayOriginal && [imagesArrayOriginal count]>0){
        for (NSString *imageUrl in imagesArrayOriginal) {
            NSRange lastComma = [imageUrl rangeOfString:oldTransactionId options:NSBackwardsSearch];
            if(lastComma.location != NSNotFound) {
                NSString* newUrl = [imageUrl stringByReplacingCharactersInRange:lastComma
                                                   withString:newTransactionId];
                if(newUrl)
                    [imagesArrayNew addObject:newUrl];
                else
                    [imagesArrayNew addObject:imageUrl];
            }
        }
    }
    return imagesArrayNew;
}

-(NSMutableArray<Image>*)getModifiedImagesJsonWithNewTransactionId:(NSString*)newTransactionId oldTransactionId:(NSString*)oldTransactionId imagesJson:(NSString*)imagesJson{
    NSError *error;
    ImageArray *imageArray = [[ImageArray alloc] initWithString:imagesJson error:&error];
    NSMutableArray<Image> *newImageArray = [[NSMutableArray alloc]init];
    for(Image* image in imageArray.images){
        [image updatePathWithNewTransactionId:newTransactionId oldTransactionId:oldTransactionId];
        [image updateRemoteUrlWithNewTransactionId:newTransactionId oldTransactionId:oldTransactionId];
        [newImageArray addObject:image];
    }
    imageArray.images = newImageArray;
    return newImageArray;
}


/*Update the GroupId */
-(NSString*)getModifiedAuditIdWithSplitGroupId:(NSString*)splitGroupId auditGroupId:(NSString*)groupId ratingsJson:(Audit*)ratingsJson{
    NSString *originalId = ratingsJson.auditData.audit.id;
    NSString* newAuditId = [originalId stringByReplacingOccurrencesOfString:groupId withString:splitGroupId];
    return newAuditId;
}

-(NSMutableArray*)getModifiedImagesUrlWithSplitGroupId:(NSString*)splitGroupId auditGroupId:(NSString*)groupId ratingsJson:(Audit*)ratingsJson{
    NSMutableArray* imagesArrayOriginal =  ratingsJson.auditData.images;
    NSMutableArray* imagesArrayNew =  [[NSMutableArray alloc]init];
    if(imagesArrayOriginal && [imagesArrayOriginal count]>0){
        for (NSString *imageUrl in imagesArrayOriginal) {
            NSString* newUrl = [imageUrl stringByReplacingOccurrencesOfString:groupId withString:splitGroupId];
            [imagesArrayNew addObject:newUrl];
        }
    }
    return imagesArrayNew;
}

-(NSMutableArray<Image>*)getModifiedImagesJsonWithSplitGroupId:(NSString*)splitGroupId auditGroupId:(NSString*)groupId imagesJson:(NSString*)imagesJson{
    NSError *error;
    ImageArray *imageArray = [[ImageArray alloc] initWithString:imagesJson error:&error];
    NSMutableArray<Image> *newImageArray = [[NSMutableArray alloc]init];
    for(Image* image in imageArray.images){
        Image *newImage = image;
        NSString* originalPath = image.path;
        NSString* modifiedPath = [originalPath stringByReplacingOccurrencesOfString:groupId withString:splitGroupId];
        newImage.path = modifiedPath;
        
        NSString* originalRemoteUrl = newImage.remoteUrl;
        NSString* modifiedRemoteUrl = [originalRemoteUrl stringByReplacingOccurrencesOfString:groupId withString:splitGroupId];
        newImage.remoteUrl = modifiedRemoteUrl;
        [newImageArray addObject:newImage];
    }
    imageArray.images = newImageArray;
    return newImageArray;
}

//to get the itemNumber from OrderData DB directly for a given productID
-(NSString*)getItemNumberForProduct:(int)productId {
    NSString* currentPO = [Inspection sharedInspection].poNumberGlobal;
    NSString* currentGRN = [Inspection sharedInspection].grnGlobal;
    NSString* supplier = [User sharedUser].userSelectedVendorName;
    
    //get all the SKUs for the productId
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_PRODUCTS, COL_ID, productId];
    NSMutableArray *skus = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        //NSArray *arraySKUS;
        if ([results dataForColumn:COL_SKUS]) {
            skus = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_SKUS]];
        }
    }
    [database close];
    //SELECT * FROM items WHERE last_merge_id IN (?)"
    // find the itemNumber matching any one SKU + PO + Supplier
    NSString * delimitedString = [skus componentsJoinedByString:@"','"];
    NSString *itemNumberQuery;
    if((!currentPO) || ([currentPO isEqualToString:@""])){
        itemNumberQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@='%@' AND %@ IN ('%@')", TBL_ORDERDATA, COL_ORDER_GRN, currentGRN, COL_ORDER_VENDOR_NAME, supplier, COL_ORDER_ITEM_NUMBER, delimitedString];
    }else{
   itemNumberQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@='%@' AND %@ IN ('%@')", TBL_ORDERDATA, COL_ORDER_PO_NUMBER, currentPO, COL_ORDER_VENDOR_NAME, supplier, COL_ORDER_ITEM_NUMBER, delimitedString];
    }
    FMDatabase *orderDB = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *itemNumberResults;
    [orderDB open];
    NSString* itemNumber = @"";
    itemNumberResults = [orderDB executeQuery:itemNumberQuery];
    while ([itemNumberResults next]) {
        itemNumber = [itemNumberResults stringForColumn:COL_ORDER_ITEM_NUMBER];
    }
    [orderDB close];
    
    return itemNumber;
}

-(long)getOrderDataIdFromSavedAudit:(int)productId{
    long orderId = 0;
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_SAVED_AUDITS, COL_AUDIT_PRODUCT_ID, productId]];

    while ([resultsGroupRatings next]) {
        
        orderId =[resultsGroupRatings intForColumn:COL_ORDER_ID];
        
    }
    return orderId;
}
//to get the orderDataId from OrderData DB directly for a given productID
-(long)getOrderDataIdForProduct:(int)productId {
    NSString* currentPO = [Inspection sharedInspection].poNumberGlobal;
    NSString* currentGRN = [Inspection sharedInspection].grnGlobal;
    NSString* supplier = [User sharedUser].userSelectedVendorName;
    
    //get all the SKUs for the productId
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_PRODUCTS, COL_ID, productId];
    NSMutableArray *skus = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        //NSArray *arraySKUS;
        if ([results dataForColumn:COL_SKUS]) {
            skus = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_SKUS]];
        }
    }
    [database close];
    //SELECT * FROM items WHERE last_merge_id IN (?)"
    // find the itemNumber matching any one SKU + PO + Supplier
    NSString * delimitedString = [skus componentsJoinedByString:@"','"];
    NSString *itemNumberQuery;
    if((!currentPO) || ([currentPO isEqualToString:@""])){
        itemNumberQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@='%@' AND %@ IN ('%@')", TBL_ORDERDATA, COL_ORDER_GRN, currentGRN, COL_ORDER_VENDOR_NAME, supplier, COL_ORDER_ITEM_NUMBER, delimitedString];
    }else{
    itemNumberQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@='%@' AND %@ IN ('%@')", TBL_ORDERDATA, COL_ORDER_PO_NUMBER, currentPO, COL_ORDER_VENDOR_NAME, supplier, COL_ORDER_ITEM_NUMBER, delimitedString];
    }
    FMDatabase *orderDB = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *itemNumberResults;
    [orderDB open];
    //NSString* itemNumber = @"";
    long orderid = 0;
    itemNumberResults = [orderDB executeQuery:itemNumberQuery];
    while ([itemNumberResults next]) {
        //itemNumber = [itemNumberResults stringForColumn:COL_ORDER_ITEM_NUMBER];
        orderid =[itemNumberResults intForColumn:COL_ORDER_ID];
    }
    [orderDB close];
    
    return orderid;
}

- (void) createEmptyAuditAndSaveInOfflineTable: (FMDatabase *) database {
    CurrentAudit *currentAuditLocal = [[CurrentAudit alloc] init];
    [currentAuditLocal setAllTheCurrentAuditVariables:0 withAuditMasterId:self.auditMasterId withAuditGroupId:@"" withProductID:0 withProductGroupID:0 withProgramID:[NSUserDefaultsManager getIntegerFromUserDeafults:SelectedProgramId] withProgramVersion:[NSUserDefaultsManager getFloatFromUserDeafults:SelectedProgramVersion] withDatabase:database];
    currentAuditLocal.auditEndTime =  [DeviceManager getCurrentTimeString];
    Audit *ratingsJson = [currentAuditLocal generateAudit:NO];
    NSArray<AuditApiContainerRating> *containerRatings;
    containerRatings = [self getContainerRatingsForInspection:self.auditMasterId];
    NSMutableArray *imagesTemporaryArray = [[NSMutableArray alloc] init];
    [imagesTemporaryArray addObjectsFromArray:ratingsJson.auditData.images];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObjectsFromArray:[self getContainerImageJsonForInspection]];
    ImageArray *images = [[ImageArray alloc] init];
    NSArray *copy = [NSArray arrayWithArray:array];
    [images setImages:(NSArray<Image>*)copy];
    NSString* imagesJsonString = [images toJSONString];
    for (Image *image in [self getContainerImageJsonForInspection]) {
        [imagesTemporaryArray addObject:image.remoteUrl];
    }
    ratingsJson.auditData.images = [imagesTemporaryArray copy];
    ratingsJson.auditData.submittedInfo.containerRatings = containerRatings;
    int programId = [NSUserDefaultsManager getIntegerFromUserDeafults:SelectedProgramId];
    int versionNumber = [NSUserDefaultsManager getFloatFromUserDeafults:SelectedProgramVersion];
    ratingsJson.auditData.submittedInfo.program.id = programId;
    ratingsJson.auditData.submittedInfo.program.version = versionNumber;
    if (!ratingsJson.auditData.summary) {
        AuditApiSummary *summary = [[AuditApiSummary alloc] init];
        ratingsJson.auditData.summary = summary;
    }
    if (ratingsJson) {
        ratingsJson = [self checkForValidAuditsAndGenerateOne:ratingsJson];
    }
    [self saveAuditInOfflineTable:ratingsJson withImages:imagesJsonString];
}


- (NSArray<AuditApiContainerRating> *) containerMissing {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    AuditApiContainerRating *container = [[AuditApiContainerRating alloc] init];
    [array addObject:container];
    return [array copy];
}


- (NSString *) getImagesForContainerAndProducts: (NSString *) jsonString {
    NSError* err = nil;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    ImageArray *imageArray = [[ImageArray alloc] initWithString:jsonString error:&err];
    [array addObjectsFromArray:[self getContainerImageJsonForInspection]];
    [array addObjectsFromArray:imageArray.images];
    ImageArray *images = [[ImageArray alloc] init];
    NSArray *copy = [NSArray arrayWithArray:array];
    [images setImages:(NSArray<Image>*)copy];
    NSString* imagesJsonString = [images toJSONString];
    return imagesJsonString;
}

- (Audit *) checkForValidAuditsAndGenerateOne: (Audit *) ratingsJson {
    Audit *ratingsJsonLocal = ratingsJson;
    NSMutableArray *productRatingsMutable= [[NSMutableArray alloc] init];
    NSMutableArray<AuditApiRating> *productRatingsMutableArray = (NSMutableArray <AuditApiRating>*)productRatingsMutable;
    NSArray<AuditApiRating>* productRatings = ratingsJsonLocal.auditData.submittedInfo.productRatings;
    for(AuditApiRating *aRating in productRatings) {
        NSMutableArray *defectsMutable= [[NSMutableArray alloc] init];
        NSMutableArray<AuditApiDefect> *defectsMutableArray = (NSMutableArray <AuditApiDefect>*)defectsMutable;
         //if (aRating.value && ![aRating.value isEqualToString:@""]) {
                   for (AuditApiDefect *aDefect in aRating.defects) {
                       if (aDefect.present) {
                           NSMutableArray *severityMutable = [[NSMutableArray alloc] init];
                           NSMutableArray<AuditApiSeverity> *serveritiesMutableArray = (NSMutableArray <AuditApiSeverity>*)severityMutable;
                           [serveritiesMutableArray addObjectsFromArray:aDefect.severities];
                           for(AuditApiSeverity *severity in aDefect.severities){
                               if(severity.percentage == 0){
                                   [serveritiesMutableArray removeObject:severity];
                               }
                           }
                           aDefect.severities = serveritiesMutableArray;
                           [defectsMutableArray addObject:aDefect];
                       }
                   }
                   aRating.defects = [defectsMutableArray copy];
                   [productRatingsMutableArray addObject:aRating];
               //}
    }
    ratingsJsonLocal.auditData.submittedInfo.productRatings = [productRatingsMutableArray copy];
    
    NSMutableArray *containerRatingsMutable= [[NSMutableArray alloc] init];
    NSMutableArray<AuditApiContainerRating> *containerRatingsMutableArray = (NSMutableArray <AuditApiContainerRating>*)containerRatingsMutable;
    NSArray<AuditApiContainerRating>* containerRatings = ratingsJsonLocal.auditData.submittedInfo.containerRatings;
    for(AuditApiContainerRating *aRating in containerRatings) {
        NSMutableArray *defectsMutable= [[NSMutableArray alloc] init];
        NSMutableArray<AuditApiDefect> *defectsMutableArray = (NSMutableArray <AuditApiDefect>*)defectsMutable;
        //if (aRating.value && ![aRating.value isEqualToString:@""]) {
            for (AuditApiDefect *aDefect in aRating.defects) {
                if (aDefect.present) {
                    [defectsMutableArray addObject:aDefect];
                }
            }
            aRating.defects = [defectsMutableArray copy];
            [containerRatingsMutableArray addObject:aRating];
        //}
    }
    ratingsJsonLocal.auditData.submittedInfo.containerRatings = [containerRatingsMutableArray copy];

    return ratingsJsonLocal;
}

- (AuditApiSummary *) populateSummaryWithDataBase:(FMDatabase *) database withProductGroupId: (NSString *) productGroupId withProductId:(NSString *)productId withGroupId: (NSString *) groupId withSplitGroupId:(NSString*)splitGroupId{
    AuditApiSummary *summary;
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    if (!databaseGroupRatings) {
        [[User sharedUser] addLogText:[NSString stringWithFormat:@"\nSummary database open failed\n"]];
    }
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_SPLIT_GROUP_ID,splitGroupId]];
    while ([resultsGroupRatings next]) {
        NSError *err = nil;
        summary = [[AuditApiSummary alloc] initWithString:[resultsGroupRatings stringForColumn:COL_SUMMARY] error:&err];
    }
    [databaseGroupRatings close];
    return summary;
}

- (Product *) getProduct:(int) groupId withProductID:(int) productId {
    Store *store = [[User sharedUser] currentStore];
    NSArray *groups = [store getAllGroupsOfProductsForTheStore];
    for (ProgramGroup *pg in groups) {
        if (pg.programGroupID == groupId) {
            NSArray *products = [pg getAllProducts];
            for (Product *p in products) {
                if (productId == p.product_id) {
                    [p getAllRatings];
                    NSMutableArray *ratingsForProductWithDefects = [[NSMutableArray alloc] init];
                    for (Rating *rating in p.ratings) {
                        [rating getAllDefects];
                        [ratingsForProductWithDefects addObject:rating];
                    }
                    p.ratings = [[NSArray alloc] init];
                    p.ratings = [ratingsForProductWithDefects copy];
                    return p;
                }
            }
        }
    }
    return nil;
}


- (AuditApiSummary *) getSummaryForGroup: (NSString *) auditMasterIdLocal withGroupId: (NSString *) auditGroupId {
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    NSString *string = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterIdLocal, COL_AUDIT_GROUP_ID, auditGroupId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    AuditApiSummary *summary;
    resultsGroupRatings = [databaseGroupRatings executeQuery:string];
    while ([resultsGroupRatings next]) {
        NSError *err = nil;
        summary = [[AuditApiSummary alloc] initWithString:[resultsGroupRatings stringForColumn:COL_SUMMARY] error:&err];
    }
    [databaseGroupRatings close];
    return summary;
}

// list all the saved audits for the current active inspection

- (NSArray *) getAllSavedAuditsForInspection {
    NSMutableArray *allAudits = [[NSMutableArray alloc] init];
    //NSString *queryAllStrings = [NSString stringWithFormat:@"SELECT %@,%@,%@,%@,%@, COUNT(\"%@\") AS COUNT FROM %@ WHERE %@='%@' GROUP BY %@", COL_USERENTERED_SAMPLES, COL_PRODUCT_GROUP_ID, COL_PRODUCT_NAME, COL_AUDIT_GROUP_ID, COL_AUDIT_PRODUCT_ID, COL_AUDIT_PRODUCT_ID, TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID];
    NSString *queryAllStrings = [NSString stringWithFormat:@"SELECT %@,%@,%@,%@,%@,%@,%@, COUNT(\"%@\") AS COUNT FROM %@ WHERE %@='%@' GROUP BY %@", COL_COUNT_OF_CASES,COL_AUDIT_PRODUCT_ID,COL_USERENTERED_SAMPLES, COL_PRODUCT_GROUP_ID, COL_PRODUCT_NAME, COL_AUDIT_GROUP_ID, COL_SPLIT_GROUP_ID, COL_SPLIT_GROUP_ID, TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_SPLIT_GROUP_ID];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    FMResultSet *resultsGroupRatingsForSavedAudit;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAllStrings];
    while ([resultsGroupRatings next]) {
        NSString *productName = [resultsGroupRatings stringForColumn:COL_PRODUCT_NAME];
        int count = [resultsGroupRatings intForColumn:@"COUNT"];
        SavedAudit *savedAudit = [[SavedAudit alloc] init];
        savedAudit.productName = productName;
        savedAudit.auditsCount = count;
        savedAudit.countOfCases =[resultsGroupRatings intForColumn:COL_COUNT_OF_CASES];
        savedAudit.productId = [resultsGroupRatings intForColumn:COL_AUDIT_PRODUCT_ID];
        savedAudit.productGroupId = [resultsGroupRatings intForColumn:COL_PRODUCT_GROUP_ID];
        savedAudit.auditGroupId = [resultsGroupRatings stringForColumn:COL_AUDIT_GROUP_ID];
        savedAudit.splitGroupId =[resultsGroupRatings stringForColumn:COL_SPLIT_GROUP_ID];
        Product *productObject = [self getProductForProductId:savedAudit.productId withGroupId:savedAudit.productGroupId];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *inspectionType = [NSUserDefaultsManager getObjectFromUserDeafults:INSPECTION_TYPE];
            [savedAudit.globalInspectionStatus getAllStatuses:productObject.program_id :inspectionType];
           /* for(int i = 0; i < 100000; i = i + 1)
            {
                NSLog(@"");
            }*/
            
        });
        
        NSMutableArray *orderDataArray = [[NSMutableArray alloc]init];
        for(NSString* sku in productObject.skus){
        NSArray *array = [OrderData getOrderDataForItemNumberWithPONumber:sku withPONumber:[[Inspection sharedInspection] poNumberGlobal]];
            
            if([array count] == 0){
               array = [OrderData getOrderDataForItemNumberWithGRN:sku withGRN:[[Inspection sharedInspection] grnGlobal]];
            }
            [orderDataArray addObjectsFromArray:array];
        }
        //NSArray *orderDataArray = [OrderData getOrderDataForItemNumber:[productObject.skus lastObject]];
        for (OrderData *order in orderDataArray) {
            //NSLog(@"OrderData is: %d, %d")
            if([order.VendorName length]!=0)
            savedAudit.supplierName = order.VendorName;
            savedAudit.isFlagged = order.FlaggedProduct;
            savedAudit.score = order.score;
            savedAudit.allFlaggedProductMessages = order.allFlaggedProductMessages;
            
        }
        savedAudit.poNumber = [[Inspection sharedInspection] poNumberGlobal];
        savedAudit.grn = [[Inspection sharedInspection] grnGlobal];
        //NSLog(@"sfvd %@", [resultsGroupRatings stringForColumn:COL_USERENTERED_SAMPLES]);
        NSString *userEnteredInspectionSamplesLocal = [resultsGroupRatings stringForColumn:COL_USERENTERED_SAMPLES];
        NSString *queryStringForSavedAudit = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%d' AND %@='%d' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, savedAudit.productId, COL_PRODUCT_GROUP_ID, savedAudit.productGroupId, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_SPLIT_GROUP_ID,savedAudit.splitGroupId];
        resultsGroupRatingsForSavedAudit = [databaseGroupRatings executeQuery:queryStringForSavedAudit];
        NSString *summaryJSON = @"";
        BOOL summaryNeedsUpdate = NO;
        while ([resultsGroupRatingsForSavedAudit next]) {
            summaryJSON = [resultsGroupRatingsForSavedAudit stringForColumn:COL_SUMMARY];
            AuditApiSummary *summary = [[AuditApiSummary alloc] initWithString:summaryJSON error:nil];
            savedAudit.inspectionStatus = summary.inspectionStatus;
            savedAudit.userEnteredAuditsCount = summary.inspectionSamples;
            savedAudit.countOfCases = [[resultsGroupRatingsForSavedAudit stringForColumn:COL_COUNT_OF_CASES] integerValue];
        }
        if (aggregateSamplesMode && savedAudit.userEnteredAuditsCount != [userEnteredInspectionSamplesLocal integerValue]) {
            summaryNeedsUpdate = YES;
        }
        if (![userEnteredInspectionSamplesLocal isEqualToString:@""] && userEnteredInspectionSamplesLocal) {
            savedAudit.userEnteredAuditsCount = [[resultsGroupRatings stringForColumn:COL_USERENTERED_SAMPLES] integerValue];
            if (summaryNeedsUpdate) {
                AuditApiSummary *summaryLocal = [[AuditApiSummary alloc] initWithString:summaryJSON error:nil];
                [self updateSummaryAndUpdateInTheColumn:databaseGroupRatings withInspectionSamples:[NSString stringWithFormat:@"%d", savedAudit.userEnteredAuditsCount] withSummaryJSON:summaryLocal withProductId:[NSString stringWithFormat:@"%d", savedAudit.productId] withProductGroupId:[NSString stringWithFormat:@"%d", savedAudit.productGroupId] withSplitGroupId:savedAudit.splitGroupId];
            }
        }
        [allAudits addObject:savedAudit];
    }
    [databaseGroupRatings close];
    return [allAudits copy];
}

- (void) updateSummaryAndUpdateInTheColumn: (FMDatabase *) database withInspectionSamples: (NSString *) inspectionSamples withSummaryJSON: (AuditApiSummary *) summaryJSON withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString*)splitGroupId{
    summaryJSON.inspectionSamples = [inspectionSamples integerValue];
    NSString *summaryString = [summaryJSON toJSONString];
    NSString *queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_SUMMARY, summaryString, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, auditMasterId, COL_SPLIT_GROUP_ID, splitGroupId];
    [database executeUpdate:queryForUpdate];
}

- (NSArray *) getAllSavedAndFakeAuditsForInspection {
    if ([self.productGroups count] == 0) {
        [self getProductGroups];
    }
    NSArray *productsFilteredByOrderData = self.productGroups;
    productsFilteredByOrderData = [[[User sharedUser].currentStore filterProductsBasedOnContainers:productsFilteredByOrderData] mutableCopy];
    NSMutableArray *productsArray = [NSMutableArray array];
    for (int i=0; i < [productsFilteredByOrderData count]; i++) {
        if ([[productsFilteredByOrderData objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *pg = [productsFilteredByOrderData objectAtIndex:i];
            [productsArray addObjectsFromArray:pg.products];
        } else {
            [productsArray addObject:[productsFilteredByOrderData objectAtIndex:i]];
        }
    }
    NSArray *allSavedAudits =[self getAllSavedAuditsForInspection];
    NSMutableArray *fakeSavedAudits = [[NSMutableArray alloc] init];
    if ([self checkForOrderData]) {
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        for (Product *product in productsArray) {
            SavedAudit *savedAudit = [[SavedAudit alloc] init];
            savedAudit.productId = product.product_id;
            savedAudit.productGroupId = product.group_id;
            savedAudit.productName = product.product_name;
            savedAudit.auditsCount = 0;
    
            Product *productObject = [self getProductForProductIdFromProductGroups:savedAudit.productId withGroupId:savedAudit.productGroupId];
            NSArray *orderDataArray = [OrderData getOrderDataForItemNumber:productObject.selectedSku];
            //NSArray *orderDataArray = [OrderData getOrderDataForItemNumberWithPONumber:productObject.selectedSku withPONumber:[[Inspection sharedInspection] poNumberGlobal]];
            for (OrderData *order in orderDataArray) {
                if ([order.ItemNumber isEqualToString:productObject.selectedSku] && [order.PONumber isEqualToString:self.poNumberGlobal]) {
                    savedAudit.supplierName = order.VendorName;
                    savedAudit.flaggedProduct = order.FlaggedProduct;
                    savedAudit.score = order.score;
                }
                else if([order.ItemNumber isEqualToString:productObject.selectedSku] && [order.grn isEqualToString:self.grnGlobal]){
                    savedAudit.supplierName = order.VendorName;
                    savedAudit.flaggedProduct = order.FlaggedProduct;
                    savedAudit.score = order.score;
                }
            }
            savedAudit.poNumber = [[Inspection sharedInspection] poNumberGlobal];
            savedAudit.grn = [[Inspection sharedInspection] grnGlobal];
            savedAudit.countOfCases = [self getCountOfCasesForProduct:product withDatabase:database];
            [savedAudit populateAuditCounts];
            if(![allSavedAudits containsObject:savedAudit]){
                [fakeSavedAudits addObject:savedAudit];
            }
        }
        [database close];
    }
    NSMutableArray *finalAudits = [[NSMutableArray alloc] init];
    /*for (SavedAudit *fakeSavedAudit in fakeSavedAudits) {
        BOOL present = NO;
        for (SavedAudit *savedAudit in allSavedAudits) {
            if ((fakeSavedAudit.productGroupId == savedAudit.productGroupId)) {
                if (fakeSavedAudit.productId == savedAudit.productId) {
                    present = YES;
                    fakeSavedAudit.inspectionStatus = savedAudit.inspectionStatus;
                    fakeSavedAudit.auditsCount = savedAudit.auditsCount;
                    fakeSavedAudit.countOfCases = savedAudit.countOfCases;
                    if (savedAudit.userEnteredAuditsCount > 0) {
                        fakeSavedAudit.userEnteredAuditsCount = savedAudit.userEnteredAuditsCount;
                    }
                    fakeSavedAudit.countOfCases = savedAudit.countOfCases;
                    fakeSavedAudit.splitGroupId = savedAudit.splitGroupId;
                    [fakeSavedAudit populateAuditCounts];
                    NSLog(@"Inspection.m - AAAAA adding to finalAudits: %@ ",fakeSavedAudit.description);
                    [finalAudits addObject:fakeSavedAudit];
                }
            }
        }
        if (!present) {
            NSLog(@"Inspection.m - BBBB adding to finalAudits: %@ ",fakeSavedAudit.description);
            [finalAudits addObject:fakeSavedAudit];
        }
    }*/
    
    [finalAudits addObjectsFromArray:allSavedAudits];
    [finalAudits addObjectsFromArray:fakeSavedAudits];
    
    //loop thru each fakeAudit and check if it exists in savedAudits
    //else add it to a new array
    /*NSMutableArray* auditsWithNoInspection = [[NSMutableArray alloc]init];
    for(SavedAudit* fakeAudit in fakeSavedAudits){
        if([allSavedAudits containsObject:fakeAudit]){
            continue;
        }
        else
            [auditsWithNoInspection addObject:fakeAudit];
    }
    finalAudits = [[NSMutableArray alloc]init];
    [finalAudits addObjectsFromArray:allSavedAudits];
    [finalAudits addObjectsFromArray:auditsWithNoInspection];*/
    
    //populate audit_count_data
    for(SavedAudit *singleSavedAudit in finalAudits){
        [singleSavedAudit populateAuditCounts];
    }
    
    if ([finalAudits count] < 1) {
        return allSavedAudits;
    }
    //allSavedAudits - real audits from DB
    //finalAudits = allSavedAudits + fakeAudits
    return finalAudits;
}

- (int) getCountOfCasesForProduct:(Product *) product withDatabase: (FMDatabase *) database{
    NSString *sku = product.selectedSku;
    if (!sku || [sku isEqualToString:@""]) {
        sku = [product.skus lastObject];
    }
    int count = 0;
    NSString *receivedDateTime = self.dateTimeForOrderData;
    count = [[Summary getCountOfCasesFromDB:0 withGroupId:[NSString stringWithFormat:@"%d",product.group_id] withProductId:[NSString stringWithFormat:@"%d",product.product_id] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database] integerValue];
    OrderData *data;
    if (count < 1) {
        if((![self.poNumberGlobal  isEqual: @""]) && (self.poNumberGlobal != nil)){
        data = [OrderData getOrderDataWithPO: self.poNumberGlobal withItemNumber: sku withTime: receivedDateTime];
        count = [data.QuantityOfCases integerValue];
        }
        else{
            data = [OrderData getOrderDataWithGRN: self.grnGlobal withItemNumber: sku withTime: receivedDateTime];
            count = [data.QuantityOfCases integerValue];
        }
    }
    return count;
}

- (NSArray *) filteredProductGroups: (NSSet *) itemNumbers {
    if ([itemNumbers count] == 0) {
        return [Inspection sharedInspection].productGroups;
    }
    NSArray *itemNumbersArray = [itemNumbers allObjects];
    NSArray *productGroupsArrayLocal = [Inspection sharedInspection].productGroups;
    NSMutableArray *newProductGroupsSet = [NSMutableArray array];
    for (int i=0; i < [productGroupsArrayLocal count]; i++) {
        if ([[productGroupsArrayLocal objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *prg = [productGroupsArrayLocal objectAtIndex:i];
            NSArray *products = prg.products;
            NSMutableArray *newProductsArray = [NSMutableArray array];
            for (Product *product in products) {
                for (NSString *sku in product.skus) {
                    for (int j=0; j < [itemNumbersArray count]; j++) {
                        if ([sku isEqualToString:[itemNumbersArray objectAtIndex:j]]) {
                            product.selectedSku = sku;
                            [newProductsArray addObject:product];
                        }
                    }
                }
            }
            if ([newProductsArray count] > 0) {
                prg.products = newProductsArray;
                [newProductGroupsSet addObject:prg];
            }
        } else {
            Product *product = [productGroupsArrayLocal objectAtIndex:i];
            for (NSString *sku in product.skus) {
                for (int j=0; j < [itemNumbersArray count]; j++) {
                    if ([sku isEqualToString:[itemNumbersArray objectAtIndex:j]]) {
                        product.selectedSku = sku;
                        [newProductGroupsSet addObject:product];
                    }
                }
            }
        }
    }
    NSArray *newProductGroupsArray;
    newProductGroupsArray = [newProductGroupsSet copy];
    if ([newProductGroupsArray count] == 0) {
        if (!FILTER_PRODUCTS_CONTAINERS) {
            newProductGroupsArray = productGroupsArrayLocal;
        }
    }
    return newProductGroupsArray;
}

- (NSArray *) removeProductGroupsIfItsOrderData: (NSArray *) productGroupsArrayLocal {
    NSMutableArray *combineProductsArray = [NSMutableArray array];
    for (int i=0; i < [productGroupsArrayLocal count]; i++) {
        if ([[productGroupsArrayLocal objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *prg = [productGroupsArrayLocal objectAtIndex:i];
            NSArray *products = prg.products;
            [combineProductsArray addObjectsFromArray:products];
        } else {
            Product *product = [productGroupsArrayLocal objectAtIndex:i];
            [combineProductsArray addObject:product];
        }
    }
    return [combineProductsArray copy];
}

- (NSArray *) getProductGroups {
    Store *store = [[User sharedUser] currentStore];
    NSArray *groupsArray = [store getAllGroupsOfProductsForTheStore];
    NSMutableArray *productGroupsLocal = [[NSMutableArray alloc] init];
    for (ProgramGroup *programGroup in groupsArray) {
        NSArray *productsArray = [programGroup getAllProducts];
        if (![programGroup.name isEqualToString:@""]) {
            programGroup.products = productsArray;
            [productGroupsLocal addObject:programGroup];
        } else {
            [productGroupsLocal addObjectsFromArray:productsArray];
        }
    }
    NSArray *productGroupsSorted = [self sortListOfProductsForTheStore:productGroupsLocal];
    self.productGroups = productGroupsSorted;
    return self.productGroups;
}

- (void) clearOrderDataArray {
    self.orderDataArray = [[NSArray alloc] init];
}

- (NSArray *) getOrderData {
    if ([self.orderDataArray count] > 0) {
        return self.orderDataArray;
    }
    NSArray *orderDataLocal = [OrderData getAllPONumbers];
    if (orderDataLocal) {
        self.orderDataArray = orderDataLocal;
    }
    return self.orderDataArray;
}

- (NSArray *) sortListOfProductsForTheStore: (NSArray *) groupsArray {
//    NSArray *sortedArray = [[NSArray alloc] init];
//    if ([groupsArray count] > 0) {
//        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//        NSArray *sortDescriptors = @[sort];
//        sortedArray = [groupsArray sortedArrayUsingDescriptors:sortDescriptors];
//    }
    return groupsArray;
}

//deletes inspection data from device
- (void) cancelInspection {
    NSString *query = [NSString stringWithFormat:@"%@='%@'", COL_AUDIT_MASTER_ID, self.auditMasterId];
    NSString *deleteAudits = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", TBL_SAVED_AUDITS, query];
    NSString *deleteContainer = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", TBL_SAVED_CONTAINERS, query];
    NSString *deleteSummary = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", TBL_SAVED_SUMMARY, query];
    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[NSArray arrayWithObjects:deleteAudits, deleteContainer, deleteSummary, nil] withDatabasePath:DB_APP_DATA];
    [self setInspectiveInactive];
    [self deletePONumberFromUserDefaults];
    [self deleteGRNFromUserDefaults];
    [self deleteOtherFromUserDefaults];
    [self deleteContainerIdFromUserDefaults];
    [self deleteDateTimeFromUserDefaults];
    [self deleteVendorNameFromUserDefaults];
    
    [User sharedUser].userSelectedCustomerName = nil;
    [NSUserDefaultsManager saveObjectToUserDefaults:nil withKey:CustomerNameSelected];
    
    _sharedDCInspection = nil;
}

- (void) cancelBackInspection {
    NSString *query = [NSString stringWithFormat:@"%@='%@'", COL_AUDIT_MASTER_ID, self.auditMasterId];
    NSString *deleteAudits = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", TBL_SAVED_AUDITS, query];
    NSString *deleteContainer = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", TBL_SAVED_CONTAINERS, query];
    NSString *deleteSummary = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", TBL_SAVED_SUMMARY, query];
    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[NSArray arrayWithObjects:deleteAudits, deleteContainer, deleteSummary, nil] withDatabasePath:DB_APP_DATA];
}

//Get All The Saved Audits
- (int) getAllTheSavedAudits:(int) productId {
    int count = 0;
    NSString *queryAllRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d AND %@=%@ AND%@=%@", TBL_SAVED_AUDITS, COL_AUDIT_PRODUCT_ID, productId, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];

    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAllRatings];
    while ([resultsGroupRatings next]) {
        count = count + 1;
    }
    [databaseGroupRatings close];
    return count;
}

//Get Product based on productID and GroupID

- (Product *) getProductForProductId: (int) productId withGroupId:(int) productGroupId {
    Product *productToBeRetured = nil;
    Store *store = [[User sharedUser] currentStore];
    NSArray *groupsArray = [store getAllGroupsOfProductsForTheStore];
    for (ProgramGroup *programGroup in groupsArray) {
        if (programGroup.programGroupID == productGroupId) {
            NSArray *productsArray = [programGroup getAllProducts];
            for (Product *product in productsArray) {
                if (product.product_id == productId) {
                    productToBeRetured = product;
                }
            }
        }
    }
    return productToBeRetured;
}

- (Product *) getProductForProductIdFromProductGroups: (int) productId withGroupId:(int) productGroupId {
    Product *productToBeRetured = nil;
    NSArray *groupsArray = self.productGroups;
    //logging to crashlytics to narrow down the crash in this method
    //CLS_LOG(@"Inspection.m  getProductForProductIdFromProductGroups:%d withGroupId:%d", productId, productGroupId);
    for (int i = 0; i < [groupsArray count]; i++) {
        if ([[groupsArray objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *prg = [groupsArray objectAtIndex:i];
            NSArray *products = prg.products;
            for (Product *product in products) {
                if (product.product_id == productId) {
                    productToBeRetured = product;
                    break;
                }
            }
        } else {
            Product *product = [groupsArray objectAtIndex:i];
            if (product.product_id == productId) {
                productToBeRetured = product;
                break;
            }
        }
    }
    return productToBeRetured;
}

// Finish helper function
- (void) saveAuditInOfflineTable:(Audit *) auditJson withImages:(NSString *) jsonString {
    NSString *auditJsonString = [auditJson toJSONString];
    NSLog(@"%@",auditJsonString);
    NSError* err = nil;
    ImageArray *imageArray = [[ImageArray alloc] initWithString:jsonString error:&err];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:now];
    NSString *auditIdLocal = auditJson.auditData.audit.id;
    NSString *status = @"TRUE";
    if ([imageArray.images count] > 0) {
        status = @"FALSE";
    }
    if (auditJson.auditData.duplicate) {
        status = @"TRUE";
    }
    
    //NSLog(@"Final Product JSON Object : %@", auditJson.auditData.submittedInfo.product);
     NSLog(@"Final Audit JSON Object : %@", [auditJson.auditData.audit toJSONString]);
    //NSLog(@"Final Images JSON Object : %@", auditJson.auditData.images);
    //NSLog(@"Final Summary Object : %@", auditJson.auditData.summary);
    
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    [database open];
    [database executeUpdate:@"insert into COMPLETED_AUDITS (id, ratings, DATA_SUBMITTED, IMAGE_SUBMITTED, AUDIT_IMAGE, DATA_COMPLETED_TIME) values (?,?,?,?,?,?)", auditIdLocal, auditJsonString, @"FALSE", status, jsonString, stringFromDate];
    [database close];
    
    //[[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[NSArray arrayWithObject:queryAllContainerRating] withDatabasePath:DB_OFFLINE_DATA];
}

- (BOOL) isInspectionActive {
    isInspectionActive = [NSUserDefaultsManager getBOOLFromUserDeafults:PREF_INSPECTION_ACTIVE];
    return isInspectionActive;
}

/* Create JSON with Container Ratings in the savedContainer object */
- (NSString *) generateContainerRatingsJson{
    Container *containerWithRatings = self.savedContainer;
    NSMutableArray *listOfRatings = [[NSMutableArray alloc] init];
    [listOfRatings addObjectsFromArray:containerWithRatings.ratingsFromUI];
    
    // parent array for all container ratings
    AuditApiContainerParent *containerParentArray = [[AuditApiContainerParent alloc]init];
    NSMutableArray *arrayOfRatings = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfDefects = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfSeverities = [[NSMutableArray alloc] init];
    for(Rating *aRating in listOfRatings) {
        
        // create json of ratings
        AuditApiContainerRating *rating = [[AuditApiContainerRating alloc] init];
        [rating setId:aRating.ratingID];
        [rating setContainer_id:containerWithRatings.containerID];
        [rating setValue:aRating.ratingAnswerFromUI];
        for(Defect *aDefect in aRating.defectsFromUI) {
            AuditApiDefect *defect = [[AuditApiDefect alloc] init];
            [defect setId:aDefect.defectID];
            defect.present = aDefect.isSetFromUI;
            for(int i = 0; i < aDefect.severities.count; i++)
            {
                Severity *severity = aDefect.severities[i];
                AuditApiSeverity *severityApi = [[AuditApiSeverity alloc]init];
                severityApi.isSelected = severity.isSelected;
                severityApi.denominator = severity.inputDenominator;
                severityApi.numerator = severity.inputNumerator;
                severityApi.severity = severity.name;
                
                //[defect.severities addObject:severity];
                [arrayOfSeverities addObject:severityApi];
            }
            NSArray *severityCopy = [NSArray arrayWithArray:arrayOfSeverities];
            
            [defect setSeverities:(NSArray<AuditApiSeverity>*)severityCopy];
            [arrayOfDefects addObject:defect];
            [arrayOfSeverities removeAllObjects];
        }
        // create a copy of array
        NSArray *copy = [NSArray arrayWithArray:arrayOfDefects];
        [rating setDefects:(NSArray<AuditApiDefect>*)copy];
        [arrayOfRatings addObject:rating];
        [arrayOfDefects removeAllObjects];
    }
    [containerParentArray setContainerRatings:(NSArray<AuditApiContainerRating>*)arrayOfRatings];
    
    NSString *containerJsonString = [containerParentArray toJSONString];
    //NSLog(@"%@", containerJsonString);
    return containerJsonString;
    
}

- (NSArray *) containerImagesArrayJSON {
    // add image remote URL to JSON
    NSMutableArray *imageList = [NSMutableArray array];
    if(self.containerImages!=nil && [self.containerImages count]>0) {
        for(Image *singleImage in self.containerImages) {
            NSString *imageRemoteUrl = singleImage.remoteUrl;
            [imageList addObject:imageRemoteUrl];
        }
    }
//    NSArray* models = [Image arrayOfModelsFromDictionaries: imageList];

    return imageList;
}

// save the container ratings to JSON
- (void) saveContainerRatingsToDB {
    NSString* models = [self toJSONString:[self containerImagesArrayJSON]];
    NSString *ratingsJson = [self generateContainerRatingsJson];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
    [database executeUpdate:@"insert into SAVED_CONTAINERS (AUDIT_MASTER_ID, INSPECTION_NAME, ratings, IMAGES) values (?,?,?,?)", self.auditMasterId, @"", ratingsJson, models];
    [database close];
}

- (NSString*) toJSONString: (NSArray *) objects {
    NSString *string = [NSString stringWithFormat:@"%@", [objects componentsJoinedByString:@","]];
    return string;
}

- (void) saveContainerImagesToDB {
    self.containerImages = [[NSMutableArray alloc] init];
    NSArray *imagesArray = [[User sharedUser] allImages];
    int i = 0;
    for (UIImage *image in imagesArray) {
        Image *savedImage = [[Image alloc] init];
        NSString *deviceUrl = [NSString stringWithFormat:@"%@_%d.jpg", [self getContainerImageCompositeAuditId], i];
        [savedImage setDeviceUrl:deviceUrl];
        NSString *remoteUrl = [self getRemoteUrl:i];
        [savedImage setRemoteUrl:remoteUrl];
        NSString *path = [self getPath:i];
        [savedImage setPath:path];
        [savedImage saveImageToDevice:image];
        NSString *auditIdContainer = [self getContainerImageCompositeAuditId];
        [savedImage setAuditIdForContainer:auditIdContainer];
        [self.containerImages addObject:savedImage];
        i++;
    }
}

- (NSString *) getPath:(int) position {
    NSString* path = [NSString stringWithFormat:@"/%@/%@/%d%@", [self getContainerImageCompositeAuditId], @"CONTAINER", position, @".jpg"];
    return path;
}

- (NSString *)getRemoteUrl:(int) position {
    // originally read from GET request
    NSString* imageHost = [NSUserDefaultsManager getObjectFromUserDeafults:IMAGE_HOST_ENDPOINT];//http://cdn.yottamark.com/portal/_qa/audits
    NSString* remoreUrl = [NSString stringWithFormat:@"%@/%@/%@/%d%@", imageHost , [self getContainerImageCompositeAuditId], @"CONTAINER", position, @".jpg"];
    return remoreUrl;
}

- (NSArray *) getContainerFromDB {
    NSMutableArray *apiContainerParentArray = [[NSMutableArray alloc] init];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TBL_SAVED_CONTAINERS]];
    while ([resultsGroupRatings next]) {
        NSError* err = nil;
        AuditApiContainerParent* containerRating = [[AuditApiContainerParent alloc] initWithString:[resultsGroupRatings stringForColumn:COL_RATINGS] error:&err];
        for (AuditApiContainerRating *auditApiContainerRatingumeric in containerRating.containerRatings) {
            //NSLog(@"value %@", auditApiContainerRatingumeric.value);
            //NSLog(@"containerId %d", auditApiContainerRatingumeric.container_id);
            //NSLog(@"ratingId %d", auditApiContainerRatingumeric.id);
        }
        NSDictionary *dictionaryLocal = @{@"apiContainerParentArray":containerRating, @"MasterID": [resultsGroupRatings stringForColumn:COL_AUDIT_MASTER_ID], @"ContainerName": [resultsGroupRatings stringForColumn:COL_INSPECTION_NAME]};
        [apiContainerParentArray addObject:dictionaryLocal];
    }
    [databaseGroupRatings close];
    return [apiContainerParentArray copy];
}

//Doubtful
- (NSArray<AuditApiContainerRating> *) getContainerRatingsForInspection:(NSString *) auditMasterIdLocal {
    NSArray<AuditApiContainerRating> *ratingsJson;
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@", TBL_SAVED_CONTAINERS, COL_AUDIT_MASTER_ID, auditMasterIdLocal]];
    while ([resultsGroupRatings next]) {
        NSError* err = nil;
        AuditApiContainerParent* containerRating = [[AuditApiContainerParent alloc] initWithString:[resultsGroupRatings stringForColumn:COL_RATINGS] error:&err];
        ratingsJson = containerRating.containerRatings;
    }
    [databaseGroupRatings close];
    return ratingsJson;
}

//Returns summary to display in Inspection Summary for each product

- (AuditApiSummary *) getSummaryForGroup: (NSString *) auditMasterIdLocal withAuditGroupID: (NSString *) auditGroupIdLocal {
    AuditApiSummary *summaryJSON;
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterIdLocal, COL_AUDIT_GROUP_ID, auditGroupIdLocal,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId]];
    while ([resultsGroupRatings next]) {
        NSError* err = nil;
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_SUMMARY];
        AuditApiSummary* summaryCursor = [[AuditApiSummary alloc] initWithString:ratings error:&err];
        summaryJSON = summaryCursor;
    }
    [databaseGroupRatings close];
    return summaryJSON;
}


// unit test the generateContainerStrings
-(void) unitTestForCreatingContainerRatings {
    Inspection *inspection = [Inspection sharedInspection];
    Container *container = [[Container alloc]init];
    [container setContainerID:1];
    
    Rating *rating1 = [[Rating alloc]init];
    [rating1 setContainerID:1];
    [rating1 setRatingID:9];
    
    Rating *rating2 = [[Rating alloc]init];
    [rating1 setContainerID:4];
    [rating1 setRatingID:6];
    
    Defect *defect1 = [[Defect alloc]init];
    [defect1 setDefectID:0];
    Defect *defect2 = [[Defect alloc]init];
    [defect2 setDefectID:7];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObject:defect1];
    [array addObject:defect2];
    [rating1 setDefects:array];
    [rating2 setDefects:array];
    
    NSMutableArray *arrayRating = [NSMutableArray arrayWithObjects:rating1,rating2, nil];
    [container setRatings:arrayRating];
    
    [inspection setSavedContainer:container];
    
    [inspection generateContainerRatingsJson];
}

- (void) setInspectiveInactive {
    [NSUserDefaultsManager saveObjectToUserDefaults:@"" withKey:PREF_AUDIT_MASTER_ID];
    self.auditMasterId = nil;
    self.poNumberGlobal = @"";
    self.grnGlobal = @"";
    self.containerId = @"";
    self.dateTimeForOrderData = @"";
    self.productGroups = nil;
    self.orderDataArray = nil;
    self.isInspectionActive = NO;
    self.isOtherSelected = NO;
    self.productGroups = [NSArray array];
    self.orderDataArray = [NSArray array];
    [User sharedUser].userSelectedVendorName = @"";
    self.collobarativeInspection = nil;
}

- (NSString *) getContainerImageCompositeAuditId {
    NSString *deviceId = [DeviceManager getDeviceID];
    NSString *auditIdLocal = [NSString stringWithFormat:@"%@-%@-0000000000000-0000000000000", deviceId, self.auditMasterId];
    return auditIdLocal;
}


- (NSArray *) getContainerImageJsonForInspection {
    NSMutableArray *containerImagesLocal = [[NSMutableArray alloc] init];
    NSString *queryAllContainerRating = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@", TBL_SAVED_CONTAINERS, COL_AUDIT_MASTER_ID, self.auditMasterId];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAllContainerRating];
    while ([resultsGroupRatings next]) {
        NSString *imageJson = [resultsGroupRatings stringForColumn:COL_IMAGES];
        if (![imageJson isEqualToString:@""]) {
            NSArray *remoteUrls = [imageJson componentsSeparatedByString:@","];
            int i = 0;
            for (NSString *stringRemoteUrl in remoteUrls) {
                //NSLog(@"%@", stringRemoteUrl);
                Image *image = [[Image alloc] init];
                NSString *endPoint = [NSUserDefaultsManager getObjectFromUserDeafults:IMAGE_HOST_ENDPOINT];
                NSString *compositeIdLocal = [self getContainerImageCompositeAuditId];
                NSString *remoteUrl = [NSString stringWithFormat:@"%@/%@/CONTAINER/%d.jpg", endPoint, compositeIdLocal,i];
                image.remoteUrl = remoteUrl;
                image.path = [NSString stringWithFormat:@"/%@/CONTAINER/%d.jpg", compositeIdLocal, i];
                image.deviceUrl = [NSString stringWithFormat:@"%@_%d.jpg", compositeIdLocal, i];
                image.auditIdForContainer = [self getContainerImageCompositeAuditId];
                i++;
                [containerImagesLocal addObject:image];
            }
        }
    }
    [databaseGroupRatings close];
    return [containerImagesLocal copy];
}

/*!
 *  Saving PO Number to NSUserDefaults
 *
 *  @param poNumber
 */
- (void) savePONumberToInspection: (NSString *) poNumber {
    if (poNumber) {
        self.poNumberGlobal = poNumber;
    }
}
- (void) saveGRNToInspection: (NSString *) grn {
    if (grn) {
        self.grnGlobal = grn;
    }
}
- (void) saveOtherToInspection: (BOOL) otherSelected {
    if (otherSelected) {
        self.isOtherSelected = otherSelected;
    }
}

- (void) saveContainerIdToInspection: (NSString *) containerId {
    if (containerId) {
        self.containerId = containerId;
    }
}

//Track NonOrderDataValues
-(void)savePOForNonOrderDataInspection:(NSString*)poNumber{
    if(!self.nonOrderDataInspectionValues)
        self.nonOrderDataInspectionValues = [[NonOrderDataValues alloc]init];
    self.nonOrderDataInspectionValues.poNumber = poNumber;
}

-(void)saveGRNForNonOrderDataInspection:(NSString*)grn{
    if(!self.nonOrderDataInspectionValues)
        self.nonOrderDataInspectionValues = [[NonOrderDataValues alloc]init];
    self.nonOrderDataInspectionValues.grn = grn;
}
-(void)saveSupplierForNonOrderDataInspection:(NSString*)supplier {
    if(!self.nonOrderDataInspectionValues)
        self.nonOrderDataInspectionValues = [[NonOrderDataValues alloc]init];
    self.nonOrderDataInspectionValues.supplierName = supplier;
}

-(void)resetNonOrderDataValues {
    self.nonOrderDataInspectionValues = [[NonOrderDataValues alloc]init];
}

- (void) checkForPONumberAndSaveItInUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal && ([self checkForOrderData] || [self.poNumberGlobal isEqualToString:@""])) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        //moved after adding the dictionary - otherwise gets overwritten (if key already present in dict)
        //[mutableDict setObject:self.poNumberGlobal forKey:auditMasterIdLocal];
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:PONUMBER_DICT];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
        }
        [mutableDict setObject:self.poNumberGlobal forKey:auditMasterIdLocal];
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:PONUMBER_DICT];
    }
    NSLog(@"PO_NUMBER_DICT is %@", [NSUserDefaultsManager getObjectFromUserDeafults:PONUMBER_DICT]);
}
- (void) checkForGRNAndSaveItInUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal && ([self checkForOrderData] || [self.grnGlobal isEqualToString:@""])) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];

        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:GRN_DICT];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
        }
        [mutableDict setObject:self.grnGlobal forKey:auditMasterIdLocal];
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:GRN_DICT];
    }
    NSLog(@"GRN_DICT is %@", [NSUserDefaultsManager getObjectFromUserDeafults:GRN_DICT]);
}
- (void) checkForOtherAndSaveItInUserDefaults: (BOOL) isOtherSelected {
    [self initiateAuditMasterId];
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setObject:[NSNumber numberWithBool:isOtherSelected] forKey:self.auditMasterId];
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:OTHER_DICT];
    NSMutableDictionary *dictionaryFromDefaultsManagerMutable = [dictionaryFromDefaultsManager mutableCopy];
    if (dictionaryFromDefaultsManagerMutable) {
        [dictionaryFromDefaultsManagerMutable removeObjectForKey:self.auditMasterId];
        [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManagerMutable];
    }
    [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:OTHER_DICT];
    self.isOtherSelected = isOtherSelected;
}

- (void) checkForContainerIdAndSaveItInUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        if ([self.containerId length]) {
            [mutableDict setObject:self.containerId forKey:auditMasterIdLocal];
        }
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:containerIdForProductsFiltering];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:containerIdForProductsFiltering];
    }
}

- (NSString *) initiateAuditMasterId {
    if (!self.auditMasterId) {
        NSString *deviceCurrentTime = [DeviceManager getCurrentTimeString];
        self.auditMasterId = deviceCurrentTime;
    }
    return self.auditMasterId;
}


- (void) checkForVendorNameAndSaveItInUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal && ([self checkForOrderData] || [[User sharedUser].userSelectedVendorName isEqualToString:@""])) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        if (![[User sharedUser].userSelectedVendorName isEqualToString:@""] && [User sharedUser].userSelectedVendorName) {
            //moved after adding the dictionary - otherwise gets overwritten (if key already present in dict)
            //[mutableDict setObject:[User sharedUser].userSelectedVendorName forKey:auditMasterIdLocal];
            NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:VENDORNAME_DICT];
            if (dictionaryFromDefaultsManager) {
                [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
            }
            [mutableDict setObject:[User sharedUser].userSelectedVendorName forKey:auditMasterIdLocal];
            [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:VENDORNAME_DICT];
        }
    }
}

- (void) checkForDateTimeAndSaveItInUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal && [self checkForDateTime]) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        [mutableDict setObject:self.dateTimeForOrderData forKey:auditMasterIdLocal];
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:DATETIME_DICT];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:DATETIME_DICT];
    }
}

- (void) deletePONumberFromUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal && [self checkForOrderData]) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:PONUMBER_DICT];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
            [mutableDict removeObjectForKey:auditMasterIdLocal];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:PONUMBER_DICT];
    }
}
- (void) deleteGRNFromUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal && [self checkForOrderData]) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:GRN_DICT];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
            [mutableDict removeObjectForKey:auditMasterIdLocal];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:GRN_DICT];
    }
}
- (void) deleteOtherFromUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:OTHER_DICT];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
            [mutableDict removeObjectForKey:auditMasterIdLocal];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:OTHER_DICT];
    }
}

- (void) deleteContainerIdFromUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:containerIdForProductsFiltering];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
            [mutableDict removeObjectForKey:auditMasterIdLocal];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:containerIdForProductsFiltering];
    }
}

- (void) deleteDateTimeFromUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal && [self checkForDateTime]) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:DATETIME_DICT];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
            [mutableDict removeObjectForKey:auditMasterIdLocal];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:DATETIME_DICT];
    }
}

- (void) deleteVendorNameFromUserDefaults {
    NSString *auditMasterIdLocal = self.auditMasterId;
    if (auditMasterIdLocal && [self checkForOrderData]) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:VENDORNAME_DICT];
        if (dictionaryFromDefaultsManager) {
            [mutableDict addEntriesFromDictionary:dictionaryFromDefaultsManager];
            [mutableDict removeObjectForKey:auditMasterIdLocal];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:mutableDict withKey:VENDORNAME_DICT];
    }
}


- (BOOL) checkForOrderData {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([appName isEqualToString:@"Retail-Insights"] ) {
        return NO;
    }
    BOOL orderData = NO;
    if (![self.poNumberGlobal isEqualToString:@""] && self.poNumberGlobal) {
        orderData = YES;
    }
    else if (![self.grnGlobal isEqualToString:@""] && self.grnGlobal) {
        orderData = YES;
    }
    NSLog(@"PO is %@ : Supplier is %@", self.poNumberGlobal, [User sharedUser].userSelectedVendorName);
    return orderData;
}

- (BOOL) checkForDateTime {
    BOOL dateTime = NO;
    if (![self.dateTimeForOrderData isEqualToString:@""] && self.dateTimeForOrderData) {
        dateTime = YES;
    }
    return dateTime;
}

- (void)groupDefects:(void (^)(NSArray *array))block withDefects:(NSArray *) defects {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSMutableArray *mutableDefects = [[NSMutableArray alloc] init];
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_position" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *defectsLocal = [defects sortedArrayUsingDescriptors:descriptors]; //sorted using "order_position"
        NSMutableArray *groups = [NSMutableArray array];
        NSMutableArray *groupArrays = [NSMutableArray array];
        NSString *groupName = nil;
        // create hashmap - groupName<->array of defects
        for (int i=0; i < [defectsLocal count]; i++) {
            Defect *defect = [defectsLocal objectAtIndex:i];
            if (i == 0) {
                groupName = defect.defectGroupName;
                [groups addObject:defect];
            } else {
                if ([groupName isEqualToString:defect.defectGroupName]) {
                    [groups addObject:defect];
                    if (i == [defectsLocal count] - 1) {
                        [groupArrays addObject:groups];
                    }
                } else {
                    groupName = defect.defectGroupName;
                    [groupArrays addObject:groups];
                    groups = [NSMutableArray array];
                    [groups addObject:defect];
                    if (i == [defectsLocal count] - 1) {
                        [groupArrays addObject:groups];
                    }
                }
            }
        }
        for (int i=0; i < [groupArrays count]; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            NSMutableDictionary *group = [[NSMutableDictionary alloc] init];
            [group setObject:[groupArrays objectAtIndex:i] forKey:key];
            [mutableDefects addObject:group];
        }
//        groups = [[groups sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
//        BOOL otherPresent = NO;
//        for (int i=0; i < [groups count]; i++) {
//            if ([[groups objectAtIndex:i] isEqualToString:OtherDefectGroup]) {
//                otherPresent = YES;
//                [groups removeObjectAtIndex:i];
//            }
//        }
//        if (otherPresent) {
//            [groups addObject:OtherDefectGroup];
//        }
//        for (NSString *groupName in groups) {
//            NSMutableArray *mut = [[NSMutableArray alloc] init];
//            for (Defect *defectsLocal in defects) {
//                if ([groupName isEqualToString:defectsLocal.defectGroupName]) {
//                    [mut addObject:defectsLocal];
//                }
//            }
//            NSSortDescriptor *dateDescriptor = [NSSortDescriptor
//                                                sortDescriptorWithKey:@"severityNameForSortingLater"
//                                                ascending:YES];
//            NSSortDescriptor *dateDescriptor1 = [NSSortDescriptor
//                                                 sortDescriptorWithKey:@"name"
//                                                 ascending:YES];
//            NSArray *sortDescriptors = [NSArray arrayWithObjects: dateDescriptor, dateDescriptor1, nil];
//            NSArray *sortedEventArray = [mut sortedArrayUsingDescriptors:sortDescriptors];
//            NSLog(@"sortedEventArray == %@", sortedEventArray);
//            NSMutableDictionary *group = [[NSMutableDictionary alloc] init];
//            [group setObject:sortedEventArray forKey:groupName];
//            [mutableDefects addObject:group];
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
            block(mutableDefects);
        });
    });
}

- (NSArray *) groupSupplierNames: (NSArray *) productAudits {
    NSMutableArray *groups = [productAudits valueForKeyPath:@"@distinctUnionOfObjects.supplierName"];
    //NSLog(@"efvdf %@", groups);
    return groups;
}



- (NSArray *) groupDefects: (NSArray *) defects {
    NSMutableArray *mutableDefects = [[NSMutableArray alloc] init];
    NSMutableArray *groups = [defects valueForKeyPath:@"@distinctUnionOfObjects.defectGroupName"];
    groups = [[groups sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    BOOL otherPresent = NO;
    for (int i=0; i < [groups count]; i++) {
        if ([[groups objectAtIndex:i] isEqualToString:OtherDefectGroup]) {
            otherPresent = YES;
            [groups removeObjectAtIndex:i];
        }
    }
    if (otherPresent) {
        [groups addObject:OtherDefectGroup];
    }
    for (NSString *groupName in groups) {
        NSMutableArray *mut = [[NSMutableArray alloc] init];
        for (Defect *defectsLocal in defects) {
            if ([groupName isEqualToString:defectsLocal.defectGroupName]) {
                [mut addObject:defectsLocal];
            }
        }
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                            sortDescriptorWithKey:@"severityNameForSortingLater"
                                            ascending:YES];
        NSSortDescriptor *dateDescriptor1 = [NSSortDescriptor
                                            sortDescriptorWithKey:@"name"
                                            ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects: dateDescriptor, dateDescriptor1, nil];
        NSArray *sortedEventArray = [mut sortedArrayUsingDescriptors:sortDescriptors];
        //NSLog(@"sortedEventArray == %@", sortedEventArray);
        NSMutableDictionary *group = [[NSMutableDictionary alloc] init];
        [group setObject:sortedEventArray forKey:groupName];
        [mutableDefects addObject:group];
    }
    return mutableDefects;
}

- (NSArray *) sortAllTheDictionaries: (NSArray *) defectDicts {
    NSMutableArray *mutableDefects = [[NSMutableArray alloc] init];
    NSMutableArray *allKeys = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in defectDicts) {
        NSArray *array = [dict allKeys];
        [allKeys addObject:[array objectAtIndex:0]];
    }
    allKeys = [[allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    for (NSString *string in allKeys) {
        for (NSDictionary *dict in defectDicts) {
            NSArray *keys = [dict allKeys];
            if ([keys count] == 1) {
                NSString *stringLocal = [keys objectAtIndex:0];
                if ([string isEqualToString:stringLocal]) {
                    NSMutableDictionary *dictMutable = [NSMutableDictionary dictionary];
                    NSArray *values = [dict allValues];
                    if ([values count] == 1) {
                        [dictMutable setObject:[values objectAtIndex:0] forKey:string];
                        [mutableDefects addObject:dictMutable];
                    }
                }
            }
        }
    }
    return mutableDefects;
}

- (BOOL) checkForSysco {
    BOOL check = NO;
    NSArray *programs = [[User sharedUser] getProgramsForUserForDistinctSamples];
    for (Program *program in programs) {
        if ([[program.name lowercaseString] rangeOfString:@"sysco"].location != NSNotFound || [[program.name lowercaseString] rangeOfString:@"woolworths"].location != NSNotFound) {
            check = YES;
        }
    }
    return check;
}

- (BOOL) checkIfProgramIsDistinctMode:(NSString*)programName {
    BOOL check = NO;
    NSArray *programs = [[User sharedUser] getUserProgramsFromDB];
    for (Program *program in programs) {
        if ([program.name isEqualToString:programName]) {
            return program.distinct_products;
        }
    }
    return check;
}

-(void) updateStarRatingWithScore:(int)newScore ratingId:(int)ratingId productId:(int)productId auditCount:(int)auditCount updateAll:(BOOL)updateAll{
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    NSString *queryAllRatings;
    if(updateAll)
        queryAllRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    else
        queryAllRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%d AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_AUDIT_COUNT, auditCount,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAllRatings];
    //[resultsGroupRatings next];
    while ([resultsGroupRatings next]) {
        NSError* err = nil;
        NSString *auditRatingsJson = [resultsGroupRatings stringForColumn:COL_AUDIT_JSON];
        int rowAuditCount =[resultsGroupRatings intForColumn:COL_AUDIT_COUNT];
        Audit* currentAuditJson = [[Audit alloc] initWithString:auditRatingsJson error:&err];
        NSMutableArray *ratings =  [currentAuditJson.auditData.submittedInfo.productRatings mutableCopy];
        int indexToModify = 0;
        for(AuditApiRating *cursor in ratings){
            if(cursor.id==ratingId){
               indexToModify  = [ratings indexOfObject:cursor];
            }
        }
        AuditApiRating *ratingToModify = [ratings objectAtIndex:indexToModify];
        ratingToModify.value = [NSString stringWithFormat:@"%d", newScore];;
        [ratings replaceObjectAtIndex:indexToModify withObject:ratingToModify];
        currentAuditJson.auditData.submittedInfo.productRatings = [ratings copy];
        //NSLog(@"AUDIT IS: %@", [currentAuditJson toJSONString]);
        NSString *modifiedAudit = [currentAuditJson toJSONString];
        //update the audit JSON back
        NSLog(@"modifying audit with prod %d count %d", productId, rowAuditCount);
        [self updateAuditJSONWithModifiedAudit:modifiedAudit productId:productId auditCount:rowAuditCount withDatabase:databaseGroupRatings] ;
    }
    [resultsGroupRatings close];
    [databaseGroupRatings close];
}

-(void) updateStarRatingAverageWithScore:(float)newScore ratingId:(int)ratingId productId:(int)productId auditCount:(int)auditCount updateAll:(BOOL)updateAll{
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    NSString *queryAllRatings;
    if(updateAll)
        queryAllRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, productId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    else
        queryAllRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%d AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_AUDIT_COUNT, auditCount,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAllRatings];
    //[resultsGroupRatings next];
    while ([resultsGroupRatings next]) {
        NSError* err = nil;
        NSString *auditRatingsJson = [resultsGroupRatings stringForColumn:COL_AUDIT_JSON];
        int rowAuditCount =[resultsGroupRatings intForColumn:COL_AUDIT_COUNT];
        Audit* currentAuditJson = [[Audit alloc] initWithString:auditRatingsJson error:&err];
        NSMutableArray *ratings =  [currentAuditJson.auditData.submittedInfo.productRatings mutableCopy];
        int indexToModify = 0;
        for(AuditApiRating *cursor in ratings){
            if(cursor.id==ratingId){
                indexToModify  = [ratings indexOfObject:cursor];
            }
        }
        AuditApiRating *ratingToModify = [ratings objectAtIndex:indexToModify];
        ratingToModify.value = [NSString stringWithFormat:@"%.2f", newScore];
        [ratings replaceObjectAtIndex:indexToModify withObject:ratingToModify];
        currentAuditJson.auditData.submittedInfo.productRatings = [ratings copy];
        //NSLog(@"AUDIT IS: %@", [currentAuditJson toJSONString]);
        NSString *modifiedAudit = [currentAuditJson toJSONString];
        //update the audit JSON back
        NSLog(@"modifying audit with prod %d count %d", productId, rowAuditCount);
        [self updateAuditJSONWithModifiedAudit:modifiedAudit productId:productId auditCount:rowAuditCount withDatabase:databaseGroupRatings] ;
    }
    [resultsGroupRatings close];
    [databaseGroupRatings close];
}

-(void) updateAuditJSONWithModifiedAudit:(NSString*)string productId:(int)productId auditCount:(int)auditCount withDatabase:(FMDatabase*)database{
    //FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    //[databaseGroupRatings open];
    NSString *updateAuditQuery = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@=%@ AND %@=%d AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_JSON,string, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_AUDIT_COUNT, auditCount,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    
    //[[DBManager sharedDBManager] executeUpdateUsingFMDataBase: withDatabasePath:DB_APP_DATA];
    [database executeUpdate:updateAuditQuery];
    
    //[databaseGroupRatings close];
}

//convert audit to a fake audit - clear the product ratings and images - used when inspection samples are changed to 0 in orderData mode
-(void) convertAuditToFakeAudit:(int)productId auditCount:(int)auditCount{
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    NSString *queryAllRatings;
        queryAllRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%d AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_AUDIT_COUNT, auditCount,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAllRatings];
    //[resultsGroupRatings next];
    while ([resultsGroupRatings next]) {
        NSError* err = nil;
        NSString *auditRatingsJson = [resultsGroupRatings stringForColumn:COL_AUDIT_JSON];
        int rowAuditCount =[resultsGroupRatings intForColumn:COL_AUDIT_COUNT];
        Audit* currentAuditJson = [[Audit alloc] initWithString:auditRatingsJson error:&err];
        NSLog(@"ORIGINAL AUDIT: %@", [currentAuditJson toJSONString]);
        currentAuditJson.auditData.submittedInfo.productRatings = (NSArray<AuditApiRating>*)[[NSArray alloc]init];

        NSMutableArray *ratings =  [currentAuditJson.auditData.submittedInfo.productRatings mutableCopy];

        NSString *modifiedAudit = [currentAuditJson toJSONString];
        //update the audit JSON back
        NSLog(@"modifying audit with prod %d count %d", productId, rowAuditCount);
        NSLog(@"MODIFIED AUDIT: %@", [currentAuditJson toJSONString]);
        [self updateAuditJSONWithModifiedAudit:modifiedAudit productId:productId auditCount:rowAuditCount withDatabase:databaseGroupRatings] ;
    }
    [resultsGroupRatings close];
    [databaseGroupRatings close];
}


@end
