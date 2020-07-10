//
//  CurrentAudit.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Product.h"
#import "Rating.h"
#import "JSONModel.h"
#import "User.h"
#import "DeviceManager.h"
#import "AuditApiData.h"
#import "Audit.h"
#import "Image.h"

@interface CurrentAudit : JSONModel

@property (nonatomic, assign) NSInteger auditNumber; // the number of this individual audit
@property (nonatomic, assign) int currentPictureCount; // the number of this individual audit

@property (nonatomic, strong) Product *currentProduct;

// AuditData
@property (nonatomic, strong) NSString *auditMasterId;
@property (nonatomic, strong) NSString *auditGroupId;
@property (nonatomic, strong) NSString *auditTransactionId;
@property (nonatomic, strong) NSString *auditStartTime;
@property (nonatomic, strong) NSString *auditEndTime;
@property (nonatomic, strong) NSString *timeZone;
@property (nonatomic, strong) NSString *trackingCodes;
@property (nonatomic, strong) NSString *compositeAuditIDLocal;

//Submitted Info
@property (nonatomic, assign) NSInteger programId;
@property (nonatomic, assign) NSInteger programVersion;
@property (nonatomic, assign) BOOL countOfCasesRatingPresent;
@property (nonatomic, strong) NSMutableArray *allRatings;
@property (nonatomic, strong) NSMutableArray *allImages;
@property (nonatomic, strong) Product *product;
@property (strong, nonatomic) NSString *userEnteredInspectionSamples;
@property (assign, nonatomic) int countOfCasesFromSavedAudit;
@property (strong, nonatomic) NSString *countOfCasesFromRatings;

- (void)addRating: (Rating *) ratingLocal;
- (void) saveCurrentAuditToDB:(NSInteger)duplicateCount;
- (NSString *) getAuditFromDB;
- (void) setAllTheCurrentAuditVariables:(int) auditNumber withAuditMasterId:(NSString *) auditMasterId withAuditGroupId:(NSString *) auditGroupId withProductID:(int)productID withProductGroupID:(int)productGroupID withProgramID:(int) programId withProgramVersion:(int) programVersion;
- (void) setAllTheCurrentAuditVariables:(int) auditNumber withAuditMasterId:(NSString *) auditMasterId withAuditGroupId:(NSString *) auditGroupId withProductID:(int)productID withProductGroupID:(int)productGroupID withProgramID:(int) programId withProgramVersion:(int) programVersion withDatabase:(FMDatabase *) database;
- (BOOL) populateFromExisitingAuditInDB:(NSString *) auditSavedMasterId withAuditCount:(int) auditCount withProductID:(int) productID withProductName:(NSString *) productName withUserEnteredInspectionSamples: (int) userEnteredAuditCount;
- (NSString *) getCompositeAuditID;
- (NSString *) getRemoteUrl;
- (NSString *) getDeviceUrl;
- (NSString *) getPath;
-(void) addImage: (Image*)image;
- (int) getNumberOfSavedAudits;
- (NSString*) generateAuditJson: (BOOL) duplicateInspection;
- (Audit *) generateAudit: (BOOL) duplicateInspection;
- (void) deleteCurrentAuditFromDB;
-(BOOL) validateDaysRemainingMinConditionForRating:(Rating*)rating forProduct:(Product*)product;
@end
