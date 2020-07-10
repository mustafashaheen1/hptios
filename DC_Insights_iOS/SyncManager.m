 //

//  SyncManager.m

//  DC_Insights_iOS

//

//  Created by Shyam Ashok on 3/24/14.

//  Copyright (c) 2014 Yottamark. All rights reserved.

//



#import "SyncManager.h"
#import "StoreAPI.h"
#import "Store.h"
#import "LocationAPI.h"
#import "Location.h"
#import "ContainerRatingsAPI.h"
#import "ContainerAPI.h"
#import "Container.h"
#import "DefectAPI.h"
#import "DefectFamiliesAPI.h"
#import "Defect.h"
#import "ProgramAPI.h"
#import "ProgramGroupAPI.h"
#import "ProductAPI.h"
#import "Program.h"
#import "RatingAPI.h"
#import "DBManager.h"
#import "DBConstants.h"
#import "InsightsDBHelper.h"
#import "User.h"
#import "Audit.h"
#import "ImageArray.h"
#import "AuditImagesApi.h"
#import "ImageHostApi.h"
#import "JSONHTTPClient.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AFURLConnectionOperation.h"
#import "UIImageView+WebCache.h"
#import "SettingsViewController.h"
#import "UploadsLogHandler.h"
#import "AppDelegate.h"
#import "CollaborativeInspection.h"
#import "Inspection.h"

#define StoresDownloaded @"Stores Downloaded"
#define LocationsDownloaded @"Locations Downloaded"
#define ContainersDownloaded @"Containers Downloaded"
#define ProductsDownloaded @"Products Downloaded"
#define RatingsDownloaded @"Ratings Downloaded"
#define ProgramsDownloaded @"Programs Downloaded"
#define ProgramGroupsDownloaded @"Program Groups Downloaded"
#define ContainerRatingsDownloaded @"Container Ratings Downloaded"
#define DefectsDownloaded @"Defects Downloaded"
#define DefectsFamiliesDownloaded @"Defects Downloaded"
#define InspectionMinimumsDownloaded @"Minimums Downloaded"


@interface SyncManager ()

@property (assign, nonatomic) BOOL isStoresCompleted;
@property (assign, nonatomic) BOOL isLocationsCompleted;
@property (assign, nonatomic) BOOL isStoreLocationCompleted;
@property (assign, nonatomic) BOOL isContainersCompleted;
@property (assign, nonatomic) BOOL isContainerRatingsCompleted;
@property (assign, nonatomic) BOOL isDefectsCompleted;
@property (assign, nonatomic) BOOL isDefectsFamiliesCompleted;
@property (assign, nonatomic) BOOL isProgramsCompleted;
@property (assign, nonatomic) BOOL isProgramsProductsCompleted;
@property (assign, nonatomic) BOOL isProgramsGroupsCompleted;
@property (assign, nonatomic) BOOL isRatingsCompleted;
@property (assign, nonatomic) BOOL isOrderDataCompleted;
@property (assign, nonatomic) BOOL isDeletionLogsCompleted;
@property (assign, nonatomic) BOOL isInspectionMinimumCompleted;

@property NSMutableArray *storesApiResults;
@property NSMutableArray *locationsApiResults;
@property NSMutableArray *storeLocationApiResults;
@property NSMutableArray *containersApiResults;
@property NSMutableArray *containerRatingsApiResults;
@property NSMutableArray *defectsApiResults;
@property NSMutableArray *defectFamiliesApiResults;
@property NSMutableArray *programsApiResults;
@property NSMutableArray *programProductsApiResults;
@property NSMutableArray *programGroupsApiResults;
@property NSMutableArray *ratingsApiResults;
@property NSMutableArray *orderDataApiResults;
@property NSMutableArray *deletionLogsApiResults;
@property NSMutableArray *inspMinApiResults;

@property BOOL syncFailure;
@property NSString *syncFailMessage;
@property BOOL syncFailNotified;
@property int auditsUploaded;
@property int imagesUploaded;

//image upload
@property NSArray* arrayOfAuditIds;
@property NSMutableDictionary* auditIdAndImagesMap;
@property NSMutableArray* containerImagesUploaded;
@property int totalImagesToUpload;
@property int currentUploadCount;

@end


@implementation SyncManager

@synthesize isStoresCompleted;
@synthesize isLocationsCompleted;
@synthesize isStoreLocationCompleted;
@synthesize isContainersCompleted;
@synthesize isContainerRatingsCompleted;
@synthesize isDefectsCompleted;
@synthesize isDefectsFamiliesCompleted;
@synthesize isProgramsCompleted;
@synthesize isProgramsProductsCompleted;
@synthesize isProgramsGroupsCompleted;
@synthesize isRatingsCompleted;
@synthesize isOrderDataCompleted;
@synthesize isDeletionLogsCompleted;
@synthesize delegate;
@synthesize isInspectionMinimumCompleted;

#pragma mark - Initialization

- (id)init

{
    self = [super init];
    if (self) {
        isStoresCompleted = NO;
        isLocationsCompleted = NO;
        isStoreLocationCompleted = NO;
        isContainersCompleted = NO;
        isContainerRatingsCompleted = NO;
        isDefectsCompleted = NO;
        isDefectsFamiliesCompleted = NO;
        isProgramsCompleted = NO;
        isProgramsProductsCompleted = NO;
        isProgramsGroupsCompleted = NO;
        isRatingsCompleted = NO;
        isInspectionMinimumCompleted = NO;
    }
    
    return self;
    
}

- (void) reportCurrentTime {
    NSDate* currentDate = [NSDate date];
    NSString* dateInString = [currentDate description];
    [NSUserDefaultsManager saveObjectToUserDefaults:dateInString withKey:LASTSYNCDATE];
}

- (void) prepareSQLDatabasesAndTables {
    InsightsDBHelper *insightsDBHelper = [[InsightsDBHelper alloc] init];
    [insightsDBHelper createAllTables];
}

- (BOOL) createInsightsDB {
    BOOL opened = NO;
    opened = [[DBManager sharedDBManager] createDataBase: DB_INSIGHTS_DATA];
    return opened;
}

////// Get API calls

- (void) callAllTheAPIsAndProcessThem:(BOOL)isIncrementalSync {
    [self downloadSyncData:isIncrementalSync];
    [self getImageHost];

}

- (void) orderDataCallDownload: (SyncOverlayView *) syncOverlayView {
    BOOL incrementalSyncDisabled =![NSUserDefaultsManager getBOOLFromUserDeafults:enableIncrementalSync];
    
    self.orderData = [[OrderDataAPI alloc] init];
    [self.orderData orderDataCallwithAllTheBlocks:^(BOOL isSuccess, NSArray *orderData, NSError *error){
        if(incrementalSyncDisabled || [self.delegate isKindOfClass:[SettingsViewController class]]){
            if (!isSuccess) {
                [self.delegate orderDataDownloadFailedWithMessage:[error localizedDescription]];
                DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
            } else {
                [self getCollaborativeInspectionsWithOverlayView:syncOverlayView withBlock:^(BOOL isSuccess, NSError *error) {
                    [self processOrderDataWithoutIncrementalSync:orderData];
                }];
            }
        }else{
            int orderDataStatus = 0;
            if (!isSuccess) {
                //[self.delegate orderDataDownloadFailed];
                self.orderDataStausMessage = @"Download Failed";
                orderDataStatus = ORDER_DATA_DOWNLOAD_FAILED;
                DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
                [self.delegate orderDataDownloadFailedWithMessage:[error localizedDescription]];
            } else {
                //continue with incremental sync
                [self getCollaborativeInspectionsWithOverlayView:syncOverlayView withBlock:^(BOOL isSuccess, NSError *error) {
                     [self processOrderData:orderData];
                }];
            }
        }
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    } withSyncOverlayView: syncOverlayView];
}

