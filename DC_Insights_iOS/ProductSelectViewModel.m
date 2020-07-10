//
//  ProductSelectViewModel.m
//  Insights
//
//  Created by Vineet on 9/26/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "ProductSelectViewModel.h"
#import "User.h"

@implementation ProductSelectViewModel

//to check if need to show apply to all button
-(BOOL)isApplyToAllActive {
    return [[User sharedUser] isApplyToAllActiveForUserProgram];
}

@end
