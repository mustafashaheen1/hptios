//
//  AuditApiSeverity.h
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 11/1/19.
//  Copyright © 2019 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@protocol AuditApiSeverity
@end

@interface AuditApiSeverity : JSONModel

@property (nonatomic, strong) NSString *severity;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) float numerator;
@property (nonatomic, assign) float denominator;
@property (nonatomic, assign) float percentage;


@end
