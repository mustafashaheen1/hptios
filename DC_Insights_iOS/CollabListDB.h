//
//  CollabListDB.h
//  Insights
//
//  Created by Vineet on 11/15/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

//save the response from backend into local JSON
@interface CollabListDB: NSObject

-(void)saveList:(NSArray*)inspectionList;
-(NSArray*)getList;

@end
