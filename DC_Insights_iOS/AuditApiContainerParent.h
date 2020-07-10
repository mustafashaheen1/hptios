//
//  AuditApiContainerParent.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "AuditApiContainerRating.h"


@protocol AuditApiContainerParent
@end

@interface AuditApiContainerParent : JSONModel

@property (nonatomic, strong) NSArray<AuditApiContainerRating>* containerRatings;

@end
