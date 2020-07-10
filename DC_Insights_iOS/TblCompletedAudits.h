//
//  TblCompletedAudits.h
//  Insights
//
//  Created by Vineet Pareek on 25/5/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TblCompletedAudits : NSObject

+(int) getPendingImagesCount;
+(int) getPendingAuditsCount;
+(BOOL) isUploadNeeded;
+(void) deleteSubmittedRows;

@end
