//
//  STOAuthProtocol.h
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/18/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STTwitterOAuthProtocol <NSObject>

- (BOOL)canVerifyCredentials;
- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getResource:(NSString *)resource
         parameters:(NSDictionary *)params
       successBlock:(void(^)(id response))successBlock
         errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postResource:(NSString *)resource
          parameters:(NSDictionary *)params
        successBlock:(void(^)(id response))successBlock
          errorBlock:(void(^)(NSError *error))errorBlock;

@optional

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

- (void)invalidateBearerTokenWithSuccessBlock:(void(^)())successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

- (NSString *)oauthAccessToken;
- (NSString *)oauthAccessTokenSecret;

- (NSString *)bearerToken;

@end