-(void)processOrderData:(NSArray*)orderData {
    int orderDataStatus = 0;
    NSLog(@"posts %d Order data API", YES);
    NSDate *dateLocal = [NSDate date];
    [NSUserDefaultsManager saveObjectToUserDefaults:dateLocal withKey:SyncOrderDataDownloadTime];
    if ([orderData count] > 0) {
        //[self.delegate orderDataDownloadComplete];
        self.orderDataStausMessage = @"Download Success";
        orderDataStatus = ORDER_DATA_DOWNLOAD_SUCCESS;
    } else {
        //[self.delegate orderDataMissing];
        self.orderDataStausMessage = @"Order data not available";
        orderDataStatus = ORDER_DATA_DOWNLOAD_EMPTY;
    }
    isOrderDataCompleted = YES;
    
    //call incremental sync
    [self.delegate startIncrementalSync:orderDataStatus];
}

-(void)processOrderDataWithoutIncrementalSync:(NSArray*)orderData {
    NSLog(@"posts %d Order data API", YES);
    NSDate *dateLocal = [NSDate date];
    [NSUserDefaultsManager saveObjectToUserDefaults:dateLocal withKey:SyncOrderDataDownloadTime];
    if ([orderData count] > 0) {
        [self.delegate orderDataDownloadComplete];
    } else {
        [self.delegate orderDataMissing];
    }
    isOrderDataCompleted = YES;
}

-(void)getCollaborativeInspectionsWithOverlayView:(SyncOverlayView *)syncOverlayView
                                        withBlock:(void (^)(BOOL isSuccess, NSError *error))block {
    
    BOOL collaborativeInspectionEnabled = [NSUserDefaultsManager getBOOLFromUserDeafults:colloborativeInspectionsEnabled];
    if(!collaborativeInspectionEnabled){
        block(NO,nil);
        return;
    }
    
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    if(!collobarativeInsp) {
        collobarativeInsp = [[CollobarativeInspection alloc]init];
        [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
    }
    
    NSArray *allPONumberObjects =  [[Inspection sharedInspection] getOrderData];
    NSMutableSet *poNumbersMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allPONumberObjects) {
        [poNumbersMutableSet addObject:orderData.PONumber];
    }
    NSArray* poNumbers = [poNumbersMutableSet allObjects];
    
    CollaborativeAPIListRequest *apiRequest = [[CollaborativeAPIListRequest alloc]init];
    apiRequest.po_numbers = [poNumbers mutableCopy];
    //apiRequest.program_id = 0;
    apiRequest.store_id = (int)[User sharedUser].currentStore.storeID;
    [syncOverlayView showOnlyHeaderMessage:@"Downloading Inspections...."];
    [collobarativeInsp getAllPOStatus:apiRequest withBlock:^(NSArray *productList, NSError *error) {
        if(error)
            block(YES,error);
        else
            block(NO,error);
    }];
}


- (void) reportDownloadSync {
    NSDate *dateLocal = [NSDate date];
    [NSUserDefaultsManager saveObjectToUserDefaults:dateLocal withKey:SyncDownloadTime];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"] forKey:@"auth_token"];
    [parameters setObject:[DeviceManager getDeviceID] forKey:@"device_id"];
    [parameters setObject:[DeviceManager getCurrentVersionOfTheApp] forKey:@"version_number"];
    [parameters setObject:@"down" forKey:@"mode"];
    [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"api/sync?auth_token=%@&device_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Request: %@", JSON);
        BOOL success = [self parseBoolFromJson:JSON key:@"success"];
        if (success) {
            NSLog(@"Success");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}



- (void) reportUploadSync {
    NSDate *dateLocal = [NSDate date];
    [NSUserDefaultsManager saveObjectToUserDefaults:dateLocal withKey:SyncUploadTime];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"] forKey:@"auth_token"];
    [parameters setObject:[DeviceManager getDeviceID] forKey:@"device_id"];
    [parameters setObject:[DeviceManager getCurrentVersionOfTheApp] forKey:@"version_number"];
    [parameters setObject:@"up" forKey:@"mode"];
    [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"api/sync?auth_token=%@&device_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Request %@", JSON);
        BOOL success = [self parseBoolFromJson:JSON key:@"success"];
        if (success) {
            NSLog(@"Success");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void) sendLogsToBackend {
    //NSDate *dateLocal = [NSDate date];
    //[NSUserDefaultsManager saveObjectToUserDefaults:dateLocal withKey:SyncUploadTime];
    NSString* userLogs =[[User sharedUser] trackingLog];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[DeviceManager getDeviceID] forKey:@"device_id"];
    [parameters setObject:[DeviceManager getCurrentVersionOfTheApp] forKey:@"version_number"];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"] forKey:@"auth_token"];
    [parameters setObject:userLogs forKey:@"messages"];
    UploadsLogHandler *logHandler = [[UploadsLogHandler alloc]init];
    [logHandler addLogs:userLogs];
    NSLog(@"\n\nSubmitting Splunk Logs: \n\n%@",[[User sharedUser] trackingLog]);
    //[[User sharedUser] addLogText:[[User sharedUser] trackingLog]];
    //[[User sharedUser] trackingLog];];
    [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"api/log/?auth_token=%@&device_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        //NSLog(@"Submitting JSON for logs %@", JSON);
        BOOL success = [self parseBoolFromJson:JSON key:@"success"];
        if (success) {
            //NSLog(@"LogSuccess");
            [[User sharedUser] resetTrackingLog];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[User sharedUser] resetTrackingLog];
    }];
}


- (void) deleteAndPrepareAllTheInsightsTablesForInsert:(BOOL)isIncrementalSync {
    InsightsDBHelper *insightsDBHelper = [[InsightsDBHelper alloc] init];
    // do not delete the tables for incremental sync
    if(!isIncrementalSync){
        [insightsDBHelper deleteAllTables];
        [insightsDBHelper createAllTables];
    }

    [self.store downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.location downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.container downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.containerRatings downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.defectAPI downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.defectFamiliesAPI downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.program downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.programGroup downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.productAPI downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.rating downloadCompleteAndItsSafeToInsertDataInToDB];
    [self.inspectionMinimumsAPI downloadCompleteAndItsSafeToInsertDataInToDB];
}


- (void) appUpdateCheckCall: (void (^)(BOOL isVerionUpdateRequired, NSError *error))block {
    [[AFAppDotNetAPIClient sharedClient] getPath:[NSString stringWithFormat:@"api/app_updates?auth_token=%@&device_id=%@&app_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], AppID] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Request %@", JSON);
        BOOL isSucess = [self parseBoolFromJson:JSON key:@"success"];
        BOOL isVerionUpdateRequired = NO;
        NSString *latestVersion = @"";
        if (isSucess) {
            latestVersion = [self parseStringFromJson:JSON key:@"latest_version"];
        }
        if (![latestVersion isEqualToString:@""]) {
            NSString *latestVer = latestVersion;
            NSString *currVer = [DeviceManager getCurrentVersionOfTheApp];
            if ([latestVer compare:currVer options:NSNumericSearch] == NSOrderedDescending) {
                isVerionUpdateRequired = YES;
            }
        }
        if (block) {
            block(isVerionUpdateRequired, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Request %@", error);
            block(YES, error);
        }
    }];
}


