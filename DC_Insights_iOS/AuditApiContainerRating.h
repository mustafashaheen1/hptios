//
//  AuditApiContainerRating.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "AuditApiDefect.h"

@protocol AuditApiContainerRating
@end

@interface AuditApiContainerRating : JSONModel

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger container_id;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSArray<AuditApiDefect>* defects;
@end
