//
//  CollaborativeAPIResponse.m
//  Insights
//
//  Created by Vineet Pareek on 23/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "CollaborativeAPIResponse.h"

@implementation CollaborativeAPIResponse

- (id)init
{
    self = [super init];
    if (self) {
        self.store_id = 0;
        self.po = @"";
        self.status = 0;
        self.product_id = 0;
        self.user_id = @"";
    }
    return self;
}
/*
- (BOOL)isEqual:(id)object {
    CollaborativeAPIResponse *copy = (CollaborativeAPIResponse *) object;
    if (self == copy)
        return true;
    if (![super isEqual:copy])
        return false;
    if ([self class] != [copy class])
        return false;
    if([self.po isEqualToString:copy.po] && self.product_id ==copy.product_id) {
        return true;
    }
    else
        return false;
}*/

+(NSMutableArray*)parseJSONArrayToModelArray:(NSArray*)jsonArray {
    NSMutableArray<CollaborativeAPIResponse*>* modelArray = [[NSMutableArray alloc]init];
    for(NSMutableDictionary* object in jsonArray){
        NSError *err = nil;
        CollaborativeAPIResponse* product = [[CollaborativeAPIResponse alloc]initWithDictionary:object error:&err];
        [modelArray addObject:product];
    }
    return modelArray;
}

@end
