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

#pragma mark Generic methods to GET and POST

- (void)getResource:(NSString *)resource
         parameters:(NSDictionary *)parameters
       successBlock:(void(^)(id json))successBlock
         errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postResource:(NSString *)resource
          parameters:(NSDictionary *)parameters
        successBlock:(void(^)(id response))successBlock
          errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Timelines

/*
 GET	statuses/mentions_timeline
 Returns Tweets (*: mentions for the user)
 
 Returns the 20 most recent mentions (tweets containing a users's @screen_name) for the authenticating user.
 
 The timeline returned is the equivalent of the one seen when you view your mentions on twitter.com.
 
 This method can only return up to 800 tweets.
 */

- (void)getMentionsTimelineSinceID:(NSString *)optionalSinceID
							 count:(NSUInteger)optionalCount
					  successBlock:(void(^)(NSArray *statuses))successBlock
						errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	statuses/user_timeline
 Returns Tweets (*: tweets for the user)
 
 Returns a collection of the most recent Tweets posted by the user indicated by the screen_name or user_id parameters.
 
 User timelines belonging to protected users may only be requested when the authenticated user either "owns" the timeline or is an approved follower of the owner.
 
 The timeline returned is the equivalent of the one seen when you view a user's profile on twitter.com.
 
 This method can only return up to 3,200 of a user's most recent Tweets. Native retweets of other statuses by the user is included in this total, regardless of whether include_rts is set to false when requesting this resource.
 */

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

/*
 GET	statuses/home_timeline
 Returns Tweets (*: tweets from people the user follows)
 
 Returns a collection of the most recent Tweets and retweets posted by the authenticating user and the users they follow. The home timeline is central to how most users interact with the Twitter service.
 
 Up to 800 Tweets are obtainable on the home timeline. It is more volatile for users that follow many users or follow users who tweet frequently.
 */

- (void)getHomeTimelineSinceID:(NSString *)optionalSinceID
                         count:(NSUInteger)optionalCount
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    statuses/retweets_of_me
 
 Returns the most recent tweets authored by the authenticating user that have been retweeted by others. This timeline is a subset of the user's GET statuses/user_timeline. See Working with Timelines for instructions on traversing timelines.
 */

- (void)getStatusesRetweetsOfMeWithOptionalCount:(NSString *)count
                                 optionalSinceID:(NSString *)sinceID
                                   optionalMaxID:(NSString *)maxID
                                        trimUser:(BOOL)trimUser
                                 includeEntitied:(BOOL)includeEntities
                             includeUserEntities:(BOOL)includeUserEntities
                                    successBlock:(void(^)(NSArray *statuses))successBlock
                                      errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method without all optional values
- (void)getStatusesRetweetsOfMeWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
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

// full method
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
					  errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
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

/*
 GET friendships/no_retweets/ids

 Returns a collection of user_ids that the currently authenticated user does not want to receive retweets from. Use POST friendships/update to set the "no retweets" status for a given user account on behalf of the current user.
 */

/*
 GET		friends/ids
 Returns Users (*: user IDs for followees)
 
 Returns a cursored collection of user IDs for every user the specified user is following (otherwise known as their "friends").
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 5,000 user IDs and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 
 This method is especially powerful when used in conjunction with GET users/lookup, a method that allows you to convert user IDs into full user objects in bulk.
 */

- (void)getFriendsIDsForScreenName:(NSString *)screenName
				      successBlock:(void(^)(NSArray *friends))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    followers/ids
 Returns Users (*: user IDs for followers)
 
 Returns a cursored collection of user IDs for every user following the specified user.
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 5,000 user IDs and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 
 This method is especially powerful when used in conjunction with GET users/lookup, a method that allows you to convert user IDs into full user objects in bulk.
 */

- (void)getFollowersIDsForScreenName:(NSString *)screenName
                        successBlock:(void(^)(NSArray *followers))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    friendships/lookup

 Returns the relationships of the authenticating user to the comma-separated list of up to 100 screen_names or user_ids provided. Values for connections can be: following, following_requested, followed_by, none.
 */

/*
 GET    friendships/incoming

 Returns a collection of numeric IDs for every user who has a pending request to follow the authenticating user.
 */

/*
 GET    friendships/outgoing

 Returns a collection of numeric IDs for every protected user for whom the authenticating user has a pending follow request.
 */

/*
 POST   friendships/create
 Returns Users (1: the followed user)
 
 Allows the authenticating users to follow the user specified in the ID parameter.
 
 Returns the befriended user in the requested format when successful. Returns a string describing the failure condition when unsuccessful. If you are already friends with the user a HTTP 403 may be returned, though for performance reasons you may get a 200 OK message even if the friendship already exists.
 
 Actions taken in this method are asynchronous and changes will be eventually consistent.
 */