-(void) getImageHost {
    [JSONHTTPClient setTimeoutInSeconds:5000];
    [[JSONHTTPClient requestHeaders] setValue:@"Content-Type" forKey:@"application/json"];
    NSString *kAFAppDotNetAPIBaseURLString =[SyncManager getPortalEndpoint];
    NSString* url = [NSString stringWithFormat:@"%@%@", kAFAppDotNetAPIBaseURLString, ImageHost];
    [JSONHTTPClient getJSONFromURLWithString:url
                                      params:[self paramtersFortheGETCall]
                                  completion:^(id json, JSONModelError *err) {
                                      if(err) {
                                          /*[[[UIAlertView alloc] initWithTitle:@"Error"
                                           message:[err localizedDescription]
                                           delegate:nil
                                           cancelButtonTitle:@"Close"
                                           otherButtonTitles: nil] show];*/
                                          [NSUserDefaultsManager saveObjectToUserDefaults:DEFAULT_IMAGE_HOST withKey:IMAGE_HOST_ENDPOINT];
                                      }
                                      ImageHostApi* imageHostResponse = [[ImageHostApi alloc] initWithDictionary:(NSDictionary*)json error:&err];
                                      NSString *host = imageHostResponse.host;
                                      if(host!=NULL)
                                          [NSUserDefaultsManager saveObjectToUserDefaults:host withKey:IMAGE_HOST_ENDPOINT];
                                      else
                                          [NSUserDefaultsManager saveObjectToUserDefaults:DEFAULT_IMAGE_HOST withKey:IMAGE_HOST_ENDPOINT];
                                      NSLog(@"JSONLocal %@", json);
                                  }];
}



-(void) signalSyncSuccess {
    [JSONHTTPClient setTimeoutInSeconds:5000];
    [[JSONHTTPClient requestHeaders] setValue:@"Content-Type" forKey:@"application/json"];
    NSString *kAFAppDotNetAPIBaseURLString =[SyncManager getPortalEndpoint];
    NSString* url = [NSString stringWithFormat:@"%@%@", kAFAppDotNetAPIBaseURLString, Sync];
    [JSONHTTPClient getJSONFromURLWithString:url
                                      params:[self paramtersFortheGETCall]
                                  completion:^(id json, JSONModelError *err) {
                                      if(err) {
                                          /*[[[UIAlertView alloc] initWithTitle:@"Error"
                                           message:[err localizedDescription]
                                           delegate:nil
                                           cancelButtonTitle:@"Close"
                                           otherButtonTitles: nil] show];*/
                                          [NSUserDefaultsManager saveObjectToUserDefaults:DEFAULT_IMAGE_HOST withKey:IMAGE_HOST_ENDPOINT];
                                      }
                                      ImageHostApi* imageHostResponse = [[ImageHostApi alloc] initWithDictionary:(NSDictionary*)json error:&err];
                                      NSString *host = imageHostResponse.host;
                                      if(host!=NULL)
                                          [NSUserDefaultsManager saveObjectToUserDefaults:host withKey:IMAGE_HOST_ENDPOINT];
                                      else
                                          [NSUserDefaultsManager saveObjectToUserDefaults:DEFAULT_IMAGE_HOST withKey:IMAGE_HOST_ENDPOINT];
                                      NSLog(@"JSONLocal %@", json);
                                  }];
}

-(void) appendTrackingLog:(NSString*)log{
    [[User sharedUser]addTrackingLog:log];
}


