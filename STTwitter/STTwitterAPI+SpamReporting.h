//
//  STTwitterAPI+SpamReporting.h
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (SpamReporting)

#pragma mark Spam Reporting

/*
 POST   users/report_spam
 
 Report the specified user as a spam account to Twitter. Additionally performs the equivalent of POST blocks/create on behalf of the authenticated user.
 */

- (void)postUsersReportSpamForScreenName:(NSString *)screenName
                                orUserID:(NSString *)userID
                            successBlock:(void(^)(id userProfile))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

@end
