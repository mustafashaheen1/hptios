//
//  CEHistoryList.m
//  Insights
//
//  Created by Vineet Pareek on 20/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEHistoryList.h"
#import "NSUserDefaultsManager.h"
#import "Constants.h"

#define MAX_HISTORY_ITEMS 50

@implementation CEHistoryList

- (id)init
{
    self = [super init];
    if (self) {
        self.historyList = [[NSMutableArray<CEHistory> alloc] init];
    }
    return self;
}

-(void)saveToPrefs:(CEHistory*)historyObject{
    [self deleteOlderItems];
    CEHistoryList *history = [self getAllHistoryFromPrefs];
    
    //do not save if the last trace is the same code
    if(history.historyList && history.historyList.count >0){
        CEHistory* latestObject = [history.historyList objectAtIndex:0];
        if([historyObject.hmCode isEqualToString:latestObject.hmCode])
            return;
    }
    [history.historyList insertObject:historyObject atIndex:0];
    NSString* historyString = [history toJSONString];
    [NSUserDefaultsManager saveObjectToUserDefaults:historyString withKey:CE_HISTORY_ARRAY];
}

-(CEHistoryList*)getAllHistoryFromPrefs{
    CEHistoryList* history = [[CEHistoryList alloc]init];
    NSString* historyFromPrefs = (NSString*)[NSUserDefaultsManager getObjectFromUserDeafults:CE_HISTORY_ARRAY];
    if(!historyFromPrefs || [historyFromPrefs isEqualToString:@""])
        return history;
    else{
        NSError* err = nil;
        history = [[CEHistoryList alloc] initWithString:historyFromPrefs error:&err];
    }
    return history;
}


-(void)clearHistory{
    [NSUserDefaultsManager removeObjectFromUserDeafults:CE_HISTORY_ARRAY];
}

-(void)deleteOlderItems{
    CEHistoryList* history = [self getAllHistoryFromPrefs];
    if(history && history.historyList && [history.historyList count]>MAX_HISTORY_ITEMS){
        int count = (int)history.historyList.count;
        [history.historyList removeObjectsInRange:NSMakeRange(MAX_HISTORY_ITEMS, count-MAX_HISTORY_ITEMS)];
        NSString* historyString = [history toJSONString];
        [NSUserDefaultsManager saveObjectToUserDefaults:historyString withKey:CE_HISTORY_ARRAY];
    }
}

@end
