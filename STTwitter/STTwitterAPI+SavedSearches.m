//
//  STTwitterAPI+SavedSearches.m
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+SavedSearches.h"

@implementation STTwitterAPI (SavedSearches)

#pragma mark Saved Searches

// GET saved_searches/list
- (void)getSavedSearchesListWithSuccessBlock:(void(^)(NSArray *savedSearches))successBlock
                                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getAPIResource:@"saved_searches/list.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET saved_searches/show/:id
- (void)getSavedSearchesShow:(NSString *)savedSearchID
                successBlock:(void(^)(NSDictionary *savedSearch))successBlock
                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(savedSearchID);
    
    NSString *resource = [NSString stringWithFormat:@"saved_searches/show/%@.json", savedSearchID];
    
    [self getAPIResource:resource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST saved_searches/create
- (void)postSavedSearchesCreateWithQuery:(NSString *)query
                            successBlock:(void(^)(NSDictionary *createdSearch))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    NSDictionary *d = @{ @"query" : query };
    
    [self postAPIResource:@"saved_searches/create.json" parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST saved_searches/destroy/:id
- (void)postSavedSearchesDestroy:(NSString *)savedSearchID
                    successBlock:(void(^)(NSDictionary *destroyedSearch))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(savedSearchID);
    
    NSString *resource = [NSString stringWithFormat:@"saved_searches/destroy/%@.json", savedSearchID];
    
    [self postAPIResource:resource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

@end
