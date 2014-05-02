//
//  STTwitterAPI+FriendsAndFollowers.m
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+FriendsAndFollowers.h"
#import "STHTTPRequest.h"

@implementation STTwitterAPI (FriendsAndFollowers)

#pragma mark Friends & Followers

- (void)getFriendshipNoRetweetsIDsWithSuccessBlock:(void(^)(NSArray *ids))successBlock
                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_ids"] = @"1";
    
    [self getAPIResource:@"friendships/no_retweets/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendsIDsForUserID:(NSString *)userID
                  orScreenName:(NSString *)screenName
                        cursor:(NSString *)cursor
                         count:(NSString *)count
                  successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    
    if(count) md[@"count"] = count;
    
    [self getAPIResource:@"friends/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *ids = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            ids = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendsIDsForScreenName:(NSString *)screenName
                      successBlock:(void(^)(NSArray *friends))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getFriendsIDsForUserID:nil
                    orScreenName:screenName
                          cursor:nil
                           count:nil
                    successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                        successBlock(ids);
                    } errorBlock:^(NSError *error) {
                        errorBlock(error);
                    }];
}

- (void)getFollowersIDsForUserID:(NSString *)userID
                    orScreenName:(NSString *)screenName
                          cursor:(NSString *)cursor
                           count:(NSString *)count
                    successBlock:(void(^)(NSArray *followersIDs, NSString *previousCursor, NSString *nextCursor))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    if(count) md[@"count"] = count;
    
    [self getAPIResource:@"followers/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *followersIDs = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            followersIDs = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(followersIDs, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFollowersIDsForScreenName:(NSString *)screenName
                        successBlock:(void(^)(NSArray *followers))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getFollowersIDsForUserID:nil
                      orScreenName:screenName
                            cursor:nil
                             count:nil
                      successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                          successBlock(ids);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

- (void)getFriendshipsLookupForScreenNames:(NSArray *)screenNames
                                 orUserIDs:(NSArray *)userIDs
                              successBlock:(void(^)(NSArray *users))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenNames || userIDs), @"missing screen names or user IDs");
    
    NSString *commaSeparatedScreenNames = [screenNames componentsJoinedByString:@","];
    NSString *commaSeparatedUserIDs = [userIDs componentsJoinedByString:@","];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(commaSeparatedScreenNames) md[@"screen_name"] = commaSeparatedScreenNames;
    if(commaSeparatedUserIDs) md[@"user_id"] = commaSeparatedUserIDs;
    
    [self getAPIResource:@"friendships/lookup.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendshipIncomingWithCursor:(NSString *)cursor
                           successBlock:(void(^)(NSArray *IDs, NSString *previousCursor, NSString *nextCursor))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    
    [self getAPIResource:@"friendships/incoming.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *ids = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            ids = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendshipOutgoingWithCursor:(NSString *)cursor
                           successBlock:(void(^)(NSArray *IDs, NSString *previousCursor, NSString *nextCursor))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(cursor) md[@"cursor"] = cursor;
    md[@"stringify_ids"] = @"1";
    
    [self getAPIResource:@"friendships/outgoing.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *ids = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            ids = [response valueForKey:@"ids"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(ids, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFriendshipsCreateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                              successBlock:(void(^)(NSDictionary *befriendedUser))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    [self postAPIResource:@"friendships/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFollow:(NSString *)screenName
      successBlock:(void(^)(NSDictionary *user))successBlock
        errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self postFriendshipsCreateForScreenName:screenName orUserID:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFriendshipsDestroyScreenName:(NSString *)screenName
                                orUserID:(NSString *)userID
                            successBlock:(void(^)(NSDictionary *unfollowedUser))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    
    [self postAPIResource:@"friendships/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postUnfollow:(NSString *)screenName
        successBlock:(void(^)(NSDictionary *user))successBlock
          errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self postFriendshipsDestroyScreenName:screenName orUserID:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                 enableDeviceNotifications:(NSNumber *)enableDeviceNotifications
                            enableRetweets:(NSNumber *)enableRetweets
                              successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(enableDeviceNotifications) md[@"device"] = [enableDeviceNotifications boolValue] ? @"1" : @"0";
    if(enableRetweets) md[@"retweets"] = [enableRetweets boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"friendships/update.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                 enableDeviceNotifications:(BOOL)enableDeviceNotifications
                              successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    [self postFriendshipsUpdateForScreenName:screenName
                                    orUserID:userID
                   enableDeviceNotifications:@(enableDeviceNotifications)
                              enableRetweets:nil
                                successBlock:^(NSDictionary *user) {
                                    successBlock(user);
                                } errorBlock:^(NSError *error) {
                                    errorBlock(error);
                                }];
}

- (void)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                  orUserID:(NSString *)userID
                            enableRetweets:(BOOL)enableRetweets
                              successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    NSAssert((screenName || userID), @"screenName or userID is missing");
    
    [self postFriendshipsUpdateForScreenName:screenName
                                    orUserID:userID
                   enableDeviceNotifications:nil
                              enableRetweets:@(enableRetweets)
                                successBlock:^(NSDictionary *user) {
                                    successBlock(user);
                                } errorBlock:^(NSError *error) {
                                    errorBlock(error);
                                }];
}

- (void)getFriendshipShowForSourceID:(NSString *)sourceID
                  orSourceScreenName:(NSString *)sourceScreenName
                            targetID:(NSString *)targetID
                  orTargetScreenName:(NSString *)targetScreenName
                        successBlock:(void(^)(id relationship))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((sourceID || sourceScreenName), @"sourceID or sourceScreenName is missing");
    NSAssert((targetID || targetScreenName), @"targetID or targetScreenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sourceID) md[@"source_id"] = sourceID;
    if(sourceScreenName) md[@"source_screen_name"] = sourceScreenName;
    if(targetID) md[@"target_id"] = targetID;
    if(targetScreenName) md[@"target_screen_name"] = targetScreenName;
    
    [self getAPIResource:@"friendships/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendsListForUserID:(NSString *)userID
                   orScreenName:(NSString *)screenName
                         cursor:(NSString *)cursor
                          count:(NSString *)count
                     skipStatus:(NSNumber *)skipStatus
            includeUserEntities:(NSNumber *)includeUserEntities
                   successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(count) md[@"count"] = count;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"friends/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            users = [response valueForKey:@"users"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getFriendsForScreenName:(NSString *)screenName
                   successBlock:(void(^)(NSArray *friends))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getFriendsListForUserID:nil
                     orScreenName:screenName
                           cursor:nil
                            count:nil
                       skipStatus:NO
              includeUserEntities:@(YES)
                     successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                         successBlock(users);
                     } errorBlock:^(NSError *error) {
                         errorBlock(error);
                     }];
}

- (void)getFollowersListForUserID:(NSString *)userID
                     orScreenName:(NSString *)screenName
                           cursor:(NSString *)cursor
                       skipStatus:(NSNumber *)skipStatus
              includeUserEntities:(NSNumber *)includeUserEntities
                     successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"followers/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = nil;
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            users = [response valueForKey:@"users"];
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
        }
        
        successBlock(users, previousCursor, nextCursor);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// convenience
- (void)getFollowersForScreenName:(NSString *)screenName
                     successBlock:(void(^)(NSArray *followers))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getFollowersListForUserID:nil
                       orScreenName:screenName
                             cursor:nil
                         skipStatus:nil
                includeUserEntities:nil
                       successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                           successBlock(users);
                       } errorBlock:^(NSError *error) {
                           errorBlock(error);
                       }];
}



@end
