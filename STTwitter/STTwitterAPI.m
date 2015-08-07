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
#import "STHTTPRequest+STTwitter.h"

NSString *kBaseURLStringAPI_1_1 = @"https://api.twitter.com/1.1";
NSString *kBaseURLStringUpload_1_1 = @"https://upload.twitter.com/1.1";
NSString *kBaseURLStringStream_1_1 = @"https://stream.twitter.com/1.1";
NSString *kBaseURLStringUserStream_1_1 = @"https://userstream.twitter.com/1.1";
NSString *kBaseURLStringSiteStream_1_1 = @"https://sitestream.twitter.com/1.1";

static NSDateFormatter *dateFormatter = nil;

@interface STTwitterAPI ()
@property (nonatomic, retain) NSObject <STTwitterProtocol> *oauth;
@property (nonatomic, retain) STTwitterStreamParser *streamParser;
@end

@implementation STTwitterAPI

- (instancetype)init {
    self = [super init];
    
    STTwitterAPI * __weak weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ACAccountStoreDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        // account must be considered invalid
        
        if(weakSelf == nil) return;
        
        typeof(self) strongSelf = weakSelf;
        
        if([strongSelf.oauth isKindOfClass:[STTwitterOS class]]) {
            strongSelf.oauth = nil;
        }
    }];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACAccountStoreDidChangeNotification object:nil];
}

+ (NSString *)versionString {
    return @"0.2.2";
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

- (void)setTimeoutInSeconds:(NSTimeInterval)timeoutInSeconds {
    _oauth.timeoutInSeconds = timeoutInSeconds;
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

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
authenticateInsteadOfAuthorize:(BOOL)authenticateInsteadOfAuthorize
              forceLogin:(NSNumber *)forceLogin screenName:(NSString *)screenName
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth postTokenRequest:successBlock
authenticateInsteadOfAuthorize:authenticateInsteadOfAuthorize
                  forceLogin:forceLogin
                  screenName:screenName
               oauthCallback:oauthCallback
                  errorBlock:errorBlock];
}

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth postTokenRequest:successBlock authenticateInsteadOfAuthorize:NO forceLogin:nil screenName:nil oauthCallback:oauthCallback errorBlock:errorBlock];
}

- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth postAccessTokenRequestWithPIN:pin
                             successBlock:successBlock
                               errorBlock:errorBlock];
}

- (void)verifyCredentialsWithUserSuccessBlock:(void(^)(NSString *username, NSString *userID))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    __weak typeof(self) weakSelf = self;
    
    [_oauth verifyCredentialsLocallyWithSuccessBlock:^(NSString *username, NSString *userID) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if(strongSelf == nil) {
            errorBlock(nil);
            return;
        }
        
        if(username) [strongSelf setUserName:username];
        if(userID) [strongSelf setUserID:userID];
        
        [_oauth verifyCredentialsRemotelyWithSuccessBlock:^(NSString *username, NSString *userID) {
            
            if(strongSelf == nil) {
                errorBlock(nil);
                return;
            }
            
            [strongSelf setUserName:username];
            [strongSelf setUserID:userID];
            
            successBlock(username, userID);
        } errorBlock:^(NSError *error) {
            errorBlock(error);
        }];
        
    } errorBlock:^(NSError *error) {
        errorBlock(error); // early, local detection of account issues, eg. incomplete OS account
    }];
}

// deprecated, use verifyCredentialsWithUserSuccessBlock:errorBlock:
- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock {
    [self verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        successBlock(username);
    } errorBlock:errorBlock];
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
    if([_oauth respondsToSelector:@selector(oauthAccessTokenSecret)]) {
        return [_oauth oauthAccessTokenSecret];
    }
    return nil;
}

- (NSString *)oauthAccessToken {
    if([_oauth respondsToSelector:@selector(oauthAccessToken)]) {
        return [_oauth oauthAccessToken];
    }
    return nil;
}

- (NSString *)bearerToken {
    if([_oauth respondsToSelector:@selector(bearerToken)]) {
        return [_oauth bearerToken];
    }
    
    return nil;
}

- (NSDictionary *)OAuthEchoHeadersToVerifyCredentials {
    if([_oauth respondsToSelector:@selector(OAuthEchoHeadersToVerifyCredentials)]) {
        return [_oauth OAuthEchoHeadersToVerifyCredentials];
    }
    
    return nil;
}

- (NSString *)userName {
    
    if([_oauth isKindOfClass:[STTwitterOS class]]) {
        STTwitterOS *twitterOS = (STTwitterOS *)_oauth;
        return twitterOS.username;
    }
    
    return _userName;
}

- (NSString *)userID {
    
    if([_oauth isKindOfClass:[STTwitterOS class]]) {
        STTwitterOS *twitterOS = (STTwitterOS *)_oauth;
        return twitterOS.userID;
    }
    
    return _userID;
}

/**/

#pragma mark Generic methods to GET and POST

- (NSObject<STTwitterRequestProtocol> *)fetchResource:(NSString *)resource
                                           HTTPMethod:(NSString *)HTTPMethod
                                        baseURLString:(NSString *)baseURLString
                                           parameters:(NSDictionary *)params
                                  uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                downloadProgressBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))downloadProgressBlock
                                         successBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
                                           errorBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:HTTPMethod
                   baseURLString:baseURLString
                      parameters:params
             uploadProgressBlock:uploadProgressBlock
           downloadProgressBlock:downloadProgressBlock
                    successBlock:successBlock
                      errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)fetchAndFollowCursorsForResource:(NSString *)resource
                                                              HTTPMethod:(NSString *)HTTPMethod
                                                           baseURLString:(NSString *)baseURLString
                                                              parameters:(NSDictionary *)params
                                                     uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                                   downloadProgressBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))downloadProgressBlock
                                                            successBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response, BOOL morePagesToCome, BOOL *stop))successBlock
                                                              pauseBlock:(void(^)(NSDate *nextRequestDate))pauseBlock
                                                              errorBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    __block BOOL shouldStop = NO;
    
    return [_oauth fetchResource:resource
                      HTTPMethod:HTTPMethod
                   baseURLString:baseURLString
                      parameters:params
             uploadProgressBlock:uploadProgressBlock
           downloadProgressBlock:downloadProgressBlock
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        
                        // https://dev.twitter.com/overview/api/cursoring
                        
                        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
                        
                        BOOL morePagesToCome = NO;
                        
                        NSMutableDictionary *paramsWithCursor = [params mutableCopy];
                        if([nextCursor integerValue] > 0) {
                            paramsWithCursor[@"cursor"] = nextCursor;
                            morePagesToCome = YES;
                        }
                        
                        successBlock(request, requestHeaders, responseHeaders, response, morePagesToCome, &shouldStop);
                        
                        if(shouldStop || morePagesToCome == NO) return;
                        
                        // now consider rate limits
                        
                        NSString *remainingString = [responseHeaders objectForKey:@"x-rate-limit-remaining"];
                        NSString *resetString = [responseHeaders objectForKey:@"x-rate-limit-reset"];
                        
                        NSInteger remainingInteger = [remainingString integerValue];
                        NSInteger resetInteger = [resetString integerValue];
                        NSTimeInterval timeInterval = 0;
                        
                        if(remainingInteger == 0) {
                            NSDate *resetDate = [[NSDate alloc] initWithTimeIntervalSince1970:resetInteger];
                            timeInterval = [resetDate timeIntervalSinceDate:[NSDate date]] + 5;
                            pauseBlock([NSDate dateWithTimeIntervalSinceNow:timeInterval]);
                        }
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [self fetchAndFollowCursorsForResource:resource
                                                        HTTPMethod:HTTPMethod
                                                     baseURLString:baseURLString
                                                        parameters:paramsWithCursor
                                               uploadProgressBlock:uploadProgressBlock
                                             downloadProgressBlock:downloadProgressBlock
                                                      successBlock:successBlock
                                                        pauseBlock:pauseBlock
                                                        errorBlock:errorBlock];
                            
                        });
                        
                    } errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)getResource:(NSString *)resource
                                      baseURLString:(NSString *)baseURLString
                                         parameters:(NSDictionary *)parameters
//uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                              downloadProgressBlock:(void(^)(NSData *data))downloadProgressBlock
                                       successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:@"GET"
                   baseURLString:baseURLString
                      parameters:parameters
             uploadProgressBlock:nil
           downloadProgressBlock:^(id request, NSData *data) {
               if(downloadProgressBlock) downloadProgressBlock(data);
           } successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
               if(successBlock) successBlock(responseHeaders, response);
           } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
               if(errorBlock) errorBlock(error);
           }];
}

- (NSObject<STTwitterRequestProtocol> *)postResource:(NSString *)resource
                                       baseURLString:(NSString *)baseURLString
                                          parameters:(NSDictionary *)parameters
                                 uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                               downloadProgressBlock:(void(^)(NSData *data))downloadProgressBlock
                                        successBlock:(void(^)(NSDictionary *rateLimits, id response))successBlock
                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:@"POST"
                   baseURLString:baseURLString
                      parameters:parameters
             uploadProgressBlock:uploadProgressBlock
           downloadProgressBlock:^(id request, NSData *data) {
               if(downloadProgressBlock) downloadProgressBlock(data);
           } successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
               if(successBlock) successBlock(responseHeaders, response);
           } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
               if(errorBlock) errorBlock(error);
           }];
}

- (NSObject<STTwitterRequestProtocol> *)postResource:(NSString *)resource
                                       baseURLString:(NSString *)baseURLString
                                          parameters:(NSDictionary *)parameters
                                 uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                               downloadProgressBlock:(void(^)(NSData *data))downloadProgressBlock
                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:@"POST"
                   baseURLString:baseURLString
                      parameters:parameters
             uploadProgressBlock:uploadProgressBlock
           downloadProgressBlock:^(id request, NSData *data) {
               if(downloadProgressBlock) downloadProgressBlock(data);
           } successBlock:nil
                      errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                          errorBlock(error);
                      }];
}

- (NSObject<STTwitterRequestProtocol> *)getResource:(NSString *)resource
                                      baseURLString:(NSString *)baseURLString
                                         parameters:(NSDictionary *)parameters
                              downloadProgressBlock:(void(^)(NSData *data))downloadProgressBlock
                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:@"GET"
                   baseURLString:baseURLString
                      parameters:parameters
             uploadProgressBlock:nil
           downloadProgressBlock:^(id request, NSData *data) {
               if(downloadProgressBlock) downloadProgressBlock(data);
           } successBlock:nil
                      errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                          errorBlock(error);
                      }];
}

- (NSObject<STTwitterRequestProtocol> *)getAPIResource:(NSString *)resource
                                            parameters:(NSDictionary *)parameters
                                         progressBlock:(void(^)(NSData *data))progressBlock
                                          successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getResource:resource
               baseURLString:kBaseURLStringAPI_1_1
                  parameters:parameters
       downloadProgressBlock:progressBlock
                successBlock:successBlock
                  errorBlock:errorBlock];
}

// convenience
- (NSObject<STTwitterRequestProtocol> *)getAPIResource:(NSString *)resource
                                            parameters:(NSDictionary *)parameters
                                          successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getResource:resource
               baseURLString:kBaseURLStringAPI_1_1
                  parameters:parameters
       downloadProgressBlock:nil
                successBlock:successBlock
                  errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)postAPIResource:(NSString *)resource
                                             parameters:(NSDictionary *)parameters
                                    uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                          progressBlock:(void(^)(NSData *data))progressBlock
                                           successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self postResource:resource
                baseURLString:kBaseURLStringAPI_1_1
                   parameters:parameters
          uploadProgressBlock:uploadProgressBlock
        downloadProgressBlock:progressBlock
                 successBlock:successBlock
                   errorBlock:errorBlock];
}

// convenience
- (NSObject<STTwitterRequestProtocol> *)postAPIResource:(NSString *)resource
                                             parameters:(NSDictionary *)parameters
                                           successBlock:(void(^)(NSDictionary *rateLimits, id json))successBlock
                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self postResource:resource
                baseURLString:kBaseURLStringAPI_1_1
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
        successBlock(authenticationHeader);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// reverse auth step 2

- (void)postReverseAuthAccessTokenWithAuthenticationHeader:(NSString *)authenticationHeader
                                              successBlock:(void(^)(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName))successBlock
                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader successBlock:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName) {
        successBlock(oAuthToken, oAuthTokenSecret, userID, screenName);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

/**/

- (NSObject<STTwitterRequestProtocol> *)profileImageFor:(NSString *)screenName

                                           successBlock:(void(^)(id image))successBlock

                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    __weak typeof(self) weakSelf = self;
    
    return [self getUserInformationFor:screenName
                          successBlock:^(NSDictionary *response) {
                              
                              typeof(self) strongSelf = weakSelf;
                              
                              if(strongSelf == nil) return;
                              
                              NSString *imageURLString = [response objectForKey:@"profile_image_url"];
                              
                              STHTTPRequest *r = [STHTTPRequest requestWithURLString:imageURLString];
                              __weak STHTTPRequest *wr = r;
                              
                              r.timeoutSeconds = strongSelf.oauth.timeoutInSeconds;
                              
                              r.completionBlock = ^(NSDictionary *headers, NSString *body) {
                                  
                                  STHTTPRequest *sr = wr; // strong request
                                  
                                  NSData *imageData = sr.responseData;
                                  
#if TARGET_OS_IPHONE
                                  Class STImageClass = NSClassFromString(@"UIImage");
#else
                                  Class STImageClass = NSClassFromString(@"NSImage");
#endif
                                  successBlock([[STImageClass alloc] initWithData:imageData]);
                              };
                              
                              r.errorBlock = ^(NSError *error) {
                                  errorBlock(error);
                              };
                              
                              [r startAsynchronous];
                          } errorBlock:^(NSError *error) {
                              errorBlock(error);
                          }];
}

#pragma mark Timelines

- (NSObject<STTwitterRequestProtocol> *)getStatusesMentionTimelineWithCount:(NSString *)count
                                                                    sinceID:(NSString *)sinceID
                                                                      maxID:(NSString *)maxID
                                                                   trimUser:(NSNumber *)trimUser
                                                         contributorDetails:(NSNumber *)contributorDetails
                                                            includeEntities:(NSNumber *)includeEntities
                                                               successBlock:(void(^)(NSArray *statuses))successBlock
                                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"include_rts"] = @"1"; // "It is recommended you always send include_rts=1 when using this API method" https://dev.twitter.com/docs/api/1.1/get/statuses/mentions_timeline
    if(count) md[@"count"] = count;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"statuses/mentions_timeline.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getMentionsTimelineSinceID:(NSString *)sinceID
                                                             count:(NSUInteger)count
                                                      successBlock:(void(^)(NSArray *statuses))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getStatusesMentionTimelineWithCount:[@(count) description]
                                             sinceID:sinceID
                                               maxID:nil
                                            trimUser:nil
                                  contributorDetails:nil
                                     includeEntities:nil
                                        successBlock:^(NSArray *statuses) {
                                            successBlock(statuses);
                                        } errorBlock:^(NSError *error) {
                                            errorBlock(error);
                                        }];
}

/**/