#pragma Optimized Download Sync
-(void) downloadSyncData : (BOOL) isIncrementalSync {
    //init
    self.syncFailure = NO;
    self.syncFailMessage = @"";
    self.syncFailNotified = NO;
    [[User sharedUser] resetTrackingLog];
     [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"Download_Sync_Start_iOS for %@", [User sharedUser].email]];
    [self appendTrackingLog:[DeviceManager getConnectivityStatusLog]];
    //defects
    dispatch_queue_t defectsApiQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); //dispatch_queue_create("com.mycompany.myqueue", 0);
    self.defectsApiResults = [[NSMutableArray alloc]init];
    [self callApi:Defects withPage:1 retryCount:0 withQueue:defectsApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t defectFamiliesApiQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//dispatch_queue_create("defectFamiliesApiQueue", 0);
    self.defectFamiliesApiResults = [[NSMutableArray alloc]init];
    [self callApi:DefectsFamilies withPage:1 retryCount:0 withQueue:defectFamiliesApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t storesApiQueue = dispatch_queue_create("InsightsApidownloadQueue", 0);
    self.storesApiResults = [[NSMutableArray alloc]init];
    [self callApi:Stores withPage:1 retryCount:0 withQueue:storesApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t locationsApiQueue = dispatch_queue_create("locationsApiQueue", 0);
    self.locationsApiResults = [[NSMutableArray alloc]init];
    [self callApi:Locations withPage:1 retryCount:0 withQueue:locationsApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t containersApiQueue = dispatch_queue_create("containersApiQueue", 0);
    self.containersApiResults = [[NSMutableArray alloc]init];
    [self callApi:Containers withPage:1 retryCount:0 withQueue:containersApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t containerRatingsApiQueue = dispatch_queue_create("containerRatingsApiQueue", 0);
    self.containerRatingsApiResults = [[NSMutableArray alloc]init];
    [self callApi:ContainersRatings withPage:1 retryCount:0 withQueue:containerRatingsApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t programsApiQueue = dispatch_queue_create("programsApiQueue", 0);
    self.programsApiResults = [[NSMutableArray alloc]init];
    [self callApi:Programs withPage:1 retryCount:0 withQueue:programsApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t inspectionMinApiQueue = dispatch_queue_create("inspectionMinApiQueue", 0);
    self.inspMinApiResults = [[NSMutableArray alloc]init];
    [self callApi:InspectionMinimum withPage:1 retryCount:0 withQueue:inspectionMinApiQueue isIncrSync:isIncrementalSync];

    dispatch_queue_t programProductsApiQueue = dispatch_queue_create("programProductsApiQueue", 0);
    self.programProductsApiResults = [[NSMutableArray alloc]init];
    [self callApi:ProgramsProducts withPage:1 retryCount:0 withQueue:programProductsApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t programGroupsApiQueue = dispatch_queue_create("programGroupsApiQueue", 0);
    self.programGroupsApiResults = [[NSMutableArray alloc] init];
    [self callApi:ProgramsGroups withPage:1 retryCount:0 withQueue:programGroupsApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t ratingsApiQueue = dispatch_queue_create("ratingsApiQueue", 0);
    self.ratingsApiResults = [[NSMutableArray alloc]init];
    [self callApi:Ratings withPage:1 retryCount:0 withQueue:ratingsApiQueue isIncrSync:isIncrementalSync];
    
    dispatch_queue_t deletionLogsApiQueue = dispatch_queue_create("deletionLogsApiQueue", 0);
    self.deletionLogsApiResults = [[NSMutableArray alloc]init];
    if(isIncrementalSync)
        [self callApi:DeletionLog withPage:1 retryCount:0 withQueue:deletionLogsApiQueue isIncrSync:isIncrementalSync];
    else
        self.isDeletionLogsCompleted = YES;
    
}

-(void) callApi: (NSString*)apiName withPage:(int)pageNo retryCount:(int)retryCount withQueue:(dispatch_queue_t)queue isIncrSync:(BOOL)incrSync{
    if(self.syncFailure) {
        NSLog(@"SyncFailed all requests cancelled");
        return;
    }
    
    __block int pageNumber = pageNo;
    __block int newRetryCount = retryCount;
    __block BOOL isIncremental = incrSync;
    __weak SyncManager* weakSelf = self;
    dispatch_async(queue,^{
        NSMutableDictionary *localStoreCallParamaters = [[self paramtersFortheGETCall] mutableCopy];
        [localStoreCallParamaters setObject:[NSString stringWithFormat:@"%d", pageNumber] forKey:@"page_number"];
        [localStoreCallParamaters setObject:[NSString stringWithFormat:@"%d", limitPerPage ] forKey:@"page_size"];
        NSString* lastSyncTime = [weakSelf getLastSyncTime];
        if(isIncremental)
            [localStoreCallParamaters setObject:lastSyncTime forKey:LAST_SYNC_TIME];
        else
           [localStoreCallParamaters setObject:@"0" forKey:LAST_SYNC_TIME];
        
        [[AFAppDotNetAPIClient sharedClient] getPath:apiName parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
            [weakSelf saveResponse:JSON forApi:apiName downloadComplete:NO isIncrementalSync:incrSync];
            if ([(NSArray*)JSON count]>0) {
                int nextPage = ++pageNumber;
                NSString *cleanApiName = [apiName stringByReplacingOccurrencesOfString:@"api/"
                                                     withString:@""];
                if(incrSync){//for incr sync do not show indivdual API progress
                //[[weakSelf delegate] updateAPIName:@"Downloading Insights Data"];
                }else
                    [[weakSelf delegate] updateAPIName:[NSString stringWithFormat:@"%@ - page %d",cleanApiName,nextPage]];
                [weakSelf callApi:apiName withPage:nextPage retryCount:0 withQueue:queue isIncrSync:incrSync];
                
                //NSLog(@"SyncManager.m - Response for API: %@\n%@",apiName,JSON);
            } else {
                NSLog(@"ALL pages downloaded for %@", apiName);
                [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"Download success for %@ - Total pages received: %d",apiName,pageNumber]];
                if(!incrSync)
                    [[weakSelf delegate] updateAPIName:[NSString stringWithFormat:@"%@ Completed",apiName]];
                [weakSelf saveResponse:JSON forApi:apiName downloadComplete:YES isIncrementalSync:incrSync];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed %@",operation.request);
            if(newRetryCount==RETRY_LIMIT){
                //means that the request failed twice - kick out
                 NSLog(@"Retry Limit Hit for API %@ with Page %d",apiName,pageNumber);
                [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"Retry Limit Hit for API %@ with Page %d",apiName,pageNumber]];
                [weakSelf downloadFailedForApi:apiName forPageNumber:pageNumber];
                weakSelf.syncFailure = YES;
                weakSelf.syncFailMessage = [NSString stringWithFormat:@"Request Failed \n Error: %@ \n Request:\n %@ page %d",error.localizedDescription, apiName,pageNumber];
                [weakSelf notifyDownloadComplete:incrSync];
            } else {
                int currentRetryCount = ++newRetryCount;
                 NSLog(@"Retrying %d time for API %@ with Page %d",newRetryCount,apiName,pageNumber);
                [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"Retrying %d time for API %@ with Page %d Error: %@",newRetryCount,apiName,pageNumber, error.localizedDescription]];
            [weakSelf callApi:apiName withPage:pageNumber retryCount:currentRetryCount withQueue:queue isIncrSync:incrSync];
            }
        }];
    });
}

-(void) saveResponse:(id)JSON forApi:(NSString*)apiName downloadComplete:(BOOL)downloadComplete isIncrementalSync:(BOOL)incrSync{
    if([apiName isEqualToString:Stores]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:storesFilePath withContents:self.storesApiResults];
            if(!incrSync)
            [[self delegate] updateAPIName:StoresDownloaded];
            self.isStoresCompleted = YES;
            self.store = [[StoreAPI alloc] init];
            [self.store saveApiResponseArray:self.storesApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.storesApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.storesApiResults count]);
        }
    }else if([apiName isEqualToString:Locations]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:locationsFilePath withContents:self.locationsApiResults];
            if(!incrSync)
            [[self delegate] updateAPIName:LocationsDownloaded];
            self.isLocationsCompleted = YES;
            self.location = [[LocationAPI alloc] init];
            [self.location saveApiResponseArray:self.locationsApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.locationsApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.locationsApiResults count]);
        }
    }else if([apiName isEqualToString:Containers]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", ContainersDownloaded);
            [self writeDataToFile:containerFilePath withContents:self.containersApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:apiName];
            self.isContainersCompleted = YES;
            self.container = [[ContainerAPI alloc] init];
            [self.container saveApiResponseArray:self.containersApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.containersApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.containersApiResults count]);
        }
    }else if([apiName isEqualToString:ContainersRatings]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:containerRatingsFilePath withContents:self.containerRatingsApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:ContainerRatingsDownloaded];
            self.isContainerRatingsCompleted = YES;
            self.containerRatings = [[ContainerRatingsAPI alloc] init];
            [self.containerRatings saveApiResponseArray:self.containerRatingsApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.containerRatingsApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.containerRatingsApiResults count]);
        }
    }else if([apiName isEqualToString:Defects]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:defectsFilePath withContents:self.defectsApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:DefectsDownloaded];
            self.isDefectsCompleted = YES;
            self.defectAPI = [[DefectAPI alloc] init];
            [self.defectAPI saveApiResponseArray:self.defectsApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.defectsApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.defectsApiResults count]);
        }
    }else if([apiName isEqualToString:DefectsFamilies]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:defectsFamiliesFilePath withContents:self.defectFamiliesApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:DefectsFamiliesDownloaded];
            self.isDefectsFamiliesCompleted = YES;
            self.defectFamiliesAPI = [[DefectFamiliesAPI alloc] init];
            [self.defectFamiliesAPI saveApiResponseArray:self.defectFamiliesApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.defectFamiliesApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.defectFamiliesApiResults count]);
        }
    }else if([apiName isEqualToString:Programs]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:ProgramsFilePath withContents:self.programsApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:ProgramsDownloaded];
            self.isProgramsCompleted = YES;
            self.program = [[ProgramAPI alloc] init];
            [self.program saveApiResponseArray:self.programsApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.programsApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.programsApiResults count]);
        }
    }else if([apiName isEqualToString:InspectionMinimum]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:InspectionMinimumsFilePath withContents:self.inspMinApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:InspectionMinimumsDownloaded];
            self.isInspectionMinimumCompleted = YES;
            self.inspectionMinimumsAPI = [[InspectionMinimumsAPI alloc] init];
            [self.inspectionMinimumsAPI saveApiResponseArray:self.inspMinApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.inspMinApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.inspMinApiResults count]);
        }
    }else if([apiName isEqualToString:ProgramsProducts]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:ProgramsProductsFilePath withContents:self.programProductsApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:ProductsDownloaded];
            self.isProgramsProductsCompleted = YES;
            self.productAPI = [[ProductAPI alloc] init];
            [self.productAPI saveApiResponseArray:self.programProductsApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.programProductsApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.programProductsApiResults count]);
        }
    }else if([apiName isEqualToString:ProgramsGroups]){
        if(downloadComplete) {
             NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:ProgramsGroupsFilePath withContents:self.programGroupsApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:ProgramGroupsDownloaded];
            self.isProgramsGroupsCompleted = YES;
            self.programGroup = [[ProgramGroupAPI alloc] init];
            [self.programGroup saveApiResponseArray:self.programGroupsApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            
            [self.programGroupsApiResults addObjectsFromArray:JSON];
             NSLog(@"Response for %@ is %d", apiName, (int)[self.programGroupsApiResults count]);
        }
    } else if([apiName isEqualToString:Ratings]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:RatingsFilePath withContents:self.ratingsApiResults];
            if(!incrSync)
                [[self delegate] updateAPIName:RatingsDownloaded];
            self.isRatingsCompleted = YES;
            self.rating = [[RatingAPI alloc] init];
            [self.rating saveApiResponseArray:self.ratingsApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.ratingsApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.ratingsApiResults count]);
        }
    }else if([apiName isEqualToString:DeletionLog]){
        if(downloadComplete) {
            NSLog(@"All pages downloaded for: %@", apiName);
            [self writeDataToFile:DeletionLogsPath withContents:self.deletionLogsApiResults];
           // if(!incrSync)
             //   [[self delegate] updateAPIName:@"Deletions Dowloaded"];
            self.isDeletionLogsCompleted = YES;
            self.deletionAPI = [[SyncDeletionAPI alloc] init];
            [self.deletionAPI saveApiResponseArray:self.deletionLogsApiResults];
            [self notifyDownloadComplete:incrSync];
        }
        else {
            [self.deletionLogsApiResults addObjectsFromArray:JSON];
            NSLog(@"Response for %@ is %d", apiName, (int)[self.deletionLogsApiResults count]);
        }
    }
}

