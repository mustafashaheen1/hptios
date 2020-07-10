//
//  IMConfigValues.h
//  Insights
//
//  Created by Vineet on 2/12/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface IMConfigValues : JSONModel
@property (nonatomic, assign) NSInteger accept;
@property (nonatomic, assign) NSInteger acceptWithIssues;
@property (nonatomic, assign) NSInteger reject;

@end
