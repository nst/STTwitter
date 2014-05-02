//
//  STTwitterAPI+Timelines.h
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (Timelines)

#pragma mark Timelines

/*
 GET	statuses/mentions_timeline
 Returns Tweets (*: mentions for the user)
 
 Returns the 20 most recent mentions (tweets containing a users's @screen_name) for the authenticating user.
 
 The timeline returned is the equivalent of the one seen when you view your mentions on twitter.com.
 
 This method can only return up to 800 tweets.
 */

- (void)getStatusesMentionTimelineWithCount:(NSString *)count
                                    sinceID:(NSString *)sinceID
                                      maxID:(NSString *)maxID
                                   trimUser:(NSNumber *)trimUser
                         contributorDetails:(NSNumber *)contributorDetails
                            includeEntities:(NSNumber *)includeEntities
                               successBlock:(void(^)(NSArray *statuses))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
- (void)getMentionsTimelineSinceID:(NSString *)sinceID
							 count:(NSUInteger)count
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
                              errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
- (void)getUserTimelineWithScreenName:(NSString *)screenName
                              sinceID:(NSString *)sinceID
                                maxID:(NSString *)maxID
								count:(NSUInteger)count
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
- (void)getUserTimelineWithScreenName:(NSString *)screenName
								count:(NSUInteger)count
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
- (void)getUserTimelineWithScreenName:(NSString *)screenName
                         successBlock:(void(^)(NSArray *statuses))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	statuses/home_timeline
 
 Returns Tweets (*: tweets from people the user follows)
 
 Returns a collection of the most recent Tweets and retweets posted by the authenticating user and the users they follow. The home timeline is central to how most users interact with the Twitter service.
 
 Up to 800 Tweets are obtainable on the home timeline. It is more volatile for users that follow many users or follow users who tweet frequently.
 */

- (void)getStatusesHomeTimelineWithCount:(NSString *)count
                                 sinceID:(NSString *)sinceID
                                   maxID:(NSString *)maxID
                                trimUser:(NSNumber *)trimUser
                          excludeReplies:(NSNumber *)excludeReplies
                      contributorDetails:(NSNumber *)contributorDetails
                         includeEntities:(NSNumber *)includeEntities
                            successBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
- (void)getHomeTimelineSinceID:(NSString *)sinceID
                         count:(NSUInteger)count
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    statuses/retweets_of_me
 
 Returns the most recent tweets authored by the authenticating user that have been retweeted by others. This timeline is a subset of the user's GET statuses/user_timeline. See Working with Timelines for instructions on traversing timelines.
 */

- (void)getStatusesRetweetsOfMeWithCount:(NSString *)count
                                 sinceID:(NSString *)sinceID
                                   maxID:(NSString *)maxID
                                trimUser:(NSNumber *)trimUser
                         includeEntities:(NSNumber *)includeEntities
                     includeUserEntities:(NSNumber *)includeUserEntities
                            successBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
- (void)getStatusesRetweetsOfMeWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                                     errorBlock:(void(^)(NSError *error))errorBlock;

@end