-(void) downloadFailedForApi:(NSString*)apiName forPageNumber:(int)pageNumber{
    self.syncFailure = YES;
}


-(void) downloadImagesWithBlock :(BOOL)isIncrementalSync{
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    //results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TBL_DEFECT_FAMILY_DEFECTS]];
    results = [database executeQuery:[NSString stringWithFormat:@"SELECT %@,%@,%@ FROM %@ WHERE %@ IS NOT NULL", COL_IMAGE_URL_REMOTE, COL_ID,COL_IMAGE_UPDATED, TBL_DEFECT_FAMILY_DEFECTS, COL_IMAGE_URL_REMOTE]];
    //DefectAPI *defectApi = [[DefectAPI alloc]init];
    //dispatch_group_t group = dispatch_group_create();
    __block int requestCount = 0;
    __block int receivedCount = 0;
    __block int failedCount = 0;
    self.failedImagesCount = 0;
    while ([results next]) {
        Image *image = [[Image alloc] init];
        image.remoteUrl = [results stringForColumn:COL_IMAGE_URL_REMOTE];
        image.deviceUrl = [NSString stringWithFormat:@"defect_%d.jpg", [results intForColumn:COL_ID]];
        image.remoteUrl = [DefectAPI getModifiedUrl:image.remoteUrl];
        NSString *imageUpdatedTime = [results stringForColumn:COL_IMAGE_UPDATED];
        //NSLog(@"SyncManager - Image Update time: %@", imageUpdatedTime );
        //NSLog(@"SyncManager - Needs update ? %d", [DefectAPI needsUpdate:imageUpdatedTime]);
        BOOL imageNeedsUpdate = YES;
        
        //only download images that need update when incremental sync
        if(isIncrementalSync)
            imageNeedsUpdate = [DefectAPI needsUpdate:imageUpdatedTime];
        
        if ( imageNeedsUpdate && image.remoteUrl!=nil) {
             //dispatch_group_enter(group);
            requestCount++;
                        [image getImageFromRemoteUrlWithBlock:^(BOOL isReceived) {
                           // dispatch_group_leave(group);
                            if(!isReceived)
                                failedCount++;
                            
                            receivedCount++;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[self delegate] updateAPIName:[NSString stringWithFormat:@"Downloading Image %d of %d",receivedCount,requestCount]];
                            });
                            NSLog(@"Request Count %d --- Received Count: %d", requestCount, receivedCount);
                            if(receivedCount>=requestCount){
                                self.failedImagesCount = failedCount;
                                  [[self delegate] downloadProgress:YES];
                                [database close];
                            }
                        }];
           
            
        }
       
        
        NSString *colIdString = [NSString stringWithFormat:@"%d", [results intForColumn:COL_ID]];
        //[database executeUpdate:@"insert into DEFECT_IMAGES (id, image_updated, DEVICE_URL, REMOTE_URL) values (?,?,?,?)", colIdString, [results stringForColumn:COL_IMAGE_UPDATED], image.deviceUrl, image.remoteUrl];
        [database executeUpdate:@"insert or replace into DEFECT_IMAGES (id, DEVICE_URL, REMOTE_URL) values (?,?,?)", colIdString, image.deviceUrl, image.remoteUrl];
    }
    
    if(requestCount==0)
        [[self delegate] downloadProgress:YES];
    [database close];
    //[[self delegate] downloadProgress:YES];
}

-(void) notifyDownloadComplete : (BOOL) isIncrementalSync {
    //check if all the APIs downloaded succesfully
    if (!self.syncFailure && isStoresCompleted && isLocationsCompleted && isContainersCompleted && isContainerRatingsCompleted && isDefectsCompleted && isDefectsFamiliesCompleted && isProgramsCompleted && isProgramsProductsCompleted &&isProgramsGroupsCompleted && isRatingsCompleted &&isDeletionLogsCompleted && isInspectionMinimumCompleted) {
        [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"Sync Success"]];
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:SYNCSUCCESS];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] updateAPIName:@"Processing Data"];
        });
        [self deleteAndPrepareAllTheInsightsTablesForInsert:isIncrementalSync];
        
        //process the deletions from api/insights_deletion_logss
        if(isIncrementalSync){
            [self.deletionAPI groupAndDeleteResources];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] updateAPIName:@"Reporting Sync"];
        });
        [self reportDownloadSync];
        [self sendLogsToBackend];
        NSLog(@"Sync Download Success");
        if ([User sharedUser].currentStore) {
            [User sharedUser].currentStore.productGroups = [NSArray array];
            [User sharedUser].currentStore.groupsOfProductsForTheStore = [NSArray array];
        }
        [[self delegate] updateAPIName:@"Downloading Images"];
        [self downloadImagesWithBlock:isIncrementalSync];
        //[[self delegate] downloadProgress:YES];
    }else{
        [[self delegate] downloadProgress:NO];
    }
    
    if(self.syncFailure && !self.syncFailNotified) {
        [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"Sync Failed"]];
        [self sendLogsToBackend];
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:SYNCSUCCESS];
        NSString *failMessage = [NSString stringWithFormat:@"Go To Settings and Sync Again \n\n\n %@", self.syncFailMessage];
        self.syncFailNotified = YES;
        [[self delegate] downloadFailed:failMessage];
        [[User sharedUser] resetTrackingLog];
    }
}

-(void) cleanup {
    self.storesApiResults = nil;
    self.locationsApiResults = nil;
   self.storeLocationApiResults= nil;
    self.containersApiResults= nil;
    self.containerRatingsApiResults= nil;
    self.defectsApiResults= nil;
    self.defectFamiliesApiResults= nil;
    self.programsApiResults= nil;
    self.programProductsApiResults= nil;
    self.programGroupsApiResults= nil;
    self.ratingsApiResults= nil;
    self.orderDataApiResults= nil;
    
}


#pragma Upload Sync

- (void) uploadDataAndImages {
    [self appendTrackingLog:@""];
    [self uploadOfflineDataToBackend];
}

-(void)uploadDataAndImagesInBackground {
    [self appendTrackingLog:@""];
    [self appendTrackingLog:@"Insights_iOS: Background-Upload-Started"];
    [self uploadOfflineDataToBackend];
}

//upload data

