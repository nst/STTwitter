//
//  STTwitterAPI+Favorites.h
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (Favorites)

#pragma mark Favorites

/*
 GET    favorites/list
 
 Returns the 20 most recent Tweets favorited by the authenticating or specified user.
 
 If you do not provide either a user_id or screen_name to this method, it will assume you are requesting on behalf of the authenticating user. Specify one or the other for best results.
 */

- (void)getFavoritesListWithUserID:(NSString *)userID
                        screenName:(NSString *)screenName
                             count:(NSString *)count
                           sinceID:(NSString *)sinceID
                             maxID:(NSString *)maxID
                   includeEntities:(NSNumber *)includeEntities
                      successBlock:(void(^)(NSArray *statuses))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getFavoritesListWithSuccessBlock:(void(^)(NSArray *statuses))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	favorites/destroy
 
 Un-favorites the status specified in the ID parameter as the authenticating user. Returns the un-favorited status in the requested format when successful.
 
 This process invoked by this method is asynchronous. The immediately returned status may not indicate the resultant favorited status of the tweet. A 200 OK response from this method will indicate whether the intended action was successful or not.
 */

- (void)postFavoriteDestroyWithStatusID:(NSString *)statusID
                        includeEntities:(NSNumber *)includeEntities
                           successBlock:(void(^)(NSDictionary *status))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	favorites/create
 
 Favorites the status specified in the ID parameter as the authenticating user. Returns the favorite status when successful.
 
 This process invoked by this method is asynchronous. The immediately returned status may not indicate the resultant favorited status of the tweet. A 200 OK response from this method will indicate whether the intended action was successful or not.
 */

- (void)postFavoriteCreateWithStatusID:(NSString *)statusID
                       includeEntities:(NSNumber *)includeEntities
                          successBlock:(void(^)(NSDictionary *status))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)postFavoriteState:(BOOL)favoriteState
              forStatusID:(NSString *)statusID
             successBlock:(void(^)(NSDictionary *status))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

@end
