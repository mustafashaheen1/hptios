//
//  SyncManager.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "StoreAPI.h"
#import "LocationAPI.h"
#import "ContainerAPI.h"
#import "ContainerRatingsAPI.h"
#import "DefectAPI.h"
#import "DefectFamiliesAPI.h"
#import "ProgramAPI.h"
#import "ProductAPI.h"
#import "ProgramGroupAPI.h"
#import "RatingAPI.h"
#import "OrderDataAPI.h"
#import "SyncOverlayView.h"
#import "SyncDeletion.h"
#import "SyncDeletionAPI.h"
#import "InspectionMinimumsAPI.h"


@protocol SyncManagerDelegate <NSObject>
@required
- (void) downloadProgress: (BOOL)success;
- (void) updateAPIName: (NSString *) apiName;
- (void) auditsUploaded: (BOOL) success;
- (void) imagesUploaded: (BOOL) success withAuditsCount:(int) auditsUploaded withImagesUploaded: (int) imagesUploaded;
- (void) downloadFailed;
- (void) downloadFailed:(NSString*)failMessage;

@optional
- (void) nothingToUpload;
- (void) orderDataDownloadComplete;
- (void) orderDataMissing;
- (void) orderDataDownloadFailedWithMessage:(NSString*)message;
- (void) startIncrementalSync:(int)orderDataStatus;
@end

@interface SyncManager : DCBaseEntity

@property (retain) id <SyncManagerDelegate> delegate;
@property (strong, nonatomic) NSArray *storesArray;
@property (strong, nonatomic) NSArray *containersArray;
@property (strong, nonatomic) NSArray *containerRatingsArray;
@property (strong, nonatomic) NSArray *defectsArray;
@property (strong, nonatomic) NSArray *defectFamiliesArray;
@property (strong, nonatomic) NSArray *programsArray;
@property (strong, nonatomic) NSArray *programProductsArray;
@property (strong, nonatomic) NSArray *programGroupsArray;
@property (strong, nonatomic) NSArray *ratingsArray;
@property (strong, nonatomic) NSArray *orderDatasArray;


@property (strong, nonatomic) StoreAPI *store;
@property (strong, nonatomic) LocationAPI *location;
@property (strong, nonatomic) ContainerAPI *container;
@property (strong, nonatomic) ContainerRatingsAPI *containerRatings;
@property (strong, nonatomic) DefectAPI *defectAPI;
@property (strong, nonatomic) DefectFamiliesAPI *defectFamiliesAPI;
@property (strong, nonatomic) ProgramAPI *program;
@property (strong, nonatomic) ProductAPI *productAPI;
@property (strong, nonatomic) ProgramGroupAPI *programGroup;
@property (strong, nonatomic) RatingAPI *rating;
@property (strong, nonatomic) OrderDataAPI *orderData;
@property (strong, nonatomic) SyncDeletionAPI *deletionAPI;
@property (strong, nonatomic) InspectionMinimumsAPI *inspectionMinimumsAPI;

@property (assign, nonatomic) int failedImagesCount;
@property (assign, nonatomic) int overallTotalImagesToUploadCount;

@property (assign,nonatomic) NSString* orderDataStausMessage;

//------------------------------------------------------------------------------
// Instance Methods
//------------------------------------------------------------------------------

- (void) downloadProgramsForTeamCheck;
- (void) prepareSQLDatabasesAndTables;
- (void) callAllTheAPIsAndProcessThem : (BOOL)isIncrementalSync;
- (void) reportCurrentTime;
- (void) uploadOfflineDataToBackend;
- (void) uploadDataAndImages;
-(void) uploadDataAndImagesInBackground;
- (void)sendPost:(void (^)(BOOL isSuccess, NSError *error))block withDictionaryValues:(NSDictionary *)auditPost;
- (void) reportDownloadSync;
- (void) reportUploadSync;
- (void) sendLogsToBackend;
- (void) orderDataCallDownload: (SyncOverlayView *) syncOverlayView;
- (void) appUpdateCheckCall: (void (^)(BOOL isVerionUpdateRequired, NSError *error))block;

-(void)cleanupOfflineDatabase;

+ (NSString *) getPortalEndpoint;

@end
