//
//  IMConfig.h
//  Insights
//
//  Created by Vineet on 2/12/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMConfigValues.h"
#import "JSONModel.h"

@interface IMConfig : JSONModel
@property (atomic, strong) IMConfigValues *required;
@property (atomic, strong) IMConfigValues *recommended;
@end
