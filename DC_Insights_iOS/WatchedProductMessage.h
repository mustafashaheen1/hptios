//
//  WatchedProductMessage.h
//  Insights
//
//  Created by Vineet on 10/18/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol WatchedProductMessage

@end

@interface WatchedProductMessage : JSONModel

@property (atomic, strong) NSString* type;
@property (atomic, strong) NSString* value;

@end
