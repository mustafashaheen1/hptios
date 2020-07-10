//
//  User.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "User.h"
#import "Program.h"
#import "LocationManager.h"
#import "CLLocation+DistanceComparison.h"
#import "SavedInspection.h"
#import "SyncManager.h"
#import "AppDataDBHelper.h"
#import "InsightsDBHelper.h"
#import "Audit.h"
#import "PendingAudits.h"
#import "SubmittedAudits.h"
#import "Inspection.h"
#import "CompletedScanout.h"
#import "ImageArray.h"

static User *_sharedDCUser = nil;

// destroys sharedInstance after main exits.. REQUIRED for unit tests
// to work correclty, otherwse the FIRST shared object gets used for ALL
// tests, resulting in KVO problems

__attribute__((destructor)) static void destroy_singleton() {
    @autoreleasepool {
        _sharedDCUser = nil;
    }
}
@implementation User

@synthesize accessToken;
@synthesize device;
@synthesize isLoggedIn;
@synthesize password;
@synthesize email;
@synthesize allValidStoresForUser;
@synthesize currentStore;
@synthesize userSelectedVendorName;
@synthesize userEnteredOrderedData;
@synthesize temporaryPONumberFromUserClass;
@synthesize temporaryGRNFromUserClass;

/*------------------------------------------------------------------------------
 METHOD: sharedUser
 
 PURPOSE:
 Gets the shared User instance object and creates it if
 necessary.
 
 RETURN VALUE:
 The shared User.
 
 -----------------------------------------------------------------------------*/
+ (User *) sharedUser
{
    if (_sharedDCUser == nil)
        [User initialize] ;
    
    return _sharedDCUser ;
}

/*------------------------------------------------------------------------------
 Singleton Methods.. Generic to any Singleton
 -----------------------------------------------------------------------------*/
#pragma mark - Singleton Methods

+ (void)initialize
{
    if (_sharedDCUser == nil)
        _sharedDCUser = [[self alloc] init];
}


+ (id)sharedUserNetworkActivityView
{
    //Already set by +initialize.
    return _sharedDCUser;
}


#pragma mark - Class Level Error Checking Methods

// returns nil if there is no error
+ (NSString*)checkEmailFormat:(NSString*)theEmail
{
    NSString *errorMsg = nil;
    
    if ([theEmail length] > 0) {
        // check the format of the email
        
        NSString *emailRegEx =
        @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
        @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        // check a lowercase version
        NSRange r = [[theEmail lowercaseString] rangeOfString:emailRegEx
                                                      options:NSRegularExpressionSearch];
        if (r.location == NSNotFound) {
            errorMsg = kEmailWrongFormatMSg;
        }
        
        
    } else {
        // email is 0 length
        errorMsg = kEmailWrongFormatMSg;
    }
    
    return errorMsg;
}


// returns nil if there is no error
+ (NSString*)checkPasswordFormat:(NSString*)thePassword
{
    NSString *errorMsg = nil;
    
    if ([thePassword length] > 0) {
        // check the length of the password
        if ([thePassword length] < 5 || [thePassword length] > 32) {
            errorMsg = kPasswordLengthMsg;
        }
    } else {
        // password has no content
        errorMsg = kMissingPasswordMsg;
    }
    
    return errorMsg;
}


#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self resetUserData];
    }
    return self;
}

- (void) reportCurrentTime {
    NSDate* currentDate = [NSDate date];
    NSString* dateInString = [currentDate description];
    [NSUserDefaultsManager saveObjectToUserDefaults:dateInString withKey:LASTSYNCDATE];
}