- (void)postFollow:(NSString *)screenName
	  successBlock:(void(^)(NSDictionary *user))successBlock
		errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	friendships/destroy
 Returns Users (1: the unfollowed user)
 
 Allows the authenticating user to unfollow the user specified in the ID parameter.
 
 Returns the unfollowed user in the requested format when successful. Returns a string describing the failure condition when unsuccessful.
 
 Actions taken in this method are asynchronous and changes will be eventually consistent.
 */

- (void)postUnfollow:(NSString *)screenName
		successBlock:(void(^)(NSDictionary *user))successBlock
		  errorBlock:(void(^)(NSError *error))errorBlock;

//	POST	friendships/update
//	Returns ?
- (void)postUpdateNotifications:(BOOL)notify
				  forScreenName:(NSString *)screenName
				   successBlock:(void(^)(NSDictionary *relationship))successBlock
					 errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    friendships/show

 Returns detailed information about the relationship between two arbitrary users.
 */

/*
 GET    friends/list
 
 Returns a cursored collection of user objects for every user the specified user is following (otherwise known as their "friends").
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 */

- (void)getFriendsForScreenName:(NSString *)screenName
				   successBlock:(void(^)(NSArray *friends))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    followers/list

 Returns a cursored collection of user objects for users following the specified user.
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 */

- (void)getFollowersForScreenName:(NSString *)screenName
					 successBlock:(void(^)(NSArray *followers))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Users

/*
 GET    account/settings

 Returns settings (including current trend, geo and sleep time information) for the authenticating user.
 */
 
/*
 GET	account/verify_credentials
 Returns Users (1: the user)
 
 Returns an HTTP 200 OK response code and a representation of the requesting user if authentication was successful; returns a 401 status code and an error message if not. Use this method to test if supplied user credentials are valid.
 */

- (void)getAccountVerifyCredentialsSkipStatus:(BOOL)skipStatus
                                 successBlock:(void(^)(NSDictionary *myInfo))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	account/settings

 Updates the authenticating user's settings.
 */

/*
 POST	account/update_delivery_device

 Sets which device Twitter delivers updates to for the authenticating user. Sending none as the device parameter will disable SMS updates.
 */

/*
 POST	account/update_profile
 Returns Users (1: the user)
 
 Sets values that users are able to set under the "Account" tab of their settings page. Only the parameters specified will be updated.
 */

- (void)postUpdateProfile:(NSDictionary *)profileData
			 successBlock:(void(^)(NSDictionary *myInfo))successBlock
			   errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	account/update_profile_background_image

 Updates the authenticating user's profile background image. This method can also be used to enable or disable the profile background image. Although each parameter is marked as optional, at least one of image, tile or use must be provided when making this request.
 */

/*
 POST	account/update_profile_colors

 Sets one or more hex values that control the color scheme of the authenticating user's profile page on twitter.com. Each parameter's value must be a valid hexidecimal value, and may be either three or six characters (ex: #fff or #ffffff).
 */

/*
 POST	account/update_profile_image
 Returns Users (1: the user)
 
 Updates the authenticating user's profile image. Note that this method expects raw multipart data, not a URL to an image.
 
 This method asynchronously processes the uploaded file before updating the user's profile image URL. You can either update your local cache the next time you request the user's information, or, at least 5 seconds after uploading the image, ask for the updated URL using GET users/show.
 */

#if TARGET_OS_IPHONE
- (void)postUpdateProfileImage:(UIImage *)newImage
#else
- (void)postUpdateProfileImage:(NSImage *)newImage
#endif
				  successBlock:(void(^)(NSDictionary *myInfo))successBlock
					errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    blocks/list

 Returns a collection of user objects that the authenticating user is blocking. Important On October 15, 2012 this method will become cursored by default, altering the default response format. See Using cursors to navigate collections for more details on how cursoring works.
 */

/*
 GET    blocks/ids

 Returns an array of numeric user ids the authenticating user is blocking. Important On October 15, 2012 this method will become cursored by default, altering the default response format. See Using cursors to navigate collections for more details on how cursoring works.
 */

/*
 POST	blocks/create

 Blocks the specified user from following the authenticating user. In addition the blocked user will not show in the authenticating users mentions or timeline (unless retweeted by another user). If a follow or friend relationship exists it is destroyed.
 */

/*
 POST	blocks/destroy

 Un-blocks the user specified in the ID parameter for the authenticating user. Returns the un-blocked user in the requested format when successful. If relationships existed before the block was instated, they will not be restored.
 */

