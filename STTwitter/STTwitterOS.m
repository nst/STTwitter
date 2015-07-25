//
//  STTwitterOS.m
//  STTwitter
//
//  Created by Nicolas Seriot on 5/1/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import "STTwitterOS.h"
#import "NSString+STTwitter.h"
#import "STTwitterOSRequest.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "NSError+STTwitter.h"
#if TARGET_OS_IPHONE
#import <Twitter/Twitter.h> // iOS 5
#endif

@interface ACAccount (STTwitterOS)
- (NSString*)st_userID; // private API
@end

@interface STTwitterOS ()
@property (nonatomic, retain) ACAccountStore *accountStore; // the ACAccountStore must be kept alive for as long as we need an ACAccount instance, see WWDC 2011 Session 124 for more info
@property (nonatomic, retain) ACAccount *account; // if nil, will be set to first account available
@end

@implementation STTwitterOS

- (instancetype)init {
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

- (NSString *)userID {
    return [self.account st_userID];
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

- (void)verifyCredentialsRemotelyWithSuccessBlock:(void(^)(NSString *username, NSString *userID))successBlock
                                       errorBlock:(void(^)(NSError *error))errorBlock {
    __weak typeof(self) weakSelf = self;
    
    [self fetchResource:@"account/verify_credentials.json"
             HTTPMethod:@"GET"
          baseURLString:@"https://api.twitter.com/1.1"
             parameters:nil
    uploadProgressBlock:nil
  downloadProgressBlock:nil
           successBlock:^(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
               
               if([response isKindOfClass:[NSDictionary class]] == NO) {
                   NSString *errorDescription = [NSString stringWithFormat:@"Expected dictionary, found %@", response];
                   NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
                   errorBlock(error);
                   return;
               }
               
               typeof(self) strongSelf = weakSelf;
               if(strongSelf == nil) return;

               NSDictionary *dict = response;
               successBlock(dict[@"screen_name"], dict[@"id_str"]);
           } errorBlock:^(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
               
               // add recovery suggestion if we can
               if([[error domain] isEqualToString:kSTTwitterTwitterErrorDomain] && ([error code] == 220)) {
                   NSMutableDictionary *extendedUserInfo = [[error userInfo] mutableCopy];
                   extendedUserInfo[NSLocalizedRecoverySuggestionErrorKey] = @"Consider entering the Twitter credentials again in OS Settings.";
                   NSError *extendedError = [NSError errorWithDomain:[error domain] code:[error code] userInfo:extendedUserInfo];
                   errorBlock(extendedError);
                   return;
               }
               
               errorBlock(error);
           }];
}


- (BOOL)hasAccessToTwitter {
    
#if !TARGET_OS_IPHONE
    return YES;
#else
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        return [TWTweetComposeViewController canSendTweet]; // iOS 5
    } else {
        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    }
#else
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
#endif
    
#endif
}

- (void)verifyCredentialsLocallyWithSuccessBlock:(void(^)(NSString *username, NSString *userID))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
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

    __weak typeof(self) weakSelf = self;

    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            typeof(self) strongSelf = weakSelf;

            if(strongSelf == nil) return;
            
            if(granted == NO) {
                
                if(error) {
                    errorBlock(error);
                    return;
                }
                
                NSString *message = @"User denied access to their account(s).";
                NSError *grantError = [NSError errorWithDomain:NSStringFromClass([strongSelf class]) code:STTwitterOSUserDeniedAccessToTheirAccounts userInfo:@{NSLocalizedDescriptionKey : message}];
                errorBlock(grantError);
                return;
            }
            
            if(strongSelf.account == nil) {
                NSArray *accounts = [strongSelf.accountStore accountsWithAccountType:accountType];
                
                // ignore accounts that have no indentifier
                // possible workaround for accounts with no password stored
                // see https://twittercommunity.com/t/ios-6-twitter-accounts-with-no-password-stored/6183
                NSMutableArray *accountsWithIdentifiers = [NSMutableArray array];
                [accounts enumerateObjectsUsingBlock:^(ACAccount *account, NSUInteger idx, BOOL *stop) {

                    NSString *accountID = [account identifier];
                    
                    if([accountID length] > 0) {
                        [accountsWithIdentifiers addObject:account];
                    } else {
                        NSLog(@"-- ignore account %@ because identifier is empty", account);
                    }
                }];
                
                if([accountsWithIdentifiers count] == 0) {
                    NSString *message = @"No Twitter account available.";
                    NSError *error = [NSError errorWithDomain:NSStringFromClass([strongSelf class]) code:STTwitterOSNoTwitterAccountIsAvailable userInfo:@{NSLocalizedDescriptionKey : message}];
                    errorBlock(error);
                    return;
                }
                
                strongSelf.account = [accountsWithIdentifiers firstObject];
            }
            
            successBlock(strongSelf.account.username, [strongSelf.account st_userID]);
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
}

