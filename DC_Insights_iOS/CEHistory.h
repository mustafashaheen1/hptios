//
//  CEHistory.h
//  Insights
//
//  Created by Vineet Pareek on 19/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol CEHistory
@end

@interface CEHistory : JSONModel

@property NSString* date;
@property NSString* hmCode;
@property NSString* productName;


@end