- (void) uploadOfflineDataToBackend {
    __block BOOL auditsToBeUploaded = NO;
    NSString* msg = [NSString stringWithFormat:@"Insights_iOS: Data-Upload-Start for Device: %@, User: %@, Time: %@",[DeviceManager getDeviceID],[User sharedUser].email, [DeviceManager getCurrentTimeString]];
     [self appendTrackingLog:msg];
    [self appendTrackingLog:[DeviceManager getConnectivityStatusLog]];
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    __block int auditsUploaded = 0;
    __block int logAuditCounter = 0;
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    dispatch_group_t group = dispatch_group_create();
    while ([resultsGroupRatings next]) {
        logAuditCounter++;
        [self appendTrackingLog:[NSString stringWithFormat:@"Uploading Audit# %d |", logAuditCounter]];
        auditsToBeUploaded = YES;
        NSString *auditId = [resultsGroupRatings stringForColumn:COL_ID];
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_RATINGS];
        NSLog(@"UPLOADED DATA --- %@",ratings);
        NSError* err = nil;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger didSelect = [userDefaults objectForKey:@"didSelect"];
        Audit* audit = [[Audit alloc] initWithString:ratings error:&err];

        if (!audit.auditData.summary) {
            [self appendTrackingLog:@"Summary Null for audit - initializing empty summary"];
            [[User sharedUser] addLogText:[NSString stringWithFormat:@"| Summary is null so initializing it |"]];
            AuditApiSummary *summary = [[AuditApiSummary alloc] init];
            audit.auditData.summary.inspectionStatus = @"Accept";
            audit.auditData.summary = summary;
            [[User sharedUser] addLogText:[NSString stringWithFormat:@"| Summary initialized |"]];
        }
        NSDictionary* ratingDictionary = [audit toDictionary];
        if (ratingDictionary) {
            //[self appendTrackingLog:@"JSONModelSuccess"];
            //[[User sharedUser] addLogText:[NSString stringWithFormat:@"\nJSON model success\n"]];
        } else {
            [self appendTrackingLog:@"JSON parsing failed for audit string"];
            //[[User sharedUser] addLogText:[NSString stringWithFormat:@"\nJSON model failure\n"]];
        }
        //NSLog(@"%@", ratingDictionary);
        dispatch_group_enter(group);
        [self sendPost:^(BOOL isSuccess, NSError *error){
            if (error) {
                DebugLog(@"| Error: %@  |", [error localizedDescription]);
                   [self appendTrackingLog:[NSString stringWithFormat:@"| Audit Submission Failed with Error: %@",[error localizedDescription]]];
                //[[User sharedUser] addLogText:[NSString stringWithFormat:@"\n Error: %@  \n", [error localizedDescription]]];
            } else {
                if (isSuccess) {
                    auditsUploaded++;
                    [self appendTrackingLog:[NSString stringWithFormat:@"Audit Submitted # %d", auditsUploaded]];
                    NSString* updateMessage = [NSString stringWithFormat:@"Audit %d of %d",auditsUploaded,logAuditCounter];
                    [[self delegate]updateAPIName:updateMessage];
                    //[[User sharedUser] addLogText:[NSString stringWithFormat:@"\n Upload successful for one audit \n"]];
                    NSMutableArray *createStatements = [[NSMutableArray alloc] init];
                    NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_TRUE, COL_ID, auditId];
                    NSString *insertSubmittedAudit = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@) values ('%@', 1, '%@')", TBL_SUBMITTED_AUDITS, COL_ID, COL_AUDIT_COUNT, COL_DATE_SUBMITTED, auditId, [DeviceManager getCurrentDate]];
                    [createStatements addObject:updateStatement];
                    [createStatements addObject:insertSubmittedAudit];
                    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_OFFLINE_DATA];
                    //[self appendTrackingLog:[NSString stringWithFormat:@"AuditSuccessDBUpdate"]];
                }
                // mark the column COL_DATA_SUBMITTED as TRUE
            }
            dispatch_group_leave(group);
        }withDictionaryValues:ratingDictionary];
    }
    [databaseOfflineRatings close];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"Audits upload complete");
        [self appendTrackingLog:[NSString stringWithFormat:@"Data-Upload-End"]];
        //[self uploadOfflineImagesToBackend:auditsUploaded];
//         dispatch_queue_t defectsApiQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_async(defectsApiQueue,^{
//        [self uploadImages:auditsUploaded];
//        });
        [self uploadImages:auditsUploaded];
        if (auditsToBeUploaded) {
            auditsToBeUploaded = NO;
        }
    });
}

-(void)uploadImages: (int) auditsUploaded{
    NSString* msg = [NSString stringWithFormat:@"| Insights_iOS: Image-Upload-Start for Device: %@, User: %@, Time: %@",[DeviceManager getDeviceID],[User sharedUser].email, [DeviceManager getCurrentTimeString]];
    [self appendTrackingLog:msg];
    self.totalImagesToUpload = 0;
    self.currentUploadCount = 0;
    //get list of AuditIDs and Images array
    self.auditsUploaded = auditsUploaded;
    self.imagesUploaded = 0;
    //to avoid submitting duplicate container images across multiple audits
    self.containerImagesUploaded = [[NSMutableArray alloc]init];
    
    self.auditIdAndImagesMap = [[NSMutableDictionary alloc]init];
    self.arrayOfAuditIds =[[NSMutableArray alloc] init];
    
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_IMAGE_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    NSMutableArray* containerImages = [[NSMutableArray alloc]init];
    NSMutableDictionary* auditIdAndImagesMap = [[NSMutableDictionary alloc]init];
    while ([resultsGroupRatings next]) {
        NSString *auditId = [resultsGroupRatings stringForColumn:COL_ID];
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_AUDIT_IMAGE];
        NSError* err = nil;
        ImageArray* audit = [[ImageArray alloc] initWithString:ratings error:&err];
        NSMutableArray *totalsThatNeedTobeSubmitted = [[NSMutableArray alloc] init];
        
        NSMutableArray <Image> *imagesMutableArrayToBeSubmitted = (NSMutableArray <Image>*)totalsThatNeedTobeSubmitted;
        for (Image *image in audit.images) {
            if (!image.submitted) {
                [imagesMutableArrayToBeSubmitted addObject:image];
                
                BOOL isContainerImage = [image.path rangeOfString:@"/CONTAINER"].location != NSNotFound;
                if(isContainerImage && ![containerImages containsObject:image.path]){
                    [containerImages addObject:image.path];
                    self.totalImagesToUpload++;
                }else if(isContainerImage && [containerImages containsObject:image.path]){
                
                }else
                    self.totalImagesToUpload++;
            }
        }
        [auditIdAndImagesMap setObject:imagesMutableArrayToBeSubmitted forKey:auditId];
        
    }
    
    //set it only once to store the total pending imags
    if(self.overallTotalImagesToUploadCount==0)
        self.overallTotalImagesToUploadCount = self.totalImagesToUpload;
    
    self.auditIdAndImagesMap = auditIdAndImagesMap; //set class var
    
    [self appendTrackingLog:[NSString stringWithFormat:@"Total Images to upload: %d",self.totalImagesToUpload]];
    
    //for this map, we need loop through the auditIds(keys) and submit images one by one
    NSArray* arrayOfAuditIds = [[NSMutableArray alloc] init];
    arrayOfAuditIds = [self.auditIdAndImagesMap allKeys];
    self.arrayOfAuditIds = arrayOfAuditIds;
    //mark currentAuditID and currentImage
    int currentRowIndex = 0;
    int currentImageIndex = 0;
    //call for first row and image index
    // this gets recursively called
    [self uploadImageAtRowIndex:currentRowIndex withImageIndex:currentImageIndex];
}

