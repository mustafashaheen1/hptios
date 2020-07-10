//
//  ApplyToAllFinishInspection.h
//  Insights
//
//  Created by Vineet on 10/2/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductListItem.h"
#import "ApplyToAllViewModel.h"

@interface ApplyToAllFinishInspection : NSObject

@property (nonatomic, strong) NSArray<ProductListItem*> *allProductList;
@property (strong, nonatomic) ApplyToAllViewModel* applyToAllModel;


-(void) save;


@end

