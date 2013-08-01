//
//  STOAuthProtocol.h
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/18/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBaseURLStringAPI @"https://api.twitter.com/1.1/"
#define kBaseURLStringStream @"https://stream.twitter.com/1.1/"
#define kBaseURLStringUserStream @"https://userstream.twitter.com/1.1/"
#define kBaseURLStringSiteStream @"https://sitestream.twitter.com/1.1/"

@protocol STTwitterOAuthProtocol <NSObject>

- (BOOL)canVerifyCredentials;
- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getResource:(NSString *)resource
      baseURLString:(NSString *)baseURLString
         parameters:(NSDictionary *)params
       successBlock:(void(^)(id response))successBlock
         errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postResource:(NSString *)resource
       baseURLString:(NSString *)baseURLString
          parameters:(NSDictionary *)params
        successBlock:(void(^)(id response))successBlock
          errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getAPIResource:(NSString *)resource
            parameters:(NSDictionary *)params
          successBlock:(void(^)(id response))successBlock
            errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postAPIResource:(NSString *)resource
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
