//
//  HPTInspectionApi.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/24/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "HPTAddress.h"
#import "DCBaseEntity.h"
#import "JSONModel.h"
#import "HPTCaseCodeModel.h"

@interface HPTInspectionApi : JSONModel
@property (nonatomic, strong) NSMutableArray *ratings;
@property (nonatomic, strong) NSMutableArray *ptiCodes;
@property (atomic, strong) HPTAddress *toAddress;
@property (atomic, strong) HPTAddress *fromAddress;
@property (atomic, strong) NSString *sscc;


@end

