//
//  HPTCaseCode.m
//  Insights
//
//  Created by Mustafa Shaheen on 6/18/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "HPTCaseCode.h"

@implementation HPTCaseCode

-(BOOL) validate{
    if(self.quantity <= 0){
        return NO;
    }
    return YES;
}
@end
