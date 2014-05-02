//
//  STTwitterAPI.m
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/18/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"
#import "STTwitterOS.h"
#import "STTwitterOAuth.h"
#import "NSString+STTwitter.h"
#import "STTwitterAppOnly.h"
#import <Accounts/Accounts.h>
#import "STHTTPRequest.h"

#import "STTwitterAPI+Users.h"

static NSDateFormatter *dateFormatter = nil;

@interface STTwitterAPI ()
@property (nonatomic, retain) NSObject <STTwitterProtocol> *oauth;
@end

@implementation STTwitterAPI

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:ACAccountStoreDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            // account must be considered invalid
            if([self.oauth isKindOfClass:[STTwitterOS class]]) {
                self.oauth = nil;
            }
        }];
    }
    
    return self;
}

+ (instancetype)twitterAPIOSWithAccount:(ACAccount *)account {
    STTwitterAPI *twitter = [[STTwitterAPI alloc] init];
    twitter.oauth = [STTwitterOS twitterAPIOSWithAccount:account];
    return twitter;
}

+ (instancetype)twitterAPIOSWithFirstAccount {
    STTwitterAPI *twitter = [[STTwitterAPI alloc] init];
    twitter.oauth = [STTwitterOS twitterAPIOSWithAccount:nil];
    return twitter;
}

+ (instancetype)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                    consumerKey:(NSString *)consumerKey
                                 consumerSecret:(NSString *)consumerSecret
                                       username:(NSString *)username
                                       password:(NSString *)password {
    
    STTwitterAPI *twitter = [[STTwitterAPI alloc] init];
    
    twitter.oauth = [STTwitterOAuth twitterOAuthWithConsumerName:consumerName
                                                     consumerKey:consumerKey
                                                  consumerSecret:consumerSecret
                                                        username:username
                                                        password:password];
    
    return twitter;
}

+ (instancetype)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                consumerSecret:(NSString *)consumerSecret
                                      username:(NSString *)username
                                      password:(NSString *)password {
    
    return [self twitterAPIWithOAuthConsumerName:nil
                                     consumerKey:consumerKey
                                  consumerSecret:consumerSecret
                                        username:username
                                        password:password];
}

+ (instancetype)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                    consumerKey:(NSString *)consumerKey
                                 consumerSecret:(NSString *)consumerSecret
                                     oauthToken:(NSString *)oauthToken
                               oauthTokenSecret:(NSString *)oauthTokenSecret {
    
    STTwitterAPI *twitter = [[STTwitterAPI alloc] init];
    
    twitter.oauth = [STTwitterOAuth twitterOAuthWithConsumerName:consumerName
                                                     consumerKey:consumerKey
                                                  consumerSecret:consumerSecret
                                                      oauthToken:oauthToken
                                                oauthTokenSecret:oauthTokenSecret];
    
    return twitter;
}

+ (instancetype)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                consumerSecret:(NSString *)consumerSecret
                                    oauthToken:(NSString *)oauthToken
                              oauthTokenSecret:(NSString *)oauthTokenSecret {
    
    return [self twitterAPIWithOAuthConsumerName:nil
                                     consumerKey:consumerKey
                                  consumerSecret:consumerSecret
                                      oauthToken:oauthToken
                                oauthTokenSecret:oauthTokenSecret];
}

+ (instancetype)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                    consumerKey:(NSString *)consumerKey
                                 consumerSecret:(NSString *)consumerSecret {
    
    return [self twitterAPIWithOAuthConsumerName:consumerName
                                     consumerKey:consumerKey
                                  consumerSecret:consumerSecret
                                        username:nil
                                        password:nil];
}

+ (instancetype)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                consumerSecret:(NSString *)consumerSecret {
    
    return [self twitterAPIWithOAuthConsumerName:nil
                                     consumerKey:consumerKey
                                  consumerSecret:consumerSecret];
}

