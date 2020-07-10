//
//  InspectionStatus.h
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 9/5/19.
//  Copyright © 2019 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InspectionStatus : NSObject

@property (nonatomic, strong) NSMutableArray *allInspectionStatuses;
@property (nonatomic, strong) NSMutableArray *allDefaultStatuses;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSMutableArray *allIds;
@property (nonatomic, strong) NSMutableArray *defaultIds;
-(void) getAllStatuses: (int) programId: (NSString*) inspectionType;
-(void) getAllStatuses: (NSString*) inspectionType;
@end

NS_ASSUME_NONNULL_END
