//
//  PaginationCallsClass.m
//  Insights
//
//  Created by Shyam Ashok on 1/9/15.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import "PaginationCallsClass.h"

@implementation PaginationCallsClass


#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.results = [[NSMutableArray alloc] init];
    }
    return self;
}

/// Call Ratings

- (void) callWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    self.pageNo = self.pageNo + 1;
    NSMutableDictionary *localStoreCallParamaters = [[self paramtersFortheGETCall] mutableCopy];
    [localStoreCallParamaters setObject:[NSString stringWithFormat:@"%d", self.pageNo] forKey:@"page_number"];
    [localStoreCallParamaters setObject:[NSString stringWithFormat:@"%d", self.limit] forKey:@"page_size"];
    [[AFAppDotNetAPIClient sharedClient] getPath:self.apiCallString parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
        [self.results addObjectsFromArray:JSON];
        int countResults = self.pageNo * self.limit;
        NSLog(@"Call %@ %d page %d", self.apiCallString, [self.results count], self.pageNo);
        if ([self.results count] >= countResults) {
            [self callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error){
                if (block) {
                    block(YES, self.results, nil);
                }
            }];
        } else {
            [self writeDataToFile:self.apiCallFilePath withContents:self.results];
            if (block) {
                block(YES, self.results, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, nil, nil);
        }
    }];
}

- (void) call2WithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i < self.minimumNumberOfCalls; i++) {
        dispatch_group_enter(group);
        self.pageNo = self.pageNo + 1;
        NSMutableDictionary *localStoreCallParamaters = [[self paramtersFortheGETCall] mutableCopy];
        [localStoreCallParamaters setObject:[NSString stringWithFormat:@"%d", self.pageNo] forKey:@"page_number"];
        [localStoreCallParamaters setObject:[NSString stringWithFormat:@"%d", self.limit] forKey:@"page_size"];
        [[AFAppDotNetAPIClient sharedClient] getPath:self.apiCallString parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
            dispatch_group_leave(group);
            [self.results addObjectsFromArray:JSON];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_group_leave(group);
            if (block) {
                block(NO, nil, nil);
            }
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"Call %@ %d", self.apiCallString, [self.results count]);
        int countResults = self.pageNo * self.limit;
        if ([self.results count] >= countResults) {
            [self callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error){
                if (block) {
                    block(YES, self.results, nil);
                }
            }];
        } else {
            [self writeDataToFile:self.apiCallFilePath withContents:self.results];
            if (block) {
                block(YES, self.results, nil);
            }
        }
    });
}

@end
