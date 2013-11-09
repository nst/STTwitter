//
//  MGTwitterEngine+TH.m
//  TwitHunter
//
//  Created by Nicolas Seriot on 5/1/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import "STTwitterOS.h"
#import "NSString+STTwitter.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#if TARGET_OS_IPHONE
#import <Twitter/Twitter.h> // iOS 5
#endif

@interface STTwitterOS ()
@property (nonatomic, retain) ACAccountStore *accountStore; // the ACAccountStore must be kept alive for as long as we need an ACAccount instance, see WWDC 2011 Session 124 for more info
@property (nonatomic, retain) ACAccount *account; // if nil, will be set to first account available
@end

@implementation STTwitterOS

- (id)init {
    self = [super init];
    
    self.accountStore = [[ACAccountStore alloc] init];
    
    return self;
}

- (instancetype)initWithAccount:(ACAccount *) account {
    self = [super init];
    self.accountStore = [[ACAccountStore alloc] init];
    self.account = account;
    return self;
}

+ (instancetype)twitterAPIOSWithAccount:(ACAccount *)account {
    return [[self alloc] initWithAccount:account];
}

+ (instancetype)twitterAPIOSWithFirstAccount {
    return [self twitterAPIOSWithAccount:nil];
}

- (NSString *)username {
    return self.account.username;
}

- (NSString *)consumerName {
#if TARGET_OS_IPHONE
    return @"iOS";
#else
    return @"OS X";
#endif
}

- (NSString *)loginTypeDescription {
    return @"System";
}

- (BOOL)canVerifyCredentials {
    return YES;
}

- (BOOL)hasAccessToTwitter {
    
#if TARGET_API_MAC_OSX
    return YES;
#else
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    return [TWTweetComposeViewController canSendTweet]; // iOS 5
#else
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
#endif
    
#endif
}

- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    if([self hasAccessToTwitter] == NO) {
        NSString *message = @"This system cannot access Twitter.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSSystemCannotAccessTwitter userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return;
    }
    
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if(accountType == nil) {
        NSString *message = @"Cannot find Twitter account.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSCannotFindTwitterAccount userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return;
    }
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                
                if(error) {
                    errorBlock(error);
                    return;
                }
                
                NSString *message = @"User denied access to their account(s).";
                NSError *grantError = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSUserDeniedAccessToTheirAccounts userInfo:@{NSLocalizedDescriptionKey : message}];
                errorBlock(grantError);
                return;
            }
            
            if(self.account == nil) {
                NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
                
                if([accounts count] == 0) {
                    NSString *message = @"No Twitter account available.";
                    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSNoTwitterAccountIsAvailable userInfo:@{NSLocalizedDescriptionKey : message}];
                    errorBlock(error);
                    return;
                }
                
                self.account = [accounts objectAtIndex:0];
            }
            
            successBlock(self.account.username);
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    [self.accountStore requestAccessToAccountsWithType:accountType
                                 withCompletionHandler:accountStoreRequestCompletionHandler];
    
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
}

- (NSDictionary *)requestHeadersForRequest:(id)request {
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    return [[request signedURLRequest] allHTTPHeaderFields];
#else
    return [[request preparedURLRequest] allHTTPHeaderFields];
#endif
}

- (id)fetchAPIResource:(NSString *)resource
         baseURLString:(NSString *)baseURLString
            httpMethod:(NSInteger)httpMethod
            parameters:(NSDictionary *)params
       completionBlock:(void (^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))completionBlock
            errorBlock:(void (^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    NSData *mediaData = [params valueForKey:@"media[]"];
    
    NSMutableDictionary *paramsWithoutMedia = [params mutableCopy];
    [paramsWithoutMedia removeObjectForKey:@"media[]"];
    
    NSString *urlString = [baseURLString stringByAppendingString:resource];
    NSURL *url = [NSURL URLWithString:urlString];
    
    id request = nil;
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    TWRequestMethod method = (httpMethod == 0) ? TWRequestMethodGET : TWRequestMethodPOST;
    request = [[TWRequest alloc] initWithURL:url parameters:paramsWithoutMedia requestMethod:method];
#else
    request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:httpMethod URL:url parameters:paramsWithoutMedia];
#endif
    
    [request setAccount:self.account];
    
    if(mediaData) {
        [request addMultipartData:mediaData withName:@"media[]" type:@"application/octet-stream" filename:@"media.jpg"];
    }
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        NSString *rawResponse = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if(responseData == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], error);
            }];
            return;
        }
        
        NSError *jsonError = nil;
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if(json == nil) {
            
            // do our best to extract Twitter error message from responseString
            
            NSError *regexError = nil;
            NSString *errorString = [rawResponse firstMatchWithRegex:@"<error.*?>(.*)</error>" error:&regexError];
            
            if(errorString) {
                error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : errorString}];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], error);
                }];
                return;
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], rawResponse);
            }];
            return;
        }
        
        /**/
        
        if([json isKindOfClass:[NSArray class]] == NO && [json valueForKey:@"error"]) {
            
            NSString *message = [json valueForKey:@"error"];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
            NSError *jsonErrorFromResponse = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], jsonErrorFromResponse);
            }];
            
            return;
        }
        
        /**/
        
        id jsonErrors = [json valueForKey:@"errors"];
        
        if(jsonErrors != nil && [jsonErrors isKindOfClass:[NSArray class]] == NO) {
            if(jsonErrors == nil) jsonErrors = @"";
            jsonErrors = [NSArray arrayWithObject:@{@"message":jsonErrors, @"code" : @(0)}];
        }
        
        if([jsonErrors count] > 0 && [jsonErrors lastObject] != [NSNull null]) {
            
            NSDictionary *jsonErrorDictionary = [jsonErrors lastObject];
            NSString *message = jsonErrorDictionary[@"message"];
            NSInteger code = [jsonErrorDictionary[@"code"] intValue];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
            NSError *jsonErrorFromResponse = [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:userInfo];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], jsonErrorFromResponse);
            }];
            
            return;
        }
        
        /**/
        
        if(json) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], (NSArray *)json);
            }];
            
        } else {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], jsonError);
            }];
        }
    }];
    
    return request;
}