/*
 GET    users/lookup

 Returns fully-hydrated user objects for up to 100 users per request, as specified by comma-separated values passed to the user_id and/or screen_name parameters.
 
 This method is especially useful when used in conjunction with collections of user IDs returned from GET friends/ids and GET followers/ids.
 
 GET users/show is used to retrieve a single user object.
 */

/*
 GET    users/show

 Returns a variety of information about the user specified by the required user_id or screen_name parameter. The author's most recent Tweet will be returned inline when possible. GET users/lookup is used to retrieve a bulk collection of user objects.
 */

 //	Returns Users (1: detailed information for the user)
- (void)getUserInformationFor:(NSString *)screenName
				 successBlock:(void(^)(NSDictionary *user))successBlock
				   errorBlock:(void(^)(NSError *error))errorBlock;

- (void)profileImageFor:(NSString *)screenName
#if TARGET_OS_IPHONE
           successBlock:(void(^)(UIImage *image))successBlock
#else
           successBlock:(void(^)(NSImage *image))successBlock
#endif
             errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET		users/search

 Provides a simple, relevance-based search interface to public user accounts on Twitter. Try querying by topical interest, full name, company name, location, or other criteria. Exact match searches are not supported.
 
 Only the first 1,000 matching results are available.
 */

- (void)getUsersSearchQuery:(NSString *)query
               optionalPage:(NSString *)page
              optionalCount:(NSString *)count
            includeEntities:(BOOL)includeEntities
               successBlock:(void(^)(NSDictionary *users))successBlock
                 errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET		users/contributees

 Returns a collection of users that the specified user can "contribute" to.
 */

/*
 GET		users/contributors

 Returns a collection of users who can contribute to the specified account.
 */

/*
 POST    account/remove_profile_banner

 Removes the uploaded profile banner for the authenticating user. Returns HTTP 200 upon success.
 */

/*
 POST    account/update_profile_banner

 Uploads a profile banner on behalf of the authenticating user. For best results, upload an <5MB image that is exactly 1252px by 626px. Images will be resized for a number of display options. Users with an uploaded profile banner will have a profile_banner_url node in their Users objects. More information about sizing variations can be found in User Profile Images and Banners and GET users/profile_banner.
 
 Profile banner images are processed asynchronously. The profile_banner_url and its variant sizes will not necessary be available directly after upload.
 */

/*
 GET     users/profile_banner

 Returns a map of the available size variations of the specified user's profile banner. If the user has not uploaded a profile banner, a HTTP 404 will be served instead. This method can be used instead of string manipulation on the profile_banner_url returned in user objects as described in User Profile Images and Banners.
 */
 
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

/*
 GET    lists/list
 
 Returns all lists the authenticating or specified user subscribes to, including their own. The user is specified using the user_id or screen_name parameters. If no user is given, the authenticating user is used.
 
 This method used to be GET lists in version 1.0 of the API and has been renamed for consistency with other call.
 
 A maximum of 100 results will be returned by this call. Subscribed lists are returned first, followed by owned lists. This means that if a user subscribes to 90 lists and owns 20 lists, this method returns 90 subscriptions and 10 owned lists. The reverse method returns owned lists first, so with reverse=true, 20 owned lists and 80 subscriptions would be returned. If your goal is to obtain every list a user owns or subscribes to, use GET lists/ownerships and/or GET lists/subscriptions instead.
 */

- (void)getListsSubscribedByUsername:(NSString *)username
                            orUserID:(NSString *)userID
                             reverse:(BOOL)reverse
                        successBlock:(void(^)(NSArray *lists))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	lists/statuses
 
 Returns a timeline of tweets authored by members of the specified list. Retweets are included by default. Use the include_rts=false parameter to omit retweets. Embedded Timelines is a great way to embed list timelines on your website.
 */

- (void)getListsStatusesForListID:(NSString *)listID
                  optionalSinceID:(NSString *)sinceID
                    optionalMaxID:(NSString *)maxID
                    optionalCount:(NSString *)count
                  includeEntities:(BOOL)includeEntities
                  includeRetweets:(BOOL)includeRetweets
                     successBlock:(void(^)(NSArray *statuses))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getListsStatusesForSlug:(NSString *)slug
                ownerScreenName:(NSString *)ownerScreenName
                      orOwnerID:(NSString *)ownerID
                optionalSinceID:(NSString *)sinceID
                  optionalMaxID:(NSString *)maxID
                  optionalCount:(NSString *)count
                includeEntities:(BOOL)includeEntities
                includeRetweets:(BOOL)includeRetweets
                   successBlock:(void(^)(NSArray *statuses))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	lists/members/destroy
 
 Removes the specified member from the list. The authenticated user must be the list's owner to remove members from the list.
 */

