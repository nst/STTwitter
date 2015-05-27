//
//  STTwitterOS.h
//  STTwitter
//
//  Created by Nicolas Seriot on 5/1/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitterProtocol.h"

extern NS_ENUM(NSUInteger, STTwitterOSErrorCode) {
    STTwitterOSSystemCannotAccessTwitter = 0,
    STTwitterOSCannotFindTwitterAccount,
    STTwitterOSUserDeniedAccessToTheirAccounts,
    STTwitterOSNoTwitterAccountIsAvailable
};

@class ACAccount;

@interface STTwitterOS : NSObject <STTwitterProtocol>

@property (nonatomic) NSTimeInterval timeoutInSeconds;

+ (instancetype)twitterAPIOSWithAccount:(ACAccount *)account;
+ (instancetype)twitterAPIOSWithFirstAccount;

- (NSString *)username;
- (NSString *)userID;

// useful for the so-called 'OAuth Echo' https://dev.twitter.com/twitter-kit/ios/oauth-echo

- (NSDictionary *)OAuthEchoHeadersToVerifyCredentials;

@end
