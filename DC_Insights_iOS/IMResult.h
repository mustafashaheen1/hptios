//
//  IMResult.h
//  Insights
//
//  Created by Vineet on 3/1/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMResult : NSObject

@property (atomic, assign) BOOL isPass;
@property (atomic, assign) int requiredOrRecommended;
@property (atomic, strong) NSString* message;
@property (atomic, assign) int count;
@property (atomic, assign) int type;


extern int const REQUIRED;
extern int const RECOMMENDED;

-(IMResult*)getResultWithPass:(BOOL)isPass isRequiredOrRecommended:(int)isRequiredOrRecommended withCount:(NSInteger)count withUnit:(NSString*)unit;

@end
