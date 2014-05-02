//
//  STTwitterAPI+DirectMessages.m
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+DirectMessages.h"

@implementation STTwitterAPI (DirectMessages)

#pragma mark Direct Messages

- (void)getDirectMessagesSinceID:(NSString *)sinceID
                           maxID:(NSString *)maxID
                           count:(NSString *)count
                 includeEntities:(NSNumber *)includeEntities
                      skipStatus:(NSNumber *)skipStatus
                    successBlock:(void(^)(NSArray *messages))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) [md setObject:sinceID forKey:@"since_id"];
    if(maxID) [md setObject:maxID forKey:@"max_id"];
    if(count) [md setObject:count forKey:@"count"];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"direct_messages.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// convenience
- (void)getDirectMessagesSinceID:(NSString *)sinceID
                           count:(NSUInteger)count
                    successBlock:(void(^)(NSArray *messages))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *countString = count > 0 ? [@(count) description] : nil;
    
    [self getDirectMessagesSinceID:sinceID
                             maxID:nil
                             count:countString
                   includeEntities:nil
                        skipStatus:nil
                      successBlock:^(NSArray *statuses) {
                          successBlock(statuses);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

- (void)getDirectMessagesSinceID:(NSString *)sinceID
                           maxID:(NSString *)maxID
                           count:(NSString *)count
                            page:(NSString *)page
                 includeEntities:(NSNumber *)includeEntities
                    successBlock:(void(^)(NSArray *messages))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) [md setObject:sinceID forKey:@"since_id"];
    if(maxID) [md setObject:maxID forKey:@"max_id"];
    if(count) [md setObject:count forKey:@"count"];
    if(page) [md setObject:page forKey:@"page"];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"direct_messages/sent.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getDirectMessagesShowWithID:(NSString *)messageID
                       successBlock:(void(^)(NSArray *messages))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{@"id" : messageID};
    
    [self getAPIResource:@"direct_messages/show.json" parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
    
}

- (void)postDestroyDirectMessageWithID:(NSString *)messageID
                       includeEntities:(NSNumber *)includeEntities
                          successBlock:(void(^)(NSDictionary *message))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = messageID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"direct_messages/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postDirectMessage:(NSString *)status
					   to:(NSString *)screenName
             successBlock:(void(^)(NSDictionary *message))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObject:status forKey:@"text"];
    [md setObject:screenName forKey:@"screen_name"];
    
    [self postAPIResource:@"direct_messages/new.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

@end
