//
//  STTwitterAPI+Tweets.m
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+Tweets.h"
#import "STHTTPRequest.h"
#import "STTwitterOAuth.h"

@implementation STTwitterAPI (Tweets)

#pragma mark Tweets

- (void)getStatusesRetweetsForID:(NSString *)statusID
                           count:(NSString *)count
                        trimUser:(NSNumber *)trimUser
                    successBlock:(void(^)(NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweets/%@.json", statusID];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    [self getAPIResource:resource parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getStatusesShowID:(NSString *)statusID
                 trimUser:(NSNumber *)trimUser
         includeMyRetweet:(NSNumber *)includeMyRetweet
          includeEntities:(NSNumber *)includeEntities
             successBlock:(void(^)(NSDictionary *status))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"id"] = statusID;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(includeMyRetweet) md[@"include_my_retweet"] = [includeMyRetweet boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"statuses/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postStatusesDestroy:(NSString *)statusID
                   trimUser:(NSNumber *)trimUser
               successBlock:(void(^)(NSDictionary *status))successBlock
                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSString *resource = [NSString stringWithFormat:@"statuses/destroy/%@.json", statusID];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = statusID;
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    [self postAPIResource:resource parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)existingStatusID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
                 placeID:(NSString *)placeID // wins over lat/lon
      displayCoordinates:(NSNumber *)displayCoordinates
                trimUser:(NSNumber *)trimUser
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    if(status == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterAPICannotPostEmptyStatus userInfo:@{NSLocalizedDescriptionKey : @"cannot post empty status"}];
        ST_BLOCK_SAFE_RUN(errorBlock,error);
        return;
    }
    
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:status forKey:@"status"];
    
    if(existingStatusID) {
        md[@"in_reply_to_status_id"] = existingStatusID;
    }
    
    if(placeID) {
        md[@"place_id"] = placeID;
        md[@"display_coordinates"] = @"true";
    } else if(latitude && longitude) {
        md[@"lat"] = latitude;
        md[@"lon"] = longitude;
        md[@"display_coordinates"] = @"true";
    }
    
    [self postAPIResource:@"statuses/update.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postStatusUpdate:(NSString *)status
          mediaDataArray:(NSArray *)mediaDataArray // only one media is currently supported, help/configuration.json returns "max_media_per_upload" = 1
       possiblySensitive:(NSNumber *)possiblySensitive
       inReplyToStatusID:(NSString *)inReplyToStatusID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
                 placeID:(NSString *)placeID
      displayCoordinates:(NSNumber *)displayCoordinates
     uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(status);
    NSAssert([mediaDataArray count] > 0, @"media data array must not be empty");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"status"] = status;
    if(possiblySensitive) md[@"possibly_sensitive"] = [possiblySensitive boolValue] ? @"1" : @"0";
    if(displayCoordinates) md[@"display_coordinates"] = [displayCoordinates boolValue] ? @"1" : @"0";
    if(inReplyToStatusID) md[@"in_reply_to_status_id"] = inReplyToStatusID;
    if(latitude) md[@"lat"] = latitude;
    if(longitude) md[@"long"] = longitude;
    if(placeID) md[@"place_id"] = placeID;
    md[@"media[]"] = [mediaDataArray objectAtIndex:0];
    md[kSTPOSTDataKey] = @"media[]";
    
    [self postResource:@"statuses/update_with_media.json"
         baseURLString:kBaseURLStringAPI
            parameters:md
   uploadProgressBlock:uploadProgressBlock
 downloadProgressBlock:nil
          successBlock:^(NSDictionary *rateLimits, id response) {
              successBlock(response);
          } errorBlock:errorBlock];
}

- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)existingStatusID
                mediaURL:(NSURL *)mediaURL
                 placeID:(NSString *)placeID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
     uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSData *data = [NSData dataWithContentsOfURL:mediaURL];
    
    if(data == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterAPIMediaDataIsEmpty userInfo:@{NSLocalizedDescriptionKey : @"data is nil"}];
        errorBlock(error);
        return;
    }
    
    [self postStatusUpdate:status
            mediaDataArray:@[data]
         possiblySensitive:nil
         inReplyToStatusID:existingStatusID
                  latitude:latitude
                 longitude:longitude
                   placeID:placeID
        displayCoordinates:@(YES)
       uploadProgressBlock:uploadProgressBlock
              successBlock:^(NSDictionary *status) {
                  successBlock(status);
              } errorBlock:^(NSError *error) {
                  errorBlock(error);
              }];
}

// GET statuses/oembed

- (void)getStatusesOEmbedForStatusID:(NSString *)statusID
                           urlString:(NSString *)urlString
                            maxWidth:(NSString *)maxWidth
                           hideMedia:(NSNumber *)hideMedia
                          hideThread:(NSNumber *)hideThread
                          omitScript:(NSNumber *)omitScript
                               align:(NSString *)align // 'left', 'right', 'center' or 'none' (default)
                             related:(NSString *)related // eg. twitterapi,twittermedia,twitter
                                lang:(NSString *)lang
                        successBlock:(void(^)(NSDictionary *status))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    NSParameterAssert(urlString);
    
#if DEBUG
    if(align) {
        NSArray *validValues = @[@"left", @"right", @"center", @"none"];
        NSAssert([validValues containsObject: align], @"");
    }
#endif
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = statusID;
    md[@"url"] = urlString;
    
    if(maxWidth) md[@"maxwidth"] = maxWidth;
    
    if(hideMedia) md[@"hide_media"] = [hideMedia boolValue] ? @"1" : @"0";
    if(hideThread) md[@"hide_thread"] = [hideThread boolValue] ? @"1" : @"0";
    if(omitScript) md[@"omit_script"] = [omitScript boolValue] ? @"1" : @"0";
    
    if(align) md[@"align"] = align;
    if(related) md[@"related"] = related;
    if(lang) md[@"lang"] = lang;
    
    [self getAPIResource:@"statuses/oembed.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	statuses/retweet/:id
- (void)postStatusRetweetWithID:(NSString *)statusID
                       trimUser:(NSNumber *)trimUser
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweet/%@.json", statusID];
    
    [self postAPIResource:resource parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postStatusRetweetWithID:(NSString *)statusID
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self postStatusRetweetWithID:statusID
                         trimUser:nil
                     successBlock:^(NSDictionary *status) {
                         successBlock(status);
                     } errorBlock:^(NSError *error) {
                         errorBlock(error);
                     }];
}

- (void)getStatusesRetweetersIDsForStatusID:(NSString *)statusID
                                     cursor:(NSString *)cursor
                               successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(statusID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"id"] = statusID;
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    
    [self getAPIResource:@"statuses/retweeters/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        NSArray *ids = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            previousCursor = response[@"previous_cursor_str"];
            nextCursor = response[@"next_cursor_str"];
            ids = response[@"ids"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

/*
 GET statuses/lookup
 
 Returns fully-hydrated tweet objects for up to 100 tweets per request, as specified by comma-separated values passed to the id parameter. This method is especially useful to get the details (hydrate) a collection of Tweet IDs. GET statuses/show/:id is used to retrieve a single tweet object.
 */

- (void)getStatusesLookupTweetIDs:(NSArray *)tweetIDs
                  includeEntities:(NSNumber *)includeEntities
                         trimUser:(NSNumber *)trimUser
                              map:(NSNumber *)map
					 successBlock:(void(^)(NSArray *tweets))successBlock
					   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSParameterAssert(tweetIDs);
    NSAssert(([tweetIDs isKindOfClass:[NSArray class]]), @"tweetIDs must be an array");
    
    md[@"id"] = [tweetIDs componentsJoinedByString:@","];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"true" : @"false";
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(map) md[@"map"] = [map boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"statuses/lookup.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

@end
