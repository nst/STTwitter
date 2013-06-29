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
id removeNull(id rootObject);
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
        [self getAccountVerifyCredentialsSkipStatus:YES successBlock:^(NSDictionary *myInfo) {
            self.userName = [myInfo valueForKey:@"screen_name"];
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
					   NSString *imageURL = [response objectForKey:@"profile_image_url"];
                       
					   NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
					   
					   NSData *imageData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:nil error:nil];
                       
#if TARGET_OS_IPHONE
					   successBlock([[[UIImage alloc] initWithData:imageData] autorelease]);
#else
					   successBlock([[[NSImage alloc] initWithData:imageData] autorelease]);
#endif
                       
				   } errorBlock:^(NSError *error) {
					   errorBlock(error);
				   }];
}

#pragma mark Timelines
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

- (void)getMentionsTimelineSinceID:(NSString *)optionalSinceID
							 count:(NSUInteger)optionalCount
					  successBlock:(void(^)(NSArray *statuses))successBlock
						errorBlock:(void(^)(NSError *error))errorBlock {
	[self getTimeline:@"statuses/mentions_timeline.json"
	   withParameters:nil
			  sinceID:optionalSinceID
                maxID:nil
				count:optionalCount
		 successBlock:successBlock
		   errorBlock:errorBlock];
}

- (void)getUserTimelineWithScreenName:(NSString *)screenName
                              sinceID:(NSString *)optionalSinceID
                                maxID:(NSString *)optionalMaxID
								count:(NSUInteger)optionalCount
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    [self getTimeline:@"statuses/user_timeline.json"
	   withParameters:@{ @"screen_name" : screenName }
			  sinceID:optionalSinceID
                maxID:optionalMaxID
				count:optionalCount
		 successBlock:successBlock
		   errorBlock:errorBlock];
}


- (void)getUserTimelineWithScreenName:(NSString *)screenName
								count:(NSUInteger)optionalCount
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
	[self getUserTimelineWithScreenName:screenName
                                sinceID:nil
                                  maxID:nil
                                  count:optionalCount
                           successBlock:successBlock
                             errorBlock:errorBlock];
}

- (void)getUserTimelineWithScreenName:(NSString *)screenName
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getUserTimelineWithScreenName:screenName count:NSNotFound successBlock:successBlock errorBlock:errorBlock];
}

- (void)getHomeTimelineSinceID:(NSString *)optionalSinceID
                         count:(NSUInteger)optionalCount
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getTimeline:@"statuses/home_timeline.json"
	   withParameters:nil
			  sinceID:optionalSinceID
                maxID:nil
				count:optionalCount
		 successBlock:successBlock
		   errorBlock:errorBlock];
}

