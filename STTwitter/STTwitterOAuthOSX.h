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

typedef void (^STTE_completionBlock_t)(NSArray *statuses);
typedef void (^STTE_errorBlock_t)(NSError *error);

@class ACAccount;

@interface STTwitterOAuthOSX : NSObject <STTwitterOAuthProtocol> {

}


- (BOOL)canVerifyCredentials;
- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getResource:(NSString *)resource parameters:(NSDictionary *)params successBlock:(STTE_completionBlock_t)completionBlock errorBlock:(STTE_errorBlock_t)errorBlock;
- (void)postResource:(NSString *)resource parameters:(NSDictionary *)params successBlock:(STTE_completionBlock_t)completionBlock errorBlock:(STTE_errorBlock_t)errorBlock;

- (NSString *)username;

@end

#endif