- (BOOL)isEqual:(id)object {
    User *copy = (User *) object;
    if ([self.email isEqualToString: copy.email]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [[NSString stringWithFormat:@"%@", self.email] hash];
    return result;
}

- (void)setCurrentStore:(Store *)newStore {
    if (newStore != currentStore) {
        currentStore = newStore;
        NSString *storeId = [NSString stringWithFormat:@"%d", newStore.storeID];
        NSString *storeName =[NSString stringWithFormat:@"%@", newStore.name];
        if ([User sharedUser].currentStore) {
            [User sharedUser].currentStore.productGroups = [NSArray array];
            [User sharedUser].currentStore.groupsOfProductsForTheStore = [NSArray array];
            [Inspection sharedInspection].productGroups = [NSArray array];
        }
        [NSUserDefaultsManager saveObjectToUserDefaults:storeId withKey:STOREID];
        [NSUserDefaultsManager saveObjectToUserDefaults:storeName withKey:STORE_NAME];
    }
}

-(void) incrementPendingRequest {
    @synchronized(self)
    {
        self.pendingUploadRequests++;
    }
}

-(int) getPendingRequests {
    @synchronized(self)
    {
        return self.pendingUploadRequests;
    }
}

-(void) decrementPendingRequest {
    @synchronized(self)
    {
        if(self.pendingUploadRequests == 0)
            return;
        self.pendingUploadRequests -- ;
    }
}

-(void) initBackgroundUpload {
    if(!self.backgroundUpload)
        self.backgroundUpload = [[BackgroundUpload alloc]init];
    [self.backgroundUpload startBackgroundTimer];
}

-(void)initCollaborativeBackgroundUpload {
    if(!self.collabBackgroundUpload)
        self.collabBackgroundUpload = [[CollabBackgroundUpload alloc]init];
    [self.collabBackgroundUpload startBackgroundTimer];
}

- (BOOL) initializeAllOtherInfo {
    [[User sharedUser] findStoreFromStoreIdAndSetToCurrentStore:[NSUserDefaultsManager getObjectFromUserDeafults:STOREID]];
    return YES;
}

- (void) logoutUser {
    [self resetUserData];
    //[NSUserDefaultsManager removeObjectFromUserDeafults:LASTSYNCDATE];
    [NSUserDefaultsManager removeObjectFromUserDeafults:@"accessToken"];
}

- (void) logUserInWithValues: (NSDictionary *) responseValues {
    self.isLoggedIn = YES;
    self.email = [self parseStringFromJson:responseValues key:@"email"];
    self.password = [self parseStringFromJson:responseValues key:@"password"];
    self.accessToken = [self parseStringFromJson:responseValues key:@"token"];
    if ([self parseStringFromJson:responseValues key:@"token"]) {
        [self saveTheUserValuesInTheUserDefaults:responseValues];
    }
}

- (void) googleUserLoggedinWithValues: (NSDictionary *) responseValues {
    self.isLoggedIn = YES;
    self.email = [self parseStringFromJson:responseValues key:@"email"];
    self.password = [self parseStringFromJson:responseValues key:@"password"];
    self.accessToken = [self parseStringFromJson:responseValues key:@"auth_token"];
    if ([self parseStringFromJson:responseValues key:@"auth_token"]) {
        //[self saveTheUserValuesInTheUserDefaults:responseValues];
        [NSUserDefaultsManager saveObjectToUserDefaults:[self parseStringFromJson:responseValues key:@"auth_token"] withKey:@"accessToken"];
        [NSUserDefaultsManager saveObjectToUserDefaults:[self parseStringFromJson:responseValues key:@"email"] withKey:@"email"];
        [NSUserDefaultsManager saveObjectToUserDefaults:[self parseStringFromJson:responseValues key:@"password"] withKey:@"password"];
        
    }
}

- (void) saveTheUserValuesInTheUserDefaults: (NSDictionary *) responseValues {
    [NSUserDefaultsManager saveObjectToUserDefaults:[self parseStringFromJson:responseValues key:@"token"] withKey:@"accessToken"];
    [NSUserDefaultsManager saveObjectToUserDefaults:[self parseStringFromJson:responseValues key:@"email"] withKey:@"email"];
    [NSUserDefaultsManager saveObjectToUserDefaults:[self parseStringFromJson:responseValues key:@"password"] withKey:@"password"];
}

// called to reset the user data to an empty state
- (void) resetUserData {
    self.email = @"";
    self.password = @"";
    self.isLoggedIn = NO;
    if (!self.device) {
        self.device = [[Device alloc] init];
    }
    self.accessToken = @"";
    self.allImages = [[NSMutableArray alloc] init];
}

-(NSString*) getAuditorRole {
    NSString* auditorRole = [NSUserDefaultsManager getObjectFromUserDeafults:AUDITOR_ROLE];
    if([auditorRole length]==0)
        auditorRole = AUDITOR_ROLE_DC; //default is DC
    return auditorRole;
}

- (BOOL) checkForRetailInsights {
    BOOL retail = NO;
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([[self getAuditorRole] isEqualToString:AUDITOR_ROLE_RETAIL] || [appName isEqualToString:@"Retail-Insights"]) {
        retail = YES;
    }
    return retail;
}

- (BOOL) checkForScanOut {
    BOOL scanOut = NO;
    if ([[self getAuditorRole] isEqualToString:AUDITOR_ROLE_SCANOUT]) {
        scanOut = YES;
    }
    return scanOut;
}

- (BOOL) checkForDCInsights {
    BOOL dc = NO;
    if ([[self getAuditorRole] isEqualToString:AUDITOR_ROLE_DC]) {
        dc = YES;
    }
    return dc;
}

- (void) findStoreFromStoreIdAndSetToCurrentStore: (NSString *) storeIdLocal {
    NSArray *storesArrayLocal = [self getListOfStoresSortedByDistance];
    for (Store *store in storesArrayLocal) {
        if ([[NSString stringWithFormat:@"%d", store.storeID] isEqualToString:storeIdLocal]) {
            if ([NSUserDefaultsManager getBOOLFromUserDeafults:StoreEnteredByUser]) {
                if (store.storeEnteredByUser) {
                    self.currentStore = store;
                    break;
                } else {
                    self.currentStore = store;
                }
            } else {
                self.currentStore = store;
                break;
            }
        }
    }
}

- (NSString *)getRemoteUrl {
    // originally read from GET request
    NSString* imageHost = [NSUserDefaultsManager getObjectFromUserDeafults:IMAGE_HOST_ENDPOINT];//http://cdn.yottamark.com/portal/_qa/audits
    NSString* remoreUrl = [NSString stringWithFormat:@"%@/%@/%@/%d%@", imageHost , self.getCompositeAuditID, @"CONTAINER", self.currentPictureCount, @".jpg"];
    return remoreUrl;
}


- (NSString *) getDeviceUrl {
    NSString* deviceUrl = [NSString stringWithFormat:@"%@_%d", self.getCompositeAuditID, self.currentPictureCount];
    return deviceUrl;
}

- (NSString *) getPath {
    NSString* path = [NSString stringWithFormat:@"/%@/%@/%d%@", self.getCompositeAuditID, @"CONTAINER", self.currentPictureCount, @".jpg"];
    return path;
}

//- (NSString *) getDeviceUrlForContainerImages {
//    NSString* deviceUrl = [NSString stringWithFormat:@"%@_%d", self.getCompositeAuditID, self.currentPictureCount];
//    return deviceUrl;
//}

/*------------------------------------------------------------------------------
 Get Stores For User
 -----------------------------------------------------------------------------*/

- (NSArray *) getListOfStoresSortedByDistance {
    self.allValidStoresForUser = [self getListOfStoresFromDB];
    
    NSArray *allProgramsForUser = [self getProgramsForUser];
    for (Store *store in self.allValidStoresForUser) {
        [store getAllTheProgramsForTheStore:allProgramsForUser];
    }
    NSArray *allValidStoresForUserLocal = [self sortStores:self.allValidStoresForUser];
    self.allValidStoresForUser = [[NSArray alloc] init];
    self.allValidStoresForUser = allValidStoresForUserLocal;
    return self.allValidStoresForUser;
}

- (Store *) getListOfProgramsForTheStore: (Store *) store {
    NSArray *allProgramsForUser = [self getProgramsForUser];
    [store getAllTheProgramsForTheStore:allProgramsForUser];
    return store;
}

- (NSArray *) sortStores: (NSArray *) stores {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUserLocation" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    NSArray *sortedArray = [stores sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

NSInteger intSort(id num1, id num2, void *context)
{
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (NSArray *) getListOfStoresFromDB {
    NSMutableArray *storesMutable = [[NSMutableArray alloc] init];
    
    FMDatabase *userDatabase = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *userStoreResults;
    [userDatabase open];
    userStoreResults = [userDatabase executeQuery:[self retrieveDataFromDBForUserEnteredStores]];
    CLLocation *currentLocation = [[LocationManager sharedLocationManager] currentLocation];
    while ([userStoreResults next]) {
        Store *store = [[Store alloc] init];
        store.storeID = [userStoreResults intForColumn:@"id"];
        store.address = [userStoreResults stringForColumn:@"address"];
        store.chain_name = [userStoreResults stringForColumn:@"chain_name"];
        store.latitude = [userStoreResults doubleForColumn:@"lat"];
        store.longitude = [userStoreResults doubleForColumn:@"lon"];
        store.name= [userStoreResults stringForColumn:@"name"];
        store.postCode= [userStoreResults intForColumn:@"postCode"];
        store.storeEnteredByUser = YES; // mark this to indicate user entered store
        CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:store.latitude longitude:store.longitude];
        CLLocationDistance distance = [storeLocation distanceFromLocation:currentLocation];
        store.distanceFromUserLocation = distance/1609.344;
        [storesMutable addObject:store];
    }
    [userDatabase close];
    
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveDataFromDBForStores]];
    while ([results next]) {
        Store *store = [[Store alloc] init];
        store.address = [results stringForColumn:@"address"];
        store.city = [results stringForColumn:@"city"];
        store.distance = [results stringForColumn:@"distance"];
        store.distance_full_precision = [results doubleForColumn:@"distance_full_precision"];
        store.distance_unit = [results stringForColumn:@"distance_unit"];
        store.storeID = [results intForColumn:@"id"];
        store.latitude = [results doubleForColumn:@"lat"];
        store.longitude = [results doubleForColumn:@"lon"];
        store.msa = [results stringForColumn:@"msa"];
        store.msa_desc= [results stringForColumn:@"msa_desc"];
        store.name= [results stringForColumn:@"name"];
        store.normalizedAddress= [results stringForColumn:@"normalizedAddress"];
        store.normalizedCity= [results stringForColumn:@"normalizedCity"];
        store.postCode= [results intForColumn:@"postCode"];
        store.state= [results stringForColumn:@"state"];
        store.store_no = [results stringForColumn:@"store_no"];
        store.store_weekly_volume = [results stringForColumn:@"store_weekly_volume"];
        CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:store.latitude longitude:store.longitude];
        CLLocationDistance distance = [storeLocation distanceFromLocation:currentLocation];
        store.distanceFromUserLocation = distance/1609.344;
        [storesMutable addObject:store];
    }
    [database close];
    
    // also add the stores from TBL_USER_ENTERED_STORES (DB_USER_DATA)
    // set the variable "storeEnteredByUser" to be true
    
    return [storesMutable copy];
}

