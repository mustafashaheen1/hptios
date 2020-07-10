//
//  SavedAudit.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "AuditCountData.h"
#import "DBManager.h"
#import "DBConstants.h"
#import "ParseJsonUtil.h"
#import "InspectionMinimums.h"
#import "Defect.h"
#import "InspectionStatus.h"
@protocol SavedAudit
@end

@interface SavedAudit : JSONModel

@property (nonatomic, strong) NSString *productName;
@property (nonatomic, assign) int auditsCount;
@property (nonatomic, assign) int productId;
@property (nonatomic, assign) int productGroupId;
@property (nonatomic, strong) NSString *auditGroupId;
@property (nonatomic, strong) NSString *inspectionStatus;
@property (nonatomic, assign) int countOfCases;
@property (nonatomic, assign) int inspectionCountOfCases;
@property (nonatomic, assign) int userEnteredAuditsCount;
@property (nonatomic, strong) NSString *supplierName;
@property (nonatomic, strong) NSString *poNumber;
@property (nonatomic, strong) NSString *grn;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, assign) int auditNumberToShow;
@property (nonatomic, assign) BOOL flaggedProduct;
@property (nonatomic,strong) AuditCountData *auditCountData;
@property (nonatomic,strong) NSString* splitGroupId;
@property (nonatomic,strong) InspectionMinimums *inspectionMinimums;
@property (nonatomic,assign) BOOL isFlagged;
@property (nonatomic, strong) NSMutableArray *allFlaggedProductMessages;
@property (nonatomic, strong) NSMutableArray *defects;
@property (nonatomic, strong) InspectionStatus *globalInspectionStatus;
@property (nonatomic, strong) NSString *previousInspectionStatus;
-(void)populateAuditCounts;
-(NSString*)getWarningMessage;
-(IMResult*)getResultForInspectionMinimum:(InspectionMinimums*)inspectionMinimum;

@end
