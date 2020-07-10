//
//  BackgroundUpload.m
//  Insights
//
//  Created by Vineet Pareek on 23/5/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "BackgroundUpload.h"
#import "AppDelegate.h"
#import "TblCompletedAudits.h"

@interface BackgroundUpload ()
@property int retryCount;
@property int auditsUploadedTotalUsingRetries;
@property int imagesUploadedTotalUsingRetries;
@end

@implementation BackgroundUpload

//TODO: upgrade AFNetworking and migrate to background upload with NSURLSession

//timer to kick start the background upload - if empty results - return back
-(void) startBackgroundTimer {
    
    if (![NSUserDefaultsManager getBOOLFromUserDeafults:enableBackgroundUploads]){
        NSLog(@"background upload disabled- cancel timer start");
        return;
    }
    
    //do not start time if sync not complete yet
    if (![NSUserDefaultsManager getBOOLFromUserDeafults:SYNCSUCCESS]){
        NSLog(@" sync incomplete - cancel timer start");
        return;
    }
    
    if ([self.timer isValid]){
        NSLog(@" timer already valid - cancel timer start");
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:BACKGROUND_UPLOAD_TIME_INTERVAL
                                     target:self
                                   selector:@selector(startBackgroundUpload)
                                   userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self startBackgroundUpload];
}

-(void) stopBackgroundTimer {
 if([self.timer isValid])
     [self.timer invalidate];
}

-(void)startBackgroundUpload {
    NSLog(@"starting background upload");
//    if(self.bgTask != UIBackgroundTaskInvalid){
//        NSLog(@" background task is valid - cancel background upload");
//        return;
//    }
    
    if([self isBackgroundUploadInProgress]){
        NSLog(@" background upload in progress - cancel background upload");
        return;
    }
    
    if(![TblCompletedAudits isUploadNeeded]){
        NSLog(@" no upload needed - cancel background upload");
         return;
    }
    
    self.syncManager = [[SyncManager alloc]init];
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"InsightsBackgroundUploadTask" expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        NSLog(@"Background Task ended by system");
        // stopped or ending the task outright.
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self markUploadStart];
    self.syncManager.delegate = self;
    [self.syncManager uploadDataAndImagesInBackground];
}

-(BOOL)isBackgroundUploadInProgress {
    return self.isUploadInProgress;
}

-(void)printRemainingTime {
    //NSLog(@"Running in the background\n");
    //while(TRUE)
    {
        NSLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
        //[NSThread sleepForTimeInterval:1]; //wait for 1 sec
    }
}

-(void)endBackgroundUpload {
    [self printRemainingTime];
    [self markUploadEnd];
    [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
}

-(void)markUploadStart {
    [self printRemainingTime];
    [self updateIconOnHomeScreenForStart];
    self.isUploadInProgress = YES;
}

-(void)markUploadEnd {
    self.isUploadInProgress = NO;
    [self updateIconOnHomeScreenForComplete];
}

-(void)updateIconOnHomeScreenForComplete {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFICATION_BACKGROUND_UPLOAD_COMPLETED
     object:self];
}

-(void)updateIconOnHomeScreenForStart {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFICATION_BACKGROUND_UPLOAD_STARTED
     object:self];
}

//TODO - clean up the audits uploaded count and read from DB directly instead
// need to move this logic out of the background upload
- (void) imagesUploaded: (BOOL) success withAuditsCount:(int) auditsUploaded withImagesUploaded: (int) imagesUploaded{
    //[self uploadLoopComplete];
    
    //[self checkForAuditsToUpload];
    int auditsTobeUploaded = [TblCompletedAudits getPendingAuditsCount];
    self.auditsUploadedTotalUsingRetries = self.auditsUploadedTotalUsingRetries + auditsUploaded;
    self.imagesUploadedTotalUsingRetries = self.imagesUploadedTotalUsingRetries + imagesUploaded;
    BOOL scanout = [[User sharedUser]checkForScanOut];
    if (auditsTobeUploaded > 0 && self.retryCount < 1) { //retry count 1
        self.retryCount++;
        [self appendTrackingLog:[NSString stringWithFormat:@"| Uploaded audits: %d and images: %d",self.auditsUploadedTotalUsingRetries,self.imagesUploadedTotalUsingRetries]];
        [self appendTrackingLog:[NSString stringWithFormat:@"| Retrying Submission - retry count %d",self.retryCount]];
        [self.syncManager uploadDataAndImagesInBackground];
    } else if (auditsTobeUploaded == 0) {
        if (success) {
            [self appendTrackingLog:[NSString stringWithFormat:@"| Final Result: %d %@ And %d Images Uploaded", self.auditsUploadedTotalUsingRetries, InspectionsUploaded, self.imagesUploadedTotalUsingRetries]];
            [self.syncManager reportUploadSync];
            [self.syncManager sendLogsToBackend];
            //[[User sharedUser] addLogText:[NSString stringWithFormat:@"\nRemoved Overlay. Upload Succcessful\n"]];

            [TblCompletedAudits deleteSubmittedRows];//cleanup database
            [self endBackgroundUpload];
        } else {
            //auditsTobeUploaded = self.pendingAuditsToUpload; //TODO - fix this count
            NSString* message = [NSString stringWithFormat:@"Upload Failed. %d remaining in the device.", auditsTobeUploaded];
            int pendingImages = self.syncManager.overallTotalImagesToUploadCount - self.imagesUploadedTotalUsingRetries;
            if(pendingImages>0 && !scanout){
                message = [NSString stringWithFormat:@"Upload Failed : %d audits and %d images remaining", auditsTobeUploaded,pendingImages];
            }
            [self appendTrackingLog:message];
            [self.syncManager reportUploadSync];
            [self.syncManager sendLogsToBackend];
            [[User sharedUser] addLogText:[NSString stringWithFormat:@"| Removed Overlay. Upload Failed |"]];
            [self endBackgroundUpload];
        }
        //[self checkAppVersion];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    } else {
        //auditsTobeUploaded = self.pendingAuditsToUpload; //TODO - fix this count
        NSString* message = [NSString stringWithFormat:@"Upload Failed. %d remaining in the device.", auditsTobeUploaded];
        int pendingImages = self.syncManager.overallTotalImagesToUploadCount - self.imagesUploadedTotalUsingRetries;
        if(pendingImages>0 && !scanout){
            message = [NSString stringWithFormat:@"Upload Failed : %d audits and %d images remaining", auditsTobeUploaded,pendingImages];
        }
        [self appendTrackingLog:message];
        [self appendTrackingLog:@"Background-Upload Finished"];
        [self.syncManager reportUploadSync];
        [self.syncManager sendLogsToBackend];
        //[self checkAppVersion];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [self endBackgroundUpload];
    }
}

-(void) appendTrackingLog:(NSString*)log{
    [[User sharedUser]addTrackingLog:log];
}

-(BOOL) isBackgroundUploadEnabled {
    return [NSUserDefaultsManager getBOOLFromUserDeafults:BACKGROUND_UPLOAD_ENABLED];
}

-(void) enableBackgroundUpload {
    [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:BACKGROUND_UPLOAD_ENABLED];
}

-(void) disableBackgroundUpload {
    [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:BACKGROUND_UPLOAD_ENABLED];
}


//syncManager delegate methods
- (void) downloadProgress: (BOOL)success{
    
}
- (void) updateAPIName: (NSString *) apiName{
    
}
- (void) auditsUploaded: (BOOL) success{
    
}

- (void) downloadFailed {
    
}
- (void) downloadFailed:(NSString*)failMessage{
    
}

@end
