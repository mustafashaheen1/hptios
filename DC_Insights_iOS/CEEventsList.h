//
//  CEEventsList.h
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "CEEvent.h"

@interface CEEventsList : JSONModel

@property NSMutableArray<CEEvent>* events;

@end
