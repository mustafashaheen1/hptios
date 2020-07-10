//
//  CurrentAudit.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "CurrentAudit.h"
#import "LocationManager.h"
#import "Image.h"
#import "ImageArray.h"
#import "DCBaseEntity.h"
#import "Inspection.h"
#import "DaysRemainingValidator.h"

#define min 9999900
#define max 9999999

@implementation CurrentAudit

// create new product object
// add rating to it

- (id)init
{
    self = [super init];
    if (self) {
        self.allRatings = [[NSMutableArray alloc] init];
        self.userEnteredInspectionSamples = @"";
        self.allImages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) setAllTheCurrentAuditVariables:(int) auditNumber withAuditMasterId:(NSString *) auditMasterId withAuditGroupId:(NSString *) auditGroupId withProductID:(int)productID withProductGroupID:(int)productGroupID withProgramID:(int) programId withProgramVersion:(int) programVersion {
    self.auditMasterId = auditMasterId;
    // if audit group ID already exists - same product/group combination has already been audited
    [self initializeGroupIdFromSavedAudit:auditMasterId withProductID:productID withproductGroupID:productGroupID];
    self.auditNumber = auditNumber;
    self.programId = programId;
    self.programVersion = programVersion;
    self.auditTransactionId = [DeviceManager getCurrentTimeString];
    self.auditStartTime = [DeviceManager getCurrentTimeString];
    self.timeZone = [DeviceManager getCurrentTimeZoneString];
}

- (void) setAllTheCurrentAuditVariables:(int) auditNumber withAuditMasterId:(NSString *) auditMasterId withAuditGroupId:(NSString *) auditGroupId withProductID:(int)productID withProductGroupID:(int)productGroupID withProgramID:(int) programId withProgramVersion:(int) programVersion withDatabase:(FMDatabase *) database {
    self.auditMasterId = auditMasterId;
    // if audit group ID already exists - same product/group combination has already been audited
    [self initializeGroupIdFromSavedAudit:auditMasterId withProductID:productID withproductGroupID:productGroupID withDatabase:database];
    self.auditNumber = auditNumber;
    self.programId = programId;
    self.programVersion = programVersion;
    self.auditTransactionId = [DeviceManager getCurrentTimeString];
    self.auditStartTime = [DeviceManager getCurrentTimeString];
    self.timeZone = [DeviceManager getCurrentTimeZoneString];
}

- (void) setAllTheCurrentAuditVariablesFromExistingAudit:(int) auditNumber withAuditMasterId:(NSString *) auditMasterId withAuditGroupId:(NSString *) auditGroupId withProgramID:(int) programId withProgramVersion:(int) programVersion {
    self.auditMasterId = auditMasterId;
    self.auditGroupId = auditGroupId;
    self.auditNumber = auditNumber;
    self.programId  = programId;
    self.programVersion = programVersion;
    self.auditTransactionId = [DeviceManager getCurrentTimeString];
    self.auditStartTime =  [DeviceManager getCurrentTimeString];
}

- (void)addRating: (Rating *) ratingLocal {
    [self.allRatings addObject:ratingLocal];
}

- (NSString *) getCompositeAuditID {
    if (self.compositeAuditIDLocal) {
        return self.compositeAuditIDLocal;
    }
    NSString *deviceID = [DeviceManager getDeviceID];
    NSString *auditMasterId = self.auditMasterId;
    NSString *auditGroupString = self.auditGroupId;
    NSString *auditTransacString = self.auditTransactionId;
    NSString *auditId = [NSString stringWithFormat:@"%@-%@-%@-%@", deviceID, auditMasterId, auditGroupString, auditTransacString];
    if (!auditId) {
        return @"";
    }
    return auditId;
}

- (BOOL) isAuditPresentInDB: (NSString *) auditSavedMasterId withAuditCount:(int) auditCount withProductID: (int) productID withUserEnteredSamples: (int) userEnteredAuditCount {
    BOOL isExistingAudit = NO;
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %@ AND %@=%d AND %@=%d AND %@ = %@ ", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, auditSavedMasterId, COL_AUDIT_PRODUCT_ID, productID, COL_AUDIT_COUNT, auditCount, COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
    resultsGroupRatings = [databaseGroupRatings executeQuery:retrieveStatement];
    [databaseGroupRatings open];
    while ([resultsGroupRatings next]) {
        isExistingAudit = YES;
    }
    [databaseGroupRatings close];
    return isExistingAudit;
}

- (int) getNumberOfSavedAudits {
    int numberOfAudits = 0;
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %@ AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, self.product.product_id,COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:retrieveStatement];
    while ([resultsGroupRatings next]) {
        numberOfAudits++;
    }
    [databaseGroupRatings close];
    return numberOfAudits;
}