- (void)postListsMembersDestroyForListID:(NSString *)listID
                            successBlock:(void(^)())successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListsMembersDestroyForSlug:(NSString *)slug
                        optionalUserID:(NSString *)userID
                    optionalScreenName:(NSString *)screenName
               optionalOwnerScreenName:(NSString *)ownerScreenName
                       optionalOwnerID:(NSString *)ownerID
                          successBlock:(void(^)())successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	lists/subscribers
 
 Returns the subscribers of the specified list. Private list subscribers will only be shown if the authenticated user owns the specified list.
 */

- (void)getListsSubscribersForSlug:(NSString *)slug
                   ownerScreenName:(NSString *)ownerScreenName
                         orOwnerID:(NSString *)ownerID
                    optionalCursor:(NSString *)cursor
                   includeEntities:(BOOL)includeEntities
                        skipStatus:(BOOL)skipStatus
                      successBlock:(void(^)())successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getListsSubscribersForListID:(NSString *)listID
                      optionalCursor:(NSString *)cursor
                     includeEntities:(BOOL)includeEntities
                          skipStatus:(BOOL)skipStatus
                        successBlock:(void(^)())successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	lists/subscribers/create
 
 Subscribes the authenticated user to the specified list.
 */

- (void)postListSubscribersCreateForListID:(NSString *)listID
                              successBlock:(void(^)())successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListSubscribersCreateForSlug:(NSString *)slug
                         ownerScreenName:(NSString *)ownerScreenName
                               orOwnerID:(NSString *)ownerID
                            successBlock:(void(^)())successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	lists/subscribers/show
 
 Check if the specified user is a subscriber of the specified list. Returns the user if they are subscriber.
 */

- (void)getListsSubscribersShowForListID:(NSString *)listID
                                  userID:(NSString *)userID
                            orScreenName:(NSString *)screenName
                         includeEntities:(BOOL)includeEntities
                              skipStatus:(BOOL)skipStatus
                            successBlock:(void(^)())successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getListsSubscribersShowForSlug:(NSString *)slug
                       ownerScreenName:(NSString *)ownerScreenName
                             orOwnerID:(NSString *)ownerID
                                userID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                       includeEntities:(BOOL)includeEntities
                            skipStatus:(BOOL)skipStatus
                          successBlock:(void(^)())successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	lists/subscribers/destroy
 
 Unsubscribes the authenticated user from the specified list.
 */

- (void)postListSubscribersDestroyForListID:(NSString *)listID
                               successBlock:(void(^)())successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListSubscribersDestroyForSlug:(NSString *)slug
                          ownerScreenName:(NSString *)ownerScreenName
                                orOwnerID:(NSString *)ownerID
                             successBlock:(void(^)())successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	lists/members/create_all
 
 Adds multiple members to a list, by specifying a comma-separated list of member ids or screen names. The authenticated user must own the list to be able to add members to it. Note that lists can't have more than 5,000 members, and you are limited to adding up to 100 members to a list at a time with this method.
 
 Please note that there can be issues with lists that rapidly remove and add memberships. Take care when using these methods such that you are not too rapidly switching between removals and adds on the same list.
 */

- (void)postListsMembersCreateAllForListID:(NSString *)listID
                                   userIDs:(NSArray *)userIDs // array of strings
                             orScreenNames:(NSArray *)screenNames // array of strings
                              successBlock:(void(^)())successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListsMembersCreateAllForSlug:(NSString *)slug
                         ownerScreenName:(NSString *)ownerScreenName
                               orOwnerID:(NSString *)ownerID
                                 userIDs:(NSArray *)userIDs // array of strings
                           orScreenNames:(NSArray *)screenNames // array of strings
                            successBlock:(void(^)())successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	lists/members/show
 
 Check if the specified user is a member of the specified list.
 */

- (void)getListsMembersShowForListID:(NSString *)listID
                              userID:(NSString *)userID
                          screenName:(NSString *)screenName
                     includeEntities:(BOOL)includeEntities
                          skipStatus:(BOOL)skipStatus
                        successBlock:(void(^)(NSDictionary *user))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getListsMembersShowForSlug:(NSString *)slug
                   ownerScreenName:(NSString *)ownerScreenName
                         orOwnerID:(NSString *)ownerID
                            userID:(NSString *)userID
                        screenName:(NSString *)screenName
                   includeEntities:(BOOL)includeEntities
                        skipStatus:(BOOL)skipStatus
                      successBlock:(void(^)(NSDictionary *user))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET		lists/members
 
 Returns the members of the specified list. Private list members will only be shown if the authenticated user owns the specified list.
 */

