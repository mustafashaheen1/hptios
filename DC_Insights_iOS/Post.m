// Post.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "Post.h"

#import "AFAppDotNetAPIClient.h"

@implementation Post

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

#pragma mark - Get requests

+ (void)globalStoresWithBlock:(void (^)(NSArray *posts, NSError *error))block {
    [[AFAppDotNetAPIClient sharedClient] getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"data"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

#pragma mark - Post requests

+ (void)globalLoginWithBlock:(void (^)(NSArray *posts, NSError *error))block withDictionaryValues:(NSDictionary *)registrationValues {
    NSArray *values = @[[registrationValues objectForKey:@"email"], [registrationValues objectForKey:@"password"], @"false", SW_BUILD_NO];
    NSArray *keys = @[@"email", @"password", @"get_auws_token", @"current_software_version"];
    NSDictionary *localRegistrationValues = [self addDeviceTokenToTheParameters:[[NSDictionary alloc] initWithObjects:values forKeys:keys]];
    
    if ([registrationValues count] > 0) {
        [[AFAppDotNetAPIClient sharedClient] postPath:@"api/tokens" parameters:localRegistrationValues success:^(AFHTTPRequestOperation *operation, id JSON) {
            NSLog(@"Request: %@", JSON);
            NSArray *postsFromResponse = [JSON valueForKeyPath:@"data"];
            NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
            
            if (block) {
                block([NSArray arrayWithArray:mutablePosts], nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block([NSArray array], error);
            }
        }];
    }
}

+ (NSDictionary *) addDeviceTokenToTheParameters: (NSDictionary *) parameters {
    NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionary];
    [parametersDictionary addEntriesFromDictionary:parameters];
    
    NSString *udid;
    if (IS_OS_6_OR_LATER)
        udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    if (parametersDictionary) {
        if (udid) {
            [parametersDictionary setObject:udid forKey:@"device_id"];
        }
    }
    return [parametersDictionary copy];
}




@end
