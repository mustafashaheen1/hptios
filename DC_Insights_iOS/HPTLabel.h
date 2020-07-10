//
//  HPTLabel.h
//  Insights
//
//  Created by Mustafa Shaheen on 7/7/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTAddress.h"
#import "SSCCLabel.h"
@interface HPTLabel : NSObject
@property (nonatomic, strong) NSMutableArray *ptiLabels;
@property (atomic, strong) HPTAddress *toAddress;
@property (atomic, strong) HPTAddress *fromAddress;
@property (atomic, strong) SSCCLabel *sscc;
@end

