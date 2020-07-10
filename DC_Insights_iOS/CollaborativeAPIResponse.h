//
//  CollaborativeAPIResponse.h
//  Insights
//
//  Created by Vineet Pareek on 23/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface CollaborativeAPIResponse : JSONModel

@property (nonatomic, strong) NSString *po;
@property (nonatomic, assign) int product_id;
@property (nonatomic, assign) int status;
@property (nonatomic, assign) int store_id;
@property (nonatomic, strong) NSString *user_id;

+(NSMutableArray*)parseJSONArrayToModelArray:(NSArray*)jsonArray;

@end
