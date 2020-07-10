//
//  CollaborativeAPISaveRequest.m
//  Insights
//
//  Created by Vineet Pareek on 20/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "CollaborativeAPISaveRequest.h"

@implementation CollaborativeAPISaveRequest


- (id)init
{
    self = [super init];
    if (self) {
        self.product_ids = [[NSMutableArray<NSNumber*> alloc]init];
        self.program_id = 0;
        self.store_id = 0;
        self.po = @"";
        self.status = 0;
        self.device_id=@"";
        self.auth_token=@"";
        self.user_id=@"";
    }
    return self;
}

@end
