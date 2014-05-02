//
//  STTwitterAPI+Streaming.m
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+Streaming.h"

@implementation STTwitterAPI (Streaming)

#pragma mark Streaming

+ (NSDictionary *)stallWarningDictionaryFromJSON:(NSString *)json {
    if([json isKindOfClass:[NSDictionary class]]) return nil;
    return [json valueForKey:@"warning"];
}

// POST statuses/filter

- (id)postStatusesFilterUserIDs:(NSArray *)userIDs
                keywordsToTrack:(NSArray *)keywordsToTrack
          locationBoundingBoxes:(NSArray *)locationBoundingBoxes
                      delimited:(NSNumber *)delimited
                  stallWarnings:(NSNumber *)stallWarnings
                  progressBlock:(void(^)(NSDictionary *tweet))progressBlock
              stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *follow = [userIDs componentsJoinedByString:@","];
    NSString *keywords = [keywordsToTrack componentsJoinedByString:@","];
    NSString *locations = [locationBoundingBoxes componentsJoinedByString:@","];
    
    NSAssert(([follow length] || [keywords length] || [locations length]), @"At least one predicate parameter (follow, locations, or track) must be specified.");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(delimited) md[@"delimited"] = [delimited boolValue] ? @"1" : @"0";
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    
    if([follow length]) md[@"follow"] = follow;
    if([keywords length]) md[@"track"] = keywords;
    if([locations length]) md[@"locations"] = locations;
    
    return [self postResource:@"statuses/filter.json"
                baseURLString:kBaseURLStringStream
                   parameters:md
          uploadProgressBlock:nil
        downloadProgressBlock:^(id json) {
            
            NSDictionary *stallWarning = [[self class] stallWarningDictionaryFromJSON:json];
            if(stallWarning && stallWarningBlock) {
                stallWarningBlock([stallWarning valueForKey:@"code"],
                                  [stallWarning valueForKey:@"message"],
                                  [[stallWarning valueForKey:@"percent_full"] integerValue]);
            } else {
                progressBlock(json);
            }
            
        } successBlock:^(NSDictionary *rateLimits, id response) {
            progressBlock(response);
        } errorBlock:^(NSError *error) {
            errorBlock(error);
        }];
}

// convenience
- (id)postStatusesFilterKeyword:(NSString *)keyword
                  progressBlock:(void(^)(NSDictionary *tweet))progressBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(keyword);
    
    return [self postStatusesFilterUserIDs:nil
                           keywordsToTrack:@[keyword]
                     locationBoundingBoxes:nil
                                 delimited:nil
                             stallWarnings:nil
                             progressBlock:progressBlock
                         stallWarningBlock:nil
                                errorBlock:errorBlock];
}

// GET statuses/sample
- (id)getStatusesSampleDelimited:(NSNumber *)delimited
                   stallWarnings:(NSNumber *)stallWarnings
                   progressBlock:(void(^)(id response))progressBlock
               stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(delimited) md[@"delimited"] = [delimited boolValue] ? @"1" : @"0";
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    
    return [self getResource:@"statuses/sample.json"
               baseURLString:kBaseURLStringStream
                  parameters:md
       downloadProgressBlock:^(id json) {
           
           NSDictionary *stallWarning = [[self class] stallWarningDictionaryFromJSON:json];
           if(stallWarning && stallWarningBlock) {
               stallWarningBlock([stallWarning valueForKey:@"code"],
                                 [stallWarning valueForKey:@"message"],
                                 [[stallWarning valueForKey:@"percent_full"] integerValue]);
           } else {
               progressBlock(json);
           }
           
       } successBlock:^(NSDictionary *rateLimits, id json) {
           // reaching successBlock for a stream request is an error
           errorBlock(json);
       } errorBlock:^(NSError *error) {
           errorBlock(error);
       }];
}

