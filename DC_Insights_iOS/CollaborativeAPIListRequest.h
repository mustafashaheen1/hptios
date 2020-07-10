//
//  CollaborativeAPIRequest.h
//  Insights
//
//  Created by Vineet Pareek on 16/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "JSONModel.h"

//api/inspections/list

@interface CollaborativeAPIListRequest : JSONModel

@property (atomic,strong) NSMutableArray<NSString*> *po_numbers;
@property (atomic, assign) int program_id;
@property (atomic, assign) int store_id;
@property (atomic, strong) NSString *device_id;
@property (atomic, strong) NSString *auth_token;

@end