- (id)fetchResource:(NSString *)resource
         HTTPMethod:(NSString *)HTTPMethod
      baseURLString:(NSString *)baseURLString
         parameters:(NSDictionary *)params
      progressBlock:(void (^)(id request, id response))progressBlock // TODO: handle progressBlock?
       successBlock:(void (^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
         errorBlock:(void (^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    NSAssert(([ @[@"GET", @"POST"] containsObject:HTTPMethod]), @"unsupported HTTP method");
    
    NSInteger slRequestMethod = SLRequestMethodGET;
    
    NSDictionary *d = params;
    
    if([HTTPMethod isEqualToString:@"POST"]) {
        if (d == nil) d = @{};
        slRequestMethod = SLRequestMethodPOST;
    }
    
    NSString *baseURLStringWithTrailingSlash = baseURLString;
    if([baseURLString hasSuffix:@"/"] == NO) {
        baseURLStringWithTrailingSlash = [baseURLString stringByAppendingString:@"/"];
    }
    
    return [self fetchAPIResource:resource
                    baseURLString:baseURLStringWithTrailingSlash
                       httpMethod:slRequestMethod
                       parameters:d
                  completionBlock:successBlock
                       errorBlock:errorBlock];
}

+ (NSDictionary *)parametersDictionaryFromCommaSeparatedParametersString:(NSString *)s {
    
    NSArray *parameters = [s componentsSeparatedByString:@", "];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    for(NSString *parameter in parameters) {
        // transform k="v" into {'k':'v'}
        
        NSArray *keyValue = [parameter componentsSeparatedByString:@"="];
        if([keyValue count] != 2) {
            continue;
        }
        
        NSString *value = [keyValue[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        [md setObject:value forKey:keyValue[0]];
    }
    
    return md;
}

// TODO: this code is duplicated from STTwitterOAuth
+ (NSDictionary *)parametersDictionaryFromAmpersandSeparatedParameterString:(NSString *)s {
    
    NSArray *parameters = [s componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    for(NSString *parameter in parameters) {
        NSArray *keyValue = [parameter componentsSeparatedByString:@"="];
        if([keyValue count] != 2) {
            continue;
        }
        
        [md setObject:keyValue[1] forKey:keyValue[0]];
    }
    
    return md;
}

// reverse auth phase 2
- (void)postReverseAuthAccessTokenWithAuthenticationHeader:(NSString *)authenticationHeader
                                              successBlock:(void(^)(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName))successBlock
                                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(self.account, @"no account is set, try to call -verifyCredentialsWithSuccessBlock:errorBlock: first");
    
    NSParameterAssert(authenticationHeader);
    
    NSString *shortHeader = [authenticationHeader stringByReplacingOccurrencesOfString:@"OAuth " withString:@""];
    
    NSDictionary *authenticationHeaderDictionary = [[self class] parametersDictionaryFromCommaSeparatedParametersString:shortHeader];
    
    NSString *consumerKey = [authenticationHeaderDictionary valueForKey:@"oauth_consumer_key"];
    
    NSAssert((consumerKey != nil), @"cannot find out consumerKey");
    
    NSDictionary *d = @{@"x_reverse_auth_target" : consumerKey,
                        @"x_reverse_auth_parameters" : authenticationHeader};
    
    [self fetchResource:@"oauth/access_token"
             HTTPMethod:@"POST"
          baseURLString:@"https://api.twitter.com"
             parameters:d
          progressBlock:nil
           successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
               
               NSDictionary *d = [[self class] parametersDictionaryFromAmpersandSeparatedParameterString:response];
               
               NSString *oAuthToken = [d valueForKey:@"oauth_token"];
               NSString *oAuthTokenSecret = [d valueForKey:@"oauth_token_secret"];
               NSString *userID = [d valueForKey:@"user_id"];
               NSString *screenName = [d valueForKey:@"screen_name"];
               
               successBlock(oAuthToken, oAuthTokenSecret, userID, screenName);
           } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
               errorBlock(error);
           }];
}

@end
