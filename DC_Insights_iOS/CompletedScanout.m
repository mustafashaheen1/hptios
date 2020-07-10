//
//  CompletedScanout.m
//  Insights
//
//  Created by Vineet Pareek on 11/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "CompletedScanout.h"

@implementation CompletedScanout

- (id)init
{
    self = [super init];
    if (self) {
        self.date = @"";
        self.ratingArray = [[NSMutableArray<Rating*> alloc] init];
        self.countOfCases = 0;
        self.imageCount = 0;
    }
    return self;
}

-(void)populateFromAudit:(Audit*)audit{
    Audit* auditFromXML = audit;
    //date
    self.date = [self populateStartDateFromXML:auditFromXML];
    
    //populate array of Ratings
    self.ratingArray = [self populateArrayOfRatingsFromXML:auditFromXML];
    
    //number of cases
    // go thru ratings, find the one with HMCODES, find the number of cases (comma separated strings)
    for(Rating* rating in self.ratingArray){
        if([rating.name containsString:@"HMCODES"]){
            NSString* value = rating.value; //comma separated case codes
            NSArray *items = [value componentsSeparatedByString:@","];
            self.countOfCases = (int)[items count];
        }
    }
}

-(NSMutableArray*)populateArrayOfRatingsFromXML:(Audit*)auditFromXML{
    //create array of container Ratings from audit
    NSArray* containerRatingsFromXML = auditFromXML.auditData.submittedInfo.containerRatings;
    NSMutableArray<Rating*> *arrayOfContainerRatings = [[NSMutableArray alloc]init];
    
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    for(AuditApiContainerRating* rating in containerRatingsFromXML){
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_RATINGS, COL_ID, rating.id]];
        while ([results next]) {
            Rating *ratingObject = [[Rating alloc] init];
            ratingObject.name = [results stringForColumn:COL_NAME];
            ratingObject.displayName = [results stringForColumn:COL_DISPLAY_NAME];
            ratingObject.ratingID = rating.id;
            ratingObject.value = rating.value;
            [arrayOfContainerRatings addObject:ratingObject];
        }
    }
    return arrayOfContainerRatings;
}

-(NSString*)populateStartDateFromXML:(Audit*)auditFromXML {
    NSString* startDate = auditFromXML.auditData.audit.start;
    double dateInMillis = [startDate doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateInMillis/ 1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"dd-MMM-yy"];;
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    return  stringFromDate;
}

@end