+ (instancetype)twitterAPIAppOnlyWithConsumerName:(NSString *)consumerName
                                      consumerKey:(NSString *)consumerKey
                                   consumerSecret:(NSString *)consumerSecret {
    
    STTwitterAPI *twitter = [[STTwitterAPI alloc] init];
    
    STTwitterAppOnly *appOnly = [STTwitterAppOnly twitterAppOnlyWithConsumerName:consumerName consumerKey:consumerKey consumerSecret:consumerSecret];
    
    twitter.oauth = appOnly;
    
    return twitter;
}

+ (instancetype)twitterAPIAppOnlyWithConsumerKey:(NSString *)consumerKey
                                  consumerSecret:(NSString *)consumerSecret {
    return [self twitterAPIAppOnlyWithConsumerName:nil consumerKey:consumerKey consumerSecret:consumerSecret];
}

- (NSString *)prettyDescription {
    NSMutableString *ms = [[_oauth loginTypeDescription] mutableCopy];
    
    if([_oauth consumerName]) {
        [ms appendFormat:@" (%@)", [_oauth consumerName]];
    }
    
    if([self userName]) {
        [ms appendFormat:@" - %@", [self userName]];
    }
    
    return ms;
}

- (NSDateFormatter *)dateFormatter {
    if(dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS'Z'"];
    }
    return dateFormatter;
}

#pragma mark - Token Management

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock forceLogin:(NSNumber *)forceLogin screenName:(NSString *)screenName oauthCallback:(NSString *)oauthCallback errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth postTokenRequest:successBlock forceLogin:forceLogin screenName:screenName oauthCallback:oauthCallback errorBlock:errorBlock];
}

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock oauthCallback:(NSString *)oauthCallback errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth postTokenRequest:successBlock forceLogin:nil screenName:nil oauthCallback:oauthCallback errorBlock:errorBlock];
}

- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth postAccessTokenRequestWithPIN:pin
                             successBlock:successBlock
                               errorBlock:errorBlock];
}

- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    if([_oauth canVerifyCredentials]) {
        [_oauth verifyCredentialsWithSuccessBlock:^(NSString *username) {
            self.userName = username;
            ST_BLOCK_SAFE_RUN(successBlock, _userName);
        } errorBlock:^(NSError *error) {
            ST_BLOCK_SAFE_RUN(errorBlock,error);
        }];
    } else {
        [self getAccountVerifyCredentialsWithSuccessBlock:^(NSDictionary *account) {
            self.userName = [account valueForKey:@"screen_name"];
            ST_BLOCK_SAFE_RUN(successBlock, _userName);
        } errorBlock:^(NSError *error) {
            ST_BLOCK_SAFE_RUN(errorBlock,error);
        }];
    }
}

- (void)invalidateBearerTokenWithSuccessBlock:(void(^)())successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock {
    if([self.oauth respondsToSelector:@selector(invalidateBearerTokenWithSuccessBlock:errorBlock:)]) {
        [self.oauth invalidateBearerTokenWithSuccessBlock:successBlock errorBlock:errorBlock];
    } else {
        STLog(@"-- self.oauth does not support tokens invalidation");
    }
}

- (NSString *)oauthAccessTokenSecret {
    return [_oauth oauthAccessTokenSecret];
}

- (NSString *)oauthAccessToken {
    return [_oauth oauthAccessToken];
}

- (NSString *)bearerToken {
    if([_oauth respondsToSelector:@selector(bearerToken)]) {
        return [_oauth bearerToken];
    }
    
    return nil;
}

- (NSString *)userName {
    
#if TARGET_OS_IPHONE
#else
    if([_oauth isKindOfClass:[STTwitterOS class]]) {
        STTwitterOS *twitterOS = (STTwitterOS *)_oauth;
        return twitterOS.username;
    }
#endif
    
    return _userName;
}

/**/

#pragma mark - Generic methods to GET and POST

- (id)fetchResource:(NSString *)resource
         HTTPMethod:(NSString *)HTTPMethod
      baseURLString:(NSString *)baseURLString
         parameters:(NSDictionary *)params
uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
downloadProgressBlock:(void(^)(id request, id response))downloadProgressBlock
       successBlock:(void(^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
         errorBlock:(void(^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:HTTPMethod
                   baseURLString:baseURLString
                      parameters:params
             uploadProgressBlock:uploadProgressBlock
           downloadProgressBlock:downloadProgressBlock
                    successBlock:successBlock
                      errorBlock:errorBlock];
}

- (id)getResource:(NSString *)resource
    baseURLString:(NSString *)baseURLString
       parameters:(NSDictionary *)parameters
//uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
downloadProgressBlock:(void(^)(id json))downloadProgressBlock
     successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
       errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:@"GET"
                   baseURLString:baseURLString
                      parameters:parameters
             uploadProgressBlock:nil
           downloadProgressBlock:^(id request, id response) {
               if(downloadProgressBlock) downloadProgressBlock(response);
           } successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
               if(successBlock) successBlock(responseHeaders, response);
           } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
               if(errorBlock) errorBlock(error);
           }];
}

- (id)postResource:(NSString *)resource
     baseURLString:(NSString *)baseURLString
        parameters:(NSDictionary *)parameters
uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
downloadProgressBlock:(void(^)(id json))downloadProgressBlock
      successBlock:(void(^)(NSDictionary *rateLimits, id response))successBlock
        errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:@"POST"
                   baseURLString:baseURLString
                      parameters:parameters
             uploadProgressBlock:uploadProgressBlock
           downloadProgressBlock:^(id request, id response) {
               if(downloadProgressBlock) downloadProgressBlock(response);
           } successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
               if(successBlock) successBlock(responseHeaders, response);
           } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
               if(errorBlock) errorBlock(error);
           }];
}

- (void)postResource:(NSString *)resource
       baseURLString:(NSString *)baseURLString
          parameters:(NSDictionary *)parameters
 uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
downloadProgressBlock:(void(^)(id json))downloadProgressBlock
          errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth fetchResource:resource
               HTTPMethod:@"POST"
            baseURLString:baseURLString
               parameters:parameters
      uploadProgressBlock:uploadProgressBlock
    downloadProgressBlock:^(id request, id response) {
        if(downloadProgressBlock) downloadProgressBlock(response);
    } successBlock:nil
               errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                   ST_BLOCK_SAFE_RUN(errorBlock,error);
               }];
}

- (void)getResource:(NSString *)resource
      baseURLString:(NSString *)baseURLString
         parameters:(NSDictionary *)parameters
downloadProgressBlock:(void(^)(id json))downloadProgressBlock
         errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth fetchResource:resource
               HTTPMethod:@"GET"
            baseURLString:baseURLString
               parameters:parameters
      uploadProgressBlock:nil
    downloadProgressBlock:^(id request, id response) {
        if(downloadProgressBlock) downloadProgressBlock(response);
    } successBlock:nil
               errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                   ST_BLOCK_SAFE_RUN(errorBlock,error);
               }];
}

- (void)getAPIResource:(NSString *)resource
            parameters:(NSDictionary *)parameters
         progressBlock:(void(^)(id json))progressBlock
          successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
            errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getResource:resource
        baseURLString:kBaseURLStringAPI
           parameters:parameters
downloadProgressBlock:progressBlock
         successBlock:successBlock
           errorBlock:errorBlock];
}

// convenience
- (void)getAPIResource:(NSString *)resource
            parameters:(NSDictionary *)parameters
          successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
            errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getResource:resource
        baseURLString:kBaseURLStringAPI
           parameters:parameters
downloadProgressBlock:nil
         successBlock:successBlock
           errorBlock:errorBlock];
}

- (void)postAPIResource:(NSString *)resource
             parameters:(NSDictionary *)parameters
    uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
          progressBlock:(void(^)(id json))progressBlock
           successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
             errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self postResource:resource
         baseURLString:kBaseURLStringAPI
            parameters:parameters
   uploadProgressBlock:uploadProgressBlock
 downloadProgressBlock:progressBlock
          successBlock:successBlock
            errorBlock:errorBlock];
}

// convenience
- (void)postAPIResource:(NSString *)resource
             parameters:(NSDictionary *)parameters
           successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
             errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self postResource:resource
         baseURLString:kBaseURLStringAPI
            parameters:parameters
   uploadProgressBlock:nil
 downloadProgressBlock:nil
          successBlock:successBlock
            errorBlock:errorBlock];
}