// GET statuses/firehose
- (id)getStatusesFirehoseWithCount:(NSString *)count
                         delimited:(NSNumber *)delimited
                     stallWarnings:(NSNumber *)stallWarnings
                     progressBlock:(void(^)(id response))progressBlock
                 stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(count) md[@"count"] = count;
    if(delimited) md[@"delimited"] = [delimited boolValue] ? @"1" : @"0";
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    
    return [self getResource:@"statuses/firehose.json"
               baseURLString:kBaseURLStringStream
                  parameters:md
       downloadProgressBlock:^(id json) {
           
           NSDictionary *stallWarning = [[self class] stallWarningDictionaryFromJSON:json];
           if(stallWarning && stallWarningBlock) {
               stallWarningBlock([stallWarning valueForKey:@"code"],
                                 [stallWarning valueForKey:@"message"],
                                 [[stallWarning valueForKey:@"percent_full"] integerValue]);
           } else {
               progressBlock(json);
           }
           
       } successBlock:^(NSDictionary *rateLimits, id json) {
           progressBlock(json);
       } errorBlock:^(NSError *error) {
           errorBlock(error);
       }];
}

// GET user
- (id)getUserStreamDelimited:(NSNumber *)delimited
               stallWarnings:(NSNumber *)stallWarnings
includeMessagesFromFollowedAccounts:(NSNumber *)includeMessagesFromFollowedAccounts
              includeReplies:(NSNumber *)includeReplies
             keywordsToTrack:(NSArray *)keywordsToTrack
       locationBoundingBoxes:(NSArray *)locationBoundingBoxes
               progressBlock:(void(^)(id response))progressBlock
           stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_friend_ids"] = @"1";
    if(delimited) md[@"delimited"] = [delimited boolValue] ? @"1" : @"0";
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    if(includeMessagesFromFollowedAccounts) md[@"with"] = @"user"; // default is 'followings'
    if(includeReplies && [includeReplies boolValue]) md[@"replies"] = @"all";
    
    NSString *keywords = [keywordsToTrack componentsJoinedByString:@","];
    NSString *locations = [locationBoundingBoxes componentsJoinedByString:@","];
    
    if([keywords length]) md[@"keywords"] = keywords;
    if([locations length]) md[@"locations"] = locations;
    
    return [self getResource:@"user.json"
               baseURLString:kBaseURLStringUserStream
                  parameters:md
       downloadProgressBlock:^(id json) {
           
           NSDictionary *stallWarning = [[self class] stallWarningDictionaryFromJSON:json];
           if(stallWarning && stallWarningBlock) {
               stallWarningBlock([stallWarning valueForKey:@"code"],
                                 [stallWarning valueForKey:@"message"],
                                 [[stallWarning valueForKey:@"percent_full"] integerValue]);
           } else {
               progressBlock(json);
           }
           
       } successBlock:^(NSDictionary *rateLimits, id json) {
           progressBlock(json);
       } errorBlock:^(NSError *error) {
           errorBlock(error);
       }];
}

// GET site
- (id)getSiteStreamForUserIDs:(NSArray *)userIDs
                    delimited:(NSNumber *)delimited
                stallWarnings:(NSNumber *)stallWarnings
       restrictToUserMessages:(NSNumber *)restrictToUserMessages
               includeReplies:(NSNumber *)includeReplies
                progressBlock:(void(^)(id response))progressBlock
            stallWarningBlock:(void(^)(NSString *code, NSString *message, NSUInteger percentFull))stallWarningBlock
                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_friend_ids"] = @"1";
    if(delimited) md[@"delimited"] = [delimited boolValue] ? @"1" : @"0";
    if(stallWarnings) md[@"stall_warnings"] = [stallWarnings boolValue] ? @"1" : @"0";
    if(restrictToUserMessages) md[@"with"] = @"user"; // default is 'followings'
    if(includeReplies && [includeReplies boolValue]) md[@"replies"] = @"all";
    
    NSString *follow = [userIDs componentsJoinedByString:@","];
    if([follow length]) md[@"follow"] = follow;
    
    return [self getResource:@"site.json"
               baseURLString:kBaseURLStringSiteStream
                  parameters:md
       downloadProgressBlock:^(id json) {
           
           NSDictionary *stallWarning = [[self class] stallWarningDictionaryFromJSON:json];
           if(stallWarning && stallWarningBlock) {
               stallWarningBlock([stallWarning valueForKey:@"code"],
                                 [stallWarning valueForKey:@"message"],
                                 [[stallWarning valueForKey:@"percent_full"] integerValue]);
           } else {
               progressBlock(json);
           }
           
       } successBlock:^(NSDictionary *rateLimits, id json) {
           progressBlock(json);
       } errorBlock:^(NSError *error) {
           errorBlock(error);
       }];
}

@end
