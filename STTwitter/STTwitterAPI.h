/*
 Copyright (c) 2012, Nicolas Seriot
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the Nicolas Seriot nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  STTwitterAPI.h
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/18/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ST_BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil

NS_ENUM(NSUInteger, STTwitterAPIErrorCode) {
    STTwitterAPICannotPostEmptyStatus,
    STTwitterAPIMediaDataIsEmpty
};

static NSString *kBaseURLStringAPI = @"https://api.twitter.com/1.1";
static NSString *kBaseURLStringStream = @"https://stream.twitter.com/1.1";
static NSString *kBaseURLStringUserStream = @"https://userstream.twitter.com/1.1";
static NSString *kBaseURLStringSiteStream = @"https://sitestream.twitter.com/1.1";

/*
 Tweet fields contents
 https://dev.twitter.com/docs/platform-objects/tweets
 https://dev.twitter.com/blog/new-withheld-content-fields-api-responses
 */

@class ACAccount;

@interface STTwitterAPI : NSObject

+ (instancetype)twitterAPIOSWithAccount:(ACAccount *) account;
+ (instancetype)twitterAPIOSWithFirstAccount;

+ (instancetype)twitterAPIWithOAuthConsumerName:(NSString *)consumerName // purely informational, can be anything
                                    consumerKey:(NSString *)consumerKey
                                 consumerSecret:(NSString *)consumerSecret;

// convenience
+ (instancetype)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                consumerSecret:(NSString *)consumerSecret;

+ (instancetype)twitterAPIWithOAuthConsumerName:(NSString *)consumerName // purely informational, can be anything
                                    consumerKey:(NSString *)consumerKey
                                 consumerSecret:(NSString *)consumerSecret
                                       username:(NSString *)username
                                       password:(NSString *)password;

// convenience
+ (instancetype)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                consumerSecret:(NSString *)consumerSecret
                                      username:(NSString *)username
                                      password:(NSString *)password;

+ (instancetype)twitterAPIWithOAuthConsumerName:(NSString *)consumerName // purely informational, can be anything
                                    consumerKey:(NSString *)consumerKey
                                 consumerSecret:(NSString *)consumerSecret
                                     oauthToken:(NSString *)oauthToken
                               oauthTokenSecret:(NSString *)oauthTokenSecret;

// convenience
+ (instancetype)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                consumerSecret:(NSString *)consumerSecret
                                    oauthToken:(NSString *)oauthToken
                              oauthTokenSecret:(NSString *)oauthTokenSecret;

// https://dev.twitter.com/docs/auth/application-only-auth
+ (instancetype)twitterAPIAppOnlyWithConsumerName:(NSString *)consumerName
                                      consumerKey:(NSString *)consumerKey
                                   consumerSecret:(NSString *)consumerSecret;

// convenience
+ (instancetype)twitterAPIAppOnlyWithConsumerKey:(NSString *)consumerKey
                                  consumerSecret:(NSString *)consumerSecret;

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
              forceLogin:(NSNumber *)forceLogin
              screenName:(NSString *)screenName
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

// https://dev.twitter.com/docs/ios/using-reverse-auth

// reverse auth step 1
- (void)postReverseOAuthTokenRequest:(void(^)(NSString *authenticationHeader))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

// reverse auth step 2
// WARNING: if the Twitter account was set in iOS settings, the tokens may be nil after a system update.
// In this case, you can call -[ACAccountStore renewCredentialsForAccount:completion:] to let the user enter her Twitter password again.
- (void)postReverseAuthAccessTokenWithAuthenticationHeader:(NSString *)authenticationHeader
                                              successBlock:(void(^)(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName))successBlock
                                                errorBlock:(void(^)(NSError *error))errorBlock;

- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (void)invalidateBearerTokenWithSuccessBlock:(void(^)())successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

- (NSString *)prettyDescription;

@property (nonatomic, retain) NSString *userName; // available for osx, set after successful connection for STTwitterOAuth

@property (nonatomic, readonly) NSString *oauthAccessToken;
@property (nonatomic, readonly) NSString *oauthAccessTokenSecret;
@property (nonatomic, readonly) NSString *bearerToken;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

#pragma mark Generic methods to GET and POST

- (id)fetchResource:(NSString *)resource
         HTTPMethod:(NSString *)HTTPMethod
      baseURLString:(NSString *)baseURLString
         parameters:(NSDictionary *)params
uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
downloadProgressBlock:(void (^)(id request, id response))downloadProgressBlock
       successBlock:(void (^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
         errorBlock:(void (^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock;

- (id)getResource:(NSString *)resource
    baseURLString:(NSString *)baseURLString
       parameters:(NSDictionary *)parameters
downloadProgressBlock:(void(^)(id json))progredownloadProgressBlockssBlock
     successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
       errorBlock:(void(^)(NSError *error))errorBlock;

- (id)postResource:(NSString *)resource
     baseURLString:(NSString *)baseURLString
        parameters:(NSDictionary *)parameters
uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
downloadProgressBlock:(void(^)(id json))downloadProgressBlock
      successBlock:(void(^)(NSDictionary *rateLimits, id response))successBlock
        errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postAPIResource:(NSString *)resource
             parameters:(NSDictionary *)parameters
           successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
             errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getAPIResource:(NSString *)resource
            parameters:(NSDictionary *)parameters
         progressBlock:(void(^)(id json))progressBlock
          successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
            errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getAPIResource:(NSString *)resource
            parameters:(NSDictionary *)parameters
          successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
            errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark -
#pragma mark UNDOCUMENTED APIs

// GET activity/about_me.json
- (void)_getActivityAboutMeSinceID:(NSString *)sinceID
                             count:(NSString *)count
                      includeCards:(NSNumber *)includeCards
                      modelVersion:(NSNumber *)modelVersion
                    sendErrorCodes:(NSNumber *)sendErrorCodes
                contributorDetails:(NSNumber *)contributorDetails
                   includeEntities:(NSNumber *)includeEntities
                  includeMyRetweet:(NSNumber *)includeMyRetweet
                      successBlock:(void(^)(NSArray *activities))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

// GET activity/by_friends.json
- (void)_getActivityByFriendsSinceID:(NSString *)sinceID
                               count:(NSString *)count
                  contributorDetails:(NSNumber *)contributorDetails
                        includeCards:(NSNumber *)includeCards
                     includeEntities:(NSNumber *)includeEntities
                   includeMyRetweets:(NSNumber *)includeMyRetweets
                  includeUserEntites:(NSNumber *)includeUserEntites
                       latestResults:(NSNumber *)latestResults
                      sendErrorCodes:(NSNumber *)sendErrorCodes
                        successBlock:(void(^)(NSArray *activities))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

// GET statuses/:id/activity/summary.json
- (void)_getStatusesActivitySummaryForStatusID:(NSString *)statusID
                                  successBlock:(void(^)(NSArray *favoriters, NSArray *repliers, NSArray *retweeters, NSString *favoritersCount, NSString *repliersCount, NSString *retweetersCount))successBlock
                                    errorBlock:(void(^)(NSError *error))errorBlock;

// GET conversation/show.json
- (void)_getConversationShowForStatusID:(NSString *)statusID
                           successBlock:(void(^)(NSArray *statuses))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock;

// GET discover/highlight.json
- (void)_getDiscoverHighlightWithSuccessBlock:(void(^)(NSDictionary *metadata, NSArray *modules))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

// GET discover/universal.json
- (void)_getDiscoverUniversalWithSuccessBlock:(void(^)(NSDictionary *metadata, NSArray *modules))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

// GET statuses/media_timeline.json
- (void)_getMediaTimelineWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock;

// GET users/recommendations.json
- (void)_getUsersRecommendationsWithSuccessBlock:(void(^)(NSArray *recommendations))successBlock
                                      errorBlock:(void(^)(NSError *error))errorBlock;

// GET timeline/home.json
- (void)_getTimelineHomeWithSuccessBlock:(void(^)(id response))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

// GET statuses/mentions_timeline.json
- (void)_getStatusesMentionsTimelineWithCount:(NSString *)count
                          contributorsDetails:(NSNumber *)contributorsDetails
                              includeEntities:(NSNumber *)includeEntities
                             includeMyRetweet:(NSNumber *)includeMyRetweet
                                 successBlock:(void(^)(NSArray *statuses))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

// GET trends/available.json
- (void)_getTrendsAvailableWithSuccessBlock:(void(^)(NSArray *places))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock;

// POST users/report_spam
- (void)_postUsersReportSpamForTweetID:(NSString *)tweetID
                              reportAs:(NSString *)reportAs // spam, abused, compromised
                             blockUser:(NSNumber *)blockUser
                          successBlock:(void(^)(id userProfile))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock;

// POST account/generate.json
- (void)_postAccountGenerateWithADC:(NSString *)adc
                discoverableByEmail:(BOOL)discoverableByEmail
                              email:(NSString *)email
                         geoEnabled:(BOOL)geoEnabled
                           language:(NSString *)language
                               name:(NSString *)name
                           password:(NSString *)password
                         screenName:(NSString *)screenName
                      sendErrorCode:(BOOL)sendErrorCode
                           timeZone:(NSString *)timeZone
                       successBlock:(void(^)(id userProfile))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock;

// GET search/typeahead.json
- (void)_getSearchTypeaheadQuery:(NSString *)query
                      resultType:(NSString *)resultType // "all"
                  sendErrorCodes:(NSNumber *)sendErrorCodes
                    successBlock:(void(^)(id results))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

@end
