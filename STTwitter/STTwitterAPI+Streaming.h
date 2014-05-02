//
//  STTwitterAPI+Streaming.h
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (Streaming)

#pragma mark Streaming

/*
 POST	statuses/filter
 
 Returns public statuses that match one or more filter predicates. Multiple parameters may be specified which allows most clients to use a single connection to the Streaming API. Both GET and POST requests are supported, but GET requests with too many parameters may cause the request to be rejected for excessive URL length. Use a POST request to avoid long URLs.
 
 The track, follow, and locations fields should be considered to be combined with an OR operator. track=foo&follow=1234 returns Tweets matching "foo" OR created by user 1234.
 
 The default access level allows up to 400 track keywords, 5,000 follow userids and 25 0.1-360 degree location boxes. If you need elevated access to the Streaming API, you should explore our partner providers of Twitter data here: https://dev.twitter.com/programs/twitter-certified-products/products#Certified-Data-Products
 
 At least one predicate parameter (follow, locations, or track) must be specified.
 */

- (id)postStatusesFilterUserIDs:(NSArray *)userIDs
                keywordsToTrack:(NSArray *)keywordsToTrack
          locationBoundingBoxes:(NSArray *)locationBoundingBoxes
                      delimited:(NSNumber *)delimited
                  stallWarnings:(NSNumber *)stallWarnings
                  progressBlock:(void(^)(NSDictionary *tweet))progressBlock
              stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (id)postStatusesFilterKeyword:(NSString *)keyword
                  progressBlock:(void(^)(NSDictionary *tweet))progressBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    statuses/sample
 
 Returns a small random sample of all public statuses. The Tweets returned by the default access level are the same, so if two different clients connect to this endpoint, they will see the same Tweets.
 */

- (id)getStatusesSampleDelimited:(NSNumber *)delimited
                   stallWarnings:(NSNumber *)stallWarnings
                   progressBlock:(void(^)(id response))progressBlock
               stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    statuses/firehose
 
 This endpoint requires special permission to access.
 
 Returns all public statuses. Few applications require this level of access. Creative use of a combination of other resources and various access levels can satisfy nearly every application use case.
 */

- (id)getStatusesFirehoseWithCount:(NSString *)count
                         delimited:(NSNumber *)delimited
                     stallWarnings:(NSNumber *)stallWarnings
                     progressBlock:(void(^)(id response))progressBlock
                 stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    user
 
 Streams messages for a single user, as described in User streams https://dev.twitter.com/docs/streaming-apis/streams/user
 */

- (id)getUserStreamDelimited:(NSNumber *)delimited
               stallWarnings:(NSNumber *)stallWarnings
includeMessagesFromFollowedAccounts:(NSNumber *)includeMessagesFromFollowedAccounts
              includeReplies:(NSNumber *)includeReplies
             keywordsToTrack:(NSArray *)keywordsToTrack
       locationBoundingBoxes:(NSArray *)locationBoundingBoxes
               progressBlock:(void(^)(id response))progressBlock
           stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                  errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    site
 
 Streams messages for a set of users, as described in Site streams https://dev.twitter.com/docs/streaming-apis/streams/site
 */

- (id)getSiteStreamForUserIDs:(NSArray *)userIDs
                    delimited:(NSNumber *)delimited
                stallWarnings:(NSNumber *)stallWarnings
       restrictToUserMessages:(NSNumber *)restrictToUserMessages
               includeReplies:(NSNumber *)includeReplies
                progressBlock:(void(^)(id response))progressBlock
            stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                   errorBlock:(void(^)(NSError *error))errorBlock;

@end
