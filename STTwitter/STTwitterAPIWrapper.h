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

/*
 Partial Objective-C front-end for https://dev.twitter.com/docs/api/1.1
 */

/*
 FWIW Twitter.app for iOS 5 implements this:
 https://api.twitter.com/1/statuses/update.json
 https://upload.twitter.com/1/statuses/update_with_media.json
 https://api.twitter.com/1/geo/nearby_places.json
 https://api.twitter.com/1/friendships/show.json
 https://api.twitter.com/1/statuses/friends.json
 https://api.twitter.com/1/help/configuration.json
 https://api.twitter.com/1/apps/configuration.json
 https://api.twitter.com/1/users/show.json
 https://api.twitter.com/1/account/verify_credentials.json
 
 Tweet fields contents
 https://dev.twitter.com/docs/platform-objects/tweets
 https://dev.twitter.com/blog/new-withheld-content-fields-api-responses
 */

@interface STTwitterAPIWrapper : NSObject

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthOSX;

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                         consumerSecret:(NSString *)consumerSecret;

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                         consumerSecret:(NSString *)consumerSecret
                                               username:(NSString *)username
                                               password:(NSString *)password;

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                         consumerSecret:(NSString *)consumerSecret
                                             oauthToken:(NSString *)oauthToken
                                       oauthTokenSecret:(NSString *)oauthTokenSecret;

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

@property (nonatomic, readonly) NSString *oauthAccessToken;
@property (nonatomic, readonly) NSString *oauthAccessTokenSecret;

#pragma mark Timelines

// GET statuses/mentions_timeline

// GET statuses/user_timeline

// GET statuses/home_timeline
- (void)getHomeTimelineSinceID:(NSString *)optionalSinceID
                         count:(NSString *)optionalCount
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Tweets

// GET statuses/retweets/:id

// GET statuses/show/:id

// POST statuses/destroy/:id
- (void)postDestroyStatusWithID:(NSString *)statusID
                   successBlock:(void(^)(NSString *response))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

// POST statuses/update
- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)optionalExistingStatusID
                     lat:(NSString *)optionalLat
                     lon:(NSString *)optionalLon
            successBlock:(void(^)(NSString *response))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock;

// POST statuses/retweet/:id
- (void)postStatusRetweetWithID:(NSString *)statusID
                   successBlock:(void(^)(NSString *response))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;


// POST statuses/update_with_media
- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)optionalExistingStatusID
                mediaURL:(NSURL *)mediaURL
                     lat:(NSString *)optionalLat
                     lon:(NSString *)optionalLon
            successBlock:(void(^)(NSString *response))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock;

// GET statuses/oembed

#pragma mark Search

// GET search/tweets
- (void)getSearchTweetsWithQuery:(NSString *)q
                    successBlock:(void(^)(NSString *jsonString))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Streaming

// POST statuses/filter

// GET statuses/sample

// GET statuses/firehose

// GET user

// GET site

#pragma mark Direct Messages

// GET direct_messages

// GET direct_messages/sent

// GET direct_messages/show

// POST direct_messages/destroy

// POST direct_messages/new

#pragma mark Friends & Followers

// GET friends/ids

// GET followers/ids
- (void)getFollowersWithScreenName:(NSString *)screenName
                      successBlock:(void(^)(NSString *jsonString))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

// GET friendships/lookup

// GET friendships/incoming

// GET friendships/outgoing

// POST friendships/create

// POST friendships/destroy

// POST friendships/update

// GET friendships/show

#pragma mark Users

// GET account/settings

// GET account/verify_credentials

- (void)getAccountVerifyCredentialsSkipStatus:(BOOL)skipStatus
                                 successBlock:(void(^)(NSString *jsonString))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

// POST account/settings

// POST account/update_delivery_device

// POST account/update_profile

// POST account/update_profile_background_image

// POST account/update_profile_colors

// POST account/update_profile_image

// GET blocks/list

// GET blocks/ids

// POST blocks/create

// POST blocks/destroy

// GET users/lookup

// GET users/show

// GET users/search

// GET users/contributees

// GET users/contributors

#pragma mark Suggested Users

// GET users/suggestions/:slug

// GET users/suggestions

// GET users/suggestions/:slug/members

#pragma mark Favorites

// GET favorites/list
- (void)getFavoritesListWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

// POST favorites/destroy
// POST favorites/create
- (void)postFavoriteState:(BOOL)favoriteState
              forStatusID:(NSString *)statusID
             successBlock:(void(^)(NSString *jsonString))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Lists

// GET lists/list

// GET lists/statuses

// POST lists/members/destroy

// GET lists/memberships

// GET lists/subscribers

// POST lists/subscribers/create

// GET lists/subscribers/show

// POST lists/subscribers/destroy

// POST lists/members/create_all

// GET lists/members/show

// GET lists/members

// POST lists/members/create

// POST lists/destroy

// POST lists/update

// POST lists/create

// GET lists/show

// GET lists/subscriptions

// POST lists/members/destroy_all

#pragma mark Saved Searches

#pragma mark Places & Geo

// GET geo/id/:place_id

// GET geo/reverse_geocode
- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                               longitude:(NSString *)longitude
                            successBlock:(void(^)(NSArray *places))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

// GET geo/search
- (void)getGeoSearchWithLatitude:(NSString *)latitude
                       longitude:(NSString *)longitude
                    successBlock:(void(^)(NSArray *places))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getGeoSearchWithIPAddress:(NSString *)ipAddress
                     successBlock:(void(^)(NSArray *places))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getGeoSearchWithQuery:(NSString *)query
                 successBlock:(void(^)(NSArray *places))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock;

// GET geo/similar_places

// POST geo/place

#pragma mark Trends

#pragma mark Spam Reporting

#pragma mark OAuth

#pragma mark Help

@end
