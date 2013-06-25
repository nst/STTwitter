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
 Tweet fields contents
 https://dev.twitter.com/docs/platform-objects/tweets
 https://dev.twitter.com/blog/new-withheld-content-fields-api-responses
 */

@interface STTwitterAPIWrapper : NSObject

#if TARGET_OS_IPHONE
#else
+ (STTwitterAPIWrapper *)twitterAPIWithOAuthOSX;
#endif

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                             consumerKey:(NSString *)consumerKey
                                          consumerSecret:(NSString *)consumerSecret;

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                             consumerKey:(NSString *)consumerKey
                                          consumerSecret:(NSString *)consumerSecret
                                                username:(NSString *)username
                                                password:(NSString *)password;

+ (STTwitterAPIWrapper *)twitterAPIWithOAuthConsumerName:(NSString *)consumerName
                                             consumerKey:(NSString *)consumerKey
                                          consumerSecret:(NSString *)consumerSecret
                                              oauthToken:(NSString *)oauthToken
                                        oauthTokenSecret:(NSString *)oauthTokenSecret;

// https://dev.twitter.com/docs/auth/application-only-auth
+ (STTwitterAPIWrapper *)twitterAPIApplicationOnlyWithConsumerKey:(NSString *)consumerKey
                                                   consumerSecret:(NSString *)consumerSecret;

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (void)invalidateBearerTokenWithSuccessBlock:(void(^)())successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

@property (nonatomic, retain) NSString *consumerName;
@property (nonatomic, retain) NSString *userName; // available for osx, set after successful connection for STTwitterOAuth

@property (nonatomic, readonly) NSString *oauthAccessToken;
@property (nonatomic, readonly) NSString *oauthAccessTokenSecret;
@property (nonatomic, readonly) NSString *bearerToken;

- (void)profileImageFor:(NSString *)screenName
#if TARGET_OS_IPHONE
           successBlock:(void(^)(UIImage *image))successBlock
#else
           successBlock:(void(^)(NSImage *image))successBlock
#endif
             errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Timelines

//	GET		statuses/mentions_timeline
//	Returns Tweets (*: mentions for the user)
- (void)getMentionsTimelineSinceID:(NSString *)optionalSinceID
							 count:(NSUInteger)optionalCount
					  successBlock:(void(^)(NSArray *statuses))successBlock
						errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		statuses/user_timeline
//	Returns Tweets (*: tweets for the user)
- (void)getUserTimelineWithScreenName:(NSString *)screenName
                              sinceID:(NSString *)optionalSinceID
                                maxID:(NSString *)optionalMaxID
								count:(NSUInteger)optionalCount
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getUserTimelineWithScreenName:(NSString *)screenName
								count:(NSUInteger)optionalCount
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getUserTimelineWithScreenName:(NSString *)screenName
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		statuses/home_timeline
//	Returns Tweets (*: tweets from people the user follows)
- (void)getHomeTimelineSinceID:(NSString *)optionalSinceID
                         count:(NSUInteger)optionalCount
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Tweets

//	GET		statuses/retweets/:id
- (void)getStatusesRetweetsForID:(NSString *)statusID
                   optionalCount:(NSString *)count
                        trimUser:(BOOL)trimUser
                    successBlock:(void(^)(NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		statuses/show/:id
- (void)getStatusesShowID:(NSString *)statusID
                 trimUser:(BOOL)trimUser
         includeMyRetweet:(BOOL)includeMyRetweet
          includeEntities:(BOOL)includeEntities
             successBlock:(void(^)(NSDictionary *status))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	statuses/destroy/:id
//	Returns Tweets (1: the destroyed tweet)
- (void)postDestroyStatusWithID:(NSString *)statusID
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	statuses/update
//	Returns Tweets (1: the new tweet)
- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)optionalExistingStatusID
                 placeID:(NSString *)optionalPlaceID // wins over lat/lon
                     lat:(NSString *)optionalLat
                     lon:(NSString *)optionalLon
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	statuses/retweet/:id
//	Returns Tweets (1: the retweeted tweet)
- (void)postStatusRetweetWithID:(NSString *)statusID
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	statuses/update_with_media
//	Returns Tweets (1: the new tweet)
- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)optionalExistingStatusID
                mediaURL:(NSURL *)mediaURL
                 placeID:(NSString *)optionalPlaceID // wins over lat/lon
                     lat:(NSString *)optionalLat
                     lon:(NSString *)optionalLon
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		statuses/oembed

//  GET     statuses/retweeters/ids
- (void)getStatusesRetweetersIDsForStatusID:(NSString *)statusID
                             optionalCursor:(NSString *)cursor
                         returnIDsAsStrings:(BOOL)returnIDsAsStrings
                               successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Search

//	GET		search/tweets
//	Returns Tweets (*: tweets matching the query)
- (void)getSearchTweetsWithQuery:(NSString *)q
					successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Streaming

//	POST	statuses/filter

//	GET		statuses/sample

//	GET		statuses/firehose

//	GET		user

//	GET		site

#pragma mark Direct Messages

//	GET		direct_messages
//	Returns Tweets (*: direct messages to the user)
- (void)getDirectMessagesSinceID:(NSString *)optionalSinceID
						   count:(NSUInteger)optionalCount
					successBlock:(void(^)(NSArray *statuses))successBlock
					  errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		direct_messages/sent

//	GET		direct_messages/show

//	POST	direct_messages/destroy
//	Returns Tweets (1: the destroyed DM)
- (void)postDestroyDirectMessageWithID:(NSString *)dmID
						  successBlock:(void(^)(NSDictionary *dm))successBlock
							errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	direct_messages/new
//	Returns Tweets (1: the sent DM)
- (void)postDirectMessage:(NSString *)status
					   to:(NSString *)screenName
             successBlock:(void(^)(NSDictionary *dm))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Friends & Followers

//	GET		friends/ids
//	Returns Users (*: user IDs for followees)
- (void)getFriendsIDsForScreenName:(NSString *)screenName
				      successBlock:(void(^)(NSArray *friends))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		followers/ids
//	Returns Users (*: user IDs for followers)
- (void)getFollowersIDsForScreenName:(NSString *)screenName
                        successBlock:(void(^)(NSArray *followers))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		friendships/lookup

//	GET		friendships/incoming

//	GET		friendships/outgoing

//	POST	friendships/create
//	Returns Users (1: the followed user)
- (void)postFollow:(NSString *)screenName
	  successBlock:(void(^)(NSDictionary *user))successBlock
		errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	friendships/destroy
//	Returns Users (1: the unfollowed user)
- (void)postUnfollow:(NSString *)screenName
		successBlock:(void(^)(NSDictionary *user))successBlock
		  errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	friendships/update
//	Returns ?
- (void)postUpdateNotifications:(BOOL)notify
				  forScreenName:(NSString *)screenName
				   successBlock:(void(^)(NSDictionary *relationship))successBlock
					 errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		friendships/show

//	GET		friends/list
- (void)getFriendsForScreenName:(NSString *)screenName
				   successBlock:(void(^)(NSArray *friends))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		followers/list
- (void)getFollowersForScreenName:(NSString *)screenName
					 successBlock:(void(^)(NSArray *followers))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Users

//	GET		account/settings

//	GET		account/verify_credentials
//	Returns Users (1: the user)
- (void)getAccountVerifyCredentialsSkipStatus:(BOOL)skipStatus
                                 successBlock:(void(^)(NSDictionary *myInfo))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	account/settings

//	POST	account/update_delivery_device

//	POST	account/update_profile
//	Returns Users (1: the user)
- (void)postUpdateProfile:(NSDictionary *)profileData
			 successBlock:(void(^)(NSDictionary *myInfo))successBlock
			   errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	account/update_profile_background_image

//	POST	account/update_profile_colors

//	POST	account/update_profile_image
//	Returns Users (1: the user)
#if TARGET_OS_IPHONE
- (void)postUpdateProfileImage:(UIImage *)newImage
#else
- (void)postUpdateProfileImage:(NSImage *)newImage
#endif
				  successBlock:(void(^)(NSDictionary *myInfo))successBlock
					errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		blocks/list

//	GET		blocks/ids

//	POST	blocks/create

//	POST	blocks/destroy

//	GET		users/lookup

//	GET		users/show
//	Returns Users (1: detailed information for the user)
- (void)getUserInformationFor:(NSString *)screenName
				 successBlock:(void(^)(NSDictionary *user))successBlock
				   errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		users/search

//	GET		users/contributees

//	GET		users/contributors

#pragma mark Suggested Users

//	GET		users/suggestions/:slug

//	GET		users/suggestions

