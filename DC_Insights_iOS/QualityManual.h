//
//  QualityManual.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/25/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"

@interface QualityManual : DCBaseEntity

@property (nonatomic, strong) NSDate *updated_at;
@property (nonatomic, strong) NSString *updated_atPreProcessed;
@property (nonatomic, strong) NSString *pdf; //*url;

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *deviceUrl;
@property (nonatomic, strong) NSString *remoteUrl;
@property (nonatomic, strong) NSString *htmlContent;
@property (nonatomic, assign) BOOL lastUpdated;
@property (nonatomic, strong) NSString *html; //*document;

- (void) getHTMLContentFromRemoteUrlAndSaveToTheLocalDirectory;
- (NSString *) getFileFromDeviceUrl;
- (NSString*)getHtmlUrl;

@end
