//
//  STTwitterAPI.m
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/18/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPIWrapper.h"
#import "STTwitterOAuthOSX.h"
#import "STTwitterOAuth.h"
#import "NSString+STTwitter.h"
#import "STTwitterAppOnly.h"
#import <Accounts/Accounts.h>
#import "STHTTPRequest.h"

@interface STTwitterAPIWrapper ()
//id removeNull(id rootObject);
@property (nonatomic, retain) NSObject <STTwitterOAuthProtocol> *oauth;
@end

@implementation STTwitterAPIWrapper

#if TARGET_OS_IPHONE
#else

- (id)init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ACAccountStoreDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        // OS X account must be considered invalid
        
        if([self.oauth isKindOfClass:[STTwitterOAuthOSX class]]) {
            self.oauth = nil;//[[[STTwitterOAuthOSX alloc] init] autorelease];
        }
    }];
    
    return self;
}

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthOSX {
    STTwitterAPIWrapper *twitter = [[STTwitterAPIWrapper alloc] init];
    twitter.oauth = [[[STTwitterOAuthOSX alloc] init] autorelease];
    return [twitter autorelease];
}

#endif

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                             consumerKey:(NSString *)consumerKey
                                          consumerSecret:(NSString *)consumerSecret
                                                username:(NSString *)username
                                                password:(NSString *)password {
    
    STTwitterAPIWrapper *twitter = [[STTwitterAPIWrapper alloc] init];
    
    twitter.oauth = [STTwitterOAuth twitterServiceWithConsumerName:consumerName
                                                       consumerKey:consumerKey
                                                    consumerSecret:consumerSecret
                                                          username:username
                                                          password:password];
    return [twitter autorelease];
}

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                             consumerKey:(NSString *)consumerKey
                                          consumerSecret:(NSString *)consumerSecret
                                              oauthToken:(NSString *)oauthToken
                                        oauthTokenSecret:(NSString *)oauthTokenSecret {
    
    STTwitterAPIWrapper *twitter = [[STTwitterAPIWrapper alloc] init];
    
    twitter.oauth = [STTwitterOAuth twitterServiceWithConsumerName:consumerName
                                                       consumerKey:consumerKey
                                                    consumerSecret:consumerSecret
                                                        oauthToken:oauthToken
                                                  oauthTokenSecret:oauthTokenSecret];
    return [twitter autorelease];
}

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                             consumerKey:(NSString *)consumerKey
                                          consumerSecret:(NSString *)consumerSecret {
    
    return [self twitterAPIWithOAuthConsumerName:consumerName
                                     consumerKey:consumerKey
                                  consumerSecret:consumerSecret
                                        username:nil
                                        password:nil];
}

+ (STTwitterAPIWrapper *)twitterAPIApplicationOnlyWithConsumerKey:(NSString *)consumerKey
                                                   consumerSecret:(NSString *)consumerSecret {
    
    STTwitterAPIWrapper *twitter = [[STTwitterAPIWrapper alloc] init];
    
    STTwitterAppOnly *appOnly = [[[STTwitterAppOnly alloc] init] autorelease];
    appOnly.consumerKey = consumerKey;
    appOnly.consumerSecret = consumerSecret;
    
    twitter.oauth = appOnly;
    return twitter;
}

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock oauthCallback:(NSString *)oauthCallback errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth postTokenRequest:successBlock oauthCallback:oauthCallback errorBlock:errorBlock];
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
            successBlock(_userName);
        } errorBlock:^(NSError *error) {
            errorBlock(error);
        }];
    } else {
        [self getAccountVerifyCredentialsWithSuccessBlock:^(NSDictionary *account) {
            self.userName = [account valueForKey:@"screen_name"];
            successBlock(_userName);
        } errorBlock:^(NSError *error) {
            errorBlock(error);
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
    if([_oauth isKindOfClass:[STTwitterOAuthOSX class]]) {
        STTwitterOAuthOSX *oAuthOSX = (STTwitterOAuthOSX *)_oauth;
        return oAuthOSX.username;
    }
#endif
    
    return _userName;
}

- (void)dealloc {
    [_userName release];
    [_consumerName release];
    [_oauth release];
    [super dealloc];
}

/**/

#pragma mark Generic methods to GET and POST

- (void)getResource:(NSString *)resource
         parameters:(NSDictionary *)parameters
       successBlock:(void(^)(id json))successBlock
         errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth getResource:resource
             parameters:parameters
           successBlock:successBlock
             errorBlock:errorBlock];
}

- (void)postResource:(NSString *)resource
          parameters:(NSDictionary *)parameters
        successBlock:(void(^)(id response))successBlock
          errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth postResource:resource
              parameters:parameters
            successBlock:successBlock
              errorBlock:errorBlock];
}

/**/

- (void)profileImageFor:(NSString *)screenName

#if TARGET_OS_IPHONE
           successBlock:(void(^)(UIImage *image))successBlock
#else
           successBlock:(void(^)(NSImage *image))successBlock
#endif

             errorBlock:(void(^)(NSError *error))errorBlock {
    
	[self getUserInformationFor:screenName
				   successBlock:^(NSDictionary *response) {
					   NSString *imageURLString = [response objectForKey:@"profile_image_url"];
                       
                       __block STHTTPRequest *r = [STHTTPRequest requestWithURLString:imageURLString];
                       
                       r.completionBlock = ^(NSDictionary *headers, NSString *body) {
                           
                           NSData *imageData = r.responseData;
                           
#if TARGET_OS_IPHONE
                           successBlock([[[UIImage alloc] initWithData:imageData] autorelease]);
#else
                           successBlock([[[NSImage alloc] initWithData:imageData] autorelease]);
#endif
                       };
                       
                       r.errorBlock = ^(NSError *error) {
                           errorBlock(error);
                       };
				   } errorBlock:^(NSError *error) {
					   errorBlock(error);
				   }];
}

