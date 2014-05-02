//
//  STTwitterAPI+Timelines.m
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+Timelines.h"

@implementation STTwitterAPI (Timelines)

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
    
    [self getAPIResource:@"statuses/mentions_timeline.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
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
    
    [self getAPIResource:@"statuses/user_timeline.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getStatusesHomeTimelineWithCount:(NSString *)count
                                 sinceID:(NSString *)sinceID
                                   maxID:(NSString *)maxID
                                trimUser:(NSNumber *)trimUser
                          excludeReplies:(NSNumber *)excludeReplies
                      contributorDetails:(NSNumber *)contributorDetails
                         includeEntities:(NSNumber *)includeEntities
                            successBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(excludeReplies) md[@"exclude_replies"] = [excludeReplies boolValue] ? @"1" : @"0";
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"statuses/home_timeline.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
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
 
 [self getAPIResource:timeline parameters:mparams
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
                                     count:(count == NSNotFound ? nil : [@(count) description])
                                     maxID:maxID
                                  trimUser:nil
                            excludeReplies:nil
                        contributorDetails:nil
                           includeRetweets:nil
                              successBlock:^(NSArray *statuses) {
                                  ST_BLOCK_SAFE_RUN(successBlock,statuses);
                              } errorBlock:^(NSError *error) {
                                  ST_BLOCK_SAFE_RUN(errorBlock,error);
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
    
    [self getUserTimelineWithScreenName:screenName count:20 successBlock:successBlock errorBlock:errorBlock];
}

- (void)getHomeTimelineSinceID:(NSString *)sinceID
                         count:(NSUInteger)count
                  successBlock:(void(^)(NSArray *statuses))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *countString = count > 0 ? [@(count) description] : nil;
    
    [self getStatusesHomeTimelineWithCount:countString
                                   sinceID:sinceID
                                     maxID:nil
                                  trimUser:nil
                            excludeReplies:nil
                        contributorDetails:nil
                           includeEntities:nil
                              successBlock:^(NSArray *statuses) {
                                  ST_BLOCK_SAFE_RUN(successBlock,statuses);
                              } errorBlock:^(NSError *error) {
                                  ST_BLOCK_SAFE_RUN(errorBlock,error);
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
    
    [self getAPIResource:@"statuses/retweets_of_me.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
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
                                  ST_BLOCK_SAFE_RUN(successBlock,statuses);
                              } errorBlock:^(NSError *error) {
                                  ST_BLOCK_SAFE_RUN(errorBlock,error);
                              }];
}


@end