- (NSArray *) sortStoresByUserLocation: (NSArray *) storesToBeSorted {
    NSArray *storesSorted;
    return storesSorted;
}



/*------------------------------------------------------------------------------
 Get Programs For User
 -----------------------------------------------------------------------------*/

- (NSArray *) getProgramsForUser {
    NSMutableArray *programsMutable = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveDataFromDBForPrograms]];
    while ([results next]) {
        Program *program = [[Program alloc] init];
        program.active = [results boolForColumn:@"active"];
        program.end_date = [self parseDateFromJson:@{@"end_date" : [results stringForColumn:@"end_date"]} key:@"end_date"];
        program.programID = [results intForColumn:@"id"];
        program.name = [results stringForColumn:@"name"];
        program.start_date = [self parseDateFromJson:@{@"start_date" : [results stringForColumn:@"start_date"]} key:@"start_date"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"store_ids"]];
        program.storeIds = array;
        program.version = [results intForColumn:@"version"];
        program.distinct_products =[results intForColumn:@"distinct_products"];
        NSString* applyToAll = [results stringForColumn:COL_APPLY_TO_ALL];
       // NSLog(@"Response is:  %@", applyToAll);
        NSString *device_id = [DeviceManager getDeviceID];
        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
        NSLog(@"Device ID: %@",device_id);
        NSLog(@"Access is: %@",access_token);
        program.apply_to_all = [[ApplyToAll alloc] initFromJSONString:applyToAll];
        [programsMutable addObject:program];
    }
    [database close];
    return [programsMutable copy];
}

