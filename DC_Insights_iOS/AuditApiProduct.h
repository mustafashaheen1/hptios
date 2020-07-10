//
//  AuditApiProduct.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface AuditApiProduct : JSONModel

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString *itemNumber;
//@property (nonatomic, strong) NSString *score;
@property (nonatomic, assign) NSInteger orderDataId;//ID;

@end

