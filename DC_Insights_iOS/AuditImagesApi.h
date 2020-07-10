//
//  AuditImagesApi.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface AuditImagesApi : JSONModel

@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSString * audit_id;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSString * image_base64;

@end
