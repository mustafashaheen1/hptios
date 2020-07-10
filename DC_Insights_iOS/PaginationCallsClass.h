//
//  PaginationCallsClass.h
//  Insights
//
//  Created by Shyam Ashok on 1/9/15.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"

@interface PaginationCallsClass : DCBaseEntity

@property (assign, nonatomic) int limit;
@property (assign, nonatomic) int pageNo;
@property (assign, nonatomic) int minimumNumberOfCalls;
@property (strong, nonatomic) NSString *apiCallString;
@property (strong, nonatomic) NSString *appendJSON;
@property (strong, nonatomic) NSString *apiCallFilePath;
@property (strong, nonatomic) NSMutableArray *results;

- (void)callWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;

@end
