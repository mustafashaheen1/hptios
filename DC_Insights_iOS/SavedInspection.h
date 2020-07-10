//
//  SavedInspection.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedInspection : NSObject

@property (nonatomic, strong) NSString *inspectionName;
@property (nonatomic, assign) int auditsCount;
@property (nonatomic, strong) NSString *auditMasterId;

@end