-(void) uploadImageAtRowIndex:(int)currentRowIndex withImageIndex:(int)currentImageIndex{
 //   NSLog(@"Calling uploadImageAtRowIndex with currentRowIndex %d and ImageIndex %d", currentRowIndex, currentImageIndex);
    //TODO save container images uploaded path to an array and check in that every time
    if(currentRowIndex >= [self.arrayOfAuditIds count]){
        [self appendTrackingLog:[NSString stringWithFormat:@"| Image upload Loop complete - Submitted images %d of %d |",self.imagesUploaded,self.totalImagesToUpload]];
        NSString* updateMessage = @"Images Upload Complete";
        [[self delegate]updateAPIName:updateMessage];
        //all images uploaded - exit from here
        [[self delegate] imagesUploaded:YES withAuditsCount:self.auditsUploaded withImagesUploaded:self.imagesUploaded];
        return;
    }
    NSString *currentAuditID = [self.arrayOfAuditIds objectAtIndex:currentRowIndex];
    NSMutableArray <Image> *images = [self.auditIdAndImagesMap objectForKey:currentAuditID];
    if([images count]==0 || currentImageIndex>=[images count]){
        //NSLog(@"no more Images in the audit rows to upload - moving to next row");
        //[self appendTrackingLog:[NSString stringWithFormat:@"Image upload complete for auditId: %@",currentAuditID]];
        currentRowIndex++;
        currentImageIndex=0;
        [self uploadImageAtRowIndex:currentRowIndex withImageIndex:currentImageIndex];
        return;
    }
    Image *imageToUpload = [images objectAtIndex:currentImageIndex];

    //prepare image post data
    AuditImagesApi *auditImageApi = [[AuditImagesApi alloc]init];
    [auditImageApi setPath:imageToUpload.path];
    if (imageToUpload.auditIdForContainer && ![imageToUpload.auditIdForContainer isEqualToString:@""]) {
        [auditImageApi setAudit_id:imageToUpload.auditIdForContainer];
    } else {
        [auditImageApi setAudit_id:currentAuditID];
    }
    [auditImageApi setAudit_id:currentAuditID];
    NSString *hostUrl = [NSUserDefaultsManager getObjectFromUserDeafults:IMAGE_HOST_ENDPOINT];
    [auditImageApi setHost:hostUrl];
    NSString* imageBase64 =imageToUpload.getBase64EncodedImageFromDevice;
    [auditImageApi setImage_base64:imageBase64];
    //with duplicate samples, the image gets submitted with first sample and gets deleted
    if([imageBase64 isEqualToString:@""]){
        imageToUpload.submitted = YES;
        [self updateDBForUploadedImages:images forAuditId:currentAuditID withRowIndex:currentRowIndex withImageIndex:currentImageIndex];
        return;
    }
    //NSLog(@"Insights - Image URL is : %@ and Base64 is: %@,",auditImageApi.path, imageBase64);
    NSDictionary* ratingDictionary = [auditImageApi toDictionary];
    

    BOOL isContainerImage = [imageToUpload.path rangeOfString:@"/CONTAINER"].location != NSNotFound;
    //if container image which is already uploaded, then skip it
    if(isContainerImage && [self.containerImagesUploaded containsObject:imageToUpload.path]){
        //update DB value for images column for row
        imageToUpload.submitted = YES;
        [self updateDBForUploadedImages:images forAuditId:currentAuditID withRowIndex:currentRowIndex withImageIndex:currentImageIndex];
        return;
    }
    
    //show counter
    self.currentUploadCount++;
    NSString* updateMessage = [NSString stringWithFormat:@"Image %d of %d",self.currentUploadCount,self.totalImagesToUpload];
    [[self delegate]updateAPIName:updateMessage];
    
    [self appendTrackingLog:[NSString stringWithFormat:@"| Uploading image %d of %d at path %@ |",self.currentUploadCount,self.totalImagesToUpload,imageToUpload.path]];
    
    //upload image and wait for response
    //update DB for image status
    __block int rowIndex = currentRowIndex;
    __block int imageIndex = currentImageIndex;
    __weak SyncManager* weakSelf = self;
    NSString* uploadUrl =@"api/audits/image?auth_token=%@&device_id=%@";
    [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:uploadUrl, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:ratingDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        //NSLog(@"Request: %@", JSON);
        
        //[[User sharedUser] addLogText:[NSString stringWithFormat:@"\nImage success\n"]];
        BOOL success = [weakSelf parseBoolFromJson:JSON key:@"success"];
        if(success){
             [weakSelf appendTrackingLog:[NSString stringWithFormat:@"Success - Uploaded image %d at path %@",self.currentUploadCount,imageToUpload.path]];
            
            //track the upload for current retry loop
            self.imagesUploaded++;
            
            imageToUpload.submitted = YES;
            [imageToUpload deleteImageFromDevice:imageToUpload.path];
            [images replaceObjectAtIndex:currentImageIndex withObject:imageToUpload];
            if([imageToUpload.path containsString:@"/CONTAINER"]){
                [weakSelf.containerImagesUploaded addObject:imageToUpload.path];
            }
            //update DB value for images column for row
            [weakSelf updateDBForUploadedImages:images forAuditId:currentAuditID withRowIndex:rowIndex withImageIndex:imageIndex];
           
            
        }else{
            [weakSelf appendTrackingLog:[NSString stringWithFormat:@"Failed - Image %d success=false  at path %@ with Error: %@",self.currentUploadCount,imageToUpload.path, [operation.error localizedDescription]]];
            imageToUpload.submitted = NO;
            [images replaceObjectAtIndex:currentImageIndex withObject:imageToUpload];
            //call next image upload
            //imageIndex++;
            //[weakSelf uploadImageAtRowIndex:rowIndex withImageIndex:imageIndex];
            
            //update DB value for images column for row
            [weakSelf updateDBForUploadedImages:images forAuditId:currentAuditID withRowIndex:rowIndex withImageIndex:imageIndex];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf appendTrackingLog:[NSString stringWithFormat:@"Failed - Image %d at path %@ with Error: %@",self.currentUploadCount,imageToUpload.path, [operation.error localizedDescription]]];
        imageToUpload.submitted = NO;
        [images replaceObjectAtIndex:currentImageIndex withObject:imageToUpload];
        //call next image upload
        //imageIndex++;
        //[weakSelf uploadImageAtRowIndex:rowIndex withImageIndex:imageIndex];
        
        //update DB value for images column for row
        [weakSelf updateDBForUploadedImages:images forAuditId:currentAuditID withRowIndex:rowIndex withImageIndex:imageIndex];
    }];
}

-(BOOL)isAllImagesSubmittedInArray:(NSArray*)images{
    for(Image* cursor in images){
        if(!cursor.submitted)
            return NO;
    }
    return YES;
}

-(void)cleanupOfflineDatabase{
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@' AND %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_TRUE, COL_IMAGE_SUBMITTED, CONST_TRUE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    [databaseOfflineRatings open];
    [databaseOfflineRatings executeUpdate:queryAllOfflineRatings];
    [databaseOfflineRatings close];
}

-(void)updateDBForUploadedImages:(NSArray*)images forAuditId:(NSString*)currentAuditID withRowIndex:(int)currentRowIndex withImageIndex:(int)currentImageIndex{
    ImageArray* audit = [[ImageArray alloc]init];
    NSArray<Image> *arrayLocal = [images copy];
    audit.images = arrayLocal;
    BOOL allImagesSubmitted = [self isAllImagesSubmittedInArray:arrayLocal];
    NSString *stringImages = [audit toJSONString];
    NSMutableArray *createStatements = [[NSMutableArray alloc] init];
    NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_AUDIT_IMAGE, stringImages, COL_ID, currentAuditID];
    [createStatements addObject:updateStatement];
    //if all images submitted - mark the column
    if(allImagesSubmitted){
        NSString *markAllSubmittedQuery = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_IMAGE_SUBMITTED, CONST_TRUE, COL_ID, currentAuditID];
        NSString *updateImageStatementForSubmittedTable = [NSString stringWithFormat:@"UPDATE %@ SET %@='%d' WHERE %@='%@'", TBL_SUBMITTED_AUDITS, COL_IMAGE_COUNT, (int)[arrayLocal count], COL_ID, currentAuditID];
        [createStatements addObject:markAllSubmittedQuery];
        [createStatements addObject:updateImageStatementForSubmittedTable];
    }
    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_OFFLINE_DATA];
    //call next
    //rowIndex++;
    currentImageIndex++;
    [self uploadImageAtRowIndex:currentRowIndex withImageIndex:currentImageIndex];
}