- (NSObject<STTwitterRequestProtocol> *)getStatusesUserTimelineForUserID:(NSString *)userID
                                                              screenName:(NSString *)screenName
                                                                 sinceID:(NSString *)sinceID
                                                                   count:(NSString *)count
                                                                   maxID:(NSString *)maxID
                                                                trimUser:(NSNumber *)trimUser
                                                          excludeReplies:(NSNumber *)excludeReplies
                                                      contributorDetails:(NSNumber *)contributorDetails
                                                         includeRetweets:(NSNumber *)includeRetweets
                                                            successBlock:(void(^)(NSArray *statuses))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(sinceID) md[@"since_id"] = sinceID;
    if(count) md[@"count"] = count;
    if(maxID) md[@"max_id"] = maxID;
    
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(excludeReplies) md[@"exclude_replies"] = [excludeReplies boolValue] ? @"1" : @"0";
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeRetweets) md[@"include_rts"] = [includeRetweets boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"statuses/user_timeline.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getStatusesHomeTimelineWithCount:(NSString *)count
                                                                 sinceID:(NSString *)sinceID
                                                                   maxID:(NSString *)maxID
                                                                trimUser:(NSNumber *)trimUser
                                                          excludeReplies:(NSNumber *)excludeReplies
                                                      contributorDetails:(NSNumber *)contributorDetails
                                                         includeEntities:(NSNumber *)includeEntities
                                                            successBlock:(void(^)(NSArray *statuses))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(excludeReplies) md[@"exclude_replies"] = [excludeReplies boolValue] ? @"1" : @"0";
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"statuses/home_timeline.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getUserTimelineWithScreenName:(NSString *)screenName
                                                              sinceID:(NSString *)sinceID
                                                                maxID:(NSString *)maxID
                                                                count:(NSUInteger)count
                                                         successBlock:(void(^)(NSArray *statuses))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getStatusesUserTimelineForUserID:nil
                                       screenName:screenName
                                          sinceID:sinceID
                                            count:(count == NSNotFound ? nil : [@(count) description])
                                            maxID:maxID
                                         trimUser:nil
                                   excludeReplies:nil
                               contributorDetails:nil
                                  includeRetweets:nil
                                     successBlock:^(NSArray *statuses) {
                                         successBlock(statuses);
                                     } errorBlock:^(NSError *error) {
                                         errorBlock(error);
                                     }];
}

- (NSObject<STTwitterRequestProtocol> *)getUserTimelineWithScreenName:(NSString *)screenName
                                                                count:(NSUInteger)count
                                                         successBlock:(void(^)(NSArray *statuses))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getUserTimelineWithScreenName:screenName
                                       sinceID:nil
                                         maxID:nil
                                         count:count
                                  successBlock:successBlock
                                    errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)getUserTimelineWithScreenName:(NSString *)screenName
                                                         successBlock:(void(^)(NSArray *statuses))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getUserTimelineWithScreenName:screenName
                                         count:20
                                  successBlock:successBlock
                                    errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)getHomeTimelineSinceID:(NSString *)sinceID
                                                         count:(NSUInteger)count
                                                  successBlock:(void(^)(NSArray *statuses))successBlock
                                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *countString = count > 0 ? [@(count) description] : nil;
    
    return [self getStatusesHomeTimelineWithCount:countString
                                          sinceID:sinceID
                                            maxID:nil
                                         trimUser:nil
                                   excludeReplies:nil
                               contributorDetails:nil
                                  includeEntities:nil
                                     successBlock:^(NSArray *statuses) {
                                         successBlock(statuses);
                                     } errorBlock:^(NSError *error) {
                                         errorBlock(error);
                                     }];
}

- (NSObject<STTwitterRequestProtocol> *)getStatusesRetweetsOfMeWithCount:(NSString *)count
                                                                 sinceID:(NSString *)sinceID
                                                                   maxID:(NSString *)maxID
                                                                trimUser:(NSNumber *)trimUser
                                                         includeEntities:(NSNumber *)includeEntities
                                                     includeUserEntities:(NSNumber *)includeUserEntities
                                                            successBlock:(void(^)(NSArray *statuses))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"statuses/retweets_of_me.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// convenience method, shorter
- (NSObject<STTwitterRequestProtocol> *)getStatusesRetweetsOfMeWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    return [self getStatusesRetweetsOfMeWithCount:nil
                                          sinceID:nil
                                            maxID:nil
                                         trimUser:nil
                                  includeEntities:nil
                              includeUserEntities:nil
                                     successBlock:^(NSArray *statuses) {
                                         successBlock(statuses);
                                     } errorBlock:^(NSError *error) {
                                         errorBlock(error);
                                     }];
}

#pragma mark Tweets

- (NSObject<STTwitterRequestProtocol> *)getStatusesRetweetsForID:(NSString *)statusID
                                                           count:(NSString *)count
                                                        trimUser:(NSNumber *)trimUser
                                                    successBlock:(void(^)(NSArray *statuses))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweets/%@.json", statusID];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:resource parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getStatusesShowID:(NSString *)statusID
                                                 trimUser:(NSNumber *)trimUser
                                         includeMyRetweet:(NSNumber *)includeMyRetweet
                                          includeEntities:(NSNumber *)includeEntities
                                             successBlock:(void(^)(NSDictionary *status))successBlock
                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"id"] = statusID;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(includeMyRetweet) md[@"include_my_retweet"] = [includeMyRetweet boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"statuses/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postStatusesDestroy:(NSString *)statusID
                                                   trimUser:(NSNumber *)trimUser
                                               successBlock:(void(^)(NSDictionary *status))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"statuses/destroy/%@.json", statusID];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = statusID;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:resource parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postStatusUpdate:(NSString *)status
                                       inReplyToStatusID:(NSString *)existingStatusID
                                                mediaIDs:(NSArray *)mediaIDs
                                                latitude:(NSString *)latitude
                                               longitude:(NSString *)longitude
                                                 placeID:(NSString *)placeID // wins over lat/lon
                                      displayCoordinates:(NSNumber *)displayCoordinates
                                                trimUser:(NSNumber *)trimUser
                                            successBlock:(void(^)(NSDictionary *status))successBlock
                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    if([mediaIDs count] == 0 && status == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterAPICannotPostEmptyStatus userInfo:@{NSLocalizedDescriptionKey : @"cannot post empty status"}];
        errorBlock(error);
        return nil;
    }
    
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:status forKey:@"status"];
    
    if([mediaIDs count] > 0) {
        NSString *mediaIDsString = [mediaIDs componentsJoinedByString:@","];
        md[@"media_ids"] = mediaIDsString;
    }
    
    if(existingStatusID) {
        md[@"in_reply_to_status_id"] = existingStatusID;
    }
    
    if(placeID) {
        md[@"place_id"] = placeID;
        md[@"display_coordinates"] = @"true";
    } else if(latitude && longitude) {
        md[@"lat"] = latitude;
        md[@"lon"] = longitude;
        md[@"display_coordinates"] = @"true";
    }
    
    return [self postAPIResource:@"statuses/update.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postStatusUpdate:(NSString *)status
                                       inReplyToStatusID:(NSString *)existingStatusID
                                                latitude:(NSString *)latitude
                                               longitude:(NSString *)longitude
                                                 placeID:(NSString *)placeID // wins over lat/lon
                                      displayCoordinates:(NSNumber *)displayCoordinates
                                                trimUser:(NSNumber *)trimUser
                                            successBlock:(void(^)(NSDictionary *status))successBlock
                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self postStatusUpdate:status
                inReplyToStatusID:existingStatusID
                         mediaIDs:nil
                         latitude:latitude
                        longitude:longitude
                          placeID:placeID
               displayCoordinates:displayCoordinates
                         trimUser:trimUser
                     successBlock:successBlock
                       errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)postStatusUpdate:(NSString *)status
                                          mediaDataArray:(NSArray *)mediaDataArray // only one media is currently supported, help/configuration.json returns "max_media_per_upload" = 1
                                       possiblySensitive:(NSNumber *)possiblySensitive
                                       inReplyToStatusID:(NSString *)inReplyToStatusID
                                                latitude:(NSString *)latitude
                                               longitude:(NSString *)longitude
                                                 placeID:(NSString *)placeID
                                      displayCoordinates:(NSNumber *)displayCoordinates
                                     uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                            successBlock:(void(^)(NSDictionary *status))successBlock
                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(status);
    NSAssert([mediaDataArray count] > 0, @"media data array must not be empty");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"status"] = status;
    if(possiblySensitive) md[@"possibly_sensitive"] = [possiblySensitive boolValue] ? @"1" : @"0";
    if(displayCoordinates) md[@"display_coordinates"] = [displayCoordinates boolValue] ? @"1" : @"0";
    if(inReplyToStatusID) md[@"in_reply_to_status_id"] = inReplyToStatusID;
    if(latitude) md[@"lat"] = latitude;
    if(longitude) md[@"long"] = longitude;
    if(placeID) md[@"place_id"] = placeID;
    md[@"media[]"] = [mediaDataArray objectAtIndex:0];
    md[kSTPOSTDataKey] = @"media[]";
    
    return [self postResource:@"statuses/update_with_media.json"
                baseURLString:kBaseURLStringAPI_1_1
                   parameters:md
          uploadProgressBlock:uploadProgressBlock
        downloadProgressBlock:nil
                 successBlock:^(NSDictionary *rateLimits, id response) {
                     successBlock(response);
                 } errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)postStatusUpdate:(NSString *)status
                                       inReplyToStatusID:(NSString *)existingStatusID
                                                mediaURL:(NSURL *)mediaURL
                                                 placeID:(NSString *)placeID
                                                latitude:(NSString *)latitude
                                               longitude:(NSString *)longitude
                                     uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                            successBlock:(void(^)(NSDictionary *status))successBlock
                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSData *data = [NSData dataWithContentsOfURL:mediaURL];
    
    if(data == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterAPIMediaDataIsEmpty userInfo:@{NSLocalizedDescriptionKey : @"data is nil"}];
        errorBlock(error);
        return nil;
    }
    
    return [self postStatusUpdate:status
                   mediaDataArray:@[data]
                possiblySensitive:nil
                inReplyToStatusID:existingStatusID
                         latitude:latitude
                        longitude:longitude
                          placeID:placeID
               displayCoordinates:@(YES)
              uploadProgressBlock:uploadProgressBlock
                     successBlock:^(NSDictionary *status) {
                         successBlock(status);
                     } errorBlock:^(NSError *error) {
                         errorBlock(error);
                     }];
}

// GET statuses/oembed

- (NSObject<STTwitterRequestProtocol> *)getStatusesOEmbedForStatusID:(NSString *)statusID
                                                           urlString:(NSString *)urlString
                                                            maxWidth:(NSString *)maxWidth
                                                           hideMedia:(NSNumber *)hideMedia
                                                          hideThread:(NSNumber *)hideThread
                                                          omitScript:(NSNumber *)omitScript
                                                               align:(NSString *)align // 'left', 'right', 'center' or 'none' (default)
                                                             related:(NSString *)related // eg. twitterapi,twittermedia,twitter
                                                                lang:(NSString *)lang
                                                        successBlock:(void(^)(NSDictionary *status))successBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    NSParameterAssert(urlString);
    
#if DEBUG
    if(align) {
        NSArray *validValues = @[@"left", @"right", @"center", @"none"];
        NSAssert([validValues containsObject: align], @"");
    }
#endif
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = statusID;
    md[@"url"] = urlString;
    
    if(maxWidth) md[@"maxwidth"] = maxWidth;
    
    if(hideMedia) md[@"hide_media"] = [hideMedia boolValue] ? @"1" : @"0";
    if(hideThread) md[@"hide_thread"] = [hideThread boolValue] ? @"1" : @"0";
    if(omitScript) md[@"omit_script"] = [omitScript boolValue] ? @"1" : @"0";
    
    if(align) md[@"align"] = align;
    if(related) md[@"related"] = related;
    if(lang) md[@"lang"] = lang;
    
    return [self getAPIResource:@"statuses/oembed.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	statuses/retweet/:id
- (NSObject<STTwitterRequestProtocol> *)postStatusRetweetWithID:(NSString *)statusID
                                                       trimUser:(NSNumber *)trimUser
                                                   successBlock:(void(^)(NSDictionary *status))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweet/%@.json", statusID];
    
    return [self postAPIResource:resource parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postStatusRetweetWithID:(NSString *)statusID
                                                   successBlock:(void(^)(NSDictionary *status))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self postStatusRetweetWithID:statusID
                                trimUser:nil
                            successBlock:^(NSDictionary *status) {
                                successBlock(status);
                            } errorBlock:^(NSError *error) {
                                errorBlock(error);
                            }];
}

- (NSObject<STTwitterRequestProtocol> *)getStatusesRetweetersIDsForStatusID:(NSString *)statusID
                                                                     cursor:(NSString *)cursor
                                                               successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"id"] = statusID;
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    
    return [self getAPIResource:@"statuses/retweeters/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        NSArray *ids = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            previousCursor = response[@"previous_cursor_str"];
            nextCursor = response[@"next_cursor_str"];
            ids = response[@"ids"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
    
}

- (NSObject<STTwitterRequestProtocol> *)getListsSubscriptionsForUserID:(NSString *)userID
                                                          orScreenName:(NSString *)screenName
                                                                 count:(NSString *)count
                                                                cursor:(NSString *)cursor
                                                          successBlock:(void(^)(NSArray *lists, NSString *previousCursor, NSString *nextCursor))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) {
        md[@"user_id"] = userID;
    } else if (screenName) {
        md[@"screen_name"] = screenName;
    }
    
    if(count) md[@"count"] = count;
    if(cursor) md[@"cursor"] = cursor;
    
    return [self getAPIResource:@"lists/subscriptions.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *lists = [response valueForKey:@"lists"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(lists, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

//  GET     lists/ownerships

- (NSObject<STTwitterRequestProtocol> *)getListsOwnershipsForUserID:(NSString *)userID
                                                       orScreenName:(NSString *)screenName
                                                              count:(NSString *)count
                                                             cursor:(NSString *)cursor
                                                       successBlock:(void(^)(NSArray *lists, NSString *previousCursor, NSString *nextCursor))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) {
        md[@"user_id"] = userID;
    } else if (screenName) {
        md[@"screen_name"] = screenName;
    }
    
    if(count) md[@"count"] = count;
    if(cursor) md[@"cursor"] = cursor;
    
    return [self getAPIResource:@"lists/ownerships.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *lists = [response valueForKey:@"lists"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(lists, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Search

- (NSObject<STTwitterRequestProtocol> *)getSearchTweetsWithQuery:(NSString *)q
                                                         geocode:(NSString *)geoCode // eg. "37.781157,-122.398720,1mi"
                                                            lang:(NSString *)lang // eg. "eu"
                                                          locale:(NSString *)locale // eg. "ja"
                                                      resultType:(NSString *)resultType // eg. "mixed, recent, popular"
                                                           count:(NSString *)count // eg. "100"
                                                           until:(NSString *)until // eg. "2012-09-01"
                                                         sinceID:(NSString *)sinceID // eg. "12345"
                                                           maxID:(NSString *)maxID // eg. "54321"
                                                 includeEntities:(NSNumber *)includeEntities
                                                        callback:(NSString *)callback // eg. "processTweets"
                                                    successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSParameterAssert(q);
    
    if(geoCode) md[@"geocode"] = geoCode;
    if(lang) md[@"lang"] = lang;
    if(locale) md[@"locale"] = locale;
    if(resultType) md[@"result_type"] = resultType;
    if(count) md[@"count"] = count;
    if(until) md[@"until"] = until;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(callback) md[@"callback"] = callback;
    
    // eg. "(from:nst021 OR to:nst021)" -> "%28from%3Anst021%20OR%20to%3Anst021%29"
    // md[@"q"] = @"(from:nst021 OR to:nst021)";
    md[@"q"] = q;
    
    return [self getAPIResource:@"search/tweets.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *searchMetadata = [response valueForKey:@"search_metadata"];
        NSArray *statuses = [response valueForKey:@"statuses"];
        
        successBlock(searchMetadata, statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getSearchTweetsWithQuery:(NSString *)q
                                                    successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getSearchTweetsWithQuery:q
                                  geocode:nil
                                     lang:nil
                                   locale:nil
                               resultType:nil
                                    count:nil
                                    until:nil
                                  sinceID:nil
                                    maxID:nil
                          includeEntities:@(YES)
                                 callback:nil
                             successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
                                 successBlock(searchMetadata, statuses);
                             } errorBlock:^(NSError *error) {
                                 errorBlock(error);
                             }];
}

#pragma mark Streaming

+ (NSDictionary *)stallWarningDictionaryFromJSON:(NSString *)json {
    if([json isKindOfClass:[NSDictionary class]]) return nil;
    return [json valueForKey:@"warning"];
}

// POST statuses/filter

- (NSObject<STTwitterRequestProtocol> *)postStatusesFilterUserIDs:(NSArray *)userIDs
                                                  keywordsToTrack:(NSArray *)keywordsToTrack
                                            locationBoundingBoxes:(NSArray *)locationBoundingBoxes
                                                    stallWarnings:(NSNumber *)stallWarnings
                                                    progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *follow = [userIDs componentsJoinedByString:@","];
    NSString *keywords = [keywordsToTrack componentsJoinedByString:@","];
    NSString *locations = [locationBoundingBoxes componentsJoinedByString:@","];
    
    NSAssert(([follow length] || [keywords length] || [locations length]), @"At least one predicate parameter (follow, locations, or track) must be specified.");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"delimited"] = @"length";
    
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    
    if([follow length]) md[@"follow"] = follow;
    if([keywords length]) md[@"track"] = keywords;
    if([locations length]) md[@"locations"] = locations;
    
    self.streamParser = [[STTwitterStreamParser alloc] init];
    __weak STTwitterStreamParser *streamParser = self.streamParser;
    
    return [self postResource:@"statuses/filter.json"
                baseURLString:kBaseURLStringStream_1_1
                   parameters:md
          uploadProgressBlock:nil
        downloadProgressBlock:^(NSData *data) {
            
            if (streamParser) {
                [streamParser parseWithStreamData:data parsedJSONBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                    progressBlock(json, type);
                }];
            }
            
        } successBlock:^(NSDictionary *rateLimits, id response) {
            if([response isKindOfClass:[NSString class]] && [response length] == 0) {
                NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterAPIEmptyStream userInfo:@{NSLocalizedDescriptionKey : @"stream is empty"}];
                errorBlock(error);
                return;
            };
            
            // reaching successBlock for a stream request is an error
            errorBlock(response);
        } errorBlock:^(NSError *error) {
            errorBlock(error);
        }];
}

// convenience
- (NSObject<STTwitterRequestProtocol> *)postStatusesFilterKeyword:(NSString *)keyword
                                                       tweetBlock:(void(^)(NSDictionary *tweet))tweetBlock
                                                stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock
{
    NSParameterAssert(keyword);
    
    return [self postStatusesFilterUserIDs:nil
                           keywordsToTrack:@[keyword]
                     locationBoundingBoxes:nil
                             stallWarnings:stallWarningBlock ? @YES : @NO
                             progressBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                                 
                                 switch (type) {
                                     case STTwitterStreamJSONTypeTweet:
                                         tweetBlock(json);
                                         break;
                                     case STTwitterStreamJSONTypeWarning:
                                         if (stallWarningBlock) {
                                             stallWarningBlock([json valueForKey:@"code"],
                                                               [json valueForKey:@"message"],
                                                               [[json valueForKey:@"percent_full"] integerValue]);
                                         }
                                         break;
                                     default:
                                         break;
                                 }
                                 
                             } errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)postStatusesFilterKeyword:(NSString *)keyword
                                                       tweetBlock:(void(^)(NSDictionary *tweet))tweetBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock
{
    return [self postStatusesFilterKeyword:keyword
                                tweetBlock:tweetBlock
                         stallWarningBlock:nil
                                errorBlock:errorBlock];
}

// GET statuses/sample
- (NSObject<STTwitterRequestProtocol> *)getStatusesSampleStallWarnings:(NSNumber *)stallWarnings
                                                         progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"delimited"] = @"length";
    
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    
    self.streamParser = [[STTwitterStreamParser alloc] init];
    __weak STTwitterStreamParser *streamParser = self.streamParser;
    
    return [self getResource:@"statuses/sample.json"
               baseURLString:kBaseURLStringStream_1_1
                  parameters:md
       downloadProgressBlock:^(id response) {
           
           if (streamParser) {
               [streamParser parseWithStreamData:response parsedJSONBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                   progressBlock(json, type);
               }];
           }
           
       } successBlock:^(NSDictionary *rateLimits, id json) {
           // reaching successBlock for a stream request is an error
           errorBlock(json);
       } errorBlock:^(NSError *error) {
           errorBlock(error);
       }];
}

// convenience
- (NSObject<STTwitterRequestProtocol> *)getStatusesSampleTweetBlock:(void (^)(NSDictionary *))tweetBlock
                                                  stallWarningBlock:(void (^)(NSString *, NSString *, NSUInteger))stallWarningBlock
                                                         errorBlock:(void (^)(NSError *))errorBlock
{
    return [self getStatusesSampleStallWarnings:stallWarningBlock ? @YES : @NO
                                  progressBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                                      
                                      switch (type) {
                                          case STTwitterStreamJSONTypeTweet:
                                              tweetBlock(json);
                                              break;
                                          case STTwitterStreamJSONTypeWarning:
                                              if (stallWarningBlock) {
                                                  stallWarningBlock([json valueForKey:@"code"],
                                                                    [json valueForKey:@"message"],
                                                                    [[json valueForKey:@"percent_full"] integerValue]);
                                              }
                                              break;
                                          default:
                                              break;
                                      }
                                      
                                  } errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)getStatusesSampleTweetBlock:(void (^)(NSDictionary *))tweetBlock
                                                         errorBlock:(void (^)(NSError *))errorBlock
{
    return [self getStatusesSampleTweetBlock:tweetBlock
                           stallWarningBlock:nil
                                  errorBlock:errorBlock];
}

// GET statuses/firehose
- (NSObject<STTwitterRequestProtocol> *)getStatusesFirehoseWithCount:(NSString *)count
                                                       stallWarnings:(NSNumber *)stallWarnings
                                                       progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"delimited"] = @"length";
    
    if(count) md[@"count"] = count;
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    
    self.streamParser = [[STTwitterStreamParser alloc] init];
    __weak STTwitterStreamParser *streamParser = self.streamParser;
    
    return [self getResource:@"statuses/firehose.json"
               baseURLString:kBaseURLStringStream_1_1
                  parameters:md
       downloadProgressBlock:^(id response) {
           
           if (streamParser) {
               [streamParser parseWithStreamData:response parsedJSONBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                   progressBlock(json, type);
               }];
           }
           
       } successBlock:^(NSDictionary *rateLimits, id json) {
           // reaching successBlock for a stream request is an error
           errorBlock(json);
       } errorBlock:^(NSError *error) {
           errorBlock(error);
       }];
}

// GET user
- (NSObject<STTwitterRequestProtocol> *)getUserStreamStallWarnings:(NSNumber *)stallWarnings
                               includeMessagesFromFollowedAccounts:(NSNumber *)includeMessagesFromFollowedAccounts // default: @(NO)
                                                    includeReplies:(NSNumber *)includeReplies
                                                   keywordsToTrack:(NSArray *)keywordsToTrack
                                             locationBoundingBoxes:(NSArray *)locationBoundingBoxes
                                                     progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_friend_ids"] = @"1";
    md[@"delimited"] = @"length";
    
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    if(includeMessagesFromFollowedAccounts) md[@"with"] = @"followings";
    if(includeReplies && [includeReplies boolValue]) md[@"replies"] = @"all";
    
    NSString *keywords = [keywordsToTrack componentsJoinedByString:@","];
    NSString *locations = [locationBoundingBoxes componentsJoinedByString:@","];
    
    if([keywords length]) md[@"track"] = keywords;
    if([locations length]) md[@"locations"] = locations;
    
    self.streamParser = [[STTwitterStreamParser alloc] init];
    __weak STTwitterStreamParser *streamParser = self.streamParser;
    
    return [self getResource:@"user.json"
               baseURLString:kBaseURLStringUserStream_1_1
                  parameters:md
       downloadProgressBlock:^(id response) {
           
           if (streamParser) {
               [streamParser parseWithStreamData:response parsedJSONBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                   progressBlock(json, type);
               }];
           }
           
       } successBlock:^(NSDictionary *rateLimits, id json) {
           // reaching successBlock for a stream request is an error
           errorBlock(json);
       } errorBlock:^(NSError *error) {
           errorBlock(error);
       }];
}

// convenience
- (NSObject<STTwitterRequestProtocol> *)getUserStreamIncludeMessagesFromFollowedAccounts:(NSNumber *)includeMessagesFromFollowedAccounts
                                                                          includeReplies:(NSNumber *)includeReplies
                                                                         keywordsToTrack:(NSArray *)keywordsToTrack
                                                                   locationBoundingBoxes:(NSArray *)locationBoundingBoxes
                                                                              tweetBlock:(void(^)(NSDictionary *tweet))tweetBlock
                                                                       stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                                                                              errorBlock:(void(^)(NSError *error))errorBlock;
{
    return [self getUserStreamStallWarnings:stallWarningBlock ? @YES : @NO
        includeMessagesFromFollowedAccounts:includeMessagesFromFollowedAccounts
                             includeReplies:includeReplies
                            keywordsToTrack:keywordsToTrack
                      locationBoundingBoxes:locationBoundingBoxes
                              progressBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                                  
                                  switch (type) {
                                      case STTwitterStreamJSONTypeTweet:
                                          tweetBlock(json);
                                          break;
                                      case STTwitterStreamJSONTypeWarning:
                                          if (stallWarningBlock) {
                                              stallWarningBlock([json valueForKey:@"code"],
                                                                [json valueForKey:@"message"],
                                                                [[json valueForKey:@"percent_full"] integerValue]);
                                          }
                                          break;
                                      default:
                                          break;
                                  }
                                  
                              } errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)getUserStreamIncludeMessagesFromFollowedAccounts:(NSNumber *)includeMessagesFromFollowedAccounts
                                                                          includeReplies:(NSNumber *)includeReplies
                                                                         keywordsToTrack:(NSArray *)keywordsToTrack
                                                                   locationBoundingBoxes:(NSArray *)locationBoundingBoxes
                                                                              tweetBlock:(void(^)(NSDictionary *tweet))tweetBlock
                                                                              errorBlock:(void(^)(NSError *error))errorBlock
{
    return [self getUserStreamIncludeMessagesFromFollowedAccounts:includeMessagesFromFollowedAccounts
                                                   includeReplies:includeReplies
                                                  keywordsToTrack:keywordsToTrack
                                            locationBoundingBoxes:locationBoundingBoxes
                                                       tweetBlock:tweetBlock
                                                stallWarningBlock:nil
                                                       errorBlock:errorBlock];
}

// GET site
- (NSObject<STTwitterRequestProtocol> *)getSiteStreamForUserIDs:(NSArray *)userIDs
                                                      delimited:(NSNumber *)delimited
                                                  stallWarnings:(NSNumber *)stallWarnings
                                         restrictToUserMessages:(NSNumber *)restrictToUserMessages
                                                 includeReplies:(NSNumber *)includeReplies
                                                  progressBlock:(void (^)(NSDictionary *, STTwitterStreamJSONType))progressBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_friend_ids"] = @"1";
    if(delimited) md[@"delimited"] = [delimited boolValue] ? @"1" : @"0";
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    if(restrictToUserMessages) md[@"with"] = @"user"; // default is 'followings'
    if(includeReplies && [includeReplies boolValue]) md[@"replies"] = @"all";
    
    NSString *follow = [userIDs componentsJoinedByString:@","];
    if([follow length]) md[@"follow"] = follow;
    
    self.streamParser = [[STTwitterStreamParser alloc] init];
    __weak STTwitterStreamParser *streamParser = self.streamParser;
    
    return [self getResource:@"site.json"
               baseURLString:kBaseURLStringSiteStream_1_1
                  parameters:md
       downloadProgressBlock:^(NSData *data) {
           
           if (streamParser) {
               [streamParser parseWithStreamData:data parsedJSONBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                   progressBlock(json, type);
               }];
           }
           
       } successBlock:^(NSDictionary *rateLimits, id json) {
           // reaching successBlock for a stream request is an error
           errorBlock(json);
       } errorBlock:^(NSError *error) {
           errorBlock(error);
       }];
}

#pragma mark Direct Messages

- (NSObject<STTwitterRequestProtocol> *)getDirectMessagesSinceID:(NSString *)sinceID
                                                           maxID:(NSString *)maxID
                                                           count:(NSString *)count
                                                        fullText:(NSNumber *)fullText
                                                 includeEntities:(NSNumber *)includeEntities
                                                      skipStatus:(NSNumber *)skipStatus
                                                    successBlock:(void(^)(NSArray *messages))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) [md setObject:sinceID forKey:@"since_id"];
    if(maxID) [md setObject:maxID forKey:@"max_id"];
    if(count) [md setObject:count forKey:@"count"];
    if(fullText) md[@"full_text"] = [fullText boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"direct_messages.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// convenience
- (NSObject<STTwitterRequestProtocol> *)getDirectMessagesSinceID:(NSString *)sinceID
                                                           count:(NSUInteger)count
                                                    successBlock:(void(^)(NSArray *messages))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *countString = count > 0 ? [@(count) description] : nil;
    
    return [self getDirectMessagesSinceID:sinceID
                                    maxID:nil
                                    count:countString
                                 fullText:@(1)
                          includeEntities:nil
                               skipStatus:nil
                             successBlock:^(NSArray *statuses) {
                                 successBlock(statuses);
                             } errorBlock:^(NSError *error) {
                                 errorBlock(error);
                             }];
}

- (NSObject<STTwitterRequestProtocol> *)getDirectMessagesSinceID:(NSString *)sinceID
                                                           maxID:(NSString *)maxID
                                                           count:(NSString *)count
                                                        fullText:(NSNumber *)fullText
                                                            page:(NSString *)page
                                                 includeEntities:(NSNumber *)includeEntities
                                                    successBlock:(void(^)(NSArray *messages))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) [md setObject:sinceID forKey:@"since_id"];
    if(maxID) [md setObject:maxID forKey:@"max_id"];
    if(count) [md setObject:count forKey:@"count"];
    if(fullText) md[@"full_text"] = [fullText boolValue] ? @"1" : @"0";
    if(page) [md setObject:page forKey:@"page"];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"direct_messages/sent.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getDirectMessagesShowWithID:(NSString *)messageID
                                                           fullText:(NSNumber *)fullText
                                                       successBlock:(void(^)(NSArray *messages))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = messageID;
    if(fullText) md[@"full_text"] = [fullText boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"direct_messages/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
    
}

- (NSObject<STTwitterRequestProtocol> *)postDestroyDirectMessageWithID:(NSString *)messageID
                                                       includeEntities:(NSNumber *)includeEntities
                                                          successBlock:(void(^)(NSDictionary *message))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = messageID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"direct_messages/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postDirectMessage:(NSString *)status
                                            forScreenName:(NSString *)screenName
                                                 orUserID:(NSString *)userID
                                             successBlock:(void(^)(NSDictionary *message))successBlock
                                               errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:status forKey:@"text"];
    
    NSAssert(screenName != nil || userID != nil, @"screenName OR userID is required");
    
    if(screenName) {
        md[@"screen_name"] = screenName;
    } else {
        md[@"user_id"] = userID;
    }
    
    return [self postAPIResource:@"direct_messages/new.json"
                      parameters:md
                    successBlock:^(NSDictionary *rateLimits, id response) {
                        successBlock(response);
                    } errorBlock:^(NSError *error) {
                        errorBlock(error);
                    }];
}

- (NSObject<STTwitterRequestProtocol> *)_postDirectMessage:(NSString *)status
                                             forScreenName:(NSString *)screenName
                                                  orUserID:(NSString *)userID
                                                   mediaID:(NSString *)mediaID
                                              successBlock:(void(^)(NSDictionary *message))successBlock
                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:status forKey:@"text"];
    
    NSAssert(screenName != nil || userID != nil, @"screenName OR userID is required");
    
    if(screenName) {
        md[@"screen_name"] = screenName;
    } else {
        md[@"user_id"] = userID;
    }
    
    if(mediaID) md[@"media_id"] = mediaID;
    
    return [self postAPIResource:@"direct_messages/new.json"
                      parameters:md
                    successBlock:^(NSDictionary *rateLimits, id response) {
                        successBlock(response);
                    } errorBlock:^(NSError *error) {
                        errorBlock(error);
                    }];
}

#pragma mark Friends & Followers

- (NSObject<STTwitterRequestProtocol> *)getFriendshipNoRetweetsIDsWithSuccessBlock:(void(^)(NSArray *ids))successBlock
                                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_ids"] = @"1";
    
    return [self getAPIResource:@"friendships/no_retweets/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getFriendsIDsForUserID:(NSString *)userID
                                                  orScreenName:(NSString *)screenName
                                                        cursor:(NSString *)cursor
                                                         count:(NSString *)count
                                                  successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    
    if(count) md[@"count"] = count;
    
    return [self getAPIResource:@"friends/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *ids = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            ids = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getFriendsIDsForScreenName:(NSString *)screenName
                                                      successBlock:(void(^)(NSArray *friends))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getFriendsIDsForUserID:nil
                           orScreenName:screenName
                                 cursor:nil
                                  count:nil
                           successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                               successBlock(ids);
                           } errorBlock:^(NSError *error) {
                               errorBlock(error);
                           }];
}

- (NSObject<STTwitterRequestProtocol> *)getFollowersIDsForUserID:(NSString *)userID
                                                    orScreenName:(NSString *)screenName
                                                          cursor:(NSString *)cursor
                                                           count:(NSString *)count
                                                    successBlock:(void(^)(NSArray *followersIDs, NSString *previousCursor, NSString *nextCursor))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    if(count) md[@"count"] = count;
    
    return [self getAPIResource:@"followers/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *followersIDs = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            followersIDs = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(followersIDs, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getFollowersIDsForScreenName:(NSString *)screenName
                                                        successBlock:(void(^)(NSArray *followers))successBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getFollowersIDsForUserID:nil
                             orScreenName:screenName
                                   cursor:nil
                                    count:nil
                             successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                                 successBlock(ids);
                             } errorBlock:^(NSError *error) {
                                 errorBlock(error);
                             }];
}

- (NSObject<STTwitterRequestProtocol> *)getFriendshipsLookupForScreenNames:(NSArray *)screenNames
                                                                 orUserIDs:(NSArray *)userIDs
                                                              successBlock:(void(^)(NSArray *users))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenNames || userIDs), @"missing screen names or user IDs");
    
    NSString *commaSeparatedScreenNames = [screenNames componentsJoinedByString:@","];
    NSString *commaSeparatedUserIDs = [userIDs componentsJoinedByString:@","];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(commaSeparatedScreenNames) md[@"screen_name"] = commaSeparatedScreenNames;
    if(commaSeparatedUserIDs) md[@"user_id"] = commaSeparatedUserIDs;
    
    return [self getAPIResource:@"friendships/lookup.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getFriendshipIncomingWithCursor:(NSString *)cursor
                                                           successBlock:(void(^)(NSArray *IDs, NSString *previousCursor, NSString *nextCursor))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    
    return [self getAPIResource:@"friendships/incoming.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *ids = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            ids = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getFriendshipOutgoingWithCursor:(NSString *)cursor
                                                           successBlock:(void(^)(NSArray *IDs, NSString *previousCursor, NSString *nextCursor))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    
    return [self getAPIResource:@"friendships/outgoing.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *ids = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            ids = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postFriendshipsCreateForScreenName:(NSString *)screenName
                                                                  orUserID:(NSString *)userID
                                                              successBlock:(void(^)(NSDictionary *befriendedUser))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    return [self postAPIResource:@"friendships/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postFollow:(NSString *)screenName
                                      successBlock:(void(^)(NSDictionary *user))successBlock
                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self postFriendshipsCreateForScreenName:screenName orUserID:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postFriendshipsDestroyScreenName:(NSString *)screenName
                                                                orUserID:(NSString *)userID
                                                            successBlock:(void(^)(NSDictionary *unfollowedUser))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    return [self postAPIResource:@"friendships/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postUnfollow:(NSString *)screenName
                                        successBlock:(void(^)(NSDictionary *user))successBlock
                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self postFriendshipsDestroyScreenName:screenName orUserID:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                                                  orUserID:(NSString *)userID
                                                 enableDeviceNotifications:(NSNumber *)enableDeviceNotifications
                                                            enableRetweets:(NSNumber *)enableRetweets
                                                              successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(enableDeviceNotifications) md[@"device"] = [enableDeviceNotifications boolValue] ? @"1" : @"0";
    if(enableRetweets) md[@"retweets"] = [enableRetweets boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"friendships/update.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                                                  orUserID:(NSString *)userID
                                                 enableDeviceNotifications:(BOOL)enableDeviceNotifications
                                                              successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    return [self postFriendshipsUpdateForScreenName:screenName
                                           orUserID:userID
                          enableDeviceNotifications:@(enableDeviceNotifications)
                                     enableRetweets:nil
                                       successBlock:^(NSDictionary *user) {
                                           successBlock(user);
                                       } errorBlock:^(NSError *error) {
                                           errorBlock(error);
                                       }];
}

- (NSObject<STTwitterRequestProtocol> *)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                                                  orUserID:(NSString *)userID
                                                            enableRetweets:(BOOL)enableRetweets
                                                              successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    return [self postFriendshipsUpdateForScreenName:screenName
                                           orUserID:userID
                          enableDeviceNotifications:nil
                                     enableRetweets:@(enableRetweets)
                                       successBlock:^(NSDictionary *user) {
                                           successBlock(user);
                                       } errorBlock:^(NSError *error) {
                                           errorBlock(error);
                                       }];
}

- (NSObject<STTwitterRequestProtocol> *)getFriendshipShowForSourceID:(NSString *)sourceID
                                                  orSourceScreenName:(NSString *)sourceScreenName
                                                            targetID:(NSString *)targetID
                                                  orTargetScreenName:(NSString *)targetScreenName
                                                        successBlock:(void(^)(id relationship))successBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((sourceID || sourceScreenName), @"sourceID or sourceScreenName is missing");
    NSAssert((targetID || targetScreenName), @"targetID or targetScreenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sourceID) md[@"source_id"] = sourceID;
    if(sourceScreenName) md[@"source_screen_name"] = sourceScreenName;
    if(targetID) md[@"target_id"] = targetID;
    if(targetScreenName) md[@"target_screen_name"] = targetScreenName;
    
    return [self getAPIResource:@"friendships/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getFriendsListForUserID:(NSString *)userID
                                                   orScreenName:(NSString *)screenName
                                                         cursor:(NSString *)cursor
                                                          count:(NSString *)count
                                                     skipStatus:(NSNumber *)skipStatus
                                            includeUserEntities:(NSNumber *)includeUserEntities
                                                   successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(count) md[@"count"] = count;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"friends/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            users = [response valueForKey:@"users"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getFriendsForScreenName:(NSString *)screenName
                                                   successBlock:(void(^)(NSArray *friends))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getFriendsListForUserID:nil
                            orScreenName:screenName
                                  cursor:nil
                                   count:nil
                              skipStatus:@(NO)
                     includeUserEntities:@(YES)
                            successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                successBlock(users);
                            } errorBlock:^(NSError *error) {
                                errorBlock(error);
                            }];
}

- (NSObject<STTwitterRequestProtocol> *)getFollowersListForUserID:(NSString *)userID
                                                     orScreenName:(NSString *)screenName
                                                            count:(NSString *)count
                                                           cursor:(NSString *)cursor
                                                       skipStatus:(NSNumber *)skipStatus
                                              includeUserEntities:(NSNumber *)includeUserEntities
                                                     successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(count) md[@"count"] = count;
    if(cursor) md[@"cursor"] = cursor;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"followers/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            users = [response valueForKey:@"users"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// convenience
- (NSObject<STTwitterRequestProtocol> *)getFollowersForScreenName:(NSString *)screenName
                                                     successBlock:(void(^)(NSArray *followers))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getFollowersListForUserID:nil
                              orScreenName:screenName
                                     count:nil
                                    cursor:nil
                                skipStatus:nil
                       includeUserEntities:nil
                              successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                  successBlock(users);
                              } errorBlock:^(NSError *error) {
                                  errorBlock(error);
                              }];
}

#pragma mark Users