- (NSDictionary *)OAuthEchoHeadersToVerifyCredentials {

    // https://api.twitter.com/1.1/account/verify_credentials.json
    
    STTwitterOSRequest *r = [[STTwitterOSRequest alloc] initWithAPIResource:@"/account/verify_credentials.json"
                                                              baseURLString:@"https://api.twitter.com/1.1"
                                                                 httpMethod:SLRequestMethodGET
                                                                 parameters:nil
                                                                    account:self.account
                                                           timeoutInSeconds:0
                                                        uploadProgressBlock:nil
                                                                streamBlock:nil
                                                            completionBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                                                                //
                                                            } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                                                                //
                                                            }];
    
    NSURLRequest *preparedURLRequest = [r preparedURLRequest];
    
    NSDictionary *headers = [preparedURLRequest allHTTPHeaderFields];

    NSString *authorization = [headers valueForKey:@"Authorization"];
    
    if(authorization == nil) return nil;
    
    /*
     Please note that one should use the URL provided to them by X-Auth-Service-Provider to perform the look up,
     not a hard coded value on your servers. Apple iOS5, for example, adds an additional application_id parameter
     to all OAuth requests, and its existence should be maintained at each stage of OAuth Echo.
     https://dev.twitter.com/oauth/echo
     */
    NSString *verifyCredentialsURLString = [[preparedURLRequest URL] description];//@"https://api.twitter.com/1.1/account/verify_credentials.json";
    
    return @{@"X-Auth-Service-Provider" : verifyCredentialsURLString,
             @"X-Verify-Credentials-Authorization" : authorization};
    
    return headers;
}

+ (SLRequestMethod)slRequestMethodForString:(NSString *)HTTPMethod {
    if([HTTPMethod isEqualToString:@"POST"]) return SLRequestMethodPOST;
    if([HTTPMethod isEqualToString:@"PUT"]) return SLRequestMethodPUT;
    if([HTTPMethod isEqualToString:@"DELETE"]) return SLRequestMethodDELETE;
    if([HTTPMethod isEqualToString:@"GET"] == NO) {
        NSAssert(NO, @"Unsupported HTTP method");
    }
    return SLRequestMethodGET;
}

- (NSObject<STTwitterRequestProtocol> *)fetchResource:(NSString *)resource
                                           HTTPMethod:(NSString *)HTTPMethod
                                        baseURLString:(NSString *)baseURLString
                                           parameters:(NSDictionary *)params
                                  uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                downloadProgressBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))progressBlock // FIXME: how to handle progressBlock?
                                         successBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
                                           errorBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    NSInteger slRequestMethod = [[self class] slRequestMethodForString:HTTPMethod];
    
    NSDictionary *d = params;
    
    if([HTTPMethod isEqualToString:@"GET"] == NO) {
        if (d == nil) d = @{};
    }
    
    NSString *baseURLStringWithTrailingSlash = baseURLString;
    if([baseURLString hasSuffix:@"/"] == NO) {
        baseURLStringWithTrailingSlash = [baseURLString stringByAppendingString:@"/"];
    }
    
    STTwitterOSRequest *r = [[STTwitterOSRequest alloc] initWithAPIResource:resource
                                                              baseURLString:baseURLStringWithTrailingSlash
                                                                 httpMethod:slRequestMethod
                                                                 parameters:d
                                                                    account:self.account
                                                           timeoutInSeconds:_timeoutInSeconds
                                                        uploadProgressBlock:uploadProgressBlock
                                                                streamBlock:progressBlock
                                                            completionBlock:successBlock
                                                                 errorBlock:errorBlock];
    [r startRequest];
    
    return r;
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
    
    NSAssert(self.account, @"no account is set, try to call -verifyCredentialsWithUserSuccessBlock:errorBlock: first");
    
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
    uploadProgressBlock:nil
  downloadProgressBlock:nil
           successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
               
               NSDictionary *d = [[self class] parametersDictionaryFromAmpersandSeparatedParameterString:response];
               
               NSString *oAuthToken = [d valueForKey:@"oauth_token"];
               NSString *oAuthTokenSecret = [d valueForKey:@"oauth_token_secret"];
               NSString *userID = [d valueForKey:@"user_id"];
               NSString *screenName = [d valueForKey:@"screen_name"];
               
               successBlock(oAuthToken, oAuthTokenSecret, userID, screenName);
           } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
               errorBlock(error); // in case of -1012 error, the Twitter account may lack the 'oauth_token' property and need to be setup again in iOS Settings, see http://stackoverflow.com/questions/30307062/access-users-ios-default-twitter-account-ios/30461959#30461959
           }];
}

@end

@implementation ACAccount (STTwitterOS)

- (NSString*)st_userID
{
    return [self valueForKeyPath:@"properties.user_id"];
}

@end