//
//  IMRange.m
//  Insights
//
//  Created by Vineet on 2/12/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "IMRange.h"
#import "DBConstants.h"


@implementation IMRange
int MINIMUMS_BY_COUNT = 0;
int MINIMUMS_BY_PRECENTAGE = 1;

-(IMResult*)getResultForCount:(float)countOrPercentage
         withInspectionStatus:(NSString*)inspStatus statusBy:(int)statusBy{
    NSString* unit = @"";
    if(statusBy == MINIMUMS_BY_PRECENTAGE)
        unit = @"%";
    
    if(self.configuration){
        IMConfigValues* required =  self.configuration.required;
         IMConfigValues* recommended =  self.configuration.recommended;
        
        NSInteger requiredValue = 0;
        NSInteger recommendedValue = 0;
        if(inspStatus && [inspStatus caseInsensitiveCompare:INSPECTION_STATUS_ACCEPT]==NSOrderedSame){
            requiredValue = required.accept;
            recommendedValue = recommended.accept;
        }else if(inspStatus && [inspStatus caseInsensitiveCompare:INSPECTION_STATUS_ACCEPT_WITH_ISSUES]==NSOrderedSame){
            requiredValue = required.acceptWithIssues;
            recommendedValue = recommended.acceptWithIssues;
        }else if(inspStatus && [inspStatus caseInsensitiveCompare:INSPECTION_STATUS_REJECT]==NSOrderedSame){
            requiredValue = required.reject;
            recommendedValue = recommended.reject;
        }
        
        //return result
        if(countOrPercentage>=0 && countOrPercentage < requiredValue){
            IMResult* result = [[IMResult alloc]init];
            result.count = requiredValue;
            result.type = REQUIRED;
            return [result getResultWithPass:NO isRequiredOrRecommended:REQUIRED withCount:requiredValue withUnit:unit];
        }else if(countOrPercentage>=0 && countOrPercentage >=requiredValue && countOrPercentage < recommendedValue){
            IMResult* result = [[IMResult alloc]init];
            result.count = recommendedValue;
            result.type = RECOMMENDED;
            return [result getResultWithPass:NO isRequiredOrRecommended:RECOMMENDED withCount:recommendedValue withUnit:unit];
        }else{
            IMResult* result = [[IMResult alloc]init];
            result.count = 0;
            return [result getResultWithPass:YES isRequiredOrRecommended:-1 withCount:0 withUnit:@""];
            return result;
        }
    }
    IMResult* result = [[IMResult alloc]init];
    return [result getResultWithPass:YES isRequiredOrRecommended:-1 withCount:0 withUnit:@""];
    return result;
}



@end
