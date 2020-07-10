//
//  CollaborativeAPISaveRequest.h
//  Insights
//
//  Created by Vineet Pareek on 20/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "JSONModel.h"

//api/inspections/save

@interface CollaborativeAPISaveRequest : JSONModel

@property (atomic,strong) NSMutableArray<NSNumber*> *product_ids;
@property (atomic, assign) int program_id;
@property (atomic, assign) int store_id;
@property (atomic, strong) NSString *po;
@property (atomic, assign) int status;
@property (atomic, strong) NSString *user_id;
@property (atomic, strong) NSString *device_id;
@property (atomic, strong) NSString *auth_token;

@end