- (NSArray *) getProgramsForUserForDistinctSamples {
    if ([self.programsForUser count] > 0) {
        return self.programsForUser;
    }
    self.programsForUser = [self getProgramsForUser];
    return self.programsForUser;
}


- (NSArray *) getUserProgramsFromDB {
    self.programsForUser = [self getProgramsForUser];
    return self.programsForUser;
}

-(BOOL) isApplyToAllActiveForUserProgram {
    NSArray* allPrograms = [self getProgramsForUser];
    for(Program *program in allPrograms){
        if(program.apply_to_all.active)
            return YES;
    }
    return NO;
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveDataFromDBForStores {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_STORES];
    return retrieveStatement;
}

- (NSString *) retrieveDataFromDBForUserEnteredStores {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_USER_ENTERED_STORES];
    return retrieveStatement;
}

- (NSString *) retrieveDataFromDBForPrograms {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_PROGRAMS];
    return retrieveStatement;
}

// Get Previous User Signins

- (NSArray *) retrievePreviousUsers {
    NSMutableArray *users = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveRowDataForDB]];
    while ([results next]) {
        User *userLocal = [[User alloc] init];
        userLocal.email = [results stringForColumn:COL_USERNAME];
        userLocal.password = [results stringForColumn:COL_PASSWORD];
        [users addObject:userLocal];
    }
    NSSet *distinctItems = [NSSet setWithArray:[users copy]];
    NSArray *distinctArray = [distinctItems allObjects];
    return [distinctArray copy];
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveRowDataForDB {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_USERS];
    return retrieveStatement;
}

