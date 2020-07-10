//
//  HPTInspection.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/29/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "AuditApiData.h"



@interface HPTInspection : NSObject
-(AuditApiData*) getApiObjectFromViewModel: (HPTCaseCodeModel *) activityModel;
-(void) saveToDB: (AuditApiData *) auditApiData;
@end