- (void) deleteCurrentAuditFromDB {
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [databaseGroupRatings open];
    NSString *retrieveStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %@ AND %@=%d AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, self.product.product_id, COL_AUDIT_COUNT, self.auditNumber,COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
    [databaseGroupRatings executeUpdate:retrieveStatement];
    [databaseGroupRatings close];
    if (![self isAuditPresentInDB:self.auditMasterId withAuditCount:self.auditNumber withProductID:self.product.product_id withUserEnteredSamples:[self.userEnteredInspectionSamples integerValue]]) {
        NSLog(@"removed");
        FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        FMResultSet *resultsGroupRatings;
        NSString *retrieveStatement2 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %@ AND %@=%d AND %@>%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, self.product.product_id, COL_AUDIT_COUNT, self.auditNumber,COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
        [databaseGroupRatings open];
        resultsGroupRatings = [databaseGroupRatings executeQuery:retrieveStatement2];
        while ([resultsGroupRatings next]) {
            NSLog(@"present");
            int auditNumberLocalFromSQL = [resultsGroupRatings intForColumn:COL_AUDIT_COUNT];
            NSString *retrieveStatement3 = [NSString stringWithFormat:@"UPDATE %@ SET %@=%d WHERE %@=%@ AND %@=%d AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_COUNT, auditNumberLocalFromSQL - 1, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, self.product.product_id, COL_AUDIT_COUNT, auditNumberLocalFromSQL,COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
            [databaseGroupRatings executeUpdate:retrieveStatement3];
        }
        [databaseGroupRatings close];
    }
}

- (void) saveCurrentAuditToDB : (NSInteger)duplicateAuditCount {
    
    self.auditEndTime =  [DeviceManager getCurrentTimeString];
    NSString* auditJsonString = [self generateAuditJson:NO];
    NSLog(@"%@",auditJsonString);
    // add image remote URL to JSON
    ImageArray *images = [[ImageArray alloc] init];
    NSArray *copy = [NSArray arrayWithArray:self.allImages];
    [images setImages:(NSArray<Image>*)copy];
    NSString* imagesJsonString = [images toJSONString];
//overwrite
    if ([self isAuditPresentInDB:self.auditMasterId withAuditCount:self.auditNumber withProductID:self.product.product_id withUserEnteredSamples:[self.userEnteredInspectionSamples integerValue]]) {
        NSString *retrieveStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@=%@, %@=%@, %@=%d, %@='%@', %@='%@', %@='%@', %@=%d, %@='%d', %@=%@ WHERE %@=%@ AND %@=%d AND %@=%d AND %@='%@'", TBL_SAVED_AUDITS, COL_IMAGES, imagesJsonString, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_GROUP_ID, self.auditGroupId, COL_AUDIT_PRODUCT_ID, self.product.product_id, COL_PRODUCT_NAME, self.product.product_name, COL_AUDIT_JSON, auditJsonString, COL_INSP_STATUS, INSPECTION_STATUS_NONE, COL_AUDIT_COUNT, self.auditNumber, COL_USERENTERED_SAMPLES, [self.userEnteredInspectionSamples integerValue], COL_COUNT_OF_CASES, self.countOfCasesFromRatings, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, self.product.product_id, COL_AUDIT_COUNT, self.auditNumber, COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
        [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[NSArray arrayWithObject:retrieveStatement] withDatabasePath:DB_APP_DATA];
        FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        for(int i = self.auditNumber; i <= self.auditNumber + duplicateAuditCount; i++) {
            // if duplicateAuditCount = 0, then do not duplicate the audit
            if(i>self.auditNumber) {
                //imagesJsonString = nil;
                //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:introducingDelayForDuplicates]];
                [NSThread sleepForTimeInterval:0.3f]; //issue with sleepUntilDate on iPad
                self.auditTransactionId = [DeviceManager getCurrentTimeString];
                auditJsonString = [self generateAuditJson:YES];
                Audit *localAudit = [[Audit alloc] initWithString:auditJsonString error:nil];
                localAudit.auditData.submittedInfo.duplicates.value = YES;
                localAudit.auditData.submittedInfo.duplicates.count = duplicateAuditCount;
                auditJsonString = [localAudit toJSONString];
                imagesJsonString = @"";
                [database executeUpdate:@"insert into SAVED_AUDITS (AUDIT_MASTER_ID, AUDIT_GROUP_ID, AUDIT_PRODUCT_ID, product_name, AUDIT_JSON, INSP_STATUS, audit_count, productGroup_id, IMAGES, user_entered_inspection_samples, count_of_cases,SPLIT_GROUP_ID) values (?,?,?,?,?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%@", self.auditMasterId], self.auditGroupId, [NSString stringWithFormat:@"%d", self.product.product_id], self.product.product_name, auditJsonString, @"ACCEPT", [NSString stringWithFormat:@"%d", i], [NSString stringWithFormat:@"%d", self.product.group_id], imagesJsonString, self.userEnteredInspectionSamples, self.countOfCasesFromRatings, [Inspection sharedInspection].currentSplitGroupId];
            }
        }
        [database close];
    } else {
        FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        for(int i=0; i<=duplicateAuditCount; i++) {
            // if duplicateAuditCount = 0, then do not duplicate the audit
            //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:introducingDelayForDuplicates]];
            [NSThread sleepForTimeInterval:0.3f]; //issue with sleepUntilDate on iPad
            if(i>0) {
                self.auditTransactionId = [DeviceManager getCurrentTimeString];
                //NSLog(@"Delaying");
                auditJsonString = [self generateAuditJson:YES];
                Audit *localAudit = [[Audit alloc] initWithString:auditJsonString error:nil];
                localAudit.auditData.submittedInfo.duplicates.value = YES;
                localAudit.auditData.submittedInfo.duplicates.count = duplicateAuditCount;
                //DI-2744 - comment out to use the image in duplicate samples
                /*localAudit.auditData.images = [[NSArray alloc]init];//do not duplicate image
                imagesJsonString = @"";*/
                auditJsonString = [localAudit toJSONString];
                
                //NSLog(@"ID at duplicate : %@", [localAudit.auditData.audit toJSONString]);
            }
            long orderDataId = [OrderData getOrderDataIdForItem:self.product.selectedSku];
            [database executeUpdate:@"insert into SAVED_AUDITS (AUDIT_MASTER_ID, AUDIT_GROUP_ID, AUDIT_PRODUCT_ID, ORDER_ID, product_name, AUDIT_JSON, INSP_STATUS, audit_count, productGroup_id, IMAGES, user_entered_inspection_samples, count_of_cases,SPLIT_GROUP_ID) values (?,?,?,?,?,?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%@", self.auditMasterId], self.auditGroupId, [NSString stringWithFormat:@"%d",self.product.product_id], [NSString stringWithFormat:@"%d", orderDataId],self.product.product_name, auditJsonString, @"ACCEPT", [NSString stringWithFormat:@"%d",self.auditNumber++], [NSString stringWithFormat:@"%d", self.product.group_id], imagesJsonString, self.userEnteredInspectionSamples, self.countOfCasesFromRatings,[Inspection sharedInspection].currentSplitGroupId];
        }
        [database close];
    }
}

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
- (void) initializeGroupIdFromSavedAudit:auditMasterId withProductID:(int)productID withproductGroupID:(int) productGroupId{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        FMResultSet *resultsGroupRatings;
        [databaseGroupRatings open];
        NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@=%d AND %@=%d", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_PRODUCT_ID, productID, COL_PRODUCT_GROUP_ID, productGroupId];
        resultsGroupRatings = [databaseGroupRatings executeQuery:retrieveStatement];
        //set the groupId in case does not go into while loop
        self.auditGroupId = [DeviceManager getCurrentTimeString];
        while ([resultsGroupRatings next]) {
            NSString *auditGroupId = [resultsGroupRatings stringForColumn:COL_AUDIT_GROUP_ID];
            if(auditGroupId==nil)
                self.auditGroupId = [DeviceManager getCurrentTimeString];
            else
                self.auditGroupId = auditGroupId;
            break;
        }
        [databaseGroupRatings close];
    });
    
}