/**/

// reverse auth step 1

- (void)postReverseOAuthTokenRequest:(void(^)(NSString *authenticationHeader))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        ST_BLOCK_SAFE_RUN(successBlock,authenticationHeader);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// reverse auth step 2

- (void)postReverseAuthAccessTokenWithAuthenticationHeader:(NSString *)authenticationHeader
                                              successBlock:(void(^)(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName))successBlock
                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader successBlock:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName) {
        ST_BLOCK_SAFE_RUN(successBlock,oAuthToken, oAuthTokenSecret, userID, screenName);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

#pragma mark OAuth

// GET oauth/authenticate
// GET oauth/authorize
// POST oauth/access_token
// POST oauth/request_token
// POST oauth2/token
// POST oauth2/invalidate_token

#pragma mark -
#pragma mark UNDOCUMENTED APIs

// GET activity/about_me.json
- (void)_getActivityAboutMeSinceID:(NSString *)sinceID
                             count:(NSString *)count //
                      includeCards:(NSNumber *)includeCards
                      modelVersion:(NSNumber *)modelVersion
                    sendErrorCodes:(NSNumber *)sendErrorCodes
                contributorDetails:(NSNumber *)contributorDetails
                   includeEntities:(NSNumber *)includeEntities
                  includeMyRetweet:(NSNumber *)includeMyRetweet
                      successBlock:(void(^)(NSArray *activities))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) md[@"since_id"] = sinceID;
    if(count) md[@"count"] = count;
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"true" : @"false";
    if(includeMyRetweet) md[@"include_my_retweet"] = [includeMyRetweet boolValue] ? @"1" : @"0";
    if(includeCards) md[@"include_cards"] = [includeCards boolValue] ? @"1" : @"0";
    if(modelVersion) md[@"model_version"] = [modelVersion boolValue] ? @"true" : @"false";
    if(sendErrorCodes) md[@"send_error_codes"] = [sendErrorCodes boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"activity/about_me.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

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
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) md[@"since_id"] = sinceID;
    if(count) md[@"count"] = count;
    if(includeCards) md[@"include_cards"] = [includeCards boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"true" : @"false";
    if(includeMyRetweets) md[@"include_my_retweet"] = [includeMyRetweets boolValue] ? @"true" : @"false";
    if(includeUserEntites) md[@"include_user_entities"] = [includeUserEntites boolValue] ? @"1" : @"0";
    if(latestResults) md[@"latest_results"] = [latestResults boolValue] ? @"true" : @"false";
    if(sendErrorCodes) md[@"send_error_codes"] = [sendErrorCodes boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"activity/by_friends.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET statuses/:id/activity/summary.json
- (void)_getStatusesActivitySummaryForStatusID:(NSString *)statusID
                                  successBlock:(void(^)(NSArray *favoriters, NSArray *repliers, NSArray *retweeters, NSString *favoritersCount, NSString *repliersCount, NSString *retweetersCount))successBlock
                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *resource = [NSString stringWithFormat:@"statuses/%@/activity/summary.json", statusID];
    
    [self getAPIResource:resource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *favoriters = [response valueForKey:@"favoriters"];
        NSArray *repliers = [response valueForKey:@"repliers"];
        NSArray *retweeters = [response valueForKey:@"retweeters"];
        NSString *favoritersCount = [response valueForKey:@"favoriters_count"];
        NSString *repliersCount = [response valueForKey:@"repliers_count"];
        NSString *retweetersCount = [response valueForKey:@"retweeters_count"];
        
        successBlock(favoriters, repliers, retweeters, favoritersCount, repliersCount, retweetersCount);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET conversation/show.json
- (void)_getConversationShowForStatusID:(NSString *)statusID
                           successBlock:(void(^)(NSArray *statuses))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSDictionary *d = @{@"id":statusID};
    
    [self getAPIResource:@"conversation/show.json" parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET discover/highlight.json
- (void)_getDiscoverHighlightWithSuccessBlock:(void(^)(NSDictionary *metadata, NSArray *modules))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getAPIResource:@"discover/highlight.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *metadata = [response valueForKey:@"metadata"];
        NSArray *modules = [response valueForKey:@"modules"];
        
        successBlock(metadata, modules);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET discover/universal.json
- (void)_getDiscoverUniversalWithSuccessBlock:(void(^)(NSDictionary *metadata, NSArray *modules))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getAPIResource:@"discover/universal.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *metadata = [response valueForKey:@"metadata"];
        NSArray *modules = [response valueForKey:@"modules"];
        
        successBlock(metadata, modules);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET statuses/media_timeline.json
- (void)_getMediaTimelineWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getAPIResource:@"statuses/media_timeline.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/recommendations.json
- (void)_getUsersRecommendationsWithSuccessBlock:(void(^)(NSArray *recommendations))successBlock
                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getAPIResource:@"users/recommendations.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET timeline/home.json
- (void)_getTimelineHomeWithSuccessBlock:(void(^)(id response))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getAPIResource:@"timeline/home.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET statuses/mentions_timeline.json
- (void)_getStatusesMentionsTimelineWithCount:(NSString *)count
                          contributorsDetails:(NSNumber *)contributorsDetails
                              includeEntities:(NSNumber *)includeEntities
                             includeMyRetweet:(NSNumber *)includeMyRetweet
                                 successBlock:(void(^)(NSArray *statuses))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(count) md[@"count"] = count;
    if(contributorsDetails) md[@"contributor_details"] = [contributorsDetails boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"true" : @"false";
    if(includeMyRetweet) md[@"include_my_retweet"] = [includeMyRetweet boolValue] ? @"true" : @"false";
    
    [self getAPIResource:@"statuses/mentions_timeline.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET trends/available.json
- (void)_getTrendsAvailableWithSuccessBlock:(void(^)(NSArray *places))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getAPIResource:@"trends/available.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST users/report_spam
- (void)_postUsersReportSpamForTweetID:(NSString *)tweetID
                              reportAs:(NSString *)reportAs // spam, abused, compromised
                             blockUser:(NSNumber *)blockUser
                          successBlock:(void(^)(id userProfile))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(tweetID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"tweet_id"] = tweetID;
    if(reportAs) md[@"report_as"] = reportAs;
    if(blockUser) md[@"block_user"] = [blockUser boolValue] ? @"true" : @"false";
    
    [self postAPIResource:@"users/report_spam.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

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
                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"adc"] = adc;
    md[@"discoverable_by_email"] = discoverableByEmail ? @"1" : @"0";
    md[@"email"] = email;
    md[@"geo_enabled"] = geoEnabled ? @"1" : @"0";
    md[@"lang"] = language;
    md[@"name"] = name;
    md[@"password"] = password;
    md[@"screen_name"] = screenName;
    md[@"send_error_codes"] = sendErrorCode ? @"1": @"0";
    md[@"time_zone"] = timeZone;
    
    [self postResource:@"account/generate.json"
         baseURLString:@"https://api.twitter.com/1"
            parameters:md
   uploadProgressBlock:nil
 downloadProgressBlock:^(id json) {
     //
 } successBlock:^(NSDictionary *rateLimits, id response) {
     successBlock(response);
 } errorBlock:^(NSError *error) {
     errorBlock(error);
 }];
}

// GET search/typeahead.json
- (void)_getSearchTypeaheadQuery:(NSString *)query
                      resultType:(NSString *)resultType // "all"
                  sendErrorCodes:(NSNumber *)sendErrorCodes
                    successBlock:(void(^)(id results))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"q"] = query;
    if(resultType) md[@"result_type"] = resultType;
    if(sendErrorCodes) md[@"send_error_codes"] = @([sendErrorCodes boolValue]);
    
    [self getAPIResource:@"search/typeahead.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

@end

@implementation NSString (STTwitterAPI)

- (NSString *)htmlLinkName {
    NSString *ahref = [self st_firstMatchWithRegex:@"<a href=\".*\">(.*)</a>" error:nil];
    
    return ahref ? ahref : self;
}

@end
