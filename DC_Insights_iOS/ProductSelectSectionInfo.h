//
//  ProductSelectSectionInfo.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/19/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductSelectSectionHeader;
@class RatingSelectSectionHeader;
@class ProgramGroup;
@class Product;
@class Defect;

@interface ProductSelectSectionInfo : NSObject

@property (getter = isOpen) BOOL open;
@property ProductSelectSectionHeader *headerView;
@property RatingSelectSectionHeader *headerViewRating;
@property ProgramGroup *programGroup;
@property Product *product;
@property Defect *defect;
@property NSString *name;
@property (nonatomic) NSMutableArray *rowHeights;

- (NSUInteger)countOfRowHeights;
- (id)objectInRowHeightsAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx;
- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject;
- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes;
- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray;

@end
