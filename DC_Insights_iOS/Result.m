//
//  Result.m
//  Insights
//
//  Created by Vineet on 10/3/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "Result.h"

@implementation Result

-(id)init {
    self = [super init];
    if(self){
        self.message = @"";
        self.success = YES;
    }
    return self;
}

@end