//	GET		users/suggestions/:slug/members

#pragma mark Favorites

//	GET		favorites/list
//	Returns Tweets (20: last 20 favorited tweets)
- (void)getFavoritesListWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	favorites/destroy
//	POST	favorites/create
//	Returns Tweets (1: the (un)favorited tweet)
- (void)postFavoriteState:(BOOL)favoriteState
              forStatusID:(NSString *)statusID
             successBlock:(void(^)(NSDictionary *status))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Lists

//	GET		lists/list

- (void)getListsSubscribedByUsername:(NSString *)username
                            orUserID:(NSString *)userID
                             reverse:(BOOL)reverse
                        successBlock:(void(^)(NSArray *lists))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		lists/statuses

- (void)getListStatusesForListID:(NSString *)listID
                 optionalSinceID:(NSString *)sinceID
                   optionalMaxID:(NSString *)maxID
                   optionalCount:(NSString *)count
                 includeEntities:(BOOL)includeEntities
                 includeRetweets:(BOOL)includeRetweets
                    successBlock:(void(^)(NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getListStatusesForSlug:(NSString *)slug
               ownerScreenName:(NSString *)ownerScreenName
                     orOwnerID:(NSString *)ownerID
               optionalSinceID:(NSString *)sinceID
                 optionalMaxID:(NSString *)maxID
                 optionalCount:(NSString *)count
               includeEntities:(BOOL)includeEntities
               includeRetweets:(BOOL)includeRetweets
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	lists/members/destroy

- (void)postListMembersDestroyForListID:(NSString *)listID
                           successBlock:(void(^)())successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListMembersDestroyForSlug:(NSString *)slug
                       optionalUserID:(NSString *)userID
                   optionalScreenName:(NSString *)screenName
              optionalOwnerScreenName:(NSString *)ownerScreenName
                      optionalOwnerID:(NSString *)ownerID
                         successBlock:(void(^)())successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		lists/memberships

//	GET		lists/subscribers

//	POST	lists/subscribers/create

//	GET		lists/subscribers/show

//	POST	lists/subscribers/destroy

//	POST	lists/members/create_all

//	GET		lists/members/show

//	GET		lists/members

- (void)getListMembersForListID:(NSString *)listID
                 optionalCursor:(NSString *)cursor
                includeEntities:(BOOL)includeEntities
                     skipStatus:(BOOL)skipStatus
                   successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getListMembersForSlug:(NSString *)slug
              ownerScreenName:(NSString *)screenName
                    orOwnerID:(NSString *)ownerID
               optionalCursor:(NSString *)cursor
              includeEntities:(BOOL)includeEntities
                   skipStatus:(BOOL)skipStatus
                 successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	lists/members/create

- (void)postListMemberCreateForListID:(NSString *)listID
                               userID:(NSString *)userID
                           screenName:(NSString *)screenName
                         successBlock:(void(^)())successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListMemberCreateForSlug:(NSString *)slug
                    ownerScreenName:(NSString *)ownerScreenName
                          orOwnerID:(NSString *)ownerID
                             userID:(NSString *)userID
                         screenName:(NSString *)screenName
                       successBlock:(void(^)())successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	lists/destroy

//	POST	lists/update

//	POST	lists/create

//	GET		lists/show

//	GET		lists/subscriptions

//	POST	lists/members/destroy_all

//  GET     lists/ownerships

#pragma mark Saved Searches

#pragma mark Places & Geo

//	GET		geo/id/:place_id

//	GET		geo/reverse_geocode
//	Returns Places (*: up to 20 places that match the lat/lon)
- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                               longitude:(NSString *)longitude
                            successBlock:(void(^)(NSArray *places))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

//	GET		geo/search
//	Returns Places (*: places that match the lat/lon)
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

//	GET		geo/similar_places

//	POST	geo/place

#pragma mark Trends

#pragma mark Spam Reporting

- (void)postReportSpamWithScreenName:(NSString *)screenName
                            orUserID:(NSString *)userID
                        successBlock:(void(^)(id userProfile))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark OAuth

#pragma mark Help
//	GET		application/rate_limit_status
//	Returns ?
- (void)getRateLimitsForResources:(NSArray *)resources
					 successBlock:(void(^)(NSDictionary *rateLimits))successBlock
					   errorBlock:(void(^)(NSError *error))errorBlock;

@end