- (void) initializeGroupIdFromSavedAudit:auditMasterId withProductID:(int)productID withproductGroupID:(int) productGroupId withDatabase:(FMDatabase *) databaseLocal {
    FMResultSet *resultsGroupRatings;
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@=%d AND %@=%d", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_PRODUCT_ID, productID, COL_PRODUCT_GROUP_ID, productGroupId];
    resultsGroupRatings = [database executeQuery:retrieveStatement];
    //set the groupId in case does not go into while loop
    self.auditGroupId = [DeviceManager getCurrentTimeString];
    while ([resultsGroupRatings next]) {
        NSString *auditGroupId = [resultsGroupRatings stringForColumn:COL_AUDIT_GROUP_ID];
        if(auditGroupId==nil)
            self.auditGroupId = [DeviceManager getCurrentTimeString];
        else
            self.auditGroupId = auditGroupId;
        break;
    }
    if (!databaseLocal) {
        [database close];
    }else
        [databaseLocal close];
}

- (Audit *) generateAudit: (BOOL) duplicateInspection {
    Product *savedProduct = self.product;
    
    Audit *auditApi = [[Audit alloc] init]; // return object
    AuditApiData *auditApiData = [[AuditApiData alloc] init]; // auditData parent object
    
    AuditApiTrackingCodes *auditApiTrackingCodes = [self setupAuditApiTrackingCodes];
    auditApiData.trackingCodes = auditApiTrackingCodes;
    
    AuditApiDescriptor *auditApiDescriptor = [self setupAuditApiDescriptor];
    auditApiData.audit = auditApiDescriptor;
    
    AuditApiDevice *auditApiDevice = [self setupAuditApiDevice];
    auditApiData.device = auditApiDevice;
    
    AuditApiUser *auditApiUser = [self setupAuditApiUser];
    auditApiData.user = auditApiUser;
    
    AuditApiLocation *location = [self setupAuditApiLocation];
    auditApiData.location = location;
    
    AuditApiStore *store = [self setupAuditApiStore];
    location.store = store;
    
    if (store.id >= min && max >= store.id) {
        store.id = 0;
    }
    
    AuditApiRetailStore *retailStore = [self setupAuditApiRetailStore];
    location.retailStore = retailStore;
    
    Store *stor = [[User sharedUser] currentStore];
    if (!stor.storeEnteredByUser) {
        location.retailStore = nil;
    }
    
    // add image remote URL to JSON
    NSMutableArray *imageList = [NSMutableArray array];
    if(self.allImages!=nil && [self.allImages count]>0) {
        for(Image *singleImage in self.allImages) {
            NSString *imageRemoteUrl = singleImage.remoteUrl;
            [imageList addObject:imageRemoteUrl];
        }
    }
    
    auditApiData.images = imageList;
    
    AuditApiProgram *program = [self setupAuditApiProgram];
    
    AuditApiSummary *summary = [[AuditApiSummary alloc] init];
    summary.inspectionStatus = INSPECTION_STATUS_NONE;
    auditApiData.summary = summary;
    
    AuditApiProduct *product = [[AuditApiProduct alloc]init];
    product.id = savedProduct.product_id;
   // product.score = savedProduct.score;
    if(!savedProduct.selectedSku)
        product.itemNumber = @"";
    else
        product.itemNumber = savedProduct.selectedSku;
    
    
    NSArray *productRatings = [self setupArrayOfRatings:savedProduct];
    
    AuditApiSubmittedInfo *submittedInfo = [[AuditApiSubmittedInfo alloc] init];
    submittedInfo.product = product;
    submittedInfo.productRatings = (NSMutableArray<AuditApiRating>*)productRatings;
    submittedInfo.program = program;
    
    auditApiData.submittedInfo = submittedInfo;
    auditApi.auditData = auditApiData;
    auditApi.auditData.duplicate = duplicateInspection;
    return auditApi;
}

