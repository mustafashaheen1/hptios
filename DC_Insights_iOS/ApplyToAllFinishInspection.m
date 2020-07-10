
//
//  ApplyToAllFinishInspection.m
//  Insights
//
//  Created by Vineet on 10/2/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "ApplyToAllFinishInspection.h"
#import "Inspection.h"

@implementation ApplyToAllFinishInspection

-(id)init {
    self = [super init];
    if(self){
        self.allProductList = [[NSArray alloc]init];
    }
    return self;
}

-(void) save {
    NSMutableArray* allGroupIds = [[NSMutableArray alloc]init];
    NSMutableArray<Audit*> *allAudits = [[NSMutableArray alloc]init];
    //get list of products in the PO (PoriductId, OrderData Id)
    
    for(ProductListItem *productListItem in self.allProductList){
        CurrentAudit *currentAudit = [self getCurrentAuditWithProduct:productListItem];
        [allGroupIds addObject:currentAudit.auditGroupId]; //to be used in summary
        
        //Audit
        Audit *audit = [currentAudit generateAudit:NO];
        
        //container ratings
        NSArray<AuditApiContainerRating> *containerRatings = [self getContainerRatings];
        audit.auditData.submittedInfo.containerRatings = containerRatings;
        
        //product ratings
        NSArray<AuditApiRating> *productRatings = [self getProductRatings];
        audit.auditData.submittedInfo.productRatings = productRatings;
        
        //Summary
        AuditApiSummary *summary = [self getSummaryForProduct:productListItem];
        audit.auditData.summary = summary;
        
        [allAudits addObject:audit];
        NSString* string = audit.toJSONString;
        NSLog(@"String %@",string);
    }
    
    [self updateAuditGroupIds:allGroupIds inAudits:allAudits];
    
    for(Audit *audit in allAudits){
        [[Inspection sharedInspection] saveAuditInOfflineTable:audit withImages:@""];
    }
    [[Inspection sharedInspection] cleanupCollaborativeInspections];
    [[Inspection sharedInspection] cancelInspection];
    //[[Inspection sharedInspection] startBackgroundUpload];
}

-(CurrentAudit*) getCurrentAuditWithProduct:(ProductListItem*)productListItem {
    CurrentAudit *currentAudit = [[CurrentAudit alloc]init];
    currentAudit.product = productListItem.product;
    currentAudit.auditMasterId = [[Inspection sharedInspection] auditMasterId];
    currentAudit.auditNumber = 1;
    currentAudit.programId = productListItem.product.program_id;
    currentAudit.programVersion = [currentAudit.product.program_version intValue];
    currentAudit.auditTransactionId = [DeviceManager getCurrentTimeString];
    currentAudit.auditStartTime = [DeviceManager getCurrentTimeString];
    currentAudit.timeZone = [DeviceManager getCurrentTimeZoneString];
    currentAudit.auditGroupId = [DeviceManager getCurrentTimeString];
    currentAudit.auditEndTime = [DeviceManager getCurrentTimeString];
    return currentAudit;
}

-(NSArray<AuditApiContainerRating> *) getContainerRatings {
    Inspection *inspection = [Inspection sharedInspection];
    NSArray<AuditApiContainerRating> *containerRatings;
    containerRatings = [inspection getContainerRatingsForInspection:inspection.auditMasterId];
    if ([containerRatings count] == 0) {
        //send empty container ratings array when no container
        //otherwise no email notification
        containerRatings = nil; //[self containerMissing];
    }
    return containerRatings;
}

-(NSArray<AuditApiRating>* )getProductRatings {
    NSMutableArray<AuditApiRating> *programRatings = [[NSMutableArray<AuditApiRating> alloc]init];
    
    for(Rating *rating in self.applyToAllModel.ratings){
        
        AuditApiRating* tempRating = [[AuditApiRating alloc]init];
        tempRating.id = rating.id;
        tempRating.value = rating.value;
        tempRating.type = rating.type;
        [programRatings addObject:tempRating];
    }

    return programRatings;
}

-(AuditApiSummary*) getSummaryForProduct:(ProductListItem*)listItem {
    AuditApiSummary *summary = [[AuditApiSummary alloc]init];
    int sampleCountRating;
    for(Rating* rating in self.applyToAllModel.ratings){
        if([rating.displayName isEqualToString:@"Inspection Status"]){
            summary.inspectionStatus = rating.value;
        }
        if([rating.displayName isEqualToString:@"Sample Count"]){
            sampleCountRating = [rating.value intValue];
        }
    }
    int totalCases =[listItem.orderData.QuantityOfCases intValue];
    
    if(summary.inspectionStatus == nil || [summary.inspectionStatus isEqualToString:@""])
        summary.inspectionStatus = @"Accept";
    if(![summary.inspectionStatus isEqualToString:@"Accept"]){
        summary.sendNotification = YES;
    }
    summary.totalCases = totalCases;
    
        summary.inspectionSamples = sampleCountRating;
        summary.percentageOfCases = (float)(sampleCountRating*1.0f/totalCases)*100;
        
   summary.percentageOfCases = [[NSString stringWithFormat:@"%.2f", summary.percentageOfCases] floatValue];
    return summary;
}

//this can only be done after all the groupIds are generated
-(void)updateAuditGroupIds:(NSArray*)allGroupIds inAudits:(NSArray<Audit*>*)allAudits {
    for(Audit *audit in allAudits){
        AuditApiSummary *summary = audit.auditData.summary;
        summary.auditGroupIds = allGroupIds;
    }
}

@end
