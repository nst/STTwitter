//
//  STTwitterAPI+SavedSearches.h
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (SavedSearches)

#pragma mark Saved Searches

/*
 GET    saved_searches/list
 
 Returns the authenticated user's saved search queries.
 */

- (void)getSavedSearchesListWithSuccessBlock:(void(^)(NSArray *savedSearches))successBlock
                                  errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    saved_searches/show/:id
 
 Retrieve the information for the saved search represented by the given id. The authenticating user must be the owner of saved search ID being requested.
 */

- (void)getSavedSearchesShow:(NSString *)savedSearchID
                successBlock:(void(^)(NSDictionary *savedSearch))successBlock
                  errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST   saved_searches/create
 
 Create a new saved search for the authenticated user. A user may only have 25 saved searches.
 */

- (void)postSavedSearchesCreateWithQuery:(NSString *)query
                            successBlock:(void(^)(NSDictionary *createdSearch))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST   saved_searches/destroy/:id
 
 Destroys a saved search for the authenticating user. The authenticating user must be the owner of saved search id being destroyed.
 */

- (void)postSavedSearchesDestroy:(NSString *)savedSearchID
                    successBlock:(void(^)(NSDictionary *destroyedSearch))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;


@end
