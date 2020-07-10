//
//  HPTCaseCode.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/18/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HPTCaseCode : NSObject
@property (atomic, strong) NSString *caseCode;
@property (atomic, strong) NSString *gtin;
@property (atomic, strong) NSString *prefixType;
@property (atomic, strong) NSString *date;
@property (atomic, strong) NSString *lotNumber;
@property (atomic, assign) int quantity;

-(BOOL) validate;
@end
