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
        NSLog(@"-- self.oauth does not support tokens invalidation");
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
			  count:(NSUInteger)optionalCount
	   successBlock:(void(^)(NSArray *statuses))successBlock
		 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *mparams = [params mutableCopy];
	if (!mparams)
		mparams = [NSMutableDictionary new];
	
    if (optionalSinceID) mparams[@"since_id"] = optionalSinceID;
	if (optionalCount != NSNotFound) mparams[@"count"] = [@(optionalCount) stringValue];
	
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
				NSUInteger maxID = [[NSDecimalNumber decimalNumberWithString:lastID] unsignedIntegerValue];
				if (maxID != NSNotFound)
					mparams[@"max_id"] = [@(--maxID) stringValue];
			}
			
			[_oauth getResource:timeline parameters:mparams
				   successBlock:requestHandler
					 errorBlock:errorBlock];
		} else {
			successBlock(removeNull(statuses));
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
				count:optionalCount
		 successBlock:successBlock
		   errorBlock:errorBlock];
}

- (void)getUserTimelineWithScreenName:(NSString *)screenName
								count:(NSUInteger)optionalCount
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
	[self getTimeline:@"statuses/user_timeline.json"
	   withParameters:@{ @"screen_name" : screenName }
			  sinceID:nil
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
				count:optionalCount
		 successBlock:successBlock
		   errorBlock:errorBlock];
}

#pragma mark Tweets

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

#pragma mark Search

- (void)getSearchTweetsWithQuery:(NSString *)q
					successBlock:(void(^)(NSArray *statuses))successBlock
					  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{@"q" : q};
    
    [_oauth getResource:@"search/tweets.json" parameters:d successBlock:^(id response) {
        successBlock(response);
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
			cursor = [[response objectForKey:@"next_cursor_str"] copy];
			d[@"cursor"] = cursor;
		}
		
		if ([cursor isEqualToString:@"0"]) {
			successBlock(ids);
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
    
    [_oauth getResource:@"users/report_spam.json" parameters:d successBlock:^(id response) {
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
