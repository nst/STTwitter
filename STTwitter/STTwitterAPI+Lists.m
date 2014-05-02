//
//  STTwitterAPI+Lists.m
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+Lists.h"
#import "STHTTPRequest.h"

@implementation STTwitterAPI (Lists)

#pragma mark Lists

// GET	lists/list

- (void)getListsSubscribedByUsername:(NSString *)username
                            orUserID:(NSString *)userID
                             reverse:(NSNumber *)reverse
                        successBlock:(void(^)(NSArray *lists))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((username || userID), @"missing username or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(username) {
        md[@"screen_name"] = username;
    } else if (userID) {
        md[@"user_id"] = userID;
    }
    
    if(reverse) md[@"reverse"] = [reverse boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *lists = (NSArray *)response;
        ST_BLOCK_SAFE_RUN(successBlock,lists);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// GET    lists/statuses

- (void)getListsStatusesForListID:(NSString *)listID
                          sinceID:(NSString *)sinceID
                            maxID:(NSString *)maxID
                            count:(NSString *)count
                  includeEntities:(NSNumber *)includeEntities
                  includeRetweets:(NSNumber *)includeRetweets
                     successBlock:(void(^)(NSArray *statuses))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(count) md[@"count"] = count;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(includeRetweets) md[@"include_rts"] = includeRetweets ? @"1" : @"0";
    
    [self getAPIResource:@"lists/statuses.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *statuses = (NSArray *)response;
        ST_BLOCK_SAFE_RUN(successBlock,statuses);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getListsStatusesForSlug:(NSString *)slug
                     screenName:(NSString *)ownerScreenName
                        ownerID:(NSString *)ownerID
                        sinceID:(NSString *)sinceID
                          maxID:(NSString *)maxID
                          count:(NSString *)count
                includeEntities:(NSNumber *)includeEntities
                includeRetweets:(NSNumber *)includeRetweets
                   successBlock:(void(^)(NSArray *statuses))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(count) md[@"count"] = count;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(includeRetweets) md[@"include_rts"] = [includeRetweets boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/statuses.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSAssert([response isKindOfClass:[NSArray class]], @"bad response type");
        
        NSArray *statuses = (NSArray *)response;
        ST_BLOCK_SAFE_RUN(successBlock,statuses);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST lists/members/destroy

- (void)postListsMembersDestroyForListID:(NSString *)listID
                            successBlock:(void(^)(id response))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSDictionary *d = @{ @"list_id" : listID };
    
    [self postAPIResource:@"lists/members/destroy" parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postListsMembersDestroyForSlug:(NSString *)slug
                                userID:(NSString *)userID
                            screenName:(NSString *)screenName
                       ownerScreenName:(NSString *)ownerScreenName
                               ownerID:(NSString *)ownerID
                          successBlock:(void(^)())successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"slug"] = slug;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerScreenName) md[@"owner_id"] = ownerID;
    
    [self postAPIResource:@"lists/members/destroy" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock();
        ST_BLOCK_SAFE_RUN(successBlock);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// GET lists/memberships

- (void)getListsMembershipsForUserID:(NSString *)userID
                        orScreenName:(NSString *)screenName
                              cursor:(NSString *)cursor
                  filterToOwnedLists:(NSNumber *)filterToOwnedLists
                        successBlock:(void(^)(NSArray *lists, NSString *previousCursor, NSString *nextCursor))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(filterToOwnedLists) md[@"filter_to_owned_lists"] = [filterToOwnedLists boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/memberships.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSString *previousCursor = nil;
        NSString *nextCursor = nil;
        NSArray *lists = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            previousCursor = [response valueForKey:@"previous_cursor_str"];
            nextCursor = [response valueForKey:@"next_cursor_str"];
            lists = [response valueForKey:@"lists"];
        }
        
        ST_BLOCK_SAFE_RUN(successBlock,lists, previousCursor, nextCursor);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// GET	lists/subscribers

- (void)getListsSubscribersForSlug:(NSString *)slug
                   ownerScreenName:(NSString *)ownerScreenName
                         orOwnerID:(NSString *)ownerID
                            cursor:(NSString *)cursor
                   includeEntities:(NSNumber *)includeEntities
                        skipStatus:(NSNumber *)skipStatus
                      successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or onwerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) {
        md[@"owner_screen_name"] = ownerScreenName;
    } else if (ownerID) {
        md[@"owner_id"] = ownerID;
    }
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/subscribers.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        ST_BLOCK_SAFE_RUN(successBlock,users, previousCursor, nextCursor);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getListsSubscribersForListID:(NSString *)listID
                              cursor:(NSString *)cursor
                     includeEntities:(NSNumber *)includeEntities
                          skipStatus:(NSNumber *)skipStatus
                        successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/subscribers.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        ST_BLOCK_SAFE_RUN(successBlock,users, previousCursor, nextCursor);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST	lists/subscribers/create

- (void)postListSubscribersCreateForListID:(NSString *)listID
                              successBlock:(void(^)(id response))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    [self postAPIResource:@"lists/subscribers/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postListSubscribersCreateForSlug:(NSString *)slug
                         ownerScreenName:(NSString *)ownerScreenName
                               orOwnerID:(NSString *)ownerID
                            successBlock:(void(^)(id response))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    [self postAPIResource:@"lists/subscribers/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// GET	lists/subscribers/show

- (void)getListsSubscribersShowForListID:(NSString *)listID
                                  userID:(NSString *)userID
                            orScreenName:(NSString *)screenName
                         includeEntities:(NSNumber *)includeEntities
                              skipStatus:(NSNumber *)skipStatus
                            successBlock:(void(^)(id response))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(listID);
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/subscribers/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getListsSubscribersShowForSlug:(NSString *)slug
                       ownerScreenName:(NSString *)ownerScreenName
                             orOwnerID:(NSString *)ownerID
                                userID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                       includeEntities:(NSNumber *)includeEntities
                            skipStatus:(NSNumber *)skipStatus
                          successBlock:(void(^)(id response))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/subscribers/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST	lists/subscribers/destroy

- (void)postListSubscribersDestroyForListID:(NSString *)listID
                               successBlock:(void(^)(id response))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    [self postAPIResource:@"lists/subscribers/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postListSubscribersDestroyForSlug:(NSString *)slug
                          ownerScreenName:(NSString *)ownerScreenName
                                orOwnerID:(NSString *)ownerID
                             successBlock:(void(^)(id response))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    [self postAPIResource:@"lists/subscribers/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST	lists/members/create_all

- (void)postListsMembersCreateAllForListID:(NSString *)listID
                                   userIDs:(NSArray *)userIDs // array of strings
                             orScreenNames:(NSArray *)screenNames // array of strings
                              successBlock:(void(^)(id response))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(listID);
    NSAssert((userIDs || screenNames), @"missing usersIDs or screenNames");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    if(userIDs) {
        md[@"user_id"] = [userIDs componentsJoinedByString:@","];
    } else if (screenNames) {
        md[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    }
    
    [self postAPIResource:@"lists/members/create_all.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postListsMembersCreateAllForSlug:(NSString *)slug
                         ownerScreenName:(NSString *)ownerScreenName
                               orOwnerID:(NSString *)ownerID
                                 userIDs:(NSArray *)userIDs // array of strings
                           orScreenNames:(NSArray *)screenNames // array of strings
                            successBlock:(void(^)(id response))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    NSAssert((userIDs || screenNames), @"missing usersIDs or screenNames");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    
    if(ownerScreenName) {
        md[@"owner_screen_name"] = ownerScreenName;
    } else if (ownerID) {
        md[@"owner_id"] = ownerID;
    }
    
    if(userIDs) {
        md[@"user_id"] = [userIDs componentsJoinedByString:@","];
    } else if (screenNames) {
        md[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    }
    
    [self postAPIResource:@"lists/members/create_all.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// GET	lists/members/show

- (void)getListsMembersShowForListID:(NSString *)listID
                              userID:(NSString *)userID
                          screenName:(NSString *)screenName
                     includeEntities:(NSNumber *)includeEntities
                          skipStatus:(NSNumber *)skipStatus
                        successBlock:(void(^)(NSDictionary *user))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(listID, @"listID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/members/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getListsMembersShowForSlug:(NSString *)slug
                   ownerScreenName:(NSString *)ownerScreenName
                         orOwnerID:(NSString *)ownerID
                            userID:(NSString *)userID
                        screenName:(NSString *)screenName
                   includeEntities:(NSNumber *)includeEntities
                        skipStatus:(NSNumber *)skipStatus
                      successBlock:(void(^)(NSDictionary *user))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/members/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// GET	lists/members

- (void)getListsMembersForListID:(NSString *)listID
                          cursor:(NSString *)cursor
                 includeEntities:(NSNumber *)includeEntities
                      skipStatus:(NSNumber *)skipStatus
                    successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(listID, @"listID is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/members.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        ST_BLOCK_SAFE_RUN(successBlock,users, previousCursor, nextCursor);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getListsMembersForSlug:(NSString *)slug
               ownerScreenName:(NSString *)ownerScreenName
                     orOwnerID:(NSString *)ownerID
                        cursor:(NSString *)cursor
               includeEntities:(NSNumber *)includeEntities
                    skipStatus:(NSNumber *)skipStatus
                  successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(cursor) md[@"cursor"] = cursor;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"lists/members.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSArray *users = [response valueForKey:@"users"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        ST_BLOCK_SAFE_RUN(successBlock,users, previousCursor, nextCursor);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST	lists/members/create

- (void)postListMemberCreateForListID:(NSString *)listID
                               userID:(NSString *)userID
                           screenName:(NSString *)screenName
                         successBlock:(void(^)(id response))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    
    [self postAPIResource:@"lists/members/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postListMemberCreateForSlug:(NSString *)slug
                    ownerScreenName:(NSString *)ownerScreenName
                          orOwnerID:(NSString *)ownerID
                             userID:(NSString *)userID
                         screenName:(NSString *)screenName
                       successBlock:(void(^)(id response))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    md[@"user_id"] = userID;
    md[@"screen_name"] = screenName;
    
    [self postAPIResource:@"lists/members/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST	lists/destroy

- (void)postListsDestroyForListID:(NSString *)listID
                     successBlock:(void(^)(id response))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    [self postAPIResource:@"lists/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postListsDestroyForSlug:(NSString *)slug
                ownerScreenName:(NSString *)ownerScreenName
                      orOwnerID:(NSString *)ownerID
                   successBlock:(void(^)(id response))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    [self postAPIResource:@"lists/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST	lists/update

- (void)postListsUpdateForListID:(NSString *)listID
                            name:(NSString *)name
                       isPrivate:(BOOL)isPrivate
                     description:(NSString *)description
                    successBlock:(void(^)(id response))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    if(name) md[@"name"] = [name st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = [description st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self postAPIResource:@"lists/update.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postListsUpdateForSlug:(NSString *)slug
               ownerScreenName:(NSString *)ownerScreenName
                     orOwnerID:(NSString *)ownerID
                          name:(NSString *)name
                     isPrivate:(BOOL)isPrivate
                   description:(NSString *)description
                  successBlock:(void(^)(id response))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    if(name) md[@"name"] = [name st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = [description st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self postAPIResource:@"lists/update.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST	lists/create

- (void)postListsCreateWithName:(NSString *)name
                      isPrivate:(BOOL)isPrivate
                    description:(NSString *)description
                   successBlock:(void(^)(NSDictionary *list))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(name);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"name"] = [name st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    md[@"mode"] = isPrivate ? @"private" : @"public";
    if(description) md[@"description"] = [description st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self postAPIResource:@"lists/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// GET	lists/show

- (void)getListsShowListID:(NSString *)listID
              successBlock:(void(^)(NSDictionary *list))successBlock
                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    [self getAPIResource:@"lists/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getListsShowListSlug:(NSString *)slug
             ownerScreenName:(NSString *)ownerScreenName
                   orOwnerID:(NSString *)ownerID
                successBlock:(void(^)(NSDictionary *list))successBlock
                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(ownerScreenName) md[@"owner_screen_name"] = ownerScreenName;
    if(ownerID) md[@"owner_id"] = ownerID;
    
    [self getAPIResource:@"lists/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

// POST	lists/members/destroy_all

- (void)postListsMembersDestroyAllForListID:(NSString *)listID
                                    userIDs:(NSArray *)userIDs // array of strings
                              orScreenNames:(NSArray *)screenNames // array of strings
                               successBlock:(void(^)(id response))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(listID);
    NSAssert((userIDs || screenNames), @"missing usersIDs or screenNames");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"list_id"] = listID;
    
    if(userIDs) {
        md[@"user_id"] = [userIDs componentsJoinedByString:@","];
    } else if (screenNames) {
        md[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    }
    
    [self postAPIResource:@"lists/members/destroy_all.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)postListsMembersDestroyAllForSlug:(NSString *)slug
                          ownerScreenName:(NSString *)ownerScreenName
                                orOwnerID:(NSString *)ownerID
                                  userIDs:(NSArray *)userIDs // array of strings
                            orScreenNames:(NSArray *)screenNames // array of strings
                             successBlock:(void(^)(id response))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(slug);
    NSAssert((ownerScreenName || ownerID), @"missing ownerScreenName or ownerID");
    NSAssert((userIDs || screenNames), @"missing usersIDs or screenNames");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    
    if(ownerScreenName) {
        md[@"owner_screen_name"] = ownerScreenName;
    } else if (ownerID) {
        md[@"owner_id"] = ownerID;
    }
    
    if(userIDs) {
        md[@"user_id"] = [userIDs componentsJoinedByString:@","];
    } else if (screenNames) {
        md[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    }
    
    [self postAPIResource:@"lists/members/destroy_all.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        ST_BLOCK_SAFE_RUN(successBlock,response);
    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

- (void)getListsSubscriptionsForUserID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                                 count:(NSString *)count
                                cursor:(NSString *)cursor
                          successBlock:(void(^)(NSArray *lists, NSString *previousCursor, NSString *nextCursor))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) {
        md[@"user_id"] = userID;
    } else if (screenName) {
        md[@"screen_name"] = screenName;
    }
    
    if(count) md[@"count"] = count;
    if(cursor) md[@"cursor"] = cursor;
    
    [self getAPIResource:@"lists/subscriptions.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *lists = [response valueForKey:@"lists"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        ST_BLOCK_SAFE_RUN(successBlock,lists, previousCursor, nextCursor);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}

//  GET     lists/ownerships

- (void)getListsOwnershipsForUserID:(NSString *)userID
                       orScreenName:(NSString *)screenName
                              count:(NSString *)count
                             cursor:(NSString *)cursor
                       successBlock:(void(^)(NSArray *lists, NSString *previousCursor, NSString *nextCursor))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"missing userID or screenName");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) {
        md[@"user_id"] = userID;
    } else if (screenName) {
        md[@"screen_name"] = screenName;
    }
    
    if(count) md[@"count"] = count;
    if(cursor) md[@"cursor"] = cursor;
    
    [self getAPIResource:@"lists/ownerships.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSArray *lists = [response valueForKey:@"lists"];
        NSString *previousCursor = [response valueForKey:@"previous_cursor_str"];
        NSString *nextCursor = [response valueForKey:@"next_cursor_str"];
        ST_BLOCK_SAFE_RUN(successBlock,lists, previousCursor, nextCursor);

    } errorBlock:^(NSError *error) {
        ST_BLOCK_SAFE_RUN(errorBlock,error);
    }];
}


@end