- (NSArray *) getAllSavedInspections {
    NSMutableArray *savedInspections = [[NSMutableArray alloc] init];
    NSString *queryAllRatings = [NSString stringWithFormat:@"SELECT %@.%@, %@.%@, COUNT(*) AS COUNT FROM (%@ INNER JOIN %@ ON %@.%@=%@.%@) GROUP BY %@.%@", TBL_SAVED_CONTAINERS, COL_INSPECTION_NAME, TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, TBL_SAVED_AUDITS, TBL_SAVED_CONTAINERS, TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID, TBL_SAVED_CONTAINERS, COL_AUDIT_MASTER_ID, TBL_SAVED_AUDITS, COL_AUDIT_MASTER_ID];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:queryAllRatings];
    while ([results next]) {
        NSString *inspectionName = [results stringForColumn:COL_INSPECTION_NAME];
        NSString *auditMasterId = [results stringForColumn:COL_AUDIT_MASTER_ID];
        int count = [results intForColumn:@"COUNT"];
        SavedInspection *inspection = [[SavedInspection alloc] init];
        inspection.inspectionName = inspectionName;
        inspection.auditMasterId = auditMasterId;
        inspection.auditsCount = count;
        [savedInspections addObject:inspection];
    }
    return [savedInspections copy];
}

