//
//  CEEvent.h
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "CEEventAttribute.h"

@protocol CEEvent
@end

@interface CEEvent : JSONModel

@property NSString* name;
@property NSString* date;
@property NSMutableArray<CEEventAttribute>* attributes;

@end
