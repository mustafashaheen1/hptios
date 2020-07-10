//
//  CEResposeStatus.h
//  Insights
//
//  Created by Vineet Pareek on 2/11/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface CEResposeStatus : JSONModel

@property NSString* message;
@property BOOL success;
@property BOOL valid;
@property NSString* clws_status;

@end
