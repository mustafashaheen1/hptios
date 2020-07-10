//
//  RatingViewManager.h
//  Insights
//
//  Created by Vineet Pareek on 12/4/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RatingViewManager : NSObject

@property NSArray* navBarLeftItems;
@property NSArray* navBarRightItems;
@property NSString* productName;
@property BOOL leftArrowEnabled;
@property BOOL rightArrowEnabled;
@property int auditCount;
@property NSArray* productsArray;

@end
