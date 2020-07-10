//
//  Device.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/5/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *updateMethod;
@property (nonatomic, assign) BOOL deviceEnabled;

@end
