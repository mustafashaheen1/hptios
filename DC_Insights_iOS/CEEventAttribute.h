//
//  CEEventAttribute.h
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@protocol CEEventAttribute
@end

@interface CEEventAttribute : JSONModel

@property NSString* name;
//@property NSString* value;
@property NSMutableArray<NSString *>* value;

//get height when rendering
-(double)getHeightWithFont:(UIFont*)font withFrameWidth:(double)width;

@end
