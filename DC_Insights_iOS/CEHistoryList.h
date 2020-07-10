//
//  CEHistoryList.h
//  Insights
//
//  Created by Vineet Pareek on 20/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "CEHistory.h"


@interface CEHistoryList : JSONModel

@property NSMutableArray<CEHistory> *historyList;


-(void)saveToPrefs:(CEHistory*)historyObject;
-(CEHistoryList*)getAllHistoryFromPrefs;
-(void)clearHistory;

@end
