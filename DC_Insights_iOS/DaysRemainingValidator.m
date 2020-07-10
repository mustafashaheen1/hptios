//
// Created by Vineet on 7/9/18.
// Copyright (c) 2018 Yottamark. All rights reserved.
//

#import "DaysRemainingValidator.h"


@implementation DaysRemainingValidator


- (id)init {
    self = [super init];
    if (self) {
        self.dateRating = [[Rating alloc] init];
        self.product = [[Product alloc]init];
    }
    return self;
}

-(id) initWithRating:(Rating*)rating withProduct:(Product *)product{
    self = [super init];
    if (self) {
        self.dateRating = rating;
        self.product = product;
    }
    return self;
}

-(BOOL) isCheckRequiredForRating {
    //read DB and check if validation required
    if(self.dateRating && [self.dateRating.type isEqualToString:DATE_RATING]){
        DateRatingModel *dateModel = self.dateRating.content.dateRatingModel;
        if(dateModel && dateModel.isDaysRemainingValidation)
            return YES;
    }
    return NO;
}

-(BOOL) isValidForMinimumDays {
    int daysRemaining = (int)self.product.daysRemaining;
    int differenceFromToday = [self dateDifferenceFromToday];
    NSLog(@"Insights - Minimum: daysRemaining :%d, differenceFromToday: %d",daysRemaining,differenceFromToday);
    if(daysRemaining>0 &&
       differenceFromToday>=0 &&
       differenceFromToday < daysRemaining)
        return NO;

    return YES;
}

-(BOOL) isValidForMaximumDays {
    
    int daysRemainingMax = (int)self.product.daysRemainingMax;
    int differenceFromToday = [self dateDifferenceFromToday];
    NSLog(@"Insights - Maximum: daysRemainingMax :%d, differenceFromToday: %d",daysRemainingMax,differenceFromToday);
    if(daysRemainingMax>0 &&
       differenceFromToday>=0 &&
       differenceFromToday > daysRemainingMax)
        return NO;
    
    return YES;
}

-(int) dateDifferenceFromToday {
    NSString* dateRatingValue = self.dateRating.ratingAnswerFromUI;
    if(!dateRatingValue || [dateRatingValue isEqualToString:@""])
        return -1;
    
    NSString *dateString = dateRatingValue;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSDate *userInputDate = [dateFormatter dateFromString:dateString];
    NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter dateFromString:currentDateString];
  
    NSTimeInterval secondsBetween = [userInputDate timeIntervalSinceDate:currentDate];
    int numberOfDays = secondsBetween / 86400;
    return numberOfDays;
}


-(NSString*)getDateRange {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSDate* date = [NSDate date];
  
    int daysRemaining = (int)self.product.daysRemaining;
    NSDate* dateForMin = [self addDays:daysRemaining toDate:date];
    NSString* dateStringForMin = [dateFormatter stringFromDate:dateForMin];
    
    int daysRemainingMax = (int)self.product.daysRemainingMax;
    NSDate* dateForMax = [self addDays:daysRemainingMax toDate:date];
    NSString* dateStringForMax = [dateFormatter stringFromDate:dateForMax];
    
    NSString* dateRange = [NSString stringWithFormat:@"%@ - %@",dateStringForMin,dateStringForMax];
    
    NSLog(@"date Range is: %@ ",dateRange);
    return dateRange;
}
//
//-(NSDate*)getDateFromTodayWithDifference:(int)days {
//    //get date based on today +/- days
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
//    [dateFormatter setLocale:[NSLocale currentLocale]];
//
//}


-(NSDate *)addDays:(NSInteger)days toDate:(NSDate *)originalDate {
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setDay:days];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:originalDate options:0];
}

@end
