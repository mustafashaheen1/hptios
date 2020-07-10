//
//  Severity.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/2/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Severity : NSObject

@property (nonatomic, assign) int id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int order_position;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) float inputNumerator;
@property (nonatomic, assign) float inputDenominator;
@property (nonatomic, assign) float inputOrCalculatedPercentage;
@property (nonatomic, assign) float criteriaAcceptWithIssues;
@property (nonatomic, assign) float criteriaReject;
@property (nonatomic, assign) float thresholdTotal;
@property (nonatomic, assign) float thresholdAcceptWithIssues;
- (void) addPercentage: (double) percentage;
- (void) populateSeverityWithCriteria: (id) productWithReferenceData withRatingId:(int) ratingId withDefectId:(int) defectId;

@end
