//
//  STTwitterAPI+SpamReporting.m
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+SpamReporting.h"

@implementation STTwitterAPI (SpamReporting)

#pragma mark Spam Reporting

// POST users/report_spam
- (void)postUsersReportSpamForScreenName:(NSString *)screenName
                                orUserID:(NSString *)userID
                            successBlock:(void(^)(id userProfile))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(screenName || userID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    [self postAPIResource:@"users/report_spam.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

@end
