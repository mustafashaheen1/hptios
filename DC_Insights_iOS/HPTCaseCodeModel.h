//
//  HPTCaseCodeModel.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/18/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"
#import "JSONMOdel.h"
#import "DCBaseEntity.h"
#import "HPTAddress.h"
#import "Store.h"
@interface HPTCaseCodeModel : DCBaseEntity<NSCopying>
@property (nonatomic, strong) NSMutableArray *ratings;
@property (nonatomic, strong) NSMutableArray *caseCodes;
@property (atomic, strong) HPTAddress *toAddress;
@property (atomic, strong) NSString *sscc;
-(NSArray *) getAllRatings;
-(void)setValuesFromViews: (NSArray *) tempRatings;
-(HPTAddress *) convert: (Store *) store;
-(void) setValuesFromViews: (NSArray *) tempRatings: (NSArray *) caseCodeList: (HPTAddress *) toAddress: (NSString *) sscc;
@end
