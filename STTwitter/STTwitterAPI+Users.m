//
//  STTwitterAPI+Users.m
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+Users.h"
#import "STHTTPRequest.h"

@implementation STTwitterAPI (Users)

#pragma mark Users

// GET account/settings
- (void)getAccountSettingsWithSuccessBlock:(void(^)(NSDictionary *settings))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    [self getAPIResource:@"account/settings.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET account/verify_credentials
- (void)getAccountVerifyCredentialsWithIncludeEntites:(NSNumber *)includeEntities
                                           skipStatus:(NSNumber *)skipStatus
                                         successBlock:(void(^)(NSDictionary *myInfo))successBlock
                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"account/verify_credentials.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getAccountVerifyCredentialsWithSuccessBlock:(void(^)(NSDictionary *account))successBlock
                                         errorBlock:(void(^)(NSError *error))errorBlock {
    [self getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil successBlock:^(NSDictionary *account) {
        successBlock(account);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/settings
- (void)postAccountSettingsWithTrendLocationWOEID:(NSString *)trendLocationWOEID // eg. "1"
                                 sleepTimeEnabled:(NSNumber *)sleepTimeEnabled // eg. @(YES)
                                   startSleepTime:(NSString *)startSleepTime // eg. "13"
                                     endSleepTime:(NSString *)endSleepTime // eg. "13"
                                         timezone:(NSString *)timezone // eg. "Europe/Copenhagen", "Pacific/Tongatapu"
                                         language:(NSString *)language // eg. "it", "en", "es"
                                     successBlock:(void(^)(NSDictionary *settings))successBlock
                                       errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((trendLocationWOEID || sleepTimeEnabled || startSleepTime || endSleepTime || timezone || language), @"at least one parameter is needed");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(trendLocationWOEID) md[@"trend_location_woeid"] = trendLocationWOEID;
    if(sleepTimeEnabled) md[@"sleep_time_enabled"] = [sleepTimeEnabled boolValue] ? @"1" : @"0";
    if(startSleepTime) md[@"start_sleep_time"] = startSleepTime;
    if(endSleepTime) md[@"end_sleep_time"] = endSleepTime;
    if(timezone) md[@"time_zone"] = timezone;
    if(language) md[@"lang"] = language;
    
    [self postAPIResource:@"account/settings.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST	account/update_delivery_device
- (void)postAccountUpdateDeliveryDeviceSMS:(BOOL)deliveryDeviceSMS
                           includeEntities:(NSNumber *)includeEntities
                              successBlock:(void(^)(NSDictionary *response))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"device"] = deliveryDeviceSMS ? @"sms" : @"none";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"account/update_delivery_device.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile
- (void)postAccountUpdateProfileWithName:(NSString *)name
                               URLString:(NSString *)URLString
                                location:(NSString *)location
                             description:(NSString *)description
                         includeEntities:(NSNumber *)includeEntities
                              skipStatus:(NSNumber *)skipStatus
                            successBlock:(void(^)(NSDictionary *profile))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((name || URLString || location || description || includeEntities || skipStatus), @"at least one parameter is needed");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(name) md[@"name"] = name;
    if(URLString) md[@"url"] = URLString;
    if(location) md[@"location"] = location;
    if(description) md[@"description"] = description;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"account/update_profile.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)postUpdateProfile:(NSDictionary *)profileData
			 successBlock:(void(^)(NSDictionary *myInfo))successBlock
			   errorBlock:(void(^)(NSError *error))errorBlock {
    [self postAPIResource:@"account/update_profile.json" parameters:profileData successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_background_image
- (void)postAccountUpdateProfileBackgroundImageWithImage:(NSString *)base64EncodedImage
                                                   title:(NSString *)title
                                         includeEntities:(NSNumber *)includeEntities
                                              skipStatus:(NSNumber *)skipStatus
                                                     use:(NSNumber *)use
                                            successBlock:(void(^)(NSDictionary *profile))successBlock
                                              errorBlock:(void(^)(NSError *error))errorBlock {
    NSAssert((base64EncodedImage || title || includeEntities || skipStatus || use), @"at least one parameter is needed");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(base64EncodedImage) md[@"image"] = base64EncodedImage;
    if(title) md[@"title"] = title;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(use) md[@"use"] = [use boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"account/update_profile_background_image.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_colors
- (void)postAccountUpdateProfileColorsWithBackgroundColor:(NSString *)backgroundColor
                                                linkColor:(NSString *)linkColor
                                       sidebarBorderColor:(NSString *)sidebarBorderColor
                                         sidebarFillColor:(NSString *)sidebarFillColor
                                         profileTextColor:(NSString *)profileTextColor
                                          includeEntities:(NSNumber *)includeEntities
                                               skipStatus:(NSNumber *)skipStatus
                                             successBlock:(void(^)(NSDictionary *profile))successBlock
                                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(backgroundColor) md[@"profile_background_color"] = backgroundColor;
    if(linkColor) md[@"profile_link_color"] = linkColor;
    if(sidebarBorderColor) md[@"profile_sidebar_border_color"] = sidebarBorderColor;
    if(sidebarFillColor) md[@"profile_sidebar_fill_color"] = sidebarFillColor;
    if(profileTextColor) md[@"profile_text_color"] = profileTextColor;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"account/update_profile_colors.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_image
- (void)postAccountUpdateProfileImage:(NSString *)base64EncodedImage
                      includeEntities:(NSNumber *)includeEntities
                           skipStatus:(NSNumber *)skipStatus
                         successBlock:(void(^)(NSDictionary *profile))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(base64EncodedImage);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"image"] = base64EncodedImage;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"account/update_profile_image.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET blocks/list
- (void)getBlocksListWithincludeEntities:(NSNumber *)includeEntities
                              skipStatus:(NSNumber *)skipStatus
                                  cursor:(NSString *)cursor
                            successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(cursor) md[@"cursor"] = cursor;
    
    [self getAPIResource:@"blocks/list.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
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

// GET blocks/ids
- (void)getBlocksIDsWithCursor:(NSString *)cursor
                  successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                    errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"stringify_ids"] = @"1";
    if(cursor) md[@"cursor"] = cursor;
    
    [self getAPIResource:@"blocks/ids.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
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

// POST blocks/create
- (void)postBlocksCreateWithScreenName:(NSString *)screenName
                              orUserID:(NSString *)userID
                       includeEntities:(NSNumber *)includeEntities
                            skipStatus:(NSNumber *)skipStatus
                          successBlock:(void(^)(NSDictionary *user))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"blocks/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST blocks/destroy
- (void)postBlocksDestroyWithScreenName:(NSString *)screenName
                               orUserID:(NSString *)userID
                        includeEntities:(NSNumber *)includeEntities
                             skipStatus:(NSNumber *)skipStatus
                           successBlock:(void(^)(NSDictionary *user))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self postAPIResource:@"blocks/destroy.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/lookup
- (void)getUsersLookupForScreenName:(NSString *)screenName
                           orUserID:(NSString *)userID
                    includeEntities:(NSNumber *)includeEntities
                       successBlock:(void(^)(NSArray *users))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"users/lookup.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/show
- (void)getUsersShowForUserID:(NSString *)userID
                 orScreenName:(NSString *)screenName
              includeEntities:(NSNumber *)includeEntities
                 successBlock:(void(^)(NSDictionary *user))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"users/show.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getUserInformationFor:(NSString *)screenName
                 successBlock:(void(^)(NSDictionary *user))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getUsersShowForUserID:nil orScreenName:screenName includeEntities:nil successBlock:^(NSDictionary *user) {
        successBlock(user);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/search
- (void)getUsersSearchQuery:(NSString *)query
                       page:(NSString *)page
                      count:(NSString *)count
            includeEntities:(NSNumber *)includeEntities
               successBlock:(void(^)(NSArray *users))successBlock
                 errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"q"] = [query st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(page) md[@"page"] = page;
    if(count) md[@"count"] = count;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"users/search.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response); // NSArray of users dictionaries
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/contributees
- (void)getUsersContributeesWithUserID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                       includeEntities:(NSNumber *)includeEntities
                            skipStatus:(NSNumber *)skipStatus
                          successBlock:(void(^)(NSArray *contributees))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"users/contributees.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/contributors
- (void)getUsersContributorsWithUserID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                       includeEntities:(NSNumber *)includeEntities
                            skipStatus:(NSNumber *)skipStatus
                          successBlock:(void(^)(NSArray *contributors))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(screenName) md[@"screen_name"] = screenName;
    if(userID) md[@"user_id"] = userID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"users/contributors.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/remove_profile_banner
- (void)postAccountRemoveProfileBannerWithSuccessBlock:(void(^)(id response))successBlock
                                            errorBlock:(void(^)(NSError *error))errorBlock {
    [self postAPIResource:@"account/remove_profile_banner.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST account/update_profile_banner
- (void)postAccountUpdateProfileBannerWithImage:(NSString *)base64encodedImage
                                          width:(NSString *)width
                                         height:(NSString *)height
                                     offsetLeft:(NSString *)offsetLeft
                                      offsetTop:(NSString *)offsetTop
                                   successBlock:(void(^)(id response))successBlock
                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    if(width || height || offsetLeft || offsetTop) {
        NSParameterAssert(width);
        NSParameterAssert(height);
        NSParameterAssert(offsetLeft);
        NSParameterAssert(offsetTop);
    }
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"banner"] = base64encodedImage;
    if(width) md[@"width"] = width;
    if(height) md[@"height"] = height;
    if(offsetLeft) md[@"offset_left"] = offsetLeft;
    if(offsetTop) md[@"offset_top"] = offsetTop;
    
    [self postAPIResource:@"account/update_profile_banner.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/profile_banner
- (void)getUsersProfileBannerForUserID:(NSString *)userID
                          orScreenName:(NSString *)screenName
                          successBlock:(void(^)(NSDictionary *banner))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    
    [self getAPIResource:@"users/profile_banner.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/suggestions
- (void)getUsersSuggestionsWithISO6391LanguageCode:(NSString *)ISO6391LanguageCode
                                      successBlock:(void(^)(NSArray *suggestions))successBlock
                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(ISO6391LanguageCode) md[@"lang"] = ISO6391LanguageCode;
    
    [self getAPIResource:@"users/suggestions.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/suggestions/:slug/members
- (void)getUsersSuggestionsForSlugMembers:(NSString *)slug // short name of list or a category, eg. "twitter"
                             successBlock:(void(^)(NSArray *members))successBlock
                               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(slug, @"missing slug");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"slug"] = slug;
    
    NSString *resource = [NSString stringWithFormat:@"users/suggestions/%@/members.json", slug];
    
    [self getAPIResource:resource parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET users/suggestions/:slug
- (void)getUsersSuggestionsForSlug:(NSString *)slug // short name of list or a category, eg. "twitter"
                              lang:(NSString *)lang
                      successBlock:(void(^)(NSString *name, NSString *slug, NSArray *users))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(slug, @"slug is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"slug"] = slug;
    if(lang) md[@"lang"] = lang;
    
    [self getAPIResource:@"users/suggestions/twitter.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        NSString *name = nil;
        NSString *slug = nil;
        NSArray *users = nil;
        
        if([response isKindOfClass:[NSDictionary class]]) {
            name = [response valueForKey:@"name"];
            slug = [response valueForKey:@"slug"];
            users = [response valueForKey:@"users"];
        }
        
        successBlock(name,  slug, users);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)profileImageFor:(NSString *)screenName

           successBlock:(void(^)(id image))successBlock

             errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getUserInformationFor:screenName
                   successBlock:^(NSDictionary *response) {
                       NSString *imageURLString = [response objectForKey:@"profile_image_url"];
                       
                       __block STHTTPRequest *r = [STHTTPRequest requestWithURLString:imageURLString];
                       __weak STHTTPRequest *wr = r;
                       
                       r.completionBlock = ^(NSDictionary *headers, NSString *body) {
                           
                           NSData *imageData = wr.responseData;
                           
#if TARGET_OS_IPHONE
                           Class STImageClass = NSClassFromString(@"UIImage");
#else
                           Class STImageClass = NSClassFromString(@"NSImage");
#endif
                           ST_BLOCK_SAFE_RUN(successBlock,[[STImageClass alloc] initWithData:imageData]);
                       };
                       
                       r.errorBlock = ^(NSError *error) {
                           ST_BLOCK_SAFE_RUN(errorBlock,error);
                       };
                   } errorBlock:^(NSError *error) {
                       ST_BLOCK_SAFE_RUN(errorBlock,error);
                   }];
}


@end