#pragma mark Timelines

- (void)getStatusesMentionTimelineWithCount:(NSString *)count
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
    
    [_oauth getResource:@"statuses/mentions_timeline.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getMentionsTimelineSinceID:(NSString *)sinceID
							 count:(NSUInteger)count
					  successBlock:(void(^)(NSArray *statuses))successBlock
						errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getStatusesMentionTimelineWithCount:[@(count) description]
                                      sinceID:nil
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

- (void)getStatusesUserTimelineForUserID:(NSString *)userID
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
    
    [_oauth getResource:@"statuses/user_timeline.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getStatusesHomeTimelineWithCount:(NSString *)count
                                 sinceID:(NSString *)sinceID
                                   maxID:(NSString *)maxID
                                trimUser:(NSNumber *)trimUser
                          excludeReplies:(NSNumber *)excludeReplies
                      contributorDetails:(NSNumber *)contributorDetails
                         includeRetweets:(NSNumber *)includeRetweets
                            successBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(excludeReplies) md[@"exclude_replies"] = [excludeReplies boolValue] ? @"1" : @"0";
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeRetweets) md[@"include_rts"] = [includeRetweets boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"statuses/home_timeline.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

/*
 - (void)getTimeline:(NSString *)timeline
 withParameters:(NSDictionary *)params
 sinceID:(NSString *)optionalSinceID
 maxID:(NSString *)optionalMaxID
 count:(NSUInteger)optionalCount
 successBlock:(void(^)(NSArray *statuses))successBlock
 errorBlock:(void(^)(NSError *error))errorBlock {
 
 NSMutableDictionary *mparams = [params mutableCopy];
 if (!mparams)
 mparams = [NSMutableDictionary new];
 
 if (optionalSinceID) mparams[@"since_id"] = optionalSinceID;
 if (optionalCount != NSNotFound) mparams[@"count"] = [@(optionalCount) stringValue];
 if (optionalMaxID) {
 NSDecimalNumber* maxID = [NSDecimalNumber decimalNumberWithString:optionalMaxID];
 
 if ( [maxID longLongValue] > 0 ) {
 mparams[@"max_id"] = optionalMaxID;
 }
 }
 
 __block NSMutableArray *statuses = [NSMutableArray new];
 __block void (^requestHandler)(id response) = nil;
 __block int count = 0;
 requestHandler = [[^(id response) {
 if ([response isKindOfClass:[NSArray class]] && [response count] > 0)
 [statuses addObjectsFromArray:response];
 
 //Only send another request if we got close to the requested limit, up to a maximum of 4 api calls
 if (count++ == 0 || (count <= 4 && [response count] >= (optionalCount - 5))) {
 //Set the max_id so that we don't get statuses we've already received
 NSString *lastID = [[statuses lastObject] objectForKey:@"id_str"];
 if (lastID) {
 NSDecimalNumber* lastIDNumber = [NSDecimalNumber decimalNumberWithString:lastID];
 
 if ([lastIDNumber longLongValue] > 0) {
 mparams[@"max_id"] = [@([lastIDNumber longLongValue] - 1) stringValue];
 }
 }
 
 [_oauth getResource:timeline parameters:mparams
 successBlock:requestHandler
 errorBlock:errorBlock];
 } else {
 successBlock(removeNull(statuses));
 [mparams release];
 [statuses release];
 }
 } copy] autorelease];
 
 //Send the first request
 requestHandler(nil);
 }
 */

- (void)getUserTimelineWithScreenName:(NSString *)screenName
                              sinceID:(NSString *)sinceID
                                maxID:(NSString *)maxID
								count:(NSUInteger)count
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getStatusesUserTimelineForUserID:nil
                                screenName:screenName
                                   sinceID:sinceID
                                     count:count
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

- (void)getUserTimelineWithScreenName:(NSString *)screenName
								count:(NSUInteger)count
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
	[self getUserTimelineWithScreenName:screenName
                                sinceID:nil
                                  maxID:nil
                                  count:count
                           successBlock:successBlock
                             errorBlock:errorBlock];
}

- (void)getUserTimelineWithScreenName:(NSString *)screenName
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getUserTimelineWithScreenName:screenName count:NSNotFound successBlock:successBlock errorBlock:errorBlock];
}

