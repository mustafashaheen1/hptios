//
//  CompletedScanout.h
//  Insights
//
//  Created by Vineet Pareek on 11/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rating.h"
#import "Audit.h"

@interface CompletedScanout : NSObject

@property (nonatomic, strong) NSString *date;
@property (nonatomic, assign) int countOfCases;
@property (nonatomic, assign) int imageCount;
@property (nonatomic, strong) NSMutableArray<Rating*> *ratingArray;


-(void)populateFromAudit:(Audit*)audit;

@end