//upload images
/*
- (void) uploadOfflineImagesToBackend: (int) auditsUploaded {
    [self appendTrackingLog:@"ImageStart"];
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_IMAGE_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    __block int imagesUploaded = 0;
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
     NSMutableSet *submittedImagesPath = [[NSMutableSet alloc] init];
    dispatch_group_t group = dispatch_group_create();
    while ([resultsGroupRatings next]) {
       
        NSString *auditId = [resultsGroupRatings stringForColumn:COL_ID];
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_AUDIT_IMAGE];
        NSError* err = nil;
        ImageArray* audit = [[ImageArray alloc] initWithString:ratings error:&err];
        NSMutableArray *totalsThatNeedTobeSubmitted = [[NSMutableArray alloc] init];
       
        NSMutableArray <Image> *imagesMutableArrayToBeSubmitted = (NSMutableArray <Image>*)totalsThatNeedTobeSubmitted;
        for (Image *image in audit.images) {
            if (!image.submitted) {
                [imagesMutableArrayToBeSubmitted addObject:image];
            }
        }
        NSMutableArray *totalsLocal = [[NSMutableArray alloc] init];
        NSMutableArray <Image> *imagesMutableArray = (NSMutableArray <Image>*)totalsLocal;
        __block int imagesCountSubmitted = 0;
        [[User sharedUser] addLogText:[NSString stringWithFormat:@"\nImages to be submitted %d as per Audit ID %@\n", [imagesMutableArrayToBeSubmitted count], auditId]];
         [self appendTrackingLog:[NSString stringWithFormat:@"ImagesForOneAudit-%d", [imagesMutableArrayToBeSubmitted count]]];
        for(Image *image in imagesMutableArrayToBeSubmitted) {
            if (image.getBase64EncodedImageFromDevice && ![image.getBase64EncodedImageFromDevice isEqualToString:@""]) {
                AuditImagesApi *auditImageApi = [[AuditImagesApi alloc]init];
                [auditImageApi setPath:image.path];
                if (image.auditIdForContainer && ![image.auditIdForContainer isEqualToString:@""]) {
                    [auditImageApi setAudit_id:image.auditIdForContainer];
                } else {
                    [auditImageApi setAudit_id:auditId];
                }
                [auditImageApi setAudit_id:auditId];
                NSString *hostUrl = [NSUserDefaultsManager getObjectFromUserDeafults:IMAGE_HOST_ENDPOINT];
                [auditImageApi setHost:hostUrl]; //@"http://cdn.yottamark.com/portal/_qa/audits"
                [auditImageApi setImage_base64:image.getBase64EncodedImageFromDevice];
                NSDictionary* ratingDictionary = [auditImageApi toDictionary];
                dispatch_group_enter(group);
                [self sendImagesPost:^(BOOL isSuccess, NSError *error){
                    if (error) {
                        image.submitted = NO;
                        [imagesMutableArray addObject:image];
                        [self appendTrackingLog:[NSString stringWithFormat:@"PostError-%d", [error code]]];
                        DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
                    } else {
                        if (isSuccess) {
                            DebugLog(@"\n Image submitted successfully \n");
                            [self appendTrackingLog:[NSString stringWithFormat:@"Success"]];
                            image.submitted = YES;
                            [imagesMutableArray addObject:image];
                            [submittedImagesPath addObject:image.path];
                            [image deleteImageFromDevice:image.path];
                            imagesUploaded++;
                        } else {
                            [self appendTrackingLog:[NSString stringWithFormat:@"PostNotSuccess-%d", [error code]]];
                            image.submitted = NO;
                            [imagesMutableArray addObject:image];
                        }
                    }
                    BOOL allTheImagesAreSubmitted = YES;
                    if ([imagesMutableArray count] == [imagesMutableArrayToBeSubmitted count]) {
                        for (Image *image in imagesMutableArray) {
                            if (!image.submitted) {
                                allTheImagesAreSubmitted = NO;
                            } else {
                                imagesCountSubmitted = imagesCountSubmitted + 1;
                            }
                        }
                    } else {
                        allTheImagesAreSubmitted = NO;
                    }
                    if (allTheImagesAreSubmitted) {
                        [self appendTrackingLog:[NSString stringWithFormat:@"ImageSuccess"]];
                        NSMutableArray *createStatements = [[NSMutableArray alloc] init];
                        NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_IMAGE_SUBMITTED, CONST_TRUE, COL_ID, auditId];
                        NSString *updateImageStatementForSubmittedTable = [NSString stringWithFormat:@"UPDATE %@ SET %@='%d' WHERE %@='%@'", TBL_SUBMITTED_AUDITS, COL_IMAGE_COUNT, imagesCountSubmitted, COL_ID, auditId];
                        [createStatements addObject:updateStatement];
                        [createStatements addObject:updateImageStatementForSubmittedTable];
                        [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_OFFLINE_DATA];
                    } else {
                        if ([imagesMutableArray count] == [imagesMutableArrayToBeSubmitted count]) {
                            NSArray<Image> *arrayLocal = [imagesMutableArray copy];
                            audit.images = arrayLocal;
                            NSString *stringImages = [audit toJSONString];
                            NSMutableArray *createStatements = [[NSMutableArray alloc] init];
                            NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_AUDIT_IMAGE, stringImages, COL_ID, auditId];
                            NSString *updateImageStatementForSubmittedTable = [NSString stringWithFormat:@"UPDATE %@ SET %@='%d' WHERE %@='%@'", TBL_SUBMITTED_AUDITS, COL_IMAGE_COUNT, imagesCountSubmitted, COL_ID, auditId];
                            [createStatements addObject:updateStatement];
                            [createStatements addObject:updateImageStatementForSubmittedTable];
                            [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_OFFLINE_DATA];
                        }
                    }
                    dispatch_group_leave(group);
                }withDictionaryValues:ratingDictionary];
            } else {
                NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_IMAGE_SUBMITTED, CONST_TRUE, COL_ID, auditId];
                [databaseOfflineRatings executeUpdate:updateStatement];
                [self appendTrackingLog:[NSString stringWithFormat:@"ImageSuccessDBUpdate"]];
            }
        }
    }
    [databaseOfflineRatings close];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if(submittedImagesPath && [submittedImagesPath count]>0)
            imagesUploaded = (int)[submittedImagesPath count];// to avoid showing duplicate container images count
        [[self delegate] imagesUploaded:YES withAuditsCount:auditsUploaded withImagesUploaded:imagesUploaded];
    });
}
*/

- (void)sendPost:(void (^)(BOOL isSuccess, NSError *error))block withDictionaryValues:(NSDictionary *)auditPost {
    if ([auditPost count] > 0) {
        [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"api/audits?auth_token=%@&device_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:auditPost success:^(AFHTTPRequestOperation *operation, id JSON) {
            NSLog(@"Request: %@", JSON);
            BOOL success = [self parseBoolFromJson:JSON key:@"status"];
            if (block) {
                block(success, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block(false, error);
            }
        }];
    } else {
        if (block) {
            block(false, nil);
        }
    }
}
/*
- (void)sendImagesPost:(void (^)(BOOL isSuccess, NSError *error))block withDictionaryValues:(NSDictionary *)auditPost {
    if ([auditPost count] > 0) {
        [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"api/audits/image?auth_token=%@&device_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:auditPost success:^(AFHTTPRequestOperation *operation, id JSON) {
            NSLog(@"Request: %@", JSON);
            [[User sharedUser] addLogText:[NSString stringWithFormat:@"\nImage success\n"]];
            BOOL success = [self parseBoolFromJson:JSON key:@"success"];
            if (block) {
                block(success, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                [[User sharedUser] addLogText:[NSString stringWithFormat:@"\nImage failure\n"]];
                block(false, error);
            }
        }];
    } else {
        if (block) {
            block(false, nil);
        }
    }
}
*/
+ (NSString *)getPortalEndpoint {
    NSString *endpoint = [NSUserDefaultsManager getObjectFromUserDeafults:PORTAL_ENDPOINT];
    NSLog(@"endpoint is  %@", endpoint);
    if(endpoint!=nil && ![endpoint length]==0) {
        return endpoint;
    } else
        return DEFAULT_PORTAL_ENDPOINT;
}

- (void) downloadProgramsForTeamCheck {
    ProgramAPI *programLocal = [[ProgramAPI alloc] init];
    [programLocal programsCallForChecking:^(BOOL isSuccess, NSArray *array, NSError *error) {
        if (error) {
            DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
        } else {
            NSLog(@"posts %d Program API", isSuccess);
            if (isSuccess) {
            } else {
            }
        }
    }];
}

-(NSString*) getLastSyncTime {
    NSDate *date = [NSUserDefaultsManager getObjectFromUserDeafults:SyncDownloadTime];
    NSString* lastSyncTime = [DeviceManager getTimeInMillisFromDate:date];
    if(!lastSyncTime || [lastSyncTime length]==0)
        lastSyncTime = @"0";
    return lastSyncTime;
}


@end