- (void)getHomeTimelineSinceID:(NSString *)sinceID
                         count:(NSUInteger)count
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *countString = count > 0 ? [@(count) description] : nil;
    
    [self getStatusesUserTimelineForUserID:nil
                                screenName:nil
                                   sinceID:sinceID
                                     count:countString
                                     maxID:nil
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

- (void)getStatusesRetweetsOfMeWithCount:(NSString *)count
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
    
    [_oauth getResource:@"statuses/retweets_of_me.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// convenience method, shorter
- (void)getStatusesRetweetsOfMeWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                                     errorBlock:(void(^)(NSError *error))errorBlock {
    [self getStatusesRetweetsOfMeWithCount:nil
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

- (void)getStatusesRetweetsForID:(NSString *)statusID
                           count:(NSString *)count
                        trimUser:(NSNumber *)trimUser
                    successBlock:(void(^)(NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweets/%@.json", statusID];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    [_oauth getResource:resource parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getStatusesShowID:(NSString *)statusID
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
    
    [_oauth getResource:@"statuses/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusesDestroy:(NSString *)statusID
                   trimUser:(NSNumber *)trimUser
               successBlock:(void(^)(NSDictionary *status))successBlock
                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"statuses/destroy/%@.json", statusID];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = statusID;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    [_oauth postResource:resource parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)existingStatusID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
                 placeID:(NSString *)placeID // wins over lat/lon
      displayCoordinates:(NSNumber *)displayCoordinates
                trimUser:(NSNumber *)trimUser
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    if(status == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : @"cannot post empty status"}];
        errorBlock(error);
        return;
    }
    
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:status forKey:@"status"];
    
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
    
    [_oauth postResource:@"statuses/update.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusUpdate:(NSString *)status
          mediaDataArray:(NSArray *)mediaDataArray // only one media is currently supported
       possiblySensitive:(NSNumber *)possiblySensitive
       inReplyToStatusID:(NSString *)inReplyToStatusID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
                 placeID:(NSString *)placeID
      displayCoordinates:(NSNumber *)displayCoordinates
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
    md[@"media[]"] = [mediaDataArray lastObject];
    md[kSTPOSTDataKey] = @"media[]";
    
    [_oauth postResource:@"statuses/update_with_media.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)existingStatusID
                mediaURL:(NSURL *)mediaURL
                 placeID:(NSString *)placeID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSData *data = [NSData dataWithContentsOfURL:mediaURL];
    
    if(data == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : @"data is nil"}];
        errorBlock(error);
        return;
    }
    
    [self postStatusUpdate:status
            mediaDataArray:@[data]
         possiblySensitive:nil
         inReplyToStatusID:existingStatusID
                  latitude:latitude
                 longitude:longitude
                   placeID:placeID
        displayCoordinates:@(YES)
              successBlock:^(NSDictionary *status) {
        successBlock(status);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	statuses/retweet/:id
- (void)postStatusRetweetWithID:(NSString *)statusID
                       trimUser:(NSNumber *)trimUser
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(trimUser) md[@"trime_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweet/%@.json", statusID];
    
    [_oauth postResource:resource parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusRetweetWithID:(NSString *)statusID
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {

    [self postStatusRetweetWithID:statusID
                         trimUser:nil
                     successBlock:^(NSDictionary *status) {
        successBlock(status);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getStatusesRetweetersIDsForStatusID:(NSString *)statusID
                                     cursor:(NSString *)cursor
                         returnIDsAsStrings:(NSNumber *)returnIDsAsStrings
                               successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"id"] = statusID;
    if(cursor) md[@"cursor"] = cursor;
    if(returnIDsAsStrings) md[@"stringify_ids"] = [returnIDsAsStrings boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"statuses/retweeters/ids.json" parameters:md successBlock:^(id response) {
        
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

- (void)getListsSubscriptionsForUserID:(NSString *)userID
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
    
    [_oauth getResource:@"lists/subscriptions.json" parameters:md successBlock:^(id response) {
        
        NSArray *lists = [response valueForKey:@"lists"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(lists, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

//  GET     lists/ownerships

- (void)getListsOwnershipsForUserID:(NSString *)userID
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
    
    [_oauth getResource:@"lists/ownerships.json" parameters:md successBlock:^(id response) {
        
        NSArray *lists = [response valueForKey:@"lists"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(lists, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Search

- (void)getSearchTweetsWithQuery:(NSString *)q
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
    
    md[@"q"] = [q st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [_oauth getResource:@"search/tweets.json" parameters:md successBlock:^(id response) {
        
        NSDictionary *searchMetadata = [response valueForKey:@"search_metadata"];
        NSArray *statuses = [response valueForKey:@"statuses"];
        
        successBlock(searchMetadata, statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getSearchTweetsWithQuery:(NSString *)q
					successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
					  errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getSearchTweetsWithQuery:q
                           geocode:nil
                              lang:nil
                            locale:nil
                        resultType:nil
                             count:nil
                             until:nil
                           sinceID:nil
                             maxID:nil
                   includeEntities:YES
                          callback:nil
                      successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
                          successBlock(searchMetadata, statuses);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

#pragma mark Streaming

#pragma mark Direct Messages

- (void)getDirectMessagesSinceID:(NSString *)sinceID
                           maxID:(NSString *)maxID
                           count:(NSString *)count
                 includeEntities:(NSNumber *)includeEntities
                      skipStatus:(NSNumber *)skipStatus
                    successBlock:(void(^)(NSArray *messages))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) [md setObject:sinceID forKey:@"since_id"];
    if(maxID) [md setObject:maxID forKey:@"max_id"];
    if(count) [md setObject:count forKey:@"count"];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"direct_messages.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// convenience
- (void)getDirectMessagesSinceID:(NSString *)sinceID
						   count:(NSUInteger)count
					successBlock:(void(^)(NSArray *messages))successBlock
					  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *countString = count > 0 ? [@(count) description] : nil;
    
    [self getDirectMessagesSinceID:sinceID
                             maxID:nil
                             count:countString
                   includeEntities:nil
                        skipStatus:nil
                      successBlock:^(NSArray *statuses) {
                          successBlock(statuses);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

- (void)getDirectMessagesSinceID:(NSString *)sinceID
                           maxID:(NSString *)maxID
                           count:(NSString *)count
                            page:(NSString *)page
                 includeEntities:(NSNumber *)includeEntities
                    successBlock:(void(^)(NSArray *messages))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) [md setObject:sinceID forKey:@"since_id"];
    if(maxID) [md setObject:maxID forKey:@"max_id"];
    if(count) [md setObject:count forKey:@"count"];
    if(page) [md setObject:page forKey:@"page"];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"direct_messages/sent.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getDirectMessagesShowWithID:(NSString *)messageID
                       successBlock:(void(^)(NSArray *messages))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{@"id" : messageID};
    
    [_oauth getResource:@"direct_messages/show.json" parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
    
}

- (void)postDestroyDirectMessageWithID:(NSString *)messageID
                       includeEntities:(NSNumber *)includeEntities
						  successBlock:(void(^)(NSDictionary *message))successBlock
							errorBlock:(void(^)(NSError *error))errorBlock {
    
	NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = messageID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [_oauth postResource:@"direct_messages/destroy.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postDirectMessage:(NSString *)status
					   to:(NSString *)screenName
             successBlock:(void(^)(NSDictionary *message))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
	NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:status forKey:@"text"];
    [md setObject:screenName forKey:@"screen_name"];
    
    [_oauth postResource:@"direct_messages/new.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Friends & Followers

- (void)getFriendshipNoRetweetsIDsWithStringifyIDs:(NSNumber *)stringifyIDs
                                      successBlock:(void(^)(NSArray *ids))successBlock
                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_ids"] = stringifyIDs ? @"1" : @"0";
    
    [_oauth getResource:@"friendships/no_retweets/ids.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendsIDsForUserID:(NSString *)userID
                  orScreenName:(NSString *)screenName
                        cursor:(NSString *)cursor
                  stringifyIDs:(NSNumber *)stringifyIDs
                         count:(NSString *)count
                  successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(stringifyIDs) md[@"stringify_ids"] = [stringifyIDs boolValue] ? @"1" : @"0";
    
    if(count) md[@"count"] = count;
    
    [_oauth getResource:@"friends/ids.json" parameters:md successBlock:^(id response) {
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

//- (void)getUsersAtResource:(NSString *)resource
//			 forScreenName:(NSString *)screenName
//			  successBlock:(void(^)(NSArray *friends))successBlock
//				errorBlock:(void(^)(NSError *error))errorBlock {
//
//	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:screenName forKey:@"screen_name"];
//
//	__block NSMutableArray *ids = [NSMutableArray new];
//	__block void (^requestHandler)(id response) = nil;
//	__block NSString *cursor = @"-1";
//	requestHandler = [[^(id response) {
//		if (response) {
//			[ids addObjectsFromArray:[response objectForKey:@"users"]];
//			[cursor release]; cursor = [[response objectForKey:@"next_cursor_str"] copy];
//			d[@"cursor"] = cursor;
//		}
//
//		if ([cursor isEqualToString:@"0"]) {
//			successBlock(ids);
//			[ids release]; ids = nil;
//			[cursor release]; cursor = nil;
//		} else {
//			[_oauth getResource:resource parameters:d successBlock:requestHandler
//					 errorBlock:errorBlock];
//		}
//	} copy] autorelease];
//
//	//Send the first request
//	requestHandler(nil);
//}

- (void)getFriendsIDsForScreenName:(NSString *)screenName
				      successBlock:(void(^)(NSArray *friends))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getFriendsIDsForUserID:nil
                    orScreenName:screenName
                          cursor:nil
                    stringifyIDs:nil
                           count:nil
                    successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                        successBlock(ids);
                    } errorBlock:^(NSError *error) {
                        errorBlock(error);
                    }];
}

- (void)getFollowersIDsForUserID:(NSString *)userID
                    orScreenName:(NSString *)screenName
                          cursor:(NSString *)cursor
                    stringifyIDs:(NSNumber *)stringifyIDs
                           count:(NSString *)count
                    successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(stringifyIDs) md[@"stringify_ids"] = [stringifyIDs boolValue] ? @"1" : @"0";
    if(count) md[@"count"] = count;
    
    [_oauth getResource:@"followers/ids.json" parameters:md successBlock:^(id response) {
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

- (void)getFollowersIDsForScreenName:(NSString *)screenName
					    successBlock:(void(^)(NSArray *followers))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getFollowersIDsForUserID:nil
                      orScreenName:screenName
                            cursor:nil
                      stringifyIDs:nil
                             count:nil
                      successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                          successBlock(ids);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

- (void)getFriendshipsLookupForScreenNames:(NSArray *)screenNames
                                 orUserIDs:(NSArray *)userIDs
                              successBlock:(void(^)(NSArray *users))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenNames || userIDs), @"missing screen names or user IDs");
    
    NSString *commaSeparatedScreenNames = [screenNames componentsJoinedByString:@","];
    NSString *commaSeparatedUserIDs = [userIDs componentsJoinedByString:@","];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(commaSeparatedScreenNames) md[@"screen_name"] = commaSeparatedScreenNames;
    if(commaSeparatedUserIDs) md[@"user_id"] = commaSeparatedUserIDs;
    
    [_oauth getResource:@"friendships/lookup.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendshipIncomingWithCursor:(NSString *)cursor
                           stringifyIDs:(NSNumber *)stringifyIDs
                           successBlock:(void(^)(NSArray *IDs, NSString *previousCursor, NSString *nextCursor))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(cursor) md[@"cursor"] = cursor;
    if(stringifyIDs) md[@"stringify_ids"] = [stringifyIDs boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"friendships/incoming.json" parameters:md successBlock:^(id response) {
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

- (void)getFriendshipOutgoingWithCursor:(NSString *)cursor
                           stringifyIDs:(NSNumber *)stringifyIDs
                           successBlock:(void(^)(NSArray *IDs, NSString *previousCursor, NSString *nextCursor))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(cursor) md[@"cursor"] = cursor;
    if(stringifyIDs) md[@"stringify_ids"] = [stringifyIDs boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"friendships/outgoing.json" parameters:md successBlock:^(id response) {
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



- (void)postFriendshipsCreateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                              successBlock:(void(^)(NSDictionary *user))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    [_oauth postResource:@"friendships/create.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFollow:(NSString *)screenName
	  successBlock:(void(^)(NSDictionary *user))successBlock
		errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self postFriendshipsCreateForScreenName:screenName orUserID:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFriendshipsDestroyScreenName:(NSString *)screenName
                                orUserID:(NSString *)userID
                            successBlock:(void(^)(NSDictionary *user))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    [_oauth postResource:@"friendships/destroy.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postUnfollow:(NSString *)screenName
		successBlock:(void(^)(NSDictionary *user))successBlock
		  errorBlock:(void(^)(NSError *error))errorBlock {
	
    [self postFriendshipsDestroyScreenName:screenName orUserID:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
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
    
    [_oauth postResource:@"friendships/update.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                 enableDeviceNotifications:(BOOL)enableDeviceNotifications
                              successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    [self postFriendshipsUpdateForScreenName:screenName
                                    orUserID:userID
                   enableDeviceNotifications:@(enableDeviceNotifications)
                              enableRetweets:nil
                                successBlock:^(NSDictionary *user) {
                                    successBlock(user);
                                } errorBlock:^(NSError *error) {
                                    errorBlock(error);
                                }];
}

- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                            enableRetweets:(BOOL)enableRetweets
                              successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    [self postFriendshipsUpdateForScreenName:screenName
                                    orUserID:userID
                   enableDeviceNotifications:nil
                              enableRetweets:@(enableRetweets)
                                successBlock:^(NSDictionary *user) {
                                    successBlock(user);
                                } errorBlock:^(NSError *error) {
                                    errorBlock(error);
                                }];
}

- (void)getFriendshipShowForSourceID:(NSString *)sourceID
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
    
    [_oauth getResource:@"friendships/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendsListForUserID:(NSString *)userID
                   orScreenName:(NSString *)screenName
                         cursor:(NSString *)cursor
                     skipStatus:(NSNumber *)skipStatus
            includeUserEntities:(NSNumber *)includeUserEntities
                   successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"friends/list.json" parameters:md successBlock:^(id response) {
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

- (void)getFriendsForScreenName:(NSString *)screenName
				   successBlock:(void(^)(NSArray *friends))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getFriendsListForUserID:nil
                     orScreenName:screenName
                           cursor:nil
                       skipStatus:NO
              includeUserEntities:YES
                     successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                         successBlock(users);
                     } errorBlock:^(NSError *error) {
                         errorBlock(error);
                     }];
}

- (void)getFollowersListForUserID:(NSString *)userID
                     orScreenName:(NSString *)screenName
                           cursor:(NSString *)cursor
                       skipStatus:(NSNumber *)skipStatus
              includeUserEntities:(NSNumber *)includeUserEntities
                     successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"followers/list.json" parameters:md successBlock:^(id response) {
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

// TODO
- (void)getFollowersForScreenName:(NSString *)screenName
					 successBlock:(void(^)(NSArray *followers))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
	[self getFollowersListForUserID:nil
                       orScreenName:screenName
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
- (void)getAccountSettingsWithSuccessBlock:(void(^)(NSDictionary *settings))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth getResource:@"account/settings.json" parameters:nil successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET account/verify_credentials
- (void)getAccountVerifyCredentialsWithIncludeEntites:(NSNumber *)includeEntities
                                           skipStatus:(NSNumber *)skipStatus
                                         successBlock:(void(^)(NSDictionary *myInfo))successBlock
                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"account/verify_credentials.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getAccountVerifyCredentialsWithSuccessBlock:(void(^)(NSDictionary *account))successBlock
                                         errorBlock:(void(^)(NSError *error))errorBlock {
    [self getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil successBlock:^(NSDictionary *account) {
        successBlock(account);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/settings
- (void)postAccountSettingsWithTrendLocationWOEID:(NSString *)trendLocationWOEID // eg. "1"
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
    
    [_oauth postResource:@"account/settings.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	account/update_delivery_device
- (void)postAccountUpdateDeliveryDeviceSMS:(BOOL)deliveryDeviceSMS
                           includeEntities:(NSNumber *)includeEntities
                              successBlock:(void(^)(NSDictionary *response))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"device"] = deliveryDeviceSMS ? @"sms" : @"none";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [_oauth postResource:@"account/update_delivery_device.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile
- (void)postAccountUpdateProfileWithName:(NSString *)name
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
    
    [_oauth postResource:@"account/update_profile.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postUpdateProfile:(NSDictionary *)profileData
			 successBlock:(void(^)(NSDictionary *myInfo))successBlock
			   errorBlock:(void(^)(NSError *error))errorBlock {
	[_oauth postResource:@"account/update_profile.json" parameters:profileData successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_background_image
- (void)postAccountUpdateProfileBackgroundImageWithImage:(NSString *)base64EncodedImage
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
    
    [_oauth postResource:@"account/update_profile_background_image.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_colors
- (void)postAccountUpdateProfileColorsWithBackgroundColor:(NSString *)backgroundColor
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
    
    [_oauth postResource:@"account/update_profile_colors.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_image
- (void)postAccountUpdateProfileImage:(NSString *)base64EncodedImage
                      includeEntities:(NSNumber *)includeEntities
                           skipStatus:(NSNumber *)skipStatus
                         successBlock:(void(^)(NSDictionary *profile))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(base64EncodedImage);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"image"] = base64EncodedImage;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [_oauth postResource:@"account/update_profile_image.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET blocks/list
- (void)getBlocksListWithincludeEntities:(NSNumber *)includeEntities
                              skipStatus:(NSNumber *)skipStatus
                                  cursor:(NSString *)cursor
                            successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(cursor) md[@"cursor"] = cursor;
    
    [_oauth getResource:@"blocks/list.json" parameters:md successBlock:^(id response) {
        
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
- (void)getBlocksIDsWithCursor:(NSString *)cursor
                  successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_ids"] = @"1";
    if(cursor) md[@"cursor"] = cursor;
    
    [_oauth getResource:@"blocks/ids.json" parameters:md successBlock:^(id response) {
        
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
- (void)postBlocksCreateWithScreenName:(NSString *)screenName
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
    
    [_oauth postResource:@"blocks/create.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST blocks/destroy
- (void)postBlocksDestroyWithScreenName:(NSString *)screenName
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
    
    [_oauth postResource:@"blocks/destroy.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/lookup
- (void)getUsersLookupForScreenName:(NSString *)screenName
                           orUserID:(NSString *)userID
                    includeEntities:(NSNumber *)includeEntities
                       successBlock:(void(^)(NSArray *users))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"users/lookup.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/show
- (void)getUsersShowForUserID:(NSString *)userID
                 orScreenName:(NSString *)screenName
              includeEntities:(NSNumber *)includeEntities
                 successBlock:(void(^)(NSDictionary *user))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"users/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getUserInformationFor:(NSString *)screenName
				 successBlock:(void(^)(NSDictionary *user))successBlock
				   errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getUsersShowForUserID:nil orScreenName:screenName includeEntities:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/search
- (void)getUsersSearchQuery:(NSString *)query
                       page:(NSString *)page
                      count:(NSString *)count
            includeEntities:(NSNumber *)includeEntities
               successBlock:(void(^)(NSArray *users))successBlock
                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"query"] = [query st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(page) md[@"page"] = page;
    if(count) md[@"count"] = count;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"users/search.json" parameters:md successBlock:^(id response) {
        successBlock(response); // NSArray of users dictionaries
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/contributees
- (void)getUsersContributeesWithUserID:(NSString *)userID
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
    
    [_oauth getResource:@"users/contributees.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/contributors
- (void)getUsersContributorsWithUserID:(NSString *)userID
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
    
    [_oauth getResource:@"users/contributors.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/remove_profile_banner
- (void)postAccountRemoveProfileBannerWithSuccessBlock:(void(^)(id response))successBlock
                                            errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth postResource:@"account/remove_profile_banner.json" parameters:nil successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_banner
- (void)postAccountUpdateProfileBannerWithImage:(NSString *)base64encodedImage
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
    
    [_oauth postResource:@"account/update_profile_banner.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/profile_banner
- (void)getUsersProfileBannerForUserID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                          successBlock:(void(^)(NSDictionary *banner))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    
    [_oauth getResource:@"users/profile_banner.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Suggested Users

#pragma mark Favorites

// GET favorites/list
- (void)getFavoritesListWithUserID:(NSString *)userID
                        screenName:(NSString *)screenName
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
    
    [_oauth getResource:@"favorites/list.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFavoritesListWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getFavoritesListWithUserID:nil
                          screenName:nil
                               count:nil
                             sinceID:nil
                               maxID:nil
                     includeEntities:nil
                        successBlock:^(NSArray *statuses) {
                            successBlock(statuses);
                        } errorBlock:^(NSError *error) {
                            errorBlock(error);
                        }];
    
    [_oauth getResource:@"favorites/list.json" parameters:nil successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST favorites/destroy
- (void)postFavoriteDestroyWithStatusID:(NSString *)statusID
                        includeEntities:(NSNumber *)includeEntities
                           successBlock:(void(^)(NSDictionary *status))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(statusID) md[@"id"] = statusID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [_oauth postResource:@"favorites/destroy.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	favorites/create
- (void)postFavoriteCreateWithStatusID:(NSString *)statusID
                       includeEntities:(NSNumber *)includeEntities
                          successBlock:(void(^)(NSDictionary *status))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(statusID) md[@"id"] = statusID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [_oauth postResource:@"favorites/create.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFavoriteState:(BOOL)favoriteState
              forStatusID:(NSString *)statusID
             successBlock:(void(^)(NSDictionary *status))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *action = favoriteState ? @"create" : @"destroy";
    
    NSString *resource = [NSString stringWithFormat:@"favorites/%@.json", action];
    
    NSDictionary *d = @{@"id" : statusID};
    
    [_oauth postResource:resource parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Lists

// GET	lists/list

- (void)getListsSubscribedByUsername:(NSString *)username
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
    
    [_oauth getResource:@"lists/list.json" parameters:md successBlock:^(id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *lists = (NSArray *)response;
        
        successBlock(lists);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET    lists/statuses

- (void)getListsStatusesForListID:(NSString *)listID
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
    
    [_oauth getResource:@"lists/statuses.json" parameters:md successBlock:^(id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *statuses = (NSArray *)response;
        
        successBlock(statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getListsStatusesForSlug:(NSString *)slug
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
    
    [_oauth getResource:@"lists/statuses.json" parameters:md successBlock:^(id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *statuses = (NSArray *)response;
        
        successBlock(statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST lists/members/destroy

- (void)postListsMembersDestroyForListID:(NSString *)listID
                            successBlock:(void(^)())successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{ @"list_id" : listID };
    
    [_oauth postResource:@"lists/members/destroy" parameters:d successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postListsMembersDestroyForSlug:(NSString *)slug
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
    
    [_oauth postResource:@"lists/members/destroy" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET lists/memberships

- (void)getListsMembershipsForUserID:(NSString *)userID
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
    
    [_oauth getResource:@"lists/memberships" parameters:md successBlock:^(id response) {
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

- (void)getListsSubscribersForSlug:(NSString *)slug
                   ownerScreenName:(NSString *)ownerScreenName
                         orOwnerID:(NSString *)ownerID
                            cursor:(NSString *)cursor
                   includeEntities:(NSNumber *)includeEntities
                        skipStatus:(NSNumber *)skipStatus
                      successBlock:(void(^)())successBlock
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
    
    [_oauth getResource:@"lists/subscribers.json" parameters:md successBlock:^(id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getListsSubscribersForListID:(NSString *)listID
                              cursor:(NSString *)cursor
                     includeEntities:(NSNumber *)includeEntities
                          skipStatus:(NSNumber *)skipStatus
                        successBlock:(void(^)())successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"listID"] = listID;
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"lists/subscribers.json" parameters:md successBlock:^(id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/subscribers/create

- (void)postListSubscribersCreateForListID:(NSString *)listID
                              successBlock:(void(^)())successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    [_oauth postResource:@"lists/subscribers/create.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postListSubscribersCreateForSlug:(NSString *)slug
                         ownerScreenName:(NSString *)ownerScreenName
                               orOwnerID:(NSString *)ownerID
                            successBlock:(void(^)())successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    [_oauth postResource:@"lists/subscribers/create.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/subscribers/show

- (void)getListsSubscribersShowForListID:(NSString *)listID
                                  userID:(NSString *)userID
                            orScreenName:(NSString *)screenName
                         includeEntities:(NSNumber *)includeEntities
                              skipStatus:(NSNumber *)skipStatus
                            successBlock:(void(^)())successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(listID);
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"lists/subscribers/show.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getListsSubscribersShowForSlug:(NSString *)slug
                       ownerScreenName:(NSString *)ownerScreenName
                             orOwnerID:(NSString *)ownerID
                                userID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                       includeEntities:(NSNumber *)includeEntities
                            skipStatus:(NSNumber *)skipStatus
                          successBlock:(void(^)())successBlock
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
    
    [_oauth getResource:@"lists/subscribers/show.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/subscribers/destroy

- (void)postListSubscribersDestroyForListID:(NSString *)listID
                               successBlock:(void(^)())successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    [_oauth postResource:@"lists/subscribers/destroy.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postListSubscribersDestroyForSlug:(NSString *)slug
                          ownerScreenName:(NSString *)ownerScreenName
                                orOwnerID:(NSString *)ownerID
                             successBlock:(void(^)())successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    [_oauth postResource:@"lists/subscribers/destroy.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/members/create_all

- (void)postListsMembersCreateAllForListID:(NSString *)listID
                                   userIDs:(NSArray *)userIDs // array of strings
                             orScreenNames:(NSArray *)screenNames // array of strings
                              successBlock:(void(^)())successBlock
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
    
    [_oauth postResource:@"lists/members/create_all.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postListsMembersCreateAllForSlug:(NSString *)slug
                         ownerScreenName:(NSString *)ownerScreenName
                               orOwnerID:(NSString *)ownerID
                                 userIDs:(NSArray *)userIDs // array of strings
                           orScreenNames:(NSArray *)screenNames // array of strings
                            successBlock:(void(^)())successBlock
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
    
    [_oauth postResource:@"lists/members/create_all.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/members/show

- (void)getListsMembersShowForListID:(NSString *)listID
                              userID:(NSString *)userID
                          screenName:(NSString *)screenName
                     includeEntities:(NSNumber *)includeEntities
                          skipStatus:(NSNumber *)skipStatus
                        successBlock:(void(^)(NSDictionary *user))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert(listID, @"listID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"listID"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"lists/members/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getListsMembersShowForSlug:(NSString *)slug
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
    
    [_oauth getResource:@"lists/members/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/members

- (void)getListsMembersForListID:(NSString *)listID
                          cursor:(NSString *)cursor
                 includeEntities:(NSNumber *)includeEntities
                      skipStatus:(NSNumber *)skipStatus
                    successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(listID, @"listID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"listID"] = listID;
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"lists/members.json" parameters:md successBlock:^(id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getListsMembersForSlug:(NSString *)slug
               ownerScreenName:(NSString *)ownerScreenName
                     orOwnerID:(NSString *)ownerID
                        cursor:(NSString *)cursor
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
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [_oauth getResource:@"lists/members.json" parameters:md successBlock:^(id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/members/create

- (void)postListMemberCreateForListID:(NSString *)listID
                               userID:(NSString *)userID
                           screenName:(NSString *)screenName
                         successBlock:(void(^)())successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    NSParameterAssert(userID);
    NSParameterAssert(screenName);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    md[@"user_id"] = userID;
    md[@"screen_name"] = screenName;
    
    [_oauth postResource:@"lists/members/create.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postListMemberCreateForSlug:(NSString *)slug
                    ownerScreenName:(NSString *)ownerScreenName
                          orOwnerID:(NSString *)ownerID
                             userID:(NSString *)userID
                         screenName:(NSString *)screenName
                       successBlock:(void(^)())successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    md[@"user_id"] = userID;
    md[@"screen_name"] = screenName;
    
    [_oauth postResource:@"lists/members/create.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/destroy

- (void)postListsDestroyForListID:(NSString *)listID
                     successBlock:(void(^)())successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    [_oauth postResource:@"lists/destroy.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postListsDestroyForSlug:(NSString *)slug
                ownerScreenName:(NSString *)ownerScreenName
                      orOwnerID:(NSString *)ownerID
                   successBlock:(void(^)())successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    [_oauth postResource:@"lists/destroy.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/update

- (void)postListsUpdateForListID:(NSString *)listID
                            name:(NSString *)name
                       isPrivate:(BOOL)isPrivate
                     description:(NSString *)description
                    successBlock:(void(^)())successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(name) md[@"name"] = [name st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = [description st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [_oauth postResource:@"lists/update.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postListsUpdateForSlug:(NSString *)slug
               ownerScreenName:(NSString *)ownerScreenName
                     orOwnerID:(NSString *)ownerID
                          name:(NSString *)name
                     isPrivate:(BOOL)isPrivate
                   description:(NSString *)description
                  successBlock:(void(^)())successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(name) md[@"name"] = [name st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = [description st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [_oauth postResource:@"lists/update.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/create

- (void)postListsCreateWithName:(NSString *)name
                      isPrivate:(BOOL)isPrivate
                    description:(NSString *)description
                   successBlock:(void(^)(NSDictionary *list))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(name);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"name"] = [name st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = [description st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [_oauth postResource:@"lists/create.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/show

- (void)getListsShowListID:(NSString *)listID
              successBlock:(void(^)(NSDictionary *list))successBlock
                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    [_oauth getResource:@"lists/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getListsShowListSlug:(NSString *)slug
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
    
    [_oauth getResource:@"lists/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	lists/members/destroy_all

- (void)postListsMembersDestroyAllForListID:(NSString *)listID
                                    userIDs:(NSArray *)userIDs // array of strings
                              orScreenNames:(NSArray *)screenNames // array of strings
                               successBlock:(void(^)())successBlock
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
    
    [_oauth postResource:@"lists/members/destroy_all.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postListsMembersDestroyAllForSlug:(NSString *)slug
                          ownerScreenName:(NSString *)ownerScreenName
                                orOwnerID:(NSString *)ownerID
                                  userIDs:(NSArray *)userIDs // array of strings
                            orScreenNames:(NSArray *)screenNames // array of strings
                             successBlock:(void(^)())successBlock
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
    
    [_oauth postResource:@"lists/members/destroy_all.json" parameters:md successBlock:^(id response) {
        successBlock();
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Saved Searches

#pragma mark Places & Geo

// GET geo/id/:place_id
- (void)getGeoIDForPlaceID:(NSString *)placeID // A place in the world. These IDs can be retrieved from geo/reverse_geocode.
              successBlock:(void(^)(NSDictionary *place))successBlock
                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *resource = [NSString stringWithFormat:@"geo/id/%@.json", placeID];
    
    [_oauth getResource:resource parameters:nil successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET geo/reverse_geocode
- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude // eg. "37.7821120598956"
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
    
    [_oauth getResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(id response) {
        
        NSDictionary *query = [response valueForKeyPath:@"query"];
        NSDictionary *result = [response valueForKeyPath:@"result"];
        
        successBlock(query, result);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                               longitude:(NSString *)longitude
                            successBlock:(void(^)(NSArray *places))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getGeoReverseGeocodeWithLatitude:latitude
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

- (void)getGeoSearchWithLatitude:(NSString *)latitude // eg. "37.7821120598956"
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
    
    [_oauth getResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(id response) {
        
        NSDictionary *query = [response valueForKeyPath:@"query"];
        NSDictionary *result = [response valueForKeyPath:@"result"];
        
        successBlock(query, result);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getGeoSearchWithLatitude:(NSString *)latitude
                       longitude:(NSString *)longitude
                    successBlock:(void(^)(NSArray *places))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    [self getGeoSearchWithLatitude:latitude
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

- (void)getGeoSearchWithIPAddress:(NSString *)ipAddress
                     successBlock:(void(^)(NSArray *places))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(ipAddress);
    
    [self getGeoSearchWithLatitude:nil
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

- (void)getGeoSearchWithQuery:(NSString *)query
                 successBlock:(void(^)(NSArray *places))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    [self getGeoSearchWithLatitude:nil
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

- (void)getGeoSimilarPlacesToLatitude:(NSString *)latitude // eg. "37.7821120598956"
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
    
    [_oauth getResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(id response) {
        
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

- (void)postGeoPlaceWithName:(NSString *)name // eg. "Twitter HQ"
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
    
    [_oauth postResource:@"get/create.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Trends

#pragma mark Spam Reporting

- (void)postReportSpamWithScreenName:(NSString *)screenName
                            orUserID:(NSString *)userID
                        successBlock:(void(^)(id userProfile))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(screenName || userID);
    
    NSDictionary *d = nil;
    
    if(screenName) {
        d = @{ @"screen_name" : screenName };
    } else {
        d = @{ @"user_id" : userID };
    }
    
    [_oauth postResource:@"users/report_spam.json" parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark OAuth

#pragma mark Help
- (void)getRateLimitsForResources:(NSArray *)resources
					 successBlock:(void(^)(NSDictionary *rateLimits))successBlock
					   errorBlock:(void(^)(NSError *error))errorBlock {
	NSDictionary *d = nil;
	if (resources)
		d = @{ @"resources" : [resources componentsJoinedByString:@","] };
	[_oauth getResource:@"application/rate_limit_status.json" parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}
/*
 id removeNull(id rootObject) {
 if ([rootObject isKindOfClass:[NSDictionary class]]) {
 NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionaryWithDictionary:rootObject];
 [rootObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
 id sanitized = removeNull(obj);
 if (!sanitized) {
 [sanitizedDictionary setObject:@"" forKey:key];
 } else {
 [sanitizedDictionary setObject:sanitized forKey:key];
 }
 }];
 return [NSDictionary dictionaryWithDictionary:sanitizedDictionary];
 }
 
 if ([rootObject isKindOfClass:[NSArray class]]) {
 NSMutableArray *sanitizedArray = [NSMutableArray arrayWithArray:rootObject];
 [rootObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 id sanitized = removeNull(obj);
 if (!sanitized) {
 [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:@""];
 } else {
 [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:sanitized];
 }
 }];
 return [NSArray arrayWithArray:sanitizedArray];
 }
 
 if ([rootObject isKindOfClass:[NSNull class]]) {
 return (id)nil;
 } else {
 return rootObject;
 }
 }
 */
@end

@implementation NSString (STTwitterAPIWrapper)

- (NSString *)htmlLinkName {
    NSString *ahref = [self firstMatchWithRegex:@"<a href=\".*\">(.*)</a>" error:nil];
    
    return ahref ? ahref : self;
}

@end
