//
//  AuditApiRating.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "AuditApiDefect.h"

@protocol AuditApiRating
@end

@interface AuditApiRating : JSONModel

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString* value;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSArray<AuditApiDefect>* defects;

@end


