//
//  ApplyToAllViewModel.m
//  Insights
//
//  Created by Vineet on 9/26/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "ApplyToAllViewModel.h"
#import "Program.h"
#import "User.h"
#import "ApplyToAllFinishInspection.h"

#define RATING_ID_APPLYALL_STATUS -99999
#define RATING_ID_APPLYALL_COUNT -99998



@implementation ApplyToAllViewModel

-(void)initRatings {

}

-(NSArray*) getAllRatings {
    if(!self.ratings || [self.ratings count]==0){
        NSMutableArray* staticRatings = [[self getStaticRatings] mutableCopy];
        NSMutableArray* programRatings = [[self getProgramRatings] mutableCopy];
        self.ratings = [staticRatings arrayByAddingObjectsFromArray:programRatings];
    }
    return self.ratings;
}

-(NSArray*)getProgramRatings {
    NSArray *programRatings = [[NSArray alloc]init];
    NSArray* allPrograms = [[User sharedUser] getProgramsForUser];
    //for dc - assumption is only 1 program
    if(allPrograms && [allPrograms count]>0){
    Program *program = [allPrograms objectAtIndex:0];
        ApplyToAll *applyToAll = program.apply_to_all;
        programRatings = applyToAll.ratings;
    }
    return programRatings;
}

-(NSArray*) getStaticRatings {
    Rating *inspectionStatusRating = [self getInspectionStatusRating];
    Rating *countRating = [self getCountRating];
    NSArray *staticRatings = [[NSArray alloc]initWithObjects:inspectionStatusRating,countRating, nil];
    return staticRatings;
}

-(Rating*) getInspectionStatusRating {
    Rating *rating = [[Rating alloc]init];
    rating.type = COMBO_BOX_RATING;
    rating.name = @"Inspection Status";
    rating.displayName = @"Inspection Status";
    Content *content = [[Content alloc]init];
    ComboRatingModel *ratingModel = [[ComboRatingModel alloc]init];
    ratingModel.comboItems = [[NSArray alloc]initWithObjects:@"Accept", @"Accept With Issues", @"Reject", nil];
    rating.content = content;
    rating.content.combo_items = [[NSMutableArray alloc]initWithObjects:@"Accept", @"Accept With Issues", @"Reject", nil];;
    return rating;
}

-(Rating*) getCountRating {
    Rating *rating = [[Rating alloc]init];
    rating.type = TEXT_RATING;
    rating.name = @"Sample Count";
    rating.displayName = @"Sample Count";
   // PriceRatingModel* ratingModel = [[PriceRatingModel alloc]init];
    //ratingModel.price_items = [[NSArray alloc]initWithObjects:@"#",@"%", nil];
   // rating.content.priceRatingModel = ratingModel;
    return rating;
}

-(Rating*) getDefectRating {
    NSArray* programRatings = [self getProgramRatings];
    for(Rating* rating in programRatings){
        if([rating.type isEqualToString:COMBO_BOX_RATING]){
            return rating;
        }
    }
    return nil;
}

-(Rating*) getCommentsRating {
    NSArray* programRatings = [self getProgramRatings];
    for(Rating* rating in programRatings){
        if([rating.type isEqualToString:TEXT_RATING]){
            return rating;
        }
    }
    return nil;
}

-(void) completeApplyToAll {
    ApplyToAllFinishInspection *finishInspection = [[ApplyToAllFinishInspection alloc]init];
    finishInspection.allProductList = self.allProductList;
    finishInspection.applyToAllModel = self;
    [finishInspection save];
}

-(Result*)validateRatings {
    Result* result = [[Result alloc]init];


    return result;
}




@end