- (NSString*) generateAuditJson: (BOOL) duplicateInspection {
    Audit *auditApi = [self generateAudit:duplicateInspection];
    NSString* ratingJson = [auditApi toJSONString];
    return ratingJson;
}

- (BOOL) populateFromExisitingAuditInDB:(NSString *) auditSavedMasterId withAuditCount:(int) auditCount withProductID:(int) productID withProductName:(NSString *) productName withUserEnteredInspectionSamples: (int) userEnteredAuditCount {
    
    BOOL present = NO;
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    NSString *queryAllRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%d AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, productID, COL_AUDIT_COUNT, auditCount, COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    if (userEnteredAuditCount > 0) {
        queryAllRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%d AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, self.auditMasterId, COL_AUDIT_PRODUCT_ID, productID, COL_USERENTERED_SAMPLES, userEnteredAuditCount,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    }
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAllRatings];
    while ([resultsGroupRatings next]) {
        present = YES;
        NSError* err = nil;
        NSString *auditMasterId = [resultsGroupRatings stringForColumn:COL_AUDIT_MASTER_ID];
        NSString *auditGroupId = [resultsGroupRatings stringForColumn:COL_AUDIT_GROUP_ID];
        NSString *auditRatingsJson = [resultsGroupRatings stringForColumn:COL_AUDIT_JSON];
        
        Audit* currentAuditJson = [[Audit alloc] initWithString:auditRatingsJson error:&err];
        AuditApiProgram *program = currentAuditJson.auditData.submittedInfo.program;
        int programId = program.id;
        int programVersion = program.version;
        if(self.allImages)
            [self.allImages removeAllObjects];
        AuditApiImages *images = [[AuditApiImages alloc] initWithString:[resultsGroupRatings stringForColumn:COL_IMAGES] error:&err];
        //NSLog(@"images %@", images.images);
        for (NSDictionary *imageDict in images.images) {
            Image *image = [[Image alloc] init];
            DCBaseEntity *dcbaseEntity = [[DCBaseEntity alloc] init];
            image.deviceUrl = [dcbaseEntity parseStringFromJson:imageDict key:@"deviceUrl"];
            image.path = [dcbaseEntity parseStringFromJson:imageDict key:@"path"];
            image.remoteUrl = [dcbaseEntity parseStringFromJson:imageDict key:@"remoteUrl"];
            image.submitted = [dcbaseEntity parseBoolFromJson:imageDict key:@"submitted"];
            [self.allImages addObject:image];
        }
        self.currentPictureCount = [self.allImages count];
        [self setAllTheCurrentAuditVariablesFromExistingAudit:auditCount withAuditMasterId:auditMasterId withAuditGroupId:auditGroupId withProgramID:programId withProgramVersion:programVersion];
        self.compositeAuditIDLocal = currentAuditJson.auditData.audit.id;
        NSArray<AuditApiRating>* prodRatings = currentAuditJson.auditData.submittedInfo.productRatings;
        //TODO Product got reset here - need to reuse the product object
        Product *currentProduct = [[Product alloc] init];
        currentProduct.product_id = productID;
        currentProduct.product_name = productName;
        // fixes the blank item number after editing a saved audit (from a saved inspection)
        currentProduct.selectedSku = currentAuditJson.auditData.submittedInfo.product.itemNumber;
        
        for (AuditApiRating *inRating in prodRatings) {
            Rating *rating = [[Rating alloc] init];
            rating.ratingID = inRating.id;
            rating.ratingAnswerFromUI = inRating.value;
            rating.type = inRating.type;
            NSArray<AuditApiDefect>* allDefects = inRating.defects;
            for (AuditApiDefect *inDefect in allDefects) {
                Defect *defect = [[Defect alloc] init];
                defect.defectID = inDefect.id;
                defect.isSetFromUI = inDefect.present;
                for(int i = 0; i < inDefect.severities.count; i++){
                    Severity *severity = [[Severity alloc] init];
                    severity = inDefect.severities[i];
                    [defect.severities addObject:severity];
                }
                
                [rating addDefect:defect];
            }
            [currentProduct addRating:rating];
        }
        self.product = currentProduct;
        Product *refProduct = [self getReferenceProductObject];
        if(refProduct){
            self.product.daysRemaining = refProduct.daysRemaining;
            self.product.daysRemainingMax = refProduct.daysRemainingMax;
        }
            
        self.userEnteredInspectionSamples = [resultsGroupRatings stringForColumn:COL_USERENTERED_SAMPLES];
    }
    [databaseGroupRatings close];
    //NSLog(@"images %@", self.allImages);
    return present;
}

