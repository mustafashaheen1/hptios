//
//  AuditApiSubmittedInfo.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "AuditApiProgram.h"
#import "AuditApiProduct.h"
#import "AuditApiProductRatings.h"
#import "AuditApiImages.h"
#import "AuditApiContainerRating.h"
#import "AuditApiDuplicate.h"

@interface AuditApiSubmittedInfo : JSONModel

@property (nonatomic, strong) AuditApiProgram *program;
@property (nonatomic, strong) AuditApiProduct *product;
//@property (nonatomic, assign) AuditApiProductRatings *productRatings;
@property (nonatomic, strong) NSArray<AuditApiRating>* productRatings;
@property (nonatomic, strong) NSArray<AuditApiContainerRating>* containerRatings;
@property (nonatomic, strong) AuditApiDuplicate *duplicates;

@end