- (void) addNetworkActivityView {
    self.activityView = [UserNetworkActivityView sharedActivityView];
    [self.activityView setCustomMessage:@"Loading ..."];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self.activityView show:self withOperation:nil showCancel:NO];
    }
}

- (void) removeNetworkActivityView {
    if (![UserNetworkActivityView sharedActivityView].hidden)
        [[UserNetworkActivityView sharedActivityView] hide];
}

- (BOOL) checkIfTheUserBelongsToTheTeam: (NSArray *) programsLocal {
    NSArray *programsAlreadyPresent = [self getProgramsForUser];
    BOOL same = NO;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"programID" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    NSArray *sortedArray1 = [programsLocal sortedArrayUsingDescriptors:sortDescriptors];
    NSArray *sortedArray2 = [programsAlreadyPresent sortedArrayUsingDescriptors:sortDescriptors];
    
    if ([sortedArray1 isEqualToArray:sortedArray2]) {
        NSLog(@"both are same");
        same = YES;
    }
    
    return same;
}

- (void) downloadProgramsForChecking {
    SyncManager *syncManager = [[SyncManager alloc] init];
    [syncManager downloadProgramsForTeamCheck];
}

- (BOOL) doWhatNeedsTobeDoneIfTheArrayIsEqualOrNot: (BOOL) same {
    if (!same) {
        AppDataDBHelper *appDataDBHelper = [[AppDataDBHelper alloc] init];
        [appDataDBHelper deleteAllTables];
        [appDataDBHelper createTablesForSavedAudits];
        
        InsightsDBHelper *insightsDBHelper = [[InsightsDBHelper alloc] init];
        [insightsDBHelper deleteAllTables];
        
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:SYNCSUCCESS];
    }
    return same;
}

- (BOOL) checkIfUserLoggedIn {
    BOOL loggedIn = NO;
    if (![[[User sharedUser] accessToken] isEqualToString:@""] && [[User sharedUser] accessToken]) {
        loggedIn = YES;
    }
    return loggedIn;
}

-(NSArray*) getAllPendingScanouts {
    NSMutableArray *pendingScanouts = [[NSMutableArray alloc] init];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    while ([resultsGroupRatings next]) {
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_RATINGS];
        NSError* err = nil;
        Audit* audit = [[Audit alloc] initWithString:ratings error:&err];
        CompletedScanout *scanout = [[CompletedScanout alloc]init];
        [scanout populateFromAudit:audit];
        [pendingScanouts addObject:scanout];
    }
    [databaseOfflineRatings close];
    return [pendingScanouts copy];
}

-(NSArray*) getAllSubmittedScanouts {
    NSMutableArray *submittedScanouts = [[NSMutableArray alloc] init];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_SUBMITTED_AUDITS];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    while ([resultsGroupRatings next]) {
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_RATINGS];
        NSError* err = nil;
        Audit* audit = [[Audit alloc] initWithString:ratings error:&err];
        CompletedScanout *scanout = [[CompletedScanout alloc]init];
        [scanout populateFromAudit:audit];
        PendingAudits *pendingAudit = [[PendingAudits alloc] init];
        pendingAudit.auditMasterId = @"1234";
        
        [submittedScanouts addObject:scanout];
    }
    [databaseOfflineRatings close];
    return [submittedScanouts copy];
}

