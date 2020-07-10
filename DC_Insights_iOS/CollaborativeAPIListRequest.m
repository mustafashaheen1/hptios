//
//  CollaborativeAPIRequest.m
//  Insights
//
//  Created by Vineet Pareek on 16/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "CollaborativeAPIListRequest.h"

@implementation CollaborativeAPIListRequest

- (id)init
{
    self = [super init];
    if (self) {
        self.po_numbers = [[NSMutableArray<NSString*> alloc]init];
        self.program_id = 0;
        self.store_id = 0;
        self.device_id = @"";
        self.auth_token = @"";
    }
    return self;
}


@end