- (void) ifCountOfCasesPresentAndNotOrderData {
    BOOL orderData = [[Inspection sharedInspection] checkForOrderData];
    if (!orderData) {
        
    }
}

-(Product*)getReferenceProductObject {
    NSMutableArray* productGroups = [Inspection sharedInspection].productGroups;
    for(Product *product in productGroups){
        if(![product isKindOfClass:[Product class]]) //fix issue where some products are assigned to a group in non-order data mode
            continue;
        if(product.product_id == self.product.product_id)
            return product;
    }
    return nil;
}


- (NSString *)getRemoteUrl {
    // originally read from GET request
    NSString* imageHost = [NSUserDefaultsManager getObjectFromUserDeafults:IMAGE_HOST_ENDPOINT];//http://cdn.yottamark.com/portal/_qa/audits
    NSString* remoreUrl = [NSString stringWithFormat:@"%@/%@/%@/%d%@", imageHost , self.getCompositeAuditID, @"PRODUCT", self.currentPictureCount, @".jpg"];
    return remoreUrl;
}


- (NSString *) getDeviceUrl {
    NSString* deviceUrl = [NSString stringWithFormat:@"%@_%d", self.getCompositeAuditID, self.currentPictureCount];
    return deviceUrl;
}

- (NSString *) getPath {
    NSString* path = [NSString stringWithFormat:@"/%@/%@/%d%@", self.getCompositeAuditID, @"PRODUCT", self.currentPictureCount, @".jpg"];
    return path;
}