// GET account/settings
- (NSObject<STTwitterRequestProtocol> *)getAccountSettingsWithSuccessBlock:(void(^)(NSDictionary *settings))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    return [self getAPIResource:@"account/settings.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET account/verify_credentials
- (NSObject<STTwitterRequestProtocol> *)getAccountVerifyCredentialsWithIncludeEntites:(NSNumber *)includeEntities
                                                                           skipStatus:(NSNumber *)skipStatus
                                                                         includeEmail:(NSNumber *)includeEmail
                                                                         successBlock:(void(^)(NSDictionary *myInfo))successBlock
                                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeEmail) md[@"include_email"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"account/verify_credentials.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getAccountVerifyCredentialsWithSuccessBlock:(void(^)(NSDictionary *account))successBlock
                                                                         errorBlock:(void(^)(NSError *error))errorBlock {
    return [self getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil includeEmail:nil successBlock:^(NSDictionary *account) {
        successBlock(account);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/settings
- (NSObject<STTwitterRequestProtocol> *)postAccountSettingsWithTrendLocationWOEID:(NSString *)trendLocationWOEID // eg. "1"
                                                                 sleepTimeEnabled:(NSNumber *)sleepTimeEnabled // eg. @(YES)
                                                                   startSleepTime:(NSString *)startSleepTime // eg. "13"
                                                                     endSleepTime:(NSString *)endSleepTime // eg. "13"
                                                                         timezone:(NSString *)timezone // eg. "Europe/Copenhagen", "Pacific/Tongatapu"
                                                                         language:(NSString *)language // eg. "it", "en", "es"
                                                                     successBlock:(void(^)(NSDictionary *settings))successBlock
                                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((trendLocationWOEID || sleepTimeEnabled || startSleepTime || endSleepTime || timezone || language), @"at least one parameter is needed");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(trendLocationWOEID) md[@"trend_location_woeid"] = trendLocationWOEID;
    if(sleepTimeEnabled) md[@"sleep_time_enabled"] = [sleepTimeEnabled boolValue] ? @"1" : @"0";
    if(startSleepTime) md[@"start_sleep_time"] = startSleepTime;
    if(endSleepTime) md[@"end_sleep_time"] = endSleepTime;
    if(timezone) md[@"time_zone"] = timezone;
    if(language) md[@"lang"] = language;
    
    return [self postAPIResource:@"account/settings.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	account/update_delivery_device
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateDeliveryDeviceSMS:(BOOL)deliveryDeviceSMS
                                                           includeEntities:(NSNumber *)includeEntities
                                                              successBlock:(void(^)(NSDictionary *response))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"device"] = deliveryDeviceSMS ? @"sms" : @"none";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"account/update_delivery_device.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileWithName:(NSString *)name
                                                               URLString:(NSString *)URLString
                                                                location:(NSString *)location
                                                             description:(NSString *)description
                                                         includeEntities:(NSNumber *)includeEntities
                                                              skipStatus:(NSNumber *)skipStatus
                                                            successBlock:(void(^)(NSDictionary *profile))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((name || URLString || location || description || includeEntities || skipStatus), @"at least one parameter is needed");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(name) md[@"name"] = name;
    if(URLString) md[@"url"] = URLString;
    if(location) md[@"location"] = location;
    if(description) md[@"description"] = description;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"account/update_profile.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postUpdateProfile:(NSDictionary *)profileData
                                             successBlock:(void(^)(NSDictionary *myInfo))successBlock
                                               errorBlock:(void(^)(NSError *error))errorBlock {
    return [self postAPIResource:@"account/update_profile.json" parameters:profileData successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_background_image
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileBackgroundImageWithImage:(NSString *)base64EncodedImage
                                                                                   title:(NSString *)title
                                                                         includeEntities:(NSNumber *)includeEntities
                                                                              skipStatus:(NSNumber *)skipStatus
                                                                                     use:(NSNumber *)use
                                                                            successBlock:(void(^)(NSDictionary *profile))successBlock
                                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((base64EncodedImage || title || includeEntities || skipStatus || use), @"at least one parameter is needed");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(base64EncodedImage) md[@"image"] = base64EncodedImage;
    if(title) md[@"title"] = title;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(use) md[@"use"] = [use boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"account/update_profile_background_image.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_colors
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileColorsWithBackgroundColor:(NSString *)backgroundColor
                                                                                linkColor:(NSString *)linkColor
                                                                       sidebarBorderColor:(NSString *)sidebarBorderColor
                                                                         sidebarFillColor:(NSString *)sidebarFillColor
                                                                         profileTextColor:(NSString *)profileTextColor
                                                                          includeEntities:(NSNumber *)includeEntities
                                                                               skipStatus:(NSNumber *)skipStatus
                                                                             successBlock:(void(^)(NSDictionary *profile))successBlock
                                                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(backgroundColor) md[@"profile_background_color"] = backgroundColor;
    if(linkColor) md[@"profile_link_color"] = linkColor;
    if(sidebarBorderColor) md[@"profile_sidebar_border_color"] = sidebarBorderColor;
    if(sidebarFillColor) md[@"profile_sidebar_fill_color"] = sidebarFillColor;
    if(profileTextColor) md[@"profile_text_color"] = profileTextColor;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"account/update_profile_colors.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_image
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileImage:(NSString *)base64EncodedImage
                                                      includeEntities:(NSNumber *)includeEntities
                                                           skipStatus:(NSNumber *)skipStatus
                                                         successBlock:(void(^)(NSDictionary *profile))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(base64EncodedImage);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"image"] = base64EncodedImage;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"account/update_profile_image.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET blocks/list
- (NSObject<STTwitterRequestProtocol> *)getBlocksListWithincludeEntities:(NSNumber *)includeEntities
                                                              skipStatus:(NSNumber *)skipStatus
                                                                  cursor:(NSString *)cursor
                                                            successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(cursor) md[@"cursor"] = cursor;
    
    return [self getAPIResource:@"blocks/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *users = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            users = [response valueForKey:@"users"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET blocks/ids
- (NSObject<STTwitterRequestProtocol> *)getBlocksIDsWithCursor:(NSString *)cursor
                                                  successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                                                    errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_ids"] = @"1";
    if(cursor) md[@"cursor"] = cursor;
    
    return [self getAPIResource:@"blocks/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *ids = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            ids = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST blocks/create
- (NSObject<STTwitterRequestProtocol> *)postBlocksCreateWithScreenName:(NSString *)screenName
                                                              orUserID:(NSString *)userID
                                                       includeEntities:(NSNumber *)includeEntities
                                                            skipStatus:(NSNumber *)skipStatus
                                                          successBlock:(void(^)(NSDictionary *user))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"blocks/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST blocks/destroy
- (NSObject<STTwitterRequestProtocol> *)postBlocksDestroyWithScreenName:(NSString *)screenName
                                                               orUserID:(NSString *)userID
                                                        includeEntities:(NSNumber *)includeEntities
                                                             skipStatus:(NSNumber *)skipStatus
                                                           successBlock:(void(^)(NSDictionary *user))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"blocks/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/lookup
- (NSObject<STTwitterRequestProtocol> *)getUsersLookupForScreenName:(NSString *)screenName
                                                           orUserID:(NSString *)userID
                                                    includeEntities:(NSNumber *)includeEntities
                                                       successBlock:(void(^)(NSArray *users))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"users/lookup.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/show
- (NSObject<STTwitterRequestProtocol> *)getUsersShowForUserID:(NSString *)userID
                                                 orScreenName:(NSString *)screenName
                                              includeEntities:(NSNumber *)includeEntities
                                                 successBlock:(void(^)(NSDictionary *user))successBlock
                                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"users/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getUserInformationFor:(NSString *)screenName
                                                 successBlock:(void(^)(NSDictionary *user))successBlock
                                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getUsersShowForUserID:nil orScreenName:screenName includeEntities:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/search
- (NSObject<STTwitterRequestProtocol> *)getUsersSearchQuery:(NSString *)query
                                                       page:(NSString *)page
                                                      count:(NSString *)count
                                            includeEntities:(NSNumber *)includeEntities
                                               successBlock:(void(^)(NSArray *users))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"q"] = query;
    if(page) md[@"page"] = page;
    if(count) md[@"count"] = count;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"users/search.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response); // NSArray of users dictionaries
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/contributees
- (NSObject<STTwitterRequestProtocol> *)getUsersContributeesWithUserID:(NSString *)userID
                                                          orScreenName:(NSString *)screenName
                                                       includeEntities:(NSNumber *)includeEntities
                                                            skipStatus:(NSNumber *)skipStatus
                                                          successBlock:(void(^)(NSArray *contributees))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"users/contributees.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/contributors
- (NSObject<STTwitterRequestProtocol> *)getUsersContributorsWithUserID:(NSString *)userID
                                                          orScreenName:(NSString *)screenName
                                                       includeEntities:(NSNumber *)includeEntities
                                                            skipStatus:(NSNumber *)skipStatus
                                                          successBlock:(void(^)(NSArray *contributors))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"users/contributors.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/remove_profile_banner
- (NSObject<STTwitterRequestProtocol> *)postAccountRemoveProfileBannerWithSuccessBlock:(void(^)(id response))successBlock
                                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    return [self postAPIResource:@"account/remove_profile_banner.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_banner
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileBannerWithImage:(NSString *)base64encodedImage
                                                                          width:(NSString *)width
                                                                         height:(NSString *)height
                                                                     offsetLeft:(NSString *)offsetLeft
                                                                      offsetTop:(NSString *)offsetTop
                                                                   successBlock:(void(^)(id response))successBlock
                                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    if(width || height || offsetLeft || offsetTop) {
        NSParameterAssert(width);
        NSParameterAssert(height);
        NSParameterAssert(offsetLeft);
        NSParameterAssert(offsetTop);
    }
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"banner"] = base64encodedImage;
    if(width) md[@"width"] = width;
    if(height) md[@"height"] = height;
    if(offsetLeft) md[@"offset_left"] = offsetLeft;
    if(offsetTop) md[@"offset_top"] = offsetTop;
    
    return [self postAPIResource:@"account/update_profile_banner.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/profile_banner
- (NSObject<STTwitterRequestProtocol> *)getUsersProfileBannerForUserID:(NSString *)userID
                                                          orScreenName:(NSString *)screenName
                                                          successBlock:(void(^)(NSDictionary *banner))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    
    return [self getAPIResource:@"users/profile_banner.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/suggestions
- (NSObject<STTwitterRequestProtocol> *)getUsersSuggestionsWithISO6391LanguageCode:(NSString *)ISO6391LanguageCode
                                                                      successBlock:(void(^)(NSArray *suggestions))successBlock
                                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(ISO6391LanguageCode) md[@"lang"] = ISO6391LanguageCode;
    
    return [self getAPIResource:@"users/suggestions.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/suggestions/:slug/members
- (NSObject<STTwitterRequestProtocol> *)getUsersSuggestionsForSlugMembers:(NSString *)slug // short name of list or a category, eg. "twitter"
                                                             successBlock:(void(^)(NSArray *members))successBlock
                                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(slug, @"missing slug");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"slug"] = slug;
    
    NSString *resource = [NSString stringWithFormat:@"users/suggestions/%@/members.json", slug];
    
    return [self getAPIResource:resource parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST mutes/users/create
- (NSObject<STTwitterRequestProtocol> *)postMutesUsersCreateForScreenName:(NSString *)screenName
                                                                 orUserID:(NSString *)userID
                                                             successBlock:(void(^)(NSDictionary *user))successBlock
                                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    return [self postAPIResource:@"mutes/users/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST mutes/users/destroy
- (NSObject<STTwitterRequestProtocol> *)postMutesUsersDestroyForScreenName:(NSString *)screenName
                                                                  orUserID:(NSString *)userID
                                                              successBlock:(void(^)(NSDictionary *user))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    return [self postAPIResource:@"mutes/users/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET mutes/users/ids
- (NSObject<STTwitterRequestProtocol> *)getMutesUsersIDsWithCursor:(NSString *)cursor
                                                      successBlock:(void(^)(NSArray *userIDs, NSString *previousCursor, NSString *nextCursor))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(cursor) md[@"cursor"] = cursor;
    
    return [self getAPIResource:@"mutes/users/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *userIDs = [response valueForKey:@"ids"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        
        successBlock(userIDs, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET mutes/users/list
- (NSObject<STTwitterRequestProtocol> *)getMutesUsersListWithCursor:(NSString *)cursor
                                                    includeEntities:(NSNumber *)includeEntities
                                                         skipStatus:(NSNumber *)skipStatus
                                                       successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = includeEntities;
    if(skipStatus) md[@"skip_status"] = skipStatus;
    
    return [self getAPIResource:@"mutes/users/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Suggested Users

// GET users/suggestions/:slug
- (NSObject<STTwitterRequestProtocol> *)getUsersSuggestionsForSlug:(NSString *)slug // short name of list or a category, eg. "twitter"
                                                              lang:(NSString *)lang
                                                      successBlock:(void(^)(NSString *name, NSString *slug, NSArray *users))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(slug, @"slug is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(lang) md[@"lang"] = lang;
    
    return [self getAPIResource:@"users/suggestions/twitter.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSString *name = nil;
        NSString *slug = nil;
        NSArray *users = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            name = [response valueForKey:@"name"];
            slug = [response valueForKey:@"slug"];
            users = [response valueForKey:@"users"];
        }
        
        successBlock(name,  slug, users);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Favorites

// GET favorites/list
- (NSObject<STTwitterRequestProtocol> *)getFavoritesListWithUserID:(NSString *)userID
                                                      orScreenName:(NSString *)screenName
                                                             count:(NSString *)count
                                                           sinceID:(NSString *)sinceID
                                                             maxID:(NSString *)maxID
                                                   includeEntities:(NSNumber *)includeEntities
                                                      successBlock:(void(^)(NSArray *statuses))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(count) md[@"count"] = count;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"favorites/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getFavoritesListWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getFavoritesListWithUserID:nil
                               orScreenName:nil
                                      count:nil
                                    sinceID:nil
                                      maxID:nil
                            includeEntities:nil
                               successBlock:^(NSArray *statuses) {
                                   successBlock(statuses);
                               } errorBlock:^(NSError *error) {
                                   errorBlock(error);
                               }];
}

// POST favorites/destroy
- (NSObject<STTwitterRequestProtocol> *)postFavoriteDestroyWithStatusID:(NSString *)statusID
                                                        includeEntities:(NSNumber *)includeEntities
                                                           successBlock:(void(^)(NSDictionary *status))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(statusID) md[@"id"] = statusID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"favorites/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	favorites/create
- (NSObject<STTwitterRequestProtocol> *)postFavoriteCreateWithStatusID:(NSString *)statusID
                                                       includeEntities:(NSNumber *)includeEntities
                                                          successBlock:(void(^)(NSDictionary *status))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(statusID) md[@"id"] = statusID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [self postAPIResource:@"favorites/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postFavoriteState:(BOOL)favoriteState
                                              forStatusID:(NSString *)statusID
                                             successBlock:(void(^)(NSDictionary *status))successBlock
                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *action = favoriteState ? @"create" : @"destroy";
    
    NSString *resource = [NSString stringWithFormat:@"favorites/%@.json", action];
    
    NSDictionary *d = @{@"id" : statusID};
    
    return [self postAPIResource:resource parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Lists

// GET	lists/list

- (NSObject<STTwitterRequestProtocol> *)getListsSubscribedByUsername:(NSString *)username
                                                            orUserID:(NSString *)userID
                                                             reverse:(NSNumber *)reverse
                                                        successBlock:(void(^)(NSArray *lists))successBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((username || userID), @"missing username or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(username) {
        md[@"screen_name"] = username;
    } else if (userID) {
        md[@"user_id"] = userID;
    }
    
    if(reverse) md[@"reverse"] = [reverse boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *lists = (NSArray *)response;
        
        successBlock(lists);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET    lists/statuses

- (NSObject<STTwitterRequestProtocol> *)getListsStatusesForListID:(NSString *)listID
                                                          sinceID:(NSString *)sinceID
                                                            maxID:(NSString *)maxID
                                                            count:(NSString *)count
                                                  includeEntities:(NSNumber *)includeEntities
                                                  includeRetweets:(NSNumber *)includeRetweets
                                                     successBlock:(void(^)(NSArray *statuses))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(count) md[@"count"] = count;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(includeRetweets) md[@"include_rts"] = includeRetweets ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/statuses.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *statuses = (NSArray *)response;
        
        successBlock(statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getListsStatusesForSlug:(NSString *)slug
                                                     screenName:(NSString *)ownerScreenName
                                                        ownerID:(NSString *)ownerID
                                                        sinceID:(NSString *)sinceID
                                                          maxID:(NSString *)maxID
                                                          count:(NSString *)count
                                                includeEntities:(NSNumber *)includeEntities
                                                includeRetweets:(NSNumber *)includeRetweets
                                                   successBlock:(void(^)(NSArray *statuses))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(count) md[@"count"] = count;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(includeRetweets) md[@"include_rts"] = [includeRetweets boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/statuses.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *statuses = (NSArray *)response;
        
        successBlock(statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST lists/members/destroy

- (NSObject<STTwitterRequestProtocol> *)postListsMembersDestroyForListID:(NSString *)listID
                                                                    slug:(NSString *)slug
                                                                  userID:(NSString *)userID
                                                              screenName:(NSString *)screenName
                                                         ownerScreenName:(NSString *)ownerScreenName
                                                                 ownerID:(NSString *)ownerID
                                                            successBlock:(void(^)(id response))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((listID || slug), @"missing listID or slug");
    
    if(slug) NSAssert((ownerScreenName || ownerID), @"slug requires either ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(listID) md[@"list_id"] = listID;
    if(slug) md[@"slug"] = slug;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    return [self postAPIResource:@"lists/members/destroy" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postListsMembersDestroyForSlug:(NSString *)slug
                                                                userID:(NSString *)userID
                                                            screenName:(NSString *)screenName
                                                       ownerScreenName:(NSString *)ownerScreenName
                                                               ownerID:(NSString *)ownerID
                                                          successBlock:(void(^)())successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"slug"] = slug;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerScreenName) md[@"owner_id"] = ownerID;
    
    return [self postAPIResource:@"lists/members/destroy" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET lists/memberships

- (NSObject<STTwitterRequestProtocol> *)getListsMembershipsForUserID:(NSString *)userID
                                                        orScreenName:(NSString *)screenName
                                                              cursor:(NSString *)cursor
                                                  filterToOwnedLists:(NSNumber *)filterToOwnedLists
                                                        successBlock:(void(^)(NSArray *lists, NSString *previousCursor, NSString *nextCursor))successBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(filterToOwnedLists) md[@"filter_to_owned_lists"] = [filterToOwnedLists boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/memberships.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        NSArray *lists = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
            lists = [response valueForKey:@"lists"];
        }
        
        successBlock(lists, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/subscribers

- (NSObject<STTwitterRequestProtocol> *)getListsSubscribersForSlug:(NSString *)slug
                                                   ownerScreenName:(NSString *)ownerScreenName
                                                         orOwnerID:(NSString *)ownerID
                                                            cursor:(NSString *)cursor
                                                   includeEntities:(NSNumber *)includeEntities
                                                        skipStatus:(NSNumber *)skipStatus
                                                      successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or onwerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) {
        md[@"owner_screen_name"] = ownerScreenName;
    } else if (ownerID) {
        md[@"owner_id"] = ownerID;
    }
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/subscribers.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getListsSubscribersForListID:(NSString *)listID
                                                              cursor:(NSString *)cursor
                                                     includeEntities:(NSNumber *)includeEntities
                                                          skipStatus:(NSNumber *)skipStatus
                                                        successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/subscribers.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/subscribers/create

- (NSObject<STTwitterRequestProtocol> *)postListSubscribersCreateForListID:(NSString *)listID
                                                              successBlock:(void(^)(id response))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    return [self postAPIResource:@"lists/subscribers/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postListSubscribersCreateForSlug:(NSString *)slug
                                                         ownerScreenName:(NSString *)ownerScreenName
                                                               orOwnerID:(NSString *)ownerID
                                                            successBlock:(void(^)(id response))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    return [self postAPIResource:@"lists/subscribers/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/subscribers/show

- (NSObject<STTwitterRequestProtocol> *)getListsSubscribersShowForListID:(NSString *)listID
                                                                  userID:(NSString *)userID
                                                            orScreenName:(NSString *)screenName
                                                         includeEntities:(NSNumber *)includeEntities
                                                              skipStatus:(NSNumber *)skipStatus
                                                            successBlock:(void(^)(id response))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(listID);
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/subscribers/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getListsSubscribersShowForSlug:(NSString *)slug
                                                       ownerScreenName:(NSString *)ownerScreenName
                                                             orOwnerID:(NSString *)ownerID
                                                                userID:(NSString *)userID
                                                          orScreenName:(NSString *)screenName
                                                       includeEntities:(NSNumber *)includeEntities
                                                            skipStatus:(NSNumber *)skipStatus
                                                          successBlock:(void(^)(id response))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/subscribers/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/subscribers/destroy

- (NSObject<STTwitterRequestProtocol> *)postListSubscribersDestroyForListID:(NSString *)listID
                                                               successBlock:(void(^)(id response))successBlock
                                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    return [self postAPIResource:@"lists/subscribers/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postListSubscribersDestroyForSlug:(NSString *)slug
                                                          ownerScreenName:(NSString *)ownerScreenName
                                                                orOwnerID:(NSString *)ownerID
                                                             successBlock:(void(^)(id response))successBlock
                                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    return [self postAPIResource:@"lists/subscribers/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/members/create_all

- (NSObject<STTwitterRequestProtocol> *)postListsMembersCreateAllForListID:(NSString *)listID
                                                                   userIDs:(NSArray *)userIDs // array of strings
                                                             orScreenNames:(NSArray *)screenNames // array of strings
                                                              successBlock:(void(^)(id response))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(listID);
    NSAssert((userIDs || screenNames), @"missing usersIDs or screenNames");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    if(userIDs) {
        md[@"user_id"] = [userIDs componentsJoinedByString:@","];
    } else if (screenNames) {
        md[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    }
    
    return [self postAPIResource:@"lists/members/create_all.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postListsMembersCreateAllForSlug:(NSString *)slug
                                                         ownerScreenName:(NSString *)ownerScreenName
                                                               orOwnerID:(NSString *)ownerID
                                                                 userIDs:(NSArray *)userIDs // array of strings
                                                           orScreenNames:(NSArray *)screenNames // array of strings
                                                            successBlock:(void(^)(id response))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    NSAssert((userIDs || screenNames), @"missing usersIDs or screenNames");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    
    if(ownerScreenName) {
        md[@"owner_screen_name"] = ownerScreenName;
    } else if (ownerID) {
        md[@"owner_id"] = ownerID;
    }
    
    if(userIDs) {
        md[@"user_id"] = [userIDs componentsJoinedByString:@","];
    } else if (screenNames) {
        md[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    }
    
    return [self postAPIResource:@"lists/members/create_all.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/members/show

- (NSObject<STTwitterRequestProtocol> *)getListsMembersShowForListID:(NSString *)listID
                                                              userID:(NSString *)userID
                                                          screenName:(NSString *)screenName
                                                     includeEntities:(NSNumber *)includeEntities
                                                          skipStatus:(NSNumber *)skipStatus
                                                        successBlock:(void(^)(NSDictionary *user))successBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(listID, @"listID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/members/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getListsMembersShowForSlug:(NSString *)slug
                                                   ownerScreenName:(NSString *)ownerScreenName
                                                         orOwnerID:(NSString *)ownerID
                                                            userID:(NSString *)userID
                                                        screenName:(NSString *)screenName
                                                   includeEntities:(NSNumber *)includeEntities
                                                        skipStatus:(NSNumber *)skipStatus
                                                      successBlock:(void(^)(NSDictionary *user))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/members/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/members

- (NSObject<STTwitterRequestProtocol> *)getListsMembersForListID:(NSString *)listID
                                                          cursor:(NSString *)cursor
                                                           count:(NSString *)count
                                                 includeEntities:(NSNumber *)includeEntities
                                                      skipStatus:(NSNumber *)skipStatus
                                                    successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(listID, @"listID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(cursor) md[@"cursor"] = cursor;
    if(count) md[@"count"] = count;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/members.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getListsMembersForSlug:(NSString *)slug
                                               ownerScreenName:(NSString *)ownerScreenName
                                                     orOwnerID:(NSString *)ownerID
                                                        cursor:(NSString *)cursor
                                                         count:(NSString *)count
                                               includeEntities:(NSNumber *)includeEntities
                                                    skipStatus:(NSNumber *)skipStatus
                                                  successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(cursor) md[@"cursor"] = cursor;
    if(count) md[@"count"] = count;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"lists/members.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/members/create

- (NSObject<STTwitterRequestProtocol> *)postListMemberCreateForListID:(NSString *)listID
                                                               userID:(NSString *)userID
                                                           screenName:(NSString *)screenName
                                                         successBlock:(void(^)(id response))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    
    return [self postAPIResource:@"lists/members/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postListMemberCreateForSlug:(NSString *)slug
                                                    ownerScreenName:(NSString *)ownerScreenName
                                                          orOwnerID:(NSString *)ownerID
                                                             userID:(NSString *)userID
                                                         screenName:(NSString *)screenName
                                                       successBlock:(void(^)(id response))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    md[@"user_id"] = userID;
    md[@"screen_name"] = screenName;
    
    return [self postAPIResource:@"lists/members/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/destroy

- (NSObject<STTwitterRequestProtocol> *)postListsDestroyForListID:(NSString *)listID
                                                     successBlock:(void(^)(id response))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    return [self postAPIResource:@"lists/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postListsDestroyForSlug:(NSString *)slug
                                                ownerScreenName:(NSString *)ownerScreenName
                                                      orOwnerID:(NSString *)ownerID
                                                   successBlock:(void(^)(id response))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    return [self postAPIResource:@"lists/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/update

- (NSObject<STTwitterRequestProtocol> *)postListsUpdateForListID:(NSString *)listID
                                                            name:(NSString *)name
                                                       isPrivate:(BOOL)isPrivate
                                                     description:(NSString *)description
                                                    successBlock:(void(^)(id response))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(name) md[@"name"] = name;
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = description;
    
    return [self postAPIResource:@"lists/update.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postListsUpdateForSlug:(NSString *)slug
                                               ownerScreenName:(NSString *)ownerScreenName
                                                     orOwnerID:(NSString *)ownerID
                                                          name:(NSString *)name
                                                     isPrivate:(BOOL)isPrivate
                                                   description:(NSString *)description
                                                  successBlock:(void(^)(id response))successBlock
                                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(name) md[@"name"] = name;
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = description;
    
    return [self postAPIResource:@"lists/update.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/create

- (NSObject<STTwitterRequestProtocol> *)postListsCreateWithName:(NSString *)name
                                                      isPrivate:(BOOL)isPrivate
                                                    description:(NSString *)description
                                                   successBlock:(void(^)(NSDictionary *list))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(name);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"name"] = name;
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = description;
    
    return [self postAPIResource:@"lists/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/show

- (NSObject<STTwitterRequestProtocol> *)getListsShowListID:(NSString *)listID
                                              successBlock:(void(^)(NSDictionary *list))successBlock
                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    return [self getAPIResource:@"lists/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getListsShowListSlug:(NSString *)slug
                                             ownerScreenName:(NSString *)ownerScreenName
                                                   orOwnerID:(NSString *)ownerID
                                                successBlock:(void(^)(NSDictionary *list))successBlock
                                                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    return [self getAPIResource:@"lists/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/members/destroy_all

- (NSObject<STTwitterRequestProtocol> *)postListsMembersDestroyAllForListID:(NSString *)listID
                                                                    userIDs:(NSArray *)userIDs // array of strings
                                                              orScreenNames:(NSArray *)screenNames // array of strings
                                                               successBlock:(void(^)(id response))successBlock
                                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    NSAssert((userIDs || screenNames), @"missing usersIDs or screenNames");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    if(userIDs) {
        md[@"user_id"] = [userIDs componentsJoinedByString:@","];
    } else if (screenNames) {
        md[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    }
    
    return [self postAPIResource:@"lists/members/destroy_all.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)postListsMembersDestroyAllForSlug:(NSString *)slug
                                                          ownerScreenName:(NSString *)ownerScreenName
                                                                orOwnerID:(NSString *)ownerID
                                                                  userIDs:(NSArray *)userIDs // array of strings
                                                            orScreenNames:(NSArray *)screenNames // array of strings
                                                             successBlock:(void(^)(id response))successBlock
                                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    NSAssert((userIDs || screenNames), @"missing usersIDs or screenNames");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    
    if(ownerScreenName) {
        md[@"owner_screen_name"] = ownerScreenName;
    } else if (ownerID) {
        md[@"owner_id"] = ownerID;
    }
    
    if(userIDs) {
        md[@"user_id"] = [userIDs componentsJoinedByString:@","];
    } else if (screenNames) {
        md[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    }
    
    return [self postAPIResource:@"lists/members/destroy_all.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Saved Searches

// GET saved_searches/list
- (NSObject<STTwitterRequestProtocol> *)getSavedSearchesListWithSuccessBlock:(void(^)(NSArray *savedSearches))successBlock
                                                                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getAPIResource:@"saved_searches/list.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET saved_searches/show/:id
- (NSObject<STTwitterRequestProtocol> *)getSavedSearchesShow:(NSString *)savedSearchID
                                                successBlock:(void(^)(NSDictionary *savedSearch))successBlock
                                                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(savedSearchID);
    
    NSString *resource = [NSString stringWithFormat:@"saved_searches/show/%@.json", savedSearchID];
    
    return [self getAPIResource:resource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST saved_searches/create
- (NSObject<STTwitterRequestProtocol> *)postSavedSearchesCreateWithQuery:(NSString *)query
                                                            successBlock:(void(^)(NSDictionary *createdSearch))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    NSDictionary *d = @{ @"query" : query };
    
    return [self postAPIResource:@"saved_searches/create.json" parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST saved_searches/destroy/:id
- (NSObject<STTwitterRequestProtocol> *)postSavedSearchesDestroy:(NSString *)savedSearchID
                                                    successBlock:(void(^)(NSDictionary *destroyedSearch))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(savedSearchID);
    
    NSString *resource = [NSString stringWithFormat:@"saved_searches/destroy/%@.json", savedSearchID];
    
    return [self postAPIResource:resource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Places & Geo

// GET geo/id/:place_id
- (NSObject<STTwitterRequestProtocol> *)getGeoIDForPlaceID:(NSString *)placeID // A place in the world. These IDs can be retrieved from geo/reverse_geocode.
                                              successBlock:(void(^)(NSDictionary *place))successBlock
                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *resource = [NSString stringWithFormat:@"geo/id/%@.json", placeID];
    
    return [self getAPIResource:resource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET geo/reverse_geocode
- (NSObject<STTwitterRequestProtocol> *)getGeoReverseGeocodeWithLatitude:(NSString *)latitude // eg. "37.7821120598956"
                                                               longitude:(NSString *)longitude // eg. "-122.400612831116"
                                                                accuracy:(NSString *)accuracy // eg. "5ft"
                                                             granularity:(NSString *)granularity // eg. "city"
                                                              maxResults:(NSString *)maxResults // eg. "3"
                                                                callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                                                            successBlock:(void(^)(NSDictionary *query, NSDictionary *result))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"lat"] = latitude;
    md[@"long"] = longitude;
    if(accuracy) md[@"accuracy"] = accuracy;
    if(granularity) md[@"granularity"] = granularity;
    if(maxResults) md[@"max_results"] = maxResults;
    if(callback) md[@"callback"] = callback;
    
    return [self getAPIResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *query = [response valueForKeyPath:@"query"];
        NSDictionary *result = [response valueForKeyPath:@"result"];
        
        successBlock(query, result);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                                                               longitude:(NSString *)longitude
                                                            successBlock:(void(^)(NSArray *places))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getGeoReverseGeocodeWithLatitude:latitude
                                        longitude:longitude
                                         accuracy:nil
                                      granularity:nil
                                       maxResults:nil
                                         callback:nil
                                     successBlock:^(NSDictionary *query, NSDictionary *result) {
                                         successBlock([result valueForKey:@"places"]);
                                     } errorBlock:^(NSError *error) {
                                         errorBlock(error);
                                     }];
}

// GET geo/search

- (NSObject<STTwitterRequestProtocol> *)getGeoSearchWithLatitude:(NSString *)latitude // eg. "37.7821120598956"
                                                       longitude:(NSString *)longitude // eg. "-122.400612831116"
                                                           query:(NSString *)query // eg. "Twitter HQ"
                                                       ipAddress:(NSString *)ipAddress // eg. 74.125.19.104
                                                     granularity:(NSString *)granularity // eg. "city"
                                                        accuracy:(NSString *)accuracy // eg. "5ft"
                                                      maxResults:(NSString *)maxResults // eg. "3"
                                         placeIDContaintedWithin:(NSString *)placeIDContaintedWithin // eg. "247f43d441defc03"
                                          attributeStreetAddress:(NSString *)attributeStreetAddress // eg. "795 Folsom St"
                                                        callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                                                    successBlock:(void(^)(NSDictionary *query, NSDictionary *result))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(latitude) md[@"lat"] = latitude;
    if(longitude) md[@"long"] = longitude;
    if(query) md[@"query"] = query;
    if(ipAddress) md[@"ip"] = ipAddress;
    if(granularity) md[@"granularity"] = granularity;
    if(accuracy) md[@"accuracy"] = accuracy;
    if(maxResults) md[@"max_results"] = maxResults;
    if(placeIDContaintedWithin) md[@"contained_within"] = placeIDContaintedWithin;
    if(attributeStreetAddress) md[@"attribute:street_address"] = attributeStreetAddress;
    if(callback) md[@"callback"] = callback;
    
    return [self getAPIResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *query = [response valueForKeyPath:@"query"];
        NSDictionary *result = [response valueForKeyPath:@"result"];
        
        successBlock(query, result);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSObject<STTwitterRequestProtocol> *)getGeoSearchWithLatitude:(NSString *)latitude
                                                       longitude:(NSString *)longitude
                                                    successBlock:(void(^)(NSArray *places))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    return [self getGeoSearchWithLatitude:latitude
                                longitude:longitude
                                    query:nil
                                ipAddress:nil
                              granularity:nil
                                 accuracy:nil
                               maxResults:nil
                  placeIDContaintedWithin:nil
                   attributeStreetAddress:nil
                                 callback:nil
                             successBlock:^(NSDictionary *query, NSDictionary *result) {
                                 successBlock([result valueForKey:@"places"]);
                             } errorBlock:^(NSError *error) {
                                 errorBlock(error);
                             }];
}

- (NSObject<STTwitterRequestProtocol> *)getGeoSearchWithIPAddress:(NSString *)ipAddress
                                                     successBlock:(void(^)(NSArray *places))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(ipAddress);
    
    return [self getGeoSearchWithLatitude:nil
                                longitude:nil
                                    query:nil
                                ipAddress:ipAddress
                              granularity:nil
                                 accuracy:nil
                               maxResults:nil
                  placeIDContaintedWithin:nil
                   attributeStreetAddress:nil
                                 callback:nil
                             successBlock:^(NSDictionary *query, NSDictionary *result) {
                                 successBlock([result valueForKey:@"places"]);
                             } errorBlock:^(NSError *error) {
                                 errorBlock(error);
                             }];
}

- (NSObject<STTwitterRequestProtocol> *)getGeoSearchWithQuery:(NSString *)query
                                                 successBlock:(void(^)(NSArray *places))successBlock
                                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    return [self getGeoSearchWithLatitude:nil
                                longitude:nil
                                    query:query
                                ipAddress:nil
                              granularity:nil
                                 accuracy:nil
                               maxResults:nil
                  placeIDContaintedWithin:nil
                   attributeStreetAddress:nil
                                 callback:nil
                             successBlock:^(NSDictionary *query, NSDictionary *result) {
                                 successBlock([result valueForKey:@"places"]);
                             } errorBlock:^(NSError *error) {
                                 errorBlock(error);
                             }];
}

// GET geo/similar_places

- (NSObject<STTwitterRequestProtocol> *)getGeoSimilarPlacesToLatitude:(NSString *)latitude // eg. "37.7821120598956"
                                                            longitude:(NSString *)longitude // eg. "-122.400612831116"
                                                                 name:(NSString *)name // eg. "Twitter HQ"
                                              placeIDContaintedWithin:(NSString *)placeIDContaintedWithin // eg. "247f43d441defc03"
                                               attributeStreetAddress:(NSString *)attributeStreetAddress // eg. "795 Folsom St"
                                                             callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                                                         successBlock:(void(^)(NSDictionary *query, NSArray *resultPlaces, NSString *resultToken))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    NSParameterAssert(name);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"lat"] = latitude;
    md[@"long"] = longitude;
    md[@"name"] = name;
    if(placeIDContaintedWithin) md[@"contained_within"] = placeIDContaintedWithin;
    if(attributeStreetAddress) md[@"attribute:street_address"] = attributeStreetAddress;
    if(callback) md[@"callback"] = callback;
    
    return [self getAPIResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *query = [response valueForKey:@"query"];
        NSDictionary *result = [response valueForKey:@"result"];
        NSArray *places = [result valueForKey:@"places"];
        NSString *token = [result valueForKey:@"token"];
        
        successBlock(query, places, token);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST get/place

// WARNING: deprecated since December 2nd, 2013 https://dev.twitter.com/discussions/22452

- (NSObject<STTwitterRequestProtocol> *)postGeoPlaceWithName:(NSString *)name // eg. "Twitter HQ"
                                     placeIDContaintedWithin:(NSString *)placeIDContaintedWithin // eg. "247f43d441defc03"
                                           similarPlaceToken:(NSString *)similarPlaceToken // eg. "36179c9bf78835898ebf521c1defd4be"
                                                    latitude:(NSString *)latitude // eg. "37.7821120598956"
                                                   longitude:(NSString *)longitude // eg. "-122.400612831116"
                                      attributeStreetAddress:(NSString *)attributeStreetAddress // eg. "795 Folsom St"
                                                    callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                                                successBlock:(void(^)(NSDictionary *place))successBlock
                                                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"name"] = name;
    md[@"contained_within"] = placeIDContaintedWithin;
    md[@"token"] = similarPlaceToken;
    md[@"lat"] = latitude;
    md[@"long"] = longitude;
    if(attributeStreetAddress) md[@"attribute:street_address"] = attributeStreetAddress;
    if(callback) md[@"callback"] = callback;
    
    return [self postAPIResource:@"get/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Trends

// GET trends/place
- (NSObject<STTwitterRequestProtocol> *)getTrendsForWOEID:(NSString *)WOEID // 'Yahoo! Where On Earth ID', Paris is "615702"
                                          excludeHashtags:(NSNumber *)excludeHashtags
                                             successBlock:(void(^)(NSDate *asOf, NSDate *createdAt, NSArray *locations, NSArray *trends))successBlock
                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(WOEID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = WOEID;
    if(excludeHashtags) md[@"exclude"] = [excludeHashtags boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"trends/place.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *d = [response lastObject];
        
        NSDate *asOf = nil;
        NSDate *createdAt = nil;
        NSArray *locations = nil;
        NSArray *trends = nil;
        
        if([d isKindOfClass:[NSDictionary class]]) {
            NSString *asOfString = [d valueForKey:@"as_of"];
            NSString *createdAtString = [d valueForKey:@"created_at"];
            
            asOf = [[self dateFormatter] dateFromString:asOfString];
            createdAt = [[self dateFormatter] dateFromString:createdAtString];
            
            locations = [d valueForKey:@"locations"];
            trends = [d valueForKey:@"trends"];
        }
        
        successBlock(asOf, createdAt, locations, trends);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET trends/available
- (NSObject<STTwitterRequestProtocol> *)getTrendsAvailableWithSuccessBlock:(void(^)(NSArray *locations))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    return [self getAPIResource:@"trends/available.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET trends/closest
- (NSObject<STTwitterRequestProtocol> *)getTrendsClosestToLatitude:(NSString *)latitude
                                                         longitude:(NSString *)longitude
                                                      successBlock:(void(^)(NSArray *locations))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"lat"] = latitude;
    md[@"long"] = longitude;
    
    return [self getAPIResource:@"trends/closest.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Spam Reporting

// POST users/report_spam
- (NSObject<STTwitterRequestProtocol> *)postUsersReportSpamForScreenName:(NSString *)screenName
                                                                orUserID:(NSString *)userID
                                                            successBlock:(void(^)(id userProfile))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(screenName || userID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    return [self postAPIResource:@"users/report_spam.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark OAuth

// GET oauth/authenticate
// GET oauth/authorize
// POST oauth/access_token
// POST oauth/request_token
// POST oauth2/token
// POST oauth2/invalidate_token

#pragma mark Help

// GET help/configuration
- (NSObject<STTwitterRequestProtocol> *)getHelpConfigurationWithSuccessBlock:(void(^)(NSDictionary *currentConfiguration))successBlock
                                                                  errorBlock:(void(^)(NSError *error))errorBlock {
    return [self getAPIResource:@"help/configuration.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET help/languages
- (NSObject<STTwitterRequestProtocol> *)getHelpLanguagesWithSuccessBlock:(void (^)(NSArray *languages))successBlock
                                                              errorBlock:(void (^)(NSError *))errorBlock {
    return [self getAPIResource:@"help/languages.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET help/privacy
- (NSObject<STTwitterRequestProtocol> *)getHelpPrivacyWithSuccessBlock:(void(^)(NSString *tos))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    return [self getAPIResource:@"help/privacy.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock([response valueForKey:@"privacy"]);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET help/tos
- (NSObject<STTwitterRequestProtocol> *)getHelpTermsOfServiceWithSuccessBlock:(void(^)(NSString *tos))successBlock
                                                                   errorBlock:(void(^)(NSError *error))errorBlock {
    return [self getAPIResource:@"help/tos.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock([response valueForKey:@"tos"]);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET application/rate_limit_status
- (NSObject<STTwitterRequestProtocol> *)getRateLimitsForResources:(NSArray *)resources // eg. statuses,friends,trends,help
                                                     successBlock:(void(^)(NSDictionary *rateLimits))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    NSDictionary *d = nil;
    if (resources)
        d = @{ @"resources" : [resources componentsJoinedByString:@","] };
    return [self getAPIResource:@"application/rate_limit_status.json" parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Tweets

/*
 GET statuses/lookup
 
 Returns fully-hydrated tweet objects for up to 100 tweets per request, as specified by comma-separated values passed to the id parameter. This method is especially useful to get the details (hydrate) a collection of Tweet IDs. GET statuses/show/:id is used to retrieve a single tweet object.
 */

- (NSObject<STTwitterRequestProtocol> *)getStatusesLookupTweetIDs:(NSArray *)tweetIDs
                                                  includeEntities:(NSNumber *)includeEntities
                                                         trimUser:(NSNumber *)trimUser
                                                              map:(NSNumber *)map
                                                     successBlock:(void(^)(NSArray *tweets))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSParameterAssert(tweetIDs);
    NSAssert(([tweetIDs isKindOfClass:[NSArray class]]), @"tweetIDs must be an array");
    
    md[@"id"] = [tweetIDs componentsJoinedByString:@","];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"true" : @"false";
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(map) md[@"map"] = [map boolValue] ? @"1" : @"0";
    
    return [self getAPIResource:@"statuses/lookup.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Media

- (NSObject<STTwitterRequestProtocol> *)postMediaUpload:(NSURL *)mediaURL
                                    uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                           successBlock:(void(^)(NSDictionary *imageDictionary, NSString *mediaID, NSString *size))successBlock
                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSData *data = [NSData dataWithContentsOfURL:mediaURL];
    
    NSString *fileName = [mediaURL isFileURL] ? [[mediaURL path] lastPathComponent] : @"media.jpg";
    
    return [self postMediaUploadData:data
                            fileName:fileName
                 uploadProgressBlock:uploadProgressBlock
                        successBlock:successBlock
                          errorBlock:errorBlock];
}

- (NSObject<STTwitterRequestProtocol> *)postMediaUploadData:(NSData *)data
                                                   fileName:(NSString *)fileName
                                        uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                               successBlock:(void(^)(NSDictionary *imageDictionary, NSString *mediaID, NSString *size))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    // https://dev.twitter.com/docs/api/multiple-media-extended-entities
    
    if(data == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterAPIMediaDataIsEmpty userInfo:@{NSLocalizedDescriptionKey : @"data is nil"}];
        errorBlock(error);
        return nil;
    }
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"media"] = data;
    md[kSTPOSTDataKey] = @"media";
    md[kSTPOSTMediaFileNameKey] = fileName;
    
    return [self postResource:@"media/upload.json"
                baseURLString:kBaseURLStringUpload_1_1
                   parameters:md
          uploadProgressBlock:uploadProgressBlock
        downloadProgressBlock:nil
                 successBlock:^(NSDictionary *rateLimits, id response) {
                     
                     NSDictionary *imageDictionary = [response valueForKey:@"image"];
                     NSString *mediaID = [response valueForKey:@"media_id_string"];
                     NSString *size = [response valueForKey:@"size"];
                     
                     successBlock(imageDictionary, mediaID, size);
                 } errorBlock:^(NSError *error) {
                     errorBlock(error);
                 }];
}

- (NSObject<STTwitterRequestProtocol> *)postMediaUploadINITWithVideoURL:(NSURL *)videoMediaURL
                                                           successBlock:(void(^)(NSString *mediaID, NSString *expiresAfterSecs))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    // https://dev.twitter.com/rest/public/uploading-media
    
    NSData *data = [NSData dataWithContentsOfURL:videoMediaURL];
    
    if(data == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:STTwitterAPIMediaDataIsEmpty
                                         userInfo:@{NSLocalizedDescriptionKey : @"data is nil"}];
        errorBlock(error);
        return nil;
    }
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"command"] = @"INIT";
    md[@"media_type"] = @"video/mp4";
    md[@"total_bytes"] = [NSString stringWithFormat:@"%@", @([data length])];
    
    return [self postResource:@"media/upload.json"
                baseURLString:kBaseURLStringUpload_1_1
                   parameters:md
          uploadProgressBlock:nil
        downloadProgressBlock:nil
                 successBlock:^(NSDictionary *rateLimits, id response) {
                     
                     /*
                      {
                      "expires_after_secs" = 3599;
                      "media_id" = 605333580483575808;
                      "media_id_string" = 605333580483575808;
                      }
                      */
                     
                     NSString *mediaID = [response valueForKey:@"media_id_string"];
                     NSString *expiresAfterSecs = [response valueForKey:@"expires_after_secs"];
                     
                     successBlock(mediaID, expiresAfterSecs);
                 } errorBlock:^(NSError *error) {
                     errorBlock(error);
                 }];
}

- (void)postMediaUploadAPPENDWithVideoURL:(NSURL *)videoMediaURL
                                  mediaID:(NSString *)mediaID
                      uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                             successBlock:(void(^)(id response))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    // https://dev.twitter.com/rest/public/uploading-media
    // https://dev.twitter.com/rest/reference/post/media/upload-chunked
    
    NSData *data = [NSData dataWithContentsOfURL:videoMediaURL];
    
    NSInteger dataLength = [data length];
    
    if(dataLength == 0) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterAPIMediaDataIsEmpty userInfo:@{NSLocalizedDescriptionKey : @"cannot upload empty data"}];
        errorBlock(error);
        return;
    }
    
    NSString *fileName = [videoMediaURL isFileURL] ? [[videoMediaURL path] lastPathComponent] : @"media.jpg";
    
    NSUInteger fiveMegaBytes = 5 * (int) pow((double) 2,20);
    
    NSUInteger segmentIndex = 0;
    
    __block id lastResponseReceived = nil;
    __block NSError *lastErrorReceived = nil;
    __block NSUInteger accumulatedBytesWritten = 0;
    
    dispatch_group_t group = dispatch_group_create();
    
    while((segmentIndex * fiveMegaBytes) < dataLength) {
        
        NSUInteger subDataLength = MIN(dataLength - segmentIndex * fiveMegaBytes, fiveMegaBytes);
        NSRange subDataRange = NSMakeRange(segmentIndex * fiveMegaBytes, subDataLength);
        NSData *subData = [data subdataWithRange:subDataRange];
        
        //NSLog(@"-- SEGMENT INDEX %lu, SUBDATA %@", segmentIndex, NSStringFromRange(subDataRange));
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(strongSelf == nil) {
                lastErrorReceived = [NSError errorWithDomain:@"STTwitter" code:9999 userInfo:nil]; // TODO: improve
                return;
            }
            
            NSMutableDictionary *md = [NSMutableDictionary dictionary];
            md[@"command"] = @"APPEND";
            md[@"media_id"] = mediaID;
            md[@"segment_index"] = [NSString stringWithFormat:@"%lu", (unsigned long)segmentIndex];
            md[@"media"] = subData;
            md[kSTPOSTDataKey] = @"media";
            md[kSTPOSTMediaFileNameKey] = fileName;
            
            //NSLog(@"-- POST %@", [md valueForKey:@"segment_index"]);
            
            [strongSelf postResource:@"media/upload.json"
                 baseURLString:kBaseURLStringUpload_1_1
                    parameters:md
           uploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
               accumulatedBytesWritten += bytesWritten;
               uploadProgressBlock(bytesWritten, accumulatedBytesWritten, dataLength);
           } downloadProgressBlock:nil
                  successBlock:^(NSDictionary *rateLimits, id response) {
                      //NSLog(@"-- POST OK %@", [md valueForKey:@"segment_index"]);
                      lastResponseReceived = response;
                      dispatch_group_leave(group);
                  } errorBlock:^(NSError *error) {
                      //NSLog(@"-- POST KO %@", [md valueForKey:@"segment_index"]);
                      errorBlock(error);
                      dispatch_group_leave(group);
                  }];
        });
        
        segmentIndex += 1;
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"finished");
        if(lastErrorReceived) {
            errorBlock(lastErrorReceived);
        } else {
            successBlock(lastResponseReceived);
        }
    });
}

- (NSObject<STTwitterRequestProtocol> *)postMediaUploadFINALIZEWithMediaID:(NSString *)mediaID
                                                              successBlock:(void(^)(NSString *mediaID, NSString *size, NSString *expiresAfter, NSString *videoType))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    // https://dev.twitter.com/rest/public/uploading-media
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"command"] = @"FINALIZE";
    md[@"media_id"] = mediaID;
    
    return [self postResource:@"media/upload.json"
                baseURLString:kBaseURLStringUpload_1_1
                   parameters:md
          uploadProgressBlock:nil
        downloadProgressBlock:nil
                 successBlock:^(NSDictionary *rateLimits, id response) {
                     
                     //NSLog(@"-- %@", response);
                     
                     NSString *mediaID = [response valueForKey:@"media_id"];
                     NSString *expiresAfterSecs = [response valueForKey:@"expires_after_secs"];
                     NSString *size = [response valueForKey:@"size"];
                     NSString *videoType = [response valueForKeyPath:@"video.video_type"];
                     
                     /*
                      {
                      "expires_after_secs" = 3600;
                      "media_id" = 607552320679706624;
                      "media_id_string" = 607552320679706624;
                      size = 992496;
                      video =     {
                      "video_type" = "video/mp4";
                      };
                      }
                      */
                     
                     successBlock(mediaID, size, expiresAfterSecs, videoType);
                 } errorBlock:^(NSError *error) {
                     errorBlock(error);
                 }];
}

// convenience

- (void)postMediaUploadThreeStepsWithVideoURL:(NSURL *)videoURL // local URL
                          uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                 successBlock:(void(^)(NSString *mediaID, NSString *size, NSString *expiresAfter, NSString *videoType))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    __weak typeof(self) weakSelf = self;
    
    [self postMediaUploadINITWithVideoURL:videoURL
                             successBlock:^(NSString *mediaID, NSString *expiresAfterSecs) {
                                 
                                 __strong typeof(self) strongSelf = weakSelf;
                                 if(strongSelf == nil) {
                                     errorBlock(nil);
                                     return;
                                 }
                                 
                                 [strongSelf postMediaUploadAPPENDWithVideoURL:videoURL
                                                                       mediaID:mediaID
                                                           uploadProgressBlock:uploadProgressBlock
                                                                  successBlock:^(id response) {
                                                                      
                                                                      __strong typeof(self) strongSelf2 = weakSelf;
                                                                      if(strongSelf2 == nil) {
                                                                          errorBlock(nil);
                                                                          return;
                                                                      }
                                                                      
                                                                      [strongSelf2 postMediaUploadFINALIZEWithMediaID:mediaID
                                                                                                         successBlock:successBlock
                                                                                                           errorBlock:errorBlock];
                                                                  } errorBlock:errorBlock];
                             } errorBlock:errorBlock];
}

#pragma mark -
#pragma mark UNDOCUMENTED APIs

// GET activity/about_me.json
- (NSObject<STTwitterRequestProtocol> *)_getActivityAboutMeSinceID:(NSString *)sinceID
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
    
    return [self getAPIResource:@"activity/about_me.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET activity/by_friends.json
- (NSObject<STTwitterRequestProtocol> *)_getActivityByFriendsSinceID:(NSString *)sinceID
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
    
    return [self getAPIResource:@"activity/by_friends.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET statuses/:id/activity/summary.json
- (NSObject<STTwitterRequestProtocol> *)_getStatusesActivitySummaryForStatusID:(NSString *)statusID
                                                                  successBlock:(void(^)(NSArray *favoriters, NSArray *repliers, NSArray *retweeters, NSString *favoritersCount, NSString *repliersCount, NSString *retweetersCount))successBlock
                                                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *resource = [NSString stringWithFormat:@"statuses/%@/activity/summary.json", statusID];
    
    return [self getAPIResource:resource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        
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
- (NSObject<STTwitterRequestProtocol> *)_getConversationShowForStatusID:(NSString *)statusID
                                                           successBlock:(void(^)(NSArray *statuses))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSDictionary *d = @{@"id":statusID};
    
    return [self getAPIResource:@"conversation/show.json" parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET discover/highlight.json
- (NSObject<STTwitterRequestProtocol> *)_getDiscoverHighlightWithSuccessBlock:(void(^)(NSDictionary *metadata, NSArray *modules))successBlock
                                                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getAPIResource:@"discover/highlight.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *metadata = [response valueForKey:@"metadata"];
        NSArray *modules = [response valueForKey:@"modules"];
        
        successBlock(metadata, modules);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET discover/universal.json
- (NSObject<STTwitterRequestProtocol> *)_getDiscoverUniversalWithSuccessBlock:(void(^)(NSDictionary *metadata, NSArray *modules))successBlock
                                                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getAPIResource:@"discover/universal.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *metadata = [response valueForKey:@"metadata"];
        NSArray *modules = [response valueForKey:@"modules"];
        
        successBlock(metadata, modules);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET statuses/media_timeline.json
- (NSObject<STTwitterRequestProtocol> *)_getMediaTimelineWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getAPIResource:@"statuses/media_timeline.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/recommendations.json
- (NSObject<STTwitterRequestProtocol> *)_getUsersRecommendationsWithSuccessBlock:(void(^)(NSArray *recommendations))successBlock
                                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getAPIResource:@"users/recommendations.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET timeline/home.json
- (NSObject<STTwitterRequestProtocol> *)_getTimelineHomeWithSuccessBlock:(void(^)(id response))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getAPIResource:@"timeline/home.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET statuses/mentions_timeline.json
- (NSObject<STTwitterRequestProtocol> *)_getStatusesMentionsTimelineWithCount:(NSString *)count
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
    
    return [self getAPIResource:@"statuses/mentions_timeline.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET trends/available.json
- (NSObject<STTwitterRequestProtocol> *)_getTrendsAvailableWithSuccessBlock:(void(^)(NSArray *places))successBlock
                                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self getAPIResource:@"trends/available.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST users/report_spam
- (NSObject<STTwitterRequestProtocol> *)_postUsersReportSpamForTweetID:(NSString *)tweetID
                                                              reportAs:(NSString *)reportAs // spam, abused, compromised
                                                             blockUser:(NSNumber *)blockUser
                                                          successBlock:(void(^)(id userProfile))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(tweetID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"tweet_id"] = tweetID;
    if(reportAs) md[@"report_as"] = reportAs;
    if(blockUser) md[@"block_user"] = [blockUser boolValue] ? @"true" : @"false";
    
    return [self postAPIResource:@"users/report_spam.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/generate.json
- (NSObject<STTwitterRequestProtocol> *)_postAccountGenerateWithADC:(NSString *)adc
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
    
    return [self postResource:@"account/generate.json"
                baseURLString:@"https://api.twitter.com/1"
                   parameters:md
          uploadProgressBlock:nil
        downloadProgressBlock:^(NSData *data) {
            //
        } successBlock:^(NSDictionary *rateLimits, id response) {
            successBlock(response);
        } errorBlock:^(NSError *error) {
            errorBlock(error);
        }];
}

// GET search/typeahead.json
- (NSObject<STTwitterRequestProtocol> *)_getSearchTypeaheadQuery:(NSString *)query
                                                      resultType:(NSString *)resultType // "all"
                                                  sendErrorCodes:(NSNumber *)sendErrorCodes
                                                    successBlock:(void(^)(id results))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"q"] = query;
    if(resultType) md[@"result_type"] = resultType;
    if(sendErrorCodes) md[@"send_error_codes"] = @([sendErrorCodes boolValue]);
    
    return [self getAPIResource:@"search/typeahead.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET conversation/show/:id.json
- (NSObject<STTwitterRequestProtocol> *)_getConversationShowWithTweetID:(NSString *)tweetID
                                                           successBlock:(void(^)(id results))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(tweetID);
    
    NSString *ressource = [NSString stringWithFormat:@"conversation/show/%@.json", tweetID];
    
    return [self getAPIResource:ressource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark UNDOCUMENTED APIS SCHEDULED TWEETS - VALID ONLY FOR TWEETDECK

// GET schedule/status/list.json
- (NSObject<STTwitterRequestProtocol> *)_getScheduleStatusesWithCount:(NSString *)count
                                                      includeEntities:(NSNumber *)includeEntities
                                                  includeUserEntities:(NSNumber *)includeUserEntities
                                                         includeCards:(NSNumber *)includeCards
                                                         successBlock:(void(^)(NSArray *scheduledTweets))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(count) md[@"count"] = count;
    if(includeEntities) md[@"include_entities"] = @([includeEntities boolValue]);
    if(includeUserEntities) md[@"include_user_entities"] = @([includeUserEntities boolValue]);
    if(includeCards) md[@"include_cards"] = @([includeCards boolValue]);
    
    return [self getAPIResource:@"schedule/status/list.json"
                     parameters:md
                   successBlock:^(NSDictionary *rateLimits, id response) {
                       successBlock(response);
                   } errorBlock:^(NSError *error) {
                       errorBlock(error);
                   }];
}

// POST schedule/status/tweet.json
- (NSObject<STTwitterRequestProtocol> *)_postScheduleStatus:(NSString *)status
                                                  executeAt:(NSString *)executeAtUnixTimestamp
                                                   mediaIDs:(NSArray *)mediaIDs
                                               successBlock:(void(^)(NSDictionary *scheduledTweet))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(status);
    NSParameterAssert(executeAtUnixTimestamp);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"status"] = status;
    md[@"execute_at"] = executeAtUnixTimestamp;
    if(mediaIDs) md[@"media_ids"] = [mediaIDs componentsJoinedByString:@","];
    
    return [self postAPIResource:@"schedule/status/tweet.json"
                      parameters:md
                    successBlock:^(NSDictionary *rateLimits, id response) {
                        successBlock(response);
                    } errorBlock:^(NSError *error) {
                        errorBlock(error);
                    }];
}

// DELETE schedule/status/:id.json
// delete a scheduled tweet
- (NSObject<STTwitterRequestProtocol> *)_deleteScheduleStatusWithID:(NSString *)statusID
                                                       successBlock:(void(^)(NSDictionary *deletedTweet))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"schedule/status/%@.json", statusID];
    
    return [self fetchResource:resource
                    HTTPMethod:@"DELETE"
                 baseURLString:kBaseURLStringAPI_1_1
                    parameters:nil
           uploadProgressBlock:nil
         downloadProgressBlock:nil
                  successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                      successBlock(response);
                  } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                      errorBlock(error);
                  }];
}

// PUT schedule/status/:id.json
// edit a scheduled tweet
- (NSObject<STTwitterRequestProtocol> *)_putScheduleStatusWithID:(NSString *)statusID
                                                          status:(NSString *)status
                                                       executeAt:(NSString *)executeAtUnixTimestamp
                                                        mediaIDs:(NSArray *)mediaIDs
                                                    successBlock:(void(^)(NSDictionary *scheduledTweet))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"schedule/status/%@.json", statusID];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(status) md[@"status"] = status;
    if(executeAtUnixTimestamp) md[@"execute_at"] = executeAtUnixTimestamp;
    if(mediaIDs) md[@"media_ids"] = [mediaIDs componentsJoinedByString:@","];
    
    return [self fetchResource:resource
                    HTTPMethod:@"PUT"
                 baseURLString:kBaseURLStringAPI_1_1
                    parameters:md
           uploadProgressBlock:nil
         downloadProgressBlock:nil
                  successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                      successBlock(response);
                  } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                      errorBlock(error);
                  }];
}

#pragma mark UNDOCUMENTED APIS FOR DIGITS AUTH

// POST guest/activate.json
- (NSObject<STTwitterRequestProtocol> *)_postGuestActivateWithSuccessBlock:(void(^)(NSString *guestToken))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self postAPIResource:@"guest/activate.json"
                      parameters:nil
                    successBlock:^(NSDictionary *rateLimits, id response) {
                        NSString *guestToken = [response valueForKey:@"guest_token"];
                        successBlock(guestToken);
                    } errorBlock:^(NSError *error) {
                        errorBlock(error);
                    }];
}

// POST device/register.json
- (NSObject<STTwitterRequestProtocol> *)_postDeviceRegisterPhoneNumber:(NSString *)phoneNumber // eg. @"+41764948273"
                                                            guestToken:(NSString *)guestToken
                                                          successBlock:(void(^)(id response))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(phoneNumber);
    
    NSDictionary *parameters = @{@"raw_phone_number":phoneNumber,
                                 @"text_key":@"third_party_confirmation_code",
                                 @"send_numeric_pin":@"true",
                                 @"[STTWITTER_HEADER_APPONLY_POST]x-guest-token":guestToken};
    
    return [self postAPIResource:@"device/register.json"
                      parameters:parameters
                    successBlock:^(NSDictionary *rateLimits, id response) {
                        successBlock(response);
                    } errorBlock:^(NSError *error) {
                        errorBlock(error);
                    }];
}

// POST sdk/account.json
- (NSObject<STTwitterRequestProtocol> *)_postSDKAccountNumericPIN:(NSString *)numericPIN
                                                   forPhoneNumber:(NSString *)phoneNumber
                                                       guestToken:(NSString *)guestToken
                                                     successBlock:(void(^)(id response, NSString *accessToken, NSString *accessTokenSecret))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(numericPIN);
    NSParameterAssert(phoneNumber);
    
    NSDictionary *parameters = @{@"numeric_pin":numericPIN,
                                 @"phone_number":phoneNumber,
                                 @"[STTWITTER_HEADER_APPONLY_POST]x-guest-token":guestToken};
    
    return [self fetchResource:@"sdk/account.json"
                    HTTPMethod:@"POST"
                 baseURLString:kBaseURLStringAPI_1_1
                    parameters:parameters
           uploadProgressBlock:nil
         downloadProgressBlock:nil
                  successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                      NSString *accessToken = [responseHeaders valueForKey:@"x-twitter-new-account-oauth-access-token"];
                      NSString *accessTokenSecret = [responseHeaders valueForKey:@"x-twitter-new-account-oauth-secret"];
                      successBlock(response, accessToken, accessTokenSecret);
                  } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                      errorBlock(error);
                  }];
}

#pragma mark UNDOCUMENTED APIS FOR CONTACTS

// POST contacts/upload.json
- (NSObject<STTwitterRequestProtocol> *)_postContactsUpload:(NSArray *)vCards
                                               successBlock:(void(^)(id response))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{@"vcards":vCards};
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:d options:0 error:&error];
    if(data == nil) {
        errorBlock(error);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kBaseURLStringAPI_1_1, @"contacts/upload.json"];
    
    STHTTPRequest *r = [STHTTPRequest twitterRequestWithURLString:urlString
                                                       HTTPMethod:@"POST"
                                                 timeoutInSeconds:10
                                     stTwitterUploadProgressBlock:nil
                                   stTwitterDownloadProgressBlock:nil
                                            stTwitterSuccessBlock:^(NSDictionary *requestHeaders, NSDictionary *responseHeaders, id json) {
                                                successBlock(json);
                                            } stTwitterErrorBlock:^(NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                                                errorBlock(error);
                                            }];
    
    STTwitterOAuth *oAuth = (STTwitterOAuth *)self.oauth;
    [oAuth signRequest:r isMediaUpload:NO oauthCallback:nil];
    
    [r setRawPOSTData:data];
    [r setHeaderWithName:@"Content-Type" value:@"application/json"];
    
    [r startAsynchronous];
    
    return r;
}

// GET contacts/users_and_uploaded_by.json
- (NSObject<STTwitterRequestProtocol> *)_getContactsUsersAndUploadedByWithCount:(NSString *)count
                                                                   successBlock:(void(^)(id response))successBlock
                                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(count) md[@"count"] = count;
    
    return [self getAPIResource:@"contacts/users_and_uploaded_by.json"
                     parameters:md
                   successBlock:^(NSDictionary *rateLimits, id response) {
                       successBlock(response);
                   } errorBlock:^(NSError *error) {
                       errorBlock(error);
                   }];
}

// POST contacts/destroy/all.json
- (NSObject<STTwitterRequestProtocol> *)_getContactsDestroyAllWithSuccessBlock:(void(^)(id response))successBlock
                                                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self postAPIResource:@"contacts/destroy/all.json"
                      parameters:nil
                    successBlock:^(NSDictionary *rateLimits, id response) {
                        successBlock(response);
                    } errorBlock:^(NSError *error) {
                        errorBlock(error);
                    }];
}

#pragma mark UNDOCUMENTED APIS FOR TWITTER ANALYTICS

// GET https://analytics.twitter.com/user/:screenname/tweet/:tweetid/mobile/poll.json
- (NSObject<STTwitterRequestProtocol> *)_getAnalyticsWithScreenName:(NSString *)screenName
                                                            tweetID:(NSString *)tweetID
                                                       successBlock:(void(^)(id rawResponse, NSDictionary *responseDictionary))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    
    NSParameterAssert(screenName);
    NSParameterAssert(tweetID);
    
    NSString *resource = [NSString stringWithFormat:@"user/%@/tweet/%@/mobile/poll.json", screenName, tweetID];
    
    return [_oauth fetchResource:resource
                      HTTPMethod:@"GET"
                   baseURLString:@"https://analytics.twitter.com"
                      parameters:nil
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        
                        NSString *prefix = @"/**/retrieveNewMetrics(";
                        //NSString *suffix = @")";
                        
                        NSDictionary *json = nil;
                        
                        if([response hasPrefix:prefix] && [response length] >= [prefix length] + 2) {
                            // transform jsonp into NSDictionary
                            NSMutableString *ms = [response mutableCopy];
                            [ms deleteCharactersInRange:NSMakeRange(0, [prefix length])];
                            [ms deleteCharactersInRange:NSMakeRange([ms length]-2, 2)];
                            NSLog(@"-- %@", ms);
                            NSData *data = [ms dataUsingEncoding:NSUTF8StringEncoding];
                            NSError *jsonError = nil;
                            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                            if(json == nil) {
                                NSLog(@"-- %@", [jsonError localizedDescription]);
                            }
                            NSLog(@"-- %@", json);
                        }
                        
                        successBlock(response, json);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
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
