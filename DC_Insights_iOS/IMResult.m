//
//  IMResult.m
//  Insights
//
//  Created by Vineet on 3/1/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "IMResult.h"

@implementation IMResult

int const REQUIRED = 0;
int const RECOMMENDED = 1;

-(IMResult*)getResultWithPass:(BOOL)isPass isRequiredOrRecommended:(int)isRequiredOrRecommended withCount:(NSInteger)count withUnit:(NSString*)unit{
    NSString* requiredOrRecommendedString = @"required";
    if(!isPass){
        self.isPass = NO;
        self.requiredOrRecommended = isRequiredOrRecommended;
        if(self.requiredOrRecommended == REQUIRED)
            requiredOrRecommendedString = @"required";
         if(self.requiredOrRecommended == RECOMMENDED)
             requiredOrRecommendedString = @"recommended";
        self.message = [NSString stringWithFormat:@"%ld%@ inspections are %@",count,unit,requiredOrRecommendedString];
    }else{
        self.isPass = YES;
        self.requiredOrRecommended = -1;
        self.message =  @"default";
    }
    return self;
}

@end
