//
//  User.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//
//  Will hold user object.  Should be singleton, or obj-c equivalent.
#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"
#import "Device.h"
#import "DeviceManager.h"
#import "Store.h"
#import "UserLocation.h"
#import "UserNetworkActivityView.h"
#import "UserNetworkActivityViewProtocol.h"
#import "OrderData.h"
#import "BackgroundUpload.h"
#import "CollabBackgroundUpload.h"

@interface User : DCBaseEntity <UserNetworkActivityViewProtocol>

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL isLoggedIn;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) NSArray *allValidStoresForUser;
@property (strong, nonatomic) Store *currentStore;
@property (strong, nonatomic) UserLocation *userLocation;
@property (assign, nonatomic) int currentPictureCount;
@property (strong, nonatomic) NSMutableArray *allImages;
@property (strong, nonatomic) NSString *getCompositeAuditID;
@property (strong, nonatomic) NSString *userSelectedVendorName;
@property (strong, nonatomic) NSString *userSelectedLoadId;
@property (strong, nonatomic) NSString *userSelectedCustomerName;
@property (strong, nonatomic) UserNetworkActivityView *activityView;
@property (strong, nonatomic) OrderData *userEnteredOrderedData;
@property (nonatomic, strong) NSString *logForUser;
@property (nonatomic, strong) NSString *trackingLog;
@property (nonatomic, strong) NSString *temporaryPONumberFromUserClass;
@property (nonatomic, strong) NSString *temporaryGRNFromUserClass;
@property (nonatomic, strong) NSArray *programsForUser;
@property (nonatomic, strong) BackgroundUpload *backgroundUpload;
@property (nonatomic, strong) CollabBackgroundUpload *collabBackgroundUpload;
//upload requests
@property int pendingUploadRequests;

//------------------------------------------------------------------------------
// Class Methods
//------------------------------------------------------------------------------

// Class Methods
+ (User *) sharedUser;

// Error Checking
+ (NSString*)checkEmailFormat:(NSString*)theEmail;
+ (NSString*)checkPasswordFormat:(NSString*)thePassword;
+ (void) log:(NSString *)message;
//------------------------------------------------------------------------------
// Instance Methods
//------------------------------------------------------------------------------

- (void) logoutUser;
- (void) logUserInWithValues: (NSDictionary *) responseValues;
-(void) googleUserLoggedinWithValues: (NSDictionary *) responseValues;
- (NSArray *) getListOfStoresSortedByDistance;
- (NSArray *) getProgramsForUser;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (NSArray *) retrievePreviousUsers;
- (void) reportCurrentTime;
- (NSArray *) sortStores: (NSArray *) stores;
- (NSArray *) getAllSavedInspections;
- (void) findStoreFromStoreIdAndSetToCurrentStore: (NSString *) storeIdLocal;
- (NSString *) getDeviceUrlForContainerImages;
- (NSString *)getRemoteUrl;
- (NSString *) getDeviceUrl;
- (NSString *) getPath;
- (NSString *) getAuditorRole; //DC or Retail Auditor
- (void) addNetworkActivityView;
- (void) removeNetworkActivityView;
- (BOOL) checkIfTheUserBelongsToTheTeam: (NSArray *) programsLocal;
- (void) downloadProgramsForChecking;
- (BOOL) doWhatNeedsTobeDoneIfTheArrayIsEqualOrNot: (BOOL) same;
- (BOOL) checkIfUserLoggedIn;
- (BOOL) checkForRetailInsights;
- (BOOL) checkForScanOut;
- (BOOL) checkForDCInsights;
- (Store *) getListOfProgramsForTheStore: (Store *) store;
- (NSArray *) getAllPendingAudits;
- (NSArray *) getAllSubmittedAudits;
- (NSArray *) getAllPendingScanouts;
- (NSArray *) getAllSubmittedScanouts;
- (void) addLogText: (NSString *) string;
- (void) addTrackingLog : (NSString*) log;
- (void) resetTrackingLog;
- (NSArray *) getProgramsForUserForDistinctSamples;
- (NSArray *) getUserProgramsFromDB;
-(NSString*) getAllRoles;
-(void) incrementPendingRequest;
-(int) getPendingRequests;
-(void) decrementPendingRequest;
-(void)initBackgroundUpload;
-(void)initCollaborativeBackgroundUpload;
-(BOOL)isApplyToAllActiveForUserProgram;

@end
