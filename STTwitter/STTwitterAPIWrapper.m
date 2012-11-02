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
#import "STTwitterHTML.h"
#import <Accounts/Accounts.h>

@interface STTwitterAPIWrapper ()
@property (nonatomic, retain) NSObject <STTwitterOAuthProtocol> *oauth;
@end

@implementation STTwitterAPIWrapper

- (id)init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ACAccountStoreDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        // OS X account must be considered invalid
        
        if([self.oauth isKindOfClass:[STTwitterOAuthOSX class]]) {
            NSLog(@"-- RESET OAUTH OSX");
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
        [self getAccountVerifyCredentialsSkipStatus:YES successBlock:^(NSString *jsonString) {
            self.userName = [jsonString valueForKey:@"screen_name"];
            successBlock(_userName);
        } errorBlock:^(NSError *error) {
            errorBlock(error);
        }];
    }
}

- (NSString *)oauthAccessTokenSecret {
    return [_oauth oauthAccessTokenSecret];
}

- (NSString *)oauthAccessToken {
    return [_oauth oauthAccessToken];
}

- (NSString *)userName {
    
    if([_oauth isKindOfClass:[STTwitterOAuthOSX class]]) {
        STTwitterOAuthOSX *oAuthOSX = (STTwitterOAuthOSX *)_oauth;
        return oAuthOSX.username;
    }
    
    return _userName;
}

- (void)dealloc {
    [_userName release];
    [_consumerName release];
    [_oauth release];
    [super dealloc];
}

/**/

#pragma mark Timelines

- (void)getUserTimelineWithScreenName:(NSString *)screenName
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {

    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    [md setObject:screenName forKey:@"screen_name"];
    
    [_oauth getResource:@"statuses/user_timeline.json" parameters:md successBlock:^(NSArray *statuses) {
        successBlock(statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getHomeTimelineSinceID:(NSString *)optionalSinceID
                         count:(NSString *)optionalCount
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(optionalSinceID) [md setObject:optionalSinceID forKey:@"since_id"];
    if(optionalCount) [md setObject:optionalCount forKey:@"count"];
    
    [_oauth getResource:@"statuses/home_timeline.json" parameters:md successBlock:^(NSArray *statuses) {
        successBlock(statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Tweets

- (void)postDestroyStatusWithID:(NSString *)statusID
                   successBlock:(void(^)(NSString *jsonString))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    // set trim_user to true?
    
    NSString *resource = [NSString stringWithFormat:@"statuses/destroy/%@.json", statusID];
    
    [_oauth postResource:resource parameters:nil successBlock:^(NSString *response) {
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
            successBlock:(void(^)(NSString *response))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
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
    
    [_oauth postResource:@"statuses/update.json" parameters:md successBlock:^(NSString *response) {
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
            successBlock:(void(^)(NSString *response))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSData *data = [NSData dataWithContentsOfURL:mediaURL];
    
    NSMutableDictionary *md = [[ @{ @"status":status, @"media[]":data } mutableCopy] autorelease];
    
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
    
    [_oauth postResource:@"statuses/update_with_media.json" parameters:md successBlock:^(NSString *response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusRetweetWithID:(NSString *)statusID
                   successBlock:(void(^)(NSString *response))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweet/%@.json", statusID];
    
    [_oauth postResource:resource parameters:nil successBlock:^(NSString *response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Search

- (void)getSearchTweetsWithQuery:(NSString *)q successBlock:(void(^)(NSString *jsonString))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{@"q" : q};
    
    [_oauth getResource:@"search/tweets.json" parameters:d successBlock:^(NSString *response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Streaming

#pragma mark Direct Messages

#pragma mark Friends & Followers

- (void)getFollowersWithScreenName:(NSString *)screenName
                      successBlock:(void(^)(NSString *response))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{@"screen_name" : screenName};
    
    [_oauth getResource:@"followers/ids.json" parameters:d successBlock:^(NSString *response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Users

- (void)getAccountVerifyCredentialsSkipStatus:(BOOL)skipStatus successBlock:(void(^)(NSString *jsonString))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{@"skip_status" : (skipStatus ? @"true" : @"false")};
    
    [_oauth getResource:@"account/verify_credentials.json" parameters:d successBlock:^(NSString *response) {
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
             successBlock:(void(^)(NSString *jsonString))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *action = favoriteState ? @"create" : @"destroy";
    
    NSString *resource = [NSString stringWithFormat:@"favorites/%@.json", action];
    
    NSDictionary *d = @{@"id" : statusID};
    
    [_oauth postResource:resource parameters:d successBlock:^(NSString *response) {
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
        
        NSLog(@"-- %@", [places valueForKey:@"full_name"]);
        
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
        
        NSLog(@"-- %@", [places valueForKey:@"full_name"]);
        
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
        
        NSLog(@"-- %@", [places valueForKey:@"full_name"]);
        
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
        
        NSLog(@"-- %@", [places valueForKey:@"full_name"]);
        
        successBlock(places);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark Trends

#pragma mark Spam Reporting

#pragma mark OAuth

#pragma mark Help

@end

@implementation NSString (STTwitterAPIWrapper)

- (NSString *)htmlLinkName {
    NSString *ahref = [self firstMatchWithRegex:@"<a href=\".*\">(.*)</a>" error:nil];
    
    return ahref ? ahref : self;
}

@end