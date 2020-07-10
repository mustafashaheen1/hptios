//
//  InspectionStatus.m
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 9/5/19.
//  Copyright © 2019 Yottamark. All rights reserved.
//

#import "InspectionStatus.h"
#import "OrderDataAPI.h"
#import "JSONModel.h"
#import "OrderData.h"
#import "User.h"
#import "SyncManager.h"
@implementation InspectionStatus

- (id)init
{
    self = [super init];
    if (self) {
        self.allInspectionStatuses = [[NSMutableArray alloc]init];
        self.notifications = [[NSMutableArray alloc]init];
        self.allIds = [[NSMutableArray alloc]init];
        self.allDefaultStatuses = [[NSMutableArray alloc]init];
        self.defaultIds = [[NSMutableArray alloc]init];
    }
    return self;
}
-(void) getAllStatuses: (int) programId: (NSString*) inspectionType{
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *device_id = [DeviceManager getDeviceID];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    NSString *api_name;
    if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.inventory"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.inventory"]))
    {
        api_name = [NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@&program_type_id=%@", Containers, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], INVENTORY_PROGRAM_TYPE];
    } else if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.insights"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.insights"]))
    {
        api_name = [NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@&program_type_id=%@", Containers, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], INSIGHTS_PROGRAM_TYPE];
    }
    
    [[AFAppDotNetAPIClient sharedClient] getPath:api_name  parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
       dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Response is:  %@", JSON);
            [self.allInspectionStatuses removeAllObjects];
            [self.allIds removeAllObjects];
            [self.notifications removeAllObjects];
        for (NSDictionary *dict in JSON){
            if(programId == [[dict objectForKey:@"program_id"] intValue]){
                if([inspectionType isEqualToString:[dict objectForKey:@"display"]]){
                for(NSDictionary *dict2 in dict[@"inspection_statuses"]){
                    [self.allInspectionStatuses addObject:dict2[@"display"]];
                    [self.allIds addObject:dict2[@"inspection_status_id"]];
                    [self.notifications addObject:dict2[@"send_notification"]];
                }
                }
            }
        }
           [self sortArray];
           NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
           [userDefaults setObject:self.allInspectionStatuses forKey:@"allInspectionStatuses"];
           [userDefaults setObject:self.allIds forKey:@"allIds"];
           [userDefaults setObject:self.notifications forKey:@"notifications"];
           [userDefaults synchronize];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"It was a failure");
    }];
    api_name = [NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@", InspectionStatuses, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
    [[AFAppDotNetAPIClient sharedClient] getPath:api_name  parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Response is:  %@", JSON);
        [self.allDefaultStatuses removeAllObjects];
        [self.defaultIds removeAllObjects];
        for(NSDictionary *dict in JSON){
            [self.allDefaultStatuses addObject:dict[@"name"]];
            [self.defaultIds addObject:dict[@"id"]];
        }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:self.allDefaultStatuses forKey:@"allDefaultStatuses"];
            [userDefaults setObject:self.defaultIds forKey:@"defaultIds"];
            [userDefaults synchronize];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"It was a failure");
    }];
}
-(void) getAllStatuses: (NSString*) inspectionType{
    
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *device_id = [DeviceManager getDeviceID];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    NSString *api_name;
    if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.inventory"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.inventory"]))
    {
        api_name = [NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@&program_type_id=%@", Containers, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], INVENTORY_PROGRAM_TYPE];
    } else if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.insights"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.insights"]))
    {
        api_name = [NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@&program_type_id=%@", Containers, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], INSIGHTS_PROGRAM_TYPE];
    }
    [[AFAppDotNetAPIClient sharedClient] getPath:api_name  parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
       dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Response is:  %@", JSON);
            [self.allInspectionStatuses removeAllObjects];
            [self.allIds removeAllObjects];
            [self.notifications removeAllObjects];
        for (NSDictionary *dict in JSON){
            
                if([inspectionType isEqualToString:[dict objectForKey:@"display"]]){
                for(NSDictionary *dict2 in dict[@"inspection_statuses"]){
                    [self.allInspectionStatuses addObject:dict2[@"display"]];
                    [self.allIds addObject:dict2[@"inspection_status_id"]];
                    [self.notifications addObject:dict2[@"send_notification"]];
                }
                
            }
        }
           [self sortArray];
           NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
           [userDefaults setObject:self.allInspectionStatuses forKey:@"allInspectionStatuses"];
           [userDefaults setObject:self.allIds forKey:@"allIds"];
           [userDefaults setObject:self.notifications forKey:@"notifications"];
           [userDefaults synchronize];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"It was a failure");
    }];
    api_name = [NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@", InspectionStatuses, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
    [[AFAppDotNetAPIClient sharedClient] getPath:api_name  parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Response is:  %@", JSON);
        [self.allDefaultStatuses removeAllObjects];
        [self.defaultIds removeAllObjects];
        for(NSDictionary *dict in JSON){
            [self.allDefaultStatuses addObject:dict[@"name"]];
            [self.defaultIds addObject:dict[@"id"]];
        }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:self.allDefaultStatuses forKey:@"allDefaultStatuses"];
            [userDefaults setObject:self.defaultIds forKey:@"defaultIds"];
            [userDefaults synchronize];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"It was a failure");
    }];
}

-(void) sortArray{
    
    int i = 0;
    int count = self.allInspectionStatuses.count;
    
    while(i < count){
        int j = i;
        while(j < count){
            int temp1 = [[self.allIds objectAtIndex:i] intValue];
            int temp2 = [[self.allIds objectAtIndex:j] intValue];
            if(temp1 > temp2){
                id tempId = self.allIds[i];
                id tempName = self.allInspectionStatuses[i];
                id tempNotification = self.notifications[i];
                [self.allIds replaceObjectAtIndex:i withObject:self.allIds[j]];
                [self.allInspectionStatuses replaceObjectAtIndex:i withObject:self.allInspectionStatuses[j]];
                [self.notifications replaceObjectAtIndex:i withObject:self.notifications[j]];
                [self.allIds replaceObjectAtIndex:j withObject:tempId];
                [self.allInspectionStatuses replaceObjectAtIndex:j withObject:tempName];
                [self.notifications replaceObjectAtIndex:j withObject:tempNotification];
            }
            j += 1;
        }
        i += 1;
    }
}
@end