- (NSArray *) getAllPendingAudits {
    NSArray *pendingAudits = [[NSArray alloc] init];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' OR %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE,COL_IMAGE_SUBMITTED,CONST_FALSE];
    FMResultSet *resultsGroupRatings;
    NSMutableArray *pendingAuditsMutable = [[NSMutableArray alloc] init];
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    while ([resultsGroupRatings next]) {
        NSString *auditId = [resultsGroupRatings stringForColumn:COL_ID];
        NSString *completedTime = [resultsGroupRatings stringForColumn:COL_DATA_COMPLETED_TIME];
        //NSLog(@"audit id string %@", auditId);
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_RATINGS];
        NSString *images = [resultsGroupRatings stringForColumn:COL_AUDIT_IMAGE];
        NSError* err = nil;
        Audit* audit = [[Audit alloc] initWithString:ratings error:&err];
        PendingAudits* pending =[self processTheInfoForTheSyncHistoryTable:audit withImages:images withCompletedTime:completedTime];
        if([[resultsGroupRatings stringForColumn:COL_DATA_SUBMITTED] isEqualToString:CONST_TRUE])
            pending.auditCount = 0;
        if([[resultsGroupRatings stringForColumn:COL_IMAGE_SUBMITTED] isEqualToString:CONST_TRUE])
            pending.imageCount = 0;
        [pendingAuditsMutable addObject:pending];
        //NSLog(@"audit id %@", audit.auditData.audit.id);
    }
    [databaseOfflineRatings close];
    pendingAudits = [self consolidatePendingAudits:pendingAuditsMutable];
    return pendingAudits;
}

- (NSArray *) consolidatePendingAudits:(NSArray *) pendingAudits {
    NSArray *groups = [pendingAudits valueForKeyPath:@"@distinctUnionOfObjects.auditMasterId"];
    NSMutableArray *pendingAuditsMutable = [NSMutableArray array];
    for (NSString *auditMasterId in groups) {
        PendingAudits *pendingAudit = [[PendingAudits alloc] init];
        pendingAudit.auditMasterId = auditMasterId;
        for (PendingAudits *pendingAuditLocal in pendingAudits) {
            if ([pendingAuditLocal.auditMasterId isEqualToString:auditMasterId]) {
                pendingAudit.auditCount = pendingAudit.auditCount + pendingAuditLocal.auditCount;
                pendingAudit.imageCount = pendingAudit.imageCount + pendingAuditLocal.imageCount;
                pendingAudit.dateCompleted = pendingAuditLocal.dateCompleted;
            }
        }
        [pendingAuditsMutable addObject:pendingAudit];
    }
    return [pendingAuditsMutable copy];
}

- (PendingAudits *) processTheInfoForTheSyncHistoryTable: (Audit *) audit withImages:(NSString*)images withCompletedTime: (NSString *) completedTime {
    PendingAudits *pendingAudit = [[PendingAudits alloc] init];
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    NSArray *toGetTheAuditId = [audit.auditData.audit.id componentsSeparatedByString:@"-"];
    if ([toGetTheAuditId count] > 2) {
        //NSLog(@"toGetTheAuditId %@", [toGetTheAuditId objectAtIndex:1]);
        NSString *auditId = [toGetTheAuditId objectAtIndex:1];
        [mutableDict setObject:auditId forKey:@"auditId"];
        pendingAudit.auditMasterId = auditId;
    }
    
    int totalImages = 0;
    if(images){
        NSError* err = nil;
        ImageArray* imageArray = [[ImageArray alloc] initWithString:images error:&err];
        NSMutableArray *totalsThatNeedTobeSubmitted = [[NSMutableArray alloc] init];
        for (Image *image in imageArray.images) {
            if (!image.submitted)
                totalImages++;
        }
    }
    
    pendingAudit.imageCount = totalImages; //[audit.auditData.images count];
    pendingAudit.auditCount = 1;
    pendingAudit.dateCompleted = completedTime;
    return pendingAudit;
}

