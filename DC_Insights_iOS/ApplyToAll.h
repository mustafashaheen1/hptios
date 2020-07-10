//
//  ApplyToAll.h
//  Insights
//
//  Created by Vineet on 9/26/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rating.h"
#import "JSONModel.h"


@interface ApplyToAll : JSONModel

@property (nonatomic,strong) NSMutableArray<Rating> *ratings;
@property (nonatomic,assign) BOOL active;

-(ApplyToAll*) initFromJSONDictionary:(NSDictionary*)dataMap;
-(ApplyToAll*) initFromJSONString:(NSString*)data;
@end

