//
//  ProductViewModel.h
//  Insights
//
//  Created by Vineet on 10/3/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InspectionMinimumsAPI.h"
#import "Inspection.h"

@interface ProductViewModel : NSObject

-(InspectionMinimums*) getRequiredSampleCountWithGroupId:(int)groupId;

@end

