//
//  CEResponse.h
//  Insights
//
//  Created by Vineet Pareek on 17/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "CEEvent.h"
#import "CEProduct.h"
#import "CEEventsList.h"
#import "CEResposeStatus.h"

@interface CEResponse : JSONModel

@property NSString* code;
@property CEProduct* product;
@property NSMutableArray<CEEvent>* events;
@property CEResposeStatus *response_status;

@end
