//
//  STTwitterAPI+FriendsAndFollowers.h
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (FriendsAndFollowers)

#pragma mark Friends & Followers

/*
 GET    friendships/no_retweets/ids
 
 Returns a collection of user_ids that the currently authenticated user does not want to receive retweets from. Use POST friendships/update to set the "no retweets" status for a given user account on behalf of the current user.
 */

- (void)getFriendshipNoRetweetsIDsWithSuccessBlock:(void(^)(NSArray *ids))successBlock
                                        errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    friends/ids
 Returns Users (*: user IDs for followees)
 
 Returns a cursored collection of user IDs for every user the specified user is following (otherwise known as their "friends").
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 5,000 user IDs and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 
 This method is especially powerful when used in conjunction with GET users/lookup, a method that allows you to convert user IDs into full user objects in bulk.
 */

- (void)getFriendsIDsForUserID:(NSString *)userID
                  orScreenName:(NSString *)screenName
                        cursor:(NSString *)cursor
                         count:(NSString *)count
                  successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getFriendsIDsForScreenName:(NSString *)screenName
				      successBlock:(void(^)(NSArray *friends))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    followers/ids
 
 Returns a cursored collection of user IDs for every user following the specified user.
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 5,000 user IDs and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 
 This method is especially powerful when used in conjunction with GET users/lookup, a method that allows you to convert user IDs into full user objects in bulk.
 */

- (void)getFollowersIDsForUserID:(NSString *)userID
                    orScreenName:(NSString *)screenName
                          cursor:(NSString *)cursor
                           count:(NSString *)count
                    successBlock:(void(^)(NSArray *followersIDs, NSString *previousCursor, NSString *nextCursor))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getFollowersIDsForScreenName:(NSString *)screenName
                        successBlock:(void(^)(NSArray *followers))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    friendships/lookup
 
 Returns the relationships of the authenticating user to the comma-separated list of up to 100 screen_names or user_ids provided. Values for connections can be: following, following_requested, followed_by, none.
 */

- (void)getFriendshipsLookupForScreenNames:(NSArray *)screenNames
                                 orUserIDs:(NSArray *)userIDs
                              successBlock:(void(^)(NSArray *users))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    friendships/incoming
 
 Returns a collection of numeric IDs for every user who has a pending request to follow the authenticating user.
 */

- (void)getFriendshipIncomingWithCursor:(NSString *)cursor
                           successBlock:(void(^)(NSArray *IDs, NSString *previousCursor, NSString *nextCursor))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    friendships/outgoing
 
 Returns a collection of numeric IDs for every protected user for whom the authenticating user has a pending follow request.
 */

- (void)getFriendshipOutgoingWithCursor:(NSString *)cursor
                           successBlock:(void(^)(NSArray *IDs, NSString *previousCursor, NSString *nextCursor))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST   friendships/create
 
 Allows the authenticating users to follow the user specified in the ID parameter.
 
 Returns the befriended user in the requested format when successful. Returns a string describing the failure condition when unsuccessful. If you are already friends with the user a HTTP 403 may be returned, though for performance reasons you may get a 200 OK message even if the friendship already exists.
 
 Actions taken in this method are asynchronous and changes will be eventually consistent.
 */

- (void)postFriendshipsCreateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                              successBlock:(void(^)(NSDictionary *befriendedUser))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)postFollow:(NSString *)screenName
	  successBlock:(void(^)(NSDictionary *user))successBlock
		errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	friendships/destroy
 
 Allows the authenticating user to unfollow the user specified in the ID parameter.
 
 Returns the unfollowed user in the requested format when successful. Returns a string describing the failure condition when unsuccessful.
 
 Actions taken in this method are asynchronous and changes will be eventually consistent.
 */

- (void)postFriendshipsDestroyScreenName:(NSString *)screenName
                                orUserID:(NSString *)userID
                            successBlock:(void(^)(NSDictionary *unfollowedUser))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)postUnfollow:(NSString *)screenName
		successBlock:(void(^)(NSDictionary *user))successBlock
		  errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	friendships/update
 
 Allows one to enable or disable retweets and device notifications from the specified user.
 */

- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                 enableDeviceNotifications:(NSNumber *)enableDeviceNotifications
                            enableRetweets:(NSNumber *)enableRetweets
                              successBlock:(void(^)(NSDictionary *user))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                 enableDeviceNotifications:(BOOL)enableDeviceNotifications
                              successBlock:(void(^)(NSDictionary *user))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                            enableRetweets:(BOOL)enableRetweets
                              successBlock:(void(^)(NSDictionary *user))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    friendships/show
 
 Returns detailed information about the relationship between two arbitrary users.
 */

- (void)getFriendshipShowForSourceID:(NSString *)sourceID
                  orSourceScreenName:(NSString *)sourceScreenName
                            targetID:(NSString *)targetID
                  orTargetScreenName:(NSString *)targetScreenName
                        successBlock:(void(^)(id relationship))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    friends/list
 
 Returns a cursored collection of user objects for every user the specified user is following (otherwise known as their "friends").
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 */

- (void)getFriendsListForUserID:(NSString *)userID
                   orScreenName:(NSString *)screenName
                         cursor:(NSString *)cursor
                          count:(NSString *)count
                     skipStatus:(NSNumber *)skipStatus
            includeUserEntities:(NSNumber *)includeUserEntities
                   successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getFriendsForScreenName:(NSString *)screenName
				   successBlock:(void(^)(NSArray *friends))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    followers/list
 
 Returns a cursored collection of user objects for users following the specified user.
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 */

- (void)getFollowersListForUserID:(NSString *)userID
                     orScreenName:(NSString *)screenName
                           cursor:(NSString *)cursor
                       skipStatus:(NSNumber *)skipStatus
              includeUserEntities:(NSNumber *)includeUserEntities
                     successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getFollowersForScreenName:(NSString *)screenName
					 successBlock:(void(^)(NSArray *followers))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock;


@end