- (void) addImage: (Image*)image {
    [self.allImages addObject:image];
}

- (AuditApiDescriptor *) setupAuditApiDescriptor {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    AuditApiDescriptor *auditApiDescriptor = [[AuditApiDescriptor alloc]init];
    if ([self getCompositeAuditID]) {
        [auditApiDescriptor setId:[self getCompositeAuditID]];
    }
    auditApiDescriptor.start = self.auditStartTime;
    auditApiDescriptor.end = self.auditEndTime;
    
    if (self.timeZone) {
        auditApiDescriptor.timezone = self.timeZone;
    }
    return auditApiDescriptor;
}

- (AuditApiDevice *) setupAuditApiDevice {
    AuditApiDevice *auditApiDevice = [[AuditApiDevice alloc] init];
    auditApiDevice.os_name = @"iOS";
    auditApiDevice.os_version = [[UIDevice currentDevice] systemVersion];
    if ([DeviceManager getDeviceID]) {
        auditApiDevice.id = [DeviceManager getDeviceID];
    }
    if ([DeviceManager getCurrentVersionOfTheApp]) {
        auditApiDevice.version = [DeviceManager getCurrentVersionOfTheApp];
    }
    return auditApiDevice;
}

- (AuditApiTrackingCodes *) setupAuditApiTrackingCodes {
    AuditApiTrackingCodes *auditApiTrackingCodes = [[AuditApiTrackingCodes alloc] init];
    [auditApiTrackingCodes setTrackingCode:@"DCInsightAudit_v5"];
    if ([[User sharedUser] checkForRetailInsights]) {
        [auditApiTrackingCodes setTrackingCode:@"RetailInsights_v5"];
    }
    if ([[User sharedUser] checkForScanOut]) {
        [auditApiTrackingCodes setTrackingCode:@"ScanOut_v4"];
    }
    if (self.trackingCodes) {
        [auditApiTrackingCodes setTrackingCode:self.trackingCodes];
    }
    return auditApiTrackingCodes;
}

- (AuditApiUser *) setupAuditApiUser {
    User *user = [User sharedUser];
    AuditApiUser *auditApiUser = [[AuditApiUser alloc]init];
    auditApiUser.id = user.email;
    return auditApiUser;
}

- (AuditApiLocation *) setupAuditApiLocation {
    AuditApiLocation *auditApiLocation = [[AuditApiLocation alloc]init];
    auditApiLocation.gpsMessage = @"GPSNotAvailable";
    CLLocation *location =  [[LocationManager sharedLocationManager] currentLocation];
    if (location) {
        auditApiLocation.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        auditApiLocation.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        auditApiLocation.gpsMessage = @"GPSAvailable";
        if (location.coordinate.latitude == 0 && location.coordinate.longitude == 0) {
            auditApiLocation.gpsMessage = @"GPSNotAvailable";
        }
    }
    return auditApiLocation;
}

- (AuditApiStore *) setupAuditApiStore {
    AuditApiStore *store = [[AuditApiStore alloc] init];
    store.id = [[User sharedUser]currentStore].storeID;
    return store;
}

- (AuditApiRetailStore *) setupAuditApiRetailStore {
    AuditApiRetailStore *retailStore = [[AuditApiRetailStore alloc] init];
    CLLocation *location =  [[LocationManager sharedLocationManager] currentLocation];
    if (location) {
        retailStore.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        retailStore.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    }
    NSString *storeName = [NSUserDefaultsManager getObjectFromUserDeafults:StoreNameEnteredByUser];
    NSString *addressName = [NSUserDefaultsManager getObjectFromUserDeafults:StoreAddressEnteredByUser];
    NSString *zipcode = [NSUserDefaultsManager getObjectFromUserDeafults:StoreZipCodeEnteredByUser];
    retailStore.name = storeName;
    retailStore.address = addressName;
    retailStore.zip = zipcode;
    return retailStore;
}

- (AuditApiProgram *) setupAuditApiProgram {
    AuditApiProgram *program = [[AuditApiProgram alloc]init];
    program.id = self.programId;
    program.version = self.programVersion;
    return program;
}

- (NSArray<AuditApiRating>*) setupArrayOfRatings: (Product *) product {
    NSMutableArray *arrayOfRatings = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfDefects = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfSeverities = [[NSMutableArray alloc] init];
    NSMutableArray *listOfRatings = [product ratingsFromUI];
    for(Rating *aRating in listOfRatings) {
        // create json of ratings
        AuditApiRating *rating = [[AuditApiRating alloc] init];
        [rating setId:aRating.ratingID];
        [rating setValue:aRating.ratingAnswerFromUI];
        [rating setType:aRating.type];
        if ([aRating.order_data_field isEqualToString:@"QuantityOfCases"]) {
            self.countOfCasesFromRatings = aRating.ratingAnswerFromUI;
        }
        for(Defect *aDefect in aRating.defectsFromUI) {
            AuditApiDefect *defect = [[AuditApiDefect alloc] init];
            [defect setId:aDefect.defectID];
            [defect setGroup_id:aDefect.defectGroupID];
            if (aDefect.defectGroupID == -1) {
                [defect setGroup_id:0];
            }
            defect.present = aDefect.isSetFromUI;
            for(int i = 0; i < aDefect.severities.count; i++)
            {
                Severity *severity = aDefect.severities[i];
                AuditApiSeverity *severityApi = [[AuditApiSeverity alloc]init];
                severityApi.isSelected = severity.isSelected;
                severityApi.denominator = severity.inputDenominator;
                severityApi.numerator = severity.inputNumerator;
                severityApi.percentage = severity.inputOrCalculatedPercentage;
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
    return [(NSArray<AuditApiRating>*)arrayOfRatings copy];
}

-(BOOL) validateDaysRemainingMinConditionForRating:(Rating*)rating forProduct:(Product*)product{
    DaysRemainingValidator *daysRemainingValidator = [[DaysRemainingValidator alloc] initWithRating:rating withProduct:product];
    
    //validation not required
    if(product.daysRemaining == 0 && product.daysRemainingMax == 0)
        return YES;
    
    if([daysRemainingValidator isCheckRequiredForRating]){
        return [daysRemainingValidator isValidForMinimumDays] && [daysRemainingValidator isValidForMaximumDays];
    }
    return YES;
}


//-(BOOL) validateDaysRemainingMaxConditionForRating:(Rating*)rating forProduct:(Product*)product{
//    DaysRemainingValidator *daysRemainingValidator = [[DaysRemainingValidator alloc] initWithRating:rating withProduct:product];
//    if([daysRemainingValidator isCheckRequiredForRating]){
//        return [daysRemainingValidator isValidForMaximumDays];
//    }
//    return NO;
//}

@end