- (void)getStatusesRetweetsOfMeWithOptionalCount:(NSString *)count
                                 optionalSinceID:(NSString *)sinceID
                                   optionalMaxID:(NSString *)maxID
                                        trimUser:(BOOL)trimUser
                                 includeEntitied:(BOOL)includeEntities
                             includeUserEntities:(BOOL)includeUserEntities
                                    successBlock:(void(^)(NSArray *statuses))successBlock
                                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(trimUser) md[@"trim_user"] = @"true";
    if(includeEntities == NO) md[@"include_entities"] = @"false";
    if(includeUserEntities == NO) md[@"include_user_entities"] = @"false";
    
    [_oauth getResource:@"statuses/retweets_of_me.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// convenience method, shorter
- (void)getStatusesRetweetsOfMeWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                                     errorBlock:(void(^)(NSError *error))errorBlock {
    [self getStatusesRetweetsOfMeWithOptionalCount:nil
                                   optionalSinceID:nil
                                     optionalMaxID:nil
                                          trimUser:NO
                                   includeEntitied:YES
                               includeUserEntities:YES
                                      successBlock:^(NSArray *statuses) {
        successBlock(statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Tweets

- (void)getStatusesRetweetsForID:(NSString *)statusID
                   optionalCount:(NSString *)count
                        trimUser:(BOOL)trimUser
                    successBlock:(void(^)(NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweets/%@.json", statusID];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(trimUser) md[@"trim_user"] = @"true";
    
    [_oauth getResource:resource parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getStatusesShowID:(NSString *)statusID
                 trimUser:(BOOL)trimUser
         includeMyRetweet:(BOOL)includeMyRetweet
          includeEntities:(BOOL)includeEntities
             successBlock:(void(^)(NSDictionary *status))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"id"] = statusID;
    if(trimUser) md[@"trim_user"] = @"true";
    if(includeMyRetweet) md[@"include_my_retweet"] = @"true";
    if(includeEntities) md[@"include_entities"] = @"true";
    
    [_oauth getResource:@"statuses/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postDestroyStatusWithID:(NSString *)statusID
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    // set trim_user to true?
    
    NSString *resource = [NSString stringWithFormat:@"statuses/destroy/%@.json", statusID];
    
	//Twitter returns an unauthenticated error if parameters is nil.
    [_oauth postResource:resource parameters:@{ @"id" : statusID } successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)optionalExistingStatusID
                 placeID:(NSString *)optionalPlaceID // wins over lat/lon
                     lat:(NSString *)optionalLat
                     lon:(NSString *)optionalLon
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    if(status == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : @"cannot post empty status"}];
        errorBlock(error);
        return;
    }
    
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:status forKey:@"status"];
    
    if(optionalExistingStatusID) {
        md[@"in_reply_to_status_id"] = optionalExistingStatusID;
    }
    
    if(optionalPlaceID) {
        md[@"place_id"] = optionalPlaceID;
        md[@"display_coordinates"] = @"true";
    } else if(optionalLat && optionalLon) {
        md[@"lat"] = optionalLat;
        md[@"lon"] = optionalLon;
        md[@"display_coordinates"] = @"true";
    }
    
    [_oauth postResource:@"statuses/update.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)optionalExistingStatusID
                mediaURL:(NSURL *)mediaURL
                 placeID:(NSString *)optionalPlaceID // wins over lat/lon
                     lat:(NSString *)optionalLat
                     lon:(NSString *)optionalLon
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSData *data = [NSData dataWithContentsOfURL:mediaURL];
    
    NSMutableDictionary *md = [[ @{ @"status":status, @"media[]":data, @"postDataKey":@"media[]" } mutableCopy] autorelease];
    
    if(optionalExistingStatusID) {
        md[@"in_reply_to_status_id"] = optionalExistingStatusID;
    }
    
    if(optionalPlaceID) {
        md[@"place_id"] = optionalPlaceID;
        md[@"display_coordinates"] = @"true";
    } else if(optionalLat && optionalLon) {
        md[@"lat"] = optionalLat;
        md[@"lon"] = optionalLon;
        md[@"display_coordinates"] = @"true";
    }
    
    [_oauth postResource:@"statuses/update_with_media.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusRetweetWithID:(NSString *)statusID
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweet/%@.json", statusID];
    
    [_oauth postResource:resource parameters:nil successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getStatusesRetweetersIDsForStatusID:(NSString *)statusID
                             optionalCursor:(NSString *)cursor
                         returnIDsAsStrings:(BOOL)returnIDsAsStrings
                               successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"id"] = statusID;
    if(cursor) md[@"cursor"] = cursor;
    if(returnIDsAsStrings) md[@"stringify_ids"] = @"true";
    
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
                         optionalCount:(NSString *)count
                        optionalCursor:(NSString *)cursor
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
                      optionalCount:(NSString *)count
                     optionalCursor:(NSString *)cursor
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
                 optionalGeocode:(NSString *)geoCode // eg. "37.781157,-122.398720,1mi"
                    optionalLang:(NSString *)lang // eg. "eu"
                  optionalLocale:(NSString *)locale // eg. "ja"
              optionalResultType:(NSString *)resultType // eg. "mixed, recent, popular"
                   optionalCount:(NSString *)count // eg. "100"
                   optionalUntil:(NSString *)until // eg. "2012-09-01"
                 optionalSinceID:(NSString *)sinceID // eg. "12345"
                   optionalMaxID:(NSString *)maxID // eg. "54321"
                 includeEntities:(BOOL)includeEntities
                optionalCallback:(NSString *)callback // eg. "processTweets"
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
    if(includeEntities == NO) md[@"include_entities"] = @"false";
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
                   optionalGeocode:nil
                      optionalLang:nil
                    optionalLocale:nil
                optionalResultType:nil
                     optionalCount:nil
                     optionalUntil:nil
                   optionalSinceID:nil
                     optionalMaxID:nil
                   includeEntities:YES
                  optionalCallback:nil
                      successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
                          successBlock(searchMetadata, statuses);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

#pragma mark Streaming

#pragma mark Direct Messages
- (void)getDirectMessagesSinceID:(NSString *)optionalSinceID
						   count:(NSUInteger)optionalCount
					successBlock:(void(^)(NSArray *statuses))successBlock
					  errorBlock:(void(^)(NSError *error))errorBlock {
	NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(optionalSinceID) [md setObject:optionalSinceID forKey:@"since_id"];
	if (optionalCount != NSNotFound) [md setObject:[@(optionalCount) stringValue] forKey:@"count"];
    
    [_oauth getResource:@"direct_messages.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postDestroyDirectMessageWithID:(NSString *)dmID
						  successBlock:(void(^)(NSDictionary *dm))successBlock
							errorBlock:(void(^)(NSError *error))errorBlock {
	NSDictionary *d = @{@"id" : dmID};
    
    [_oauth postResource:@"direct_messages/destroy.json" parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postDirectMessage:(NSString *)status
					   to:(NSString *)screenName
             successBlock:(void(^)(NSDictionary *dm))successBlock
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
- (void)getUsersAtResource:(NSString *)resource
			 forScreenName:(NSString *)screenName
			  successBlock:(void(^)(NSArray *friends))successBlock
				errorBlock:(void(^)(NSError *error))errorBlock {
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:screenName forKey:@"screen_name"];
	
	__block NSMutableArray *ids = [NSMutableArray new];
	__block void (^requestHandler)(id response) = nil;
	__block NSString *cursor = @"-1";
	requestHandler = [[^(id response) {
		if (response) {
			[ids addObjectsFromArray:[response objectForKey:@"users"]];
			[cursor release]; cursor = [[response objectForKey:@"next_cursor_str"] copy];
			d[@"cursor"] = cursor;
		}
		
		if ([cursor isEqualToString:@"0"]) {
			successBlock(ids);
			[ids release]; ids = nil;
			[cursor release]; cursor = nil;
		} else {
			[_oauth getResource:resource parameters:d successBlock:requestHandler
					 errorBlock:errorBlock];
		}
	} copy] autorelease];
	
	//Send the first request
	requestHandler(nil);
}

- (void)getFriendsIDsForScreenName:(NSString *)screenName
				      successBlock:(void(^)(NSArray *friends))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
	[self getUsersAtResource:@"friends/ids.json" forScreenName:screenName successBlock:successBlock errorBlock:errorBlock];
}

- (void)getFollowersIDsForScreenName:(NSString *)screenName
					    successBlock:(void(^)(NSArray *followers))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
	[self getUsersAtResource:@"followers/ids.json" forScreenName:screenName successBlock:successBlock errorBlock:errorBlock];
}

- (void)postFollow:(NSString *)screenName
	  successBlock:(void(^)(NSDictionary *user))successBlock
		errorBlock:(void(^)(NSError *error))errorBlock {
	NSDictionary *d = @{@"screen_name" : screenName};
    
    [_oauth postResource:@"friendships/create.json" parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postUnfollow:(NSString *)screenName
		successBlock:(void(^)(NSDictionary *user))successBlock
		  errorBlock:(void(^)(NSError *error))errorBlock {
	NSDictionary *d = @{@"screen_name" : screenName};
    
    [_oauth postResource:@"friendships/destroy.json" parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postUpdateNotifications:(BOOL)notify
				  forScreenName:(NSString *)screenName
				   successBlock:(void(^)(NSDictionary *relationship))successBlock
					 errorBlock:(void(^)(NSError *error))errorBlock {
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:screenName forKey:@"screen_name"];
	d[@"device"] = notify ? @"true" : @"false";
    
    [_oauth postResource:@"friendships/update.json" parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendsForScreenName:(NSString *)screenName
				   successBlock:(void(^)(NSArray *friends))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
	[self getUsersAtResource:@"friends/list.json" forScreenName:screenName successBlock:successBlock errorBlock:errorBlock];
}

- (void)getFollowersForScreenName:(NSString *)screenName
					 successBlock:(void(^)(NSArray *followers))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
	[self getUsersAtResource:@"followers/list.json" forScreenName:screenName successBlock:successBlock errorBlock:errorBlock];
}

#pragma mark Users

- (void)getAccountVerifyCredentialsSkipStatus:(BOOL)skipStatus
								 successBlock:(void(^)(NSDictionary *myInfo))successBlock
								   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{@"skip_status" : (skipStatus ? @"true" : @"false")};
    
    [_oauth getResource:@"account/verify_credentials.json" parameters:d successBlock:^(id response) {
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

#if TARGET_OS_IPHONE
- (void)postUpdateProfileImage:(UIImage *)newImage
#else
- (void)postUpdateProfileImage:(NSImage *)newImage
#endif
				  successBlock:(void(^)(NSDictionary *myInfo))successBlock
					errorBlock:(void(^)(NSError *error))errorBlock {
	NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:newImage forKey:@"image"];
	[md setObject:@"image" forKey:@"postDataKey"];
    
    [_oauth postResource:@"account/update_profile_image.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getUserInformationFor:(NSString *)screenName
				 successBlock:(void(^)(NSDictionary *user))successBlock
				   errorBlock:(void(^)(NSError *error))errorBlock {
	NSDictionary *d = @{@"screen_name" : screenName};
    
    [_oauth getResource:@"users/show.json" parameters:d successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getUsersSearchQuery:(NSString *)query
               optionalPage:(NSString *)page
              optionalCount:(NSString *)count
            includeEntities:(BOOL)includeEntities
               successBlock:(void(^)(NSDictionary *users))successBlock
                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"query"] = [query st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(page) md[@"page"] = page;
    if(count) md[@"count"] = count;
    if(includeEntities == NO) md[@"include_entities"] = @"false";
    
    [_oauth getResource:@"users/search.json" parameters:md successBlock:^(id response) {
        successBlock(response); // NSArray of users dictionaries
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Suggested Users

#pragma mark Favorites

- (void)getFavoritesListWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth getResource:@"favorites/list.json" parameters:nil successBlock:^(id response) {
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
                             reverse:(BOOL)reverse
                        successBlock:(void(^)(NSArray *lists))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((username || userID), @"missing username or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(username) {
        md[@"screen_name"] = username;
    } else if (userID) {
        md[@"user_id"] = userID;
    }
    
    md[@"reverse"] = reverse ? @"true" : @"false";
    
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
                  optionalSinceID:(NSString *)sinceID
                    optionalMaxID:(NSString *)maxID
                    optionalCount:(NSString *)count
                  includeEntities:(BOOL)includeEntities
                  includeRetweets:(BOOL)includeRetweets
                     successBlock:(void(^)(NSArray *statuses))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(count) md[@"count"] = count;
    
    md[@"inclued_entities"] = includeEntities ? @"true" : @"false";
    md[@"inclued_rts"] = includeRetweets ? @"true" : @"false";
    
    [_oauth getResource:@"lists/statuses.json" parameters:md successBlock:^(id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *statuses = (NSArray *)response;
        
        successBlock(statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getListsStatusesForSlug:(NSString *)slug
                ownerScreenName:(NSString *)ownerScreenName
                      orOwnerID:(NSString *)ownerID
                optionalSinceID:(NSString *)sinceID
                  optionalMaxID:(NSString *)maxID
                  optionalCount:(NSString *)count
                includeEntities:(BOOL)includeEntities
                includeRetweets:(BOOL)includeRetweets
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
    
    md[@"inclued_entities"] = includeEntities ? @"true" : @"false";
    md[@"inclued_rts"] = includeRetweets ? @"true" : @"false";
    
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
                        optionalUserID:(NSString *)userID
                    optionalScreenName:(NSString *)screenName
               optionalOwnerScreenName:(NSString *)ownerScreenName
                       optionalOwnerID:(NSString *)ownerID
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

// GET	lists/subscribers

- (void)getListsSubscribersForSlug:(NSString *)slug
                   ownerScreenName:(NSString *)ownerScreenName
                         orOwnerID:(NSString *)ownerID
                    optionalCursor:(NSString *)cursor
                   includeEntities:(BOOL)includeEntities
                        skipStatus:(BOOL)skipStatus
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
    if(includeEntities) md[@"include_entities"] = @"true";
    if(skipStatus) md[@"skip_status"] = @"true";
    
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
                      optionalCursor:(NSString *)cursor
                     includeEntities:(BOOL)includeEntities
                          skipStatus:(BOOL)skipStatus
                        successBlock:(void(^)())successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"listID"] = listID;
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = @"true";
    if(skipStatus) md[@"skip_status"] = @"true";
    
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
                         includeEntities:(BOOL)includeEntities
                              skipStatus:(BOOL)skipStatus
                            successBlock:(void(^)())successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(listID);
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities == NO) md[@"include_entities"] = @"false";
    if(skipStatus) md[@"skipStatus"] = @"true";
    
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
                       includeEntities:(BOOL)includeEntities
                            skipStatus:(BOOL)skipStatus
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
    if(includeEntities == NO) md[@"include_entities"] = @"false";
    if(skipStatus) md[@"skipStatus"] = @"true";
    
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
                     includeEntities:(BOOL)includeEntities
                          skipStatus:(BOOL)skipStatus
                        successBlock:(void(^)(NSDictionary *user))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert(listID, @"listID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"listID"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = @"true";
    if(skipStatus) md[@"skip_status"] = @"true";
    
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
                   includeEntities:(BOOL)includeEntities
                        skipStatus:(BOOL)skipStatus
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
    if(includeEntities) md[@"include_entities"] = @"true";
    if(skipStatus) md[@"skip_status"] = @"true";
    
    [_oauth getResource:@"lists/members/show.json" parameters:md successBlock:^(id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET	lists/members

- (void)getListsMembersForListID:(NSString *)listID
                  optionalCursor:(NSString *)cursor
                 includeEntities:(BOOL)includeEntities
                      skipStatus:(BOOL)skipStatus
                    successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(listID, @"listID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"listID"] = listID;
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = @"true";
    if(skipStatus) md[@"skip_status"] = @"true";
    
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
                optionalCursor:(NSString *)cursor
               includeEntities:(BOOL)includeEntities
                    skipStatus:(BOOL)skipStatus
                  successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    md[@"cursor"] = cursor ? cursor : @"-1";
    if(includeEntities == NO) md[@"include_entities"] = @"false";
    if(skipStatus) md[@"skip_status"] = @"true";
    
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
                    optionalName:(NSString *)name
                       isPrivate:(BOOL)isPrivate
             optionalDescription:(NSString *)description
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
                  optionalName:(NSString *)name
                     isPrivate:(BOOL)isPrivate
           optionalDescription:(NSString *)description
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
            optionalDescription:(NSString *)description
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

- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                               longitude:(NSString *)longitude
                            successBlock:(void(^)(NSArray *places))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    NSDictionary *d = @{ @"lat":latitude, @"lon":longitude };
    
    [_oauth getResource:@"geo/reverse_geocode.json" parameters:d successBlock:^(id response) {
        
        NSArray *places = [response valueForKeyPath:@"result.places"];
        
        successBlock(places);
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
    
    NSDictionary *d = @{ @"lat":latitude, @"lon":longitude };
    
    [_oauth getResource:@"geo/search.json" parameters:d successBlock:^(id response) {
        
        NSArray *places = [response valueForKeyPath:@"result.places"];
        
        successBlock(places);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getGeoSearchWithIPAddress:(NSString *)ipAddress
                     successBlock:(void(^)(NSArray *places))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(ipAddress);
    
    NSDictionary *d = @{ @"ip":ipAddress };
    
    [_oauth getResource:@"geo/search.json" parameters:d successBlock:^(id response) {
        
        NSArray *places = [response valueForKeyPath:@"result.places"];
        
        successBlock(places);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getGeoSearchWithQuery:(NSString *)query
                 successBlock:(void(^)(NSArray *places))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    NSDictionary *d = @{ @"query":query };
    
    [_oauth getResource:@"geo/search.json" parameters:d successBlock:^(id response) {
        
        NSArray *places = [response valueForKeyPath:@"result.places"];
        
        successBlock(places);
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

@end

@implementation NSString (STTwitterAPIWrapper)

- (NSString *)htmlLinkName {
    NSString *ahref = [self firstMatchWithRegex:@"<a href=\".*\">(.*)</a>" error:nil];
    
    return ahref ? ahref : self;
}

@end