- (NSArray *) getAllSubmittedAudits {
    NSArray *submittedAudits = [[NSArray alloc] init];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_SUBMITTED_AUDITS];
    FMResultSet *resultsGroupRatings;
    NSMutableArray *submittedAuditsMutable = [[NSMutableArray alloc] init];
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    while ([resultsGroupRatings next]) {
        NSString *auditId = [resultsGroupRatings stringForColumn:COL_ID];
        NSString *completedTime = [resultsGroupRatings stringForColumn:COL_DATE_SUBMITTED];
        //NSLog(@"audit id string %@", auditId);
        int imagesCount = [resultsGroupRatings intForColumn:COL_IMAGE_COUNT];
        [submittedAuditsMutable addObject:[self processTheInfoForTheSyncHistoryTableSubmittedAudit:auditId withCompletedTime:completedTime withImagesCount:imagesCount]];
    }
    [databaseOfflineRatings close];
    submittedAudits = [self consolidateSubmittedAudits:submittedAuditsMutable];
    return submittedAudits;
}

- (NSArray *) consolidateSubmittedAudits:(NSArray *) pendingAudits {
    NSArray *groups = [pendingAudits valueForKeyPath:@"@distinctUnionOfObjects.auditMasterId"];
    NSMutableArray *submittedAuditsMutable = [NSMutableArray array];
    for (NSString *auditMasterId in groups) {
        SubmittedAudits *submittedAudit = [[SubmittedAudits alloc] init];
        submittedAudit.auditMasterId = auditMasterId;
        for (SubmittedAudits *submittedAuditLocal in pendingAudits) {
            if ([submittedAuditLocal.auditMasterId isEqualToString:auditMasterId]) {
                submittedAudit.auditCount = submittedAudit.auditCount + submittedAuditLocal.auditCount;
                submittedAudit.imageCount = submittedAudit.imageCount + submittedAuditLocal.imageCount;
                submittedAudit.dateSubmitted = submittedAuditLocal.dateSubmitted;
            }
        }
        [submittedAuditsMutable addObject:submittedAudit];
    }
    return submittedAuditsMutable;
}

- (SubmittedAudits *) processTheInfoForTheSyncHistoryTableSubmittedAudit: (NSString *) auditId withCompletedTime: (NSString *) submittedTime withImagesCount: (int) imagesCount {
    SubmittedAudits *submittedAudit = [[SubmittedAudits alloc] init];
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    NSArray *toGetTheAuditId = [auditId componentsSeparatedByString:@"-"];
    if ([toGetTheAuditId count] > 2) {
        //NSLog(@"toGetTheAuditId %@", [toGetTheAuditId objectAtIndex:1]);
        NSString *auditId = [toGetTheAuditId objectAtIndex:1];
        [mutableDict setObject:auditId forKey:@"auditId"];
        submittedAudit.auditMasterId = auditId;
    }
    submittedAudit.imageCount = imagesCount;
    submittedAudit.auditCount = 1;
    submittedAudit.dateSubmitted = submittedTime;
    return submittedAudit;
}

+ (void) log:(NSString *)message
{
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *path = [NSString stringWithFormat:@"%@/%@.%@", documentsDirectory, LOCATIONS_FILE, LOCATIONS_FILE_TYPE];
    //    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //    [file seekToEndOfFile];
    //    [file writeData: data];
    //    [file closeFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logReceived" object:message];
}

- (void) addLogText: (NSString *) string {
    self.logForUser = [NSString stringWithFormat:@"%@%@", self.logForUser, string];
}

- (void) addTrackingLog : (NSString*) log {
    @try {
        self.trackingLog = [NSString stringWithFormat:@"%@ | %@", self.trackingLog, log];
    }
    @catch (NSException *exception) {
        self.trackingLog = @"";
    }
}

- (void) resetTrackingLog {
    @try {
        self.trackingLog = @"";
        
    }
    @catch (NSException *exception) {
        self.trackingLog = @"";
    }
}

-(NSString*)getAllRoles{
    NSString* allRoles = (NSString*)[NSUserDefaultsManager getObjectFromUserDeafults:ALL_ROLES];
    if(!allRoles)
        allRoles = @"";
    return allRoles;
}


@end