- (void)getListsMembersForListID:(NSString *)listID
                  optionalCursor:(NSString *)cursor
                 includeEntities:(BOOL)includeEntities
                      skipStatus:(BOOL)skipStatus
                    successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getListsMembersForSlug:(NSString *)slug
               ownerScreenName:(NSString *)screenName
                     orOwnerID:(NSString *)ownerID
                optionalCursor:(NSString *)cursor
               includeEntities:(BOOL)includeEntities
                    skipStatus:(BOOL)skipStatus
                  successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	lists/members/create
 
 Creates a new list for the authenticated user. Note that you can't create more than 20 lists per account.
 */

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

/*
 POST	lists/destroy
 
 Deletes the specified list. The authenticated user must own the list to be able to destroy it.
 */

- (void)postListsDestroyForListID:(NSString *)listID
                     successBlock:(void(^)())successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListsDestroyForSlug:(NSString *)slug
                ownerScreenName:(NSString *)ownerScreenName
                      orOwnerID:(NSString *)ownerID
                   successBlock:(void(^)())successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	lists/update
 Updates the specified list. The authenticated user must own the list to be able to update it.
 */

- (void)postListsUpdateForListID:(NSString *)listID
                    optionalName:(NSString *)name
                       isPrivate:(BOOL)isPrivate
             optionalDescription:(NSString *)description
                    successBlock:(void(^)())successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListsUpdateForSlug:(NSString *)slug
               ownerScreenName:(NSString *)ownerScreenName
                     orOwnerID:(NSString *)ownerID
                  optionalName:(NSString *)name
                     isPrivate:(BOOL)isPrivate
           optionalDescription:(NSString *)description
                  successBlock:(void(^)())successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	lists/create
 
 Creates a new list for the authenticated user. Note that you can't create more than 20 lists per account.
 */

- (void)postListsCreateWithName:(NSString *)name
                      isPrivate:(BOOL)isPrivate
            optionalDescription:(NSString *)description
                   successBlock:(void(^)(NSDictionary *list))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	lists/show
 
 Returns the specified list. Private lists will only be shown if the authenticated user owns the specified list.
 */

- (void)getListsShowListID:(NSString *)listID
              successBlock:(void(^)(NSDictionary *list))successBlock
                errorBlock:(void(^)(NSError *error))errorBlock;

- (void)getListsShowListSlug:(NSString *)slug
             ownerScreenName:(NSString *)ownerScreenName
                   orOwnerID:(NSString *)ownerID
                successBlock:(void(^)(NSDictionary *list))successBlock
                  errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	lists/subscriptions
 
 Obtain a collection of the lists the specified user is subscribed to, 20 lists per page by default. Does not include the user's own lists.
 */

- (void)getListsSubscriptionsForUserID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                         optionalCount:(NSString *)count
                        optionalCursor:(NSString *)cursor
                          successBlock:(void(^)(NSArray *lists, NSString *previousCursor, NSString *nextCursor))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	lists/members/destroy_all
 
 Removes multiple members from a list, by specifying a comma-separated list of member ids or screen names. The authenticated user must own the list to be able to remove members from it. Note that lists can't have more than 500 members, and you are limited to removing up to 100 members to a list at a time with this method.
 
 Please note that there can be issues with lists that rapidly remove and add memberships. Take care when using these methods such that you are not too rapidly switching between removals and adds on the same list.
 */

- (void)postListsMembersDestroyAllForListID:(NSString *)listID
                                    userIDs:(NSArray *)userIDs // array of strings
                              orScreenNames:(NSArray *)screenNames // array of strings
                               successBlock:(void(^)())successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postListsMembersDestroyAllForSlug:(NSString *)slug
                          ownerScreenName:(NSString *)ownerScreenName
                                orOwnerID:(NSString *)ownerID
                                  userIDs:(NSArray *)userIDs // array of strings
                            orScreenNames:(NSArray *)screenNames // array of strings
                             successBlock:(void(^)())successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET     lists/ownerships
 
 Returns the lists owned by the specified Twitter user. Private lists will only be shown if the authenticated user is also the owner of the lists.
 */

- (void)getListsOwnershipsForUserID:(NSString *)userID
                       orScreenName:(NSString *)screenName
                      optionalCount:(NSString *)count
                     optionalCursor:(NSString *)cursor
                       successBlock:(void(^)(NSArray *lists, NSString *previousCursor, NSString *nextCursor))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock;

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
