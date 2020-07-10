//
//  ApplyToAllViewModel.h
//  Insights
//
//  Created by Vineet on 9/26/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rating.h"
#import "ProductListItem.h"
#import "Result.h"

#define SAMPLE_COUNT_NUMBER  0
#define SAMPLE_COUNT_PERCENTAGE 1

@interface ApplyToAllViewModel : NSObject

@property (strong, nonatomic) NSMutableArray* ratings;
@property (nonatomic, strong) NSArray<ProductListItem*> *allProductList;

-(void)initRatings;
-(NSArray*) getAllRatings;
-(void) completeApplyToAll;
-(Result*)validateRatings;
-(NSArray*)getProgramRatings;
/*
 -getInspectionStatusValues
 -getDefectsRating

 */

@end


