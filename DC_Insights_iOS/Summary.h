//
//  Summary.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/30/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rating.h"
#import "Severity.h"
#import "Product.h"
#import "AuditApiSummary.h"
#import "InspectionStatus.h"
@interface Summary : NSObject

@property (nonatomic, assign) NSInteger numberOfInspections;
@property (nonatomic, assign) float averagePercentageOfCases;
@property (nonatomic, assign) float inspectionPercentageOfCases;
@property (nonatomic, strong) NSString *inspectionStatus;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, assign) int totalCountOfCases;
@property (nonatomic, assign) int inspectionCountOfCases;
@property (nonatomic, assign) int productId;
@property (nonatomic, assign) int groupId;
@property (nonatomic, assign) BOOL sendNotification;
@property (nonatomic, assign) BOOL failedDateValidation;
@property (nonatomic, assign) Product *product;
// the object with summary data for summary
@property (nonatomic, strong) NSMutableArray *allRatingsList; // array of Rating
@property (nonatomic, strong) NSMutableArray *allTotalsList; // array of Severity
@property (nonatomic, assign) float grandTotal;
@property (nonatomic, strong) InspectionStatus *globalInspectionStatus;
@property (nonatomic, strong) NSString *previousInspectionStatus;
@property (nonatomic,strong) NSMutableArray *inspectionSamples; //array of samples for summary details screen
@property (nonatomic,strong) NSArray *globalThresholds;
@property (nonatomic,strong) NSArray *severityTotalThresholds;

- (Summary *) getSummaryOfAudits: (Product*) productWithReferenceData withGroupId:(NSString *) groupId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal;
- (void) updateInspectionStatusInDB:(NSString *) newInspectionStatus withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString *)splitGroupId withDatabase: (FMDatabase *) databaseLocal;
- (void) updateInspectionColumnStatusInDB:(NSString *) newInspectionStatus withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal;
- (void) updateCountOfCasesInDB:(NSString *) newCount withInspectionCount: (NSString *) inspectionCount withGroupId:(NSString *) productGroupId withProductId:(NSString *) productId withDatabase: (FMDatabase *) databaseLocal;
- (NSString *) generateJson;
- (AuditApiSummary *) generateAuditApiSummary;
- (Summary *) getSummaryOfAuditsWithDatabase: (FMDatabase *)dataBase withProduct: (Product*) productWithReferenceData withGroupId:(NSString *) groupId;
- (void) calculateAveragePercentageOfCases;
+ (NSString *) getCountOfCasesFromDB:(int) totalAuditsCompleted withGroupId:(NSString *) groupId withProductId:(NSString *) productId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal;
+ (NSString *) getInspectionCountOfCasesFromDB:(int) totalAuditsCompleted withGroupId:(NSString *) groupId withProductId:(NSString *) productId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal;
- (void) updateNumberOfInspectionsInDB:(int) newInspectionsCount withGroupId:(NSString *) productGroupId withAuditMasterID:(NSString *) auditMasterId withProductId: (NSString *) productId withSplitGroupId:(NSString *)splitGroupId withDatabase: (FMDatabase *) databaseLocal;
- (void) populateSummaryobject: (Product*) productWithReferenceData withSavedRatings:(NSArray *) savedRatings withGroupId:(NSString *) groupId withMasterId: (NSString *) auditMasterId withSplitGroupId:(NSString*)splitGroupId withSave: (BOOL) saveToDB withDatabase: (FMDatabase *) databaseLocal;
+ (NSDictionary *) getCountOfCasesForProductsFromDB:(NSArray *) productsArray;
- (void) updateNotificationInDB:(BOOL) notification withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal withSplitGroupId: (NSString *) splitGroupId;
- (void) updateNotificationInDB:(BOOL) notification withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal;
- (void) updateChangedInDB:(int) changed withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal;
-(void) deleteSummaryForProductWithGroupId:(NSString *) productGroupId withAuditMasterID:(NSString *) auditMasterId withProductId: (NSString *) productId withDatabase: (FMDatabase *) databaseLocal;
- (void) updateDaysRemainingValidationFailedStatus:(BOOL)status withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString *)splitGroupId withDatabase: (FMDatabase *) databaseLocal ;
- (int) getUserEnteredChangedFromDB:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal;

-(AuditApiSummary*) getSummaryFromDBForGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withSplitGroupId:(NSString *)splitGroupId;

@end
