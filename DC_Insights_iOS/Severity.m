//
//  Severity.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/2/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Severity.h"
#import "Product.h"

@implementation Severity

@synthesize name;
@synthesize order_position;
@synthesize isSelected;
@synthesize inputNumerator;
@synthesize inputDenominator;
@synthesize inputOrCalculatedPercentage;
@synthesize criteriaAcceptWithIssues;
@synthesize criteriaReject;
@synthesize thresholdTotal;
@synthesize thresholdAcceptWithIssues;
//public String toString() {
//    return "Severity [name=" + name + ", order_position=" + order_position
//    + ", isSelected=" + isSelected + ", inputNumerator="
//    + inputNumerator + ", inputDenominator=" + inputDenominator
//    + ", inputOrCalculatedPercentage="
//    + inputOrCalculatedPercentage + ", criteriaAcceptWithIssues="
//    + criteriaAcceptWithIssues + ", criteriaReject="
//    + criteriaReject + ", thresholdTotal=" + thresholdTotal + "]";
//}

- (BOOL)isEqual:(id)object {
    Severity *copy = (Severity *) object;
//    if (self == copy)
//        return true;
//    if (![super isEqual:copy])
//        return false;
//    if ([self class] != [copy class])
//        return false;
    if(self.id == copy.id) {
        return true;
    }
    else
        return false;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    NSInteger copy = self.id;
    result = prime * result + copy;
    return result;
}

- (void) addPercentage: (double) percentage {
    self.inputOrCalculatedPercentage += percentage;
}

- (void) populateSeverityWithCriteria: (id) productWithReferenceData withRatingId:(int) ratingId withDefectId:(int) defectId {
    Product *productLocal = (Product *)productWithReferenceData;
    NSArray *allRatings = productLocal.ratings;
    Defect *defect = [[Defect alloc] init];
    defect.defectID = defectId;
    for (Rating *rating in allRatings) {
        for (int i = 0; i < [rating.defects count]; i++) {
            Defect *defectLocal = [rating.defects objectAtIndex:i];
            if (defectLocal.defectID == defect.defectID) {
                Defect *refDefect = [rating.defects objectAtIndex:i];
                NSArray *severities = refDefect.severities;
                for (Severity *severity in  severities) {
                    if ([self.name isEqualToString:severity.name]) {
                        self.id = severity.id;
                        self.thresholdTotal = severity.thresholdTotal;
                        self.criteriaAcceptWithIssues = severity.criteriaAcceptWithIssues;
                        self.criteriaReject = severity.criteriaReject;
                        self.thresholdAcceptWithIssues = severity.thresholdAcceptWithIssues;
                    }
                }
            }
        }
    }
}


@end
