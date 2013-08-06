//
//  MGTwitterEngine+TH.h
//  TwitHunter
//
//  Created by Nicolas Seriot on 5/1/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitterOAuthProtocol.h"

#if TARGET_OS_IPHONE
#else

@class ACAccount;

@interface STTwitterOAuthOSX : NSObject <STTwitterOAuthProtocol> {
    
}

- (BOOL)canVerifyCredentials;
- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (NSString *)username;

@end

#endif
