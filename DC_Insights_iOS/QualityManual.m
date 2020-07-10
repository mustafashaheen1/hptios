//
//  QualityManual.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/25/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "QualityManual.h"
#import "SyncManager.h"
#import "AFHTTPRequestOperation.h"

@implementation QualityManual

@synthesize updated_at;
@synthesize pdf;
@synthesize updated_atPreProcessed;

- (void) getHTMLContentFromRemoteUrlAndSaveToTheLocalDirectory {
    NSString *kAFAppDotNetAPIBaseURLString = [SyncManager getPortalEndpoint];
    NSString *urlString = [NSString stringWithFormat:@"%@%@.html?auth_token=%@&device_id=%@", kAFAppDotNetAPIBaseURLString, self.path, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
    NSURL *URL = [NSURL URLWithString:urlString];
    self.remoteUrl = urlString;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.deviceUrl]];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

- (NSString *) getFileFromDeviceUrl {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *webFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", self.deviceUrl]];
    NSString* htmlString = [NSString stringWithContentsOfFile:webFilePath encoding:NSUTF8StringEncoding error:nil];
    return htmlString;
}

-(NSString*)getHtmlUrl{
    NSString *kAFAppDotNetAPIBaseURLString = [SyncManager getPortalEndpoint];
    NSString *urlString = [NSString stringWithFormat:@"%@%@.html?auth_token=%@&device_id=%@", kAFAppDotNetAPIBaseURLString, self.html, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
    NSURL *URL = [NSURL URLWithString:urlString];
    return [URL absoluteString];
}

@end
