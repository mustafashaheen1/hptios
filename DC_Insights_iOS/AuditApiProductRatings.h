//
//  AuditApiProductRatings.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "AuditApiRating.h"

@interface AuditApiProductRatings : JSONModel

@property (nonatomic, assign) NSArray<AuditApiRating>* defects;

@end

