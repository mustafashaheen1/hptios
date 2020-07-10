//
//  HPTAddress.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/18/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HPTAddress : NSObject
@property (atomic, strong) NSString *companyName;
@property (atomic, strong) NSString *streetAddress;
@property (atomic, strong) NSString *city;
@property (atomic, strong) NSString *state;
@property (atomic, strong) NSString *zip;
@property (atomic, strong) NSString *country;
@property (atomic, strong) NSString *gln;
@end
