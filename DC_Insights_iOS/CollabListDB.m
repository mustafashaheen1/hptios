//
//  CollabListDB.m
//  Insights
//
//  Created by Vineet on 11/15/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "CollabListDB.h"
#import "NSUserDefaultsManager.h"
#import "Constants.h"

@implementation CollabListDB

-(void)saveList:(NSArray*)inspectionList {
    if(inspectionList && [inspectionList count]>0)
        [NSUserDefaultsManager saveObjectToUserDefaults:inspectionList withKey:COLLABORATIVE_LIST_RESPONSE];
}

-(NSArray*)getList {
    NSArray* savedList = (NSArray*)[NSUserDefaultsManager getObjectFromUserDeafults:COLLABORATIVE_LIST_RESPONSE];
    return savedList;
}

@end
