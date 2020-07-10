//
//  IMRange.h
//  Insights
//
//  Created by Vineet on 2/12/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMConfig.h"
#import "IMResult.h"
#import "JSONModel.h"

@protocol IMRange
@end

@interface IMRange : JSONModel
@property (atomic, assign) int from;
@property (atomic, assign) int to;
@property (atomic, assign) int minimums_by;
@property (atomic, strong) IMConfig *configuration;

extern int MINIMUMS_BY_COUNT;
extern int MINIMUMS_BY_PRECENTAGE;

-(IMResult*)getResultForCount:(float)countOrPercentage withInspectionStatus:(NSString*)inspStatus statusBy:(int)statusBy;


@end
