//
//  STTwitterAPI+Search.h
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (Search)

#pragma mark Search

//	GET		search/tweets
- (void)getSearchTweetsWithQuery:(NSString *)q
                         geocode:(NSString *)geoCode // eg. "37.781157,-122.398720,1mi"
                            lang:(NSString *)lang // eg. "eu"
                          locale:(NSString *)locale // eg. "ja"
                      resultType:(NSString *)resultType // eg. "mixed, recent, popular"
                           count:(NSString *)count // eg. "100"
                           until:(NSString *)until // eg. "2012-09-01"
                         sinceID:(NSString *)sinceID // eg. "12345"
                           maxID:(NSString *)maxID // eg. "54321"
                 includeEntities:(NSNumber *)includeEntities
                        callback:(NSString *)callback // eg. "processTweets"
					successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
					  errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
- (void)getSearchTweetsWithQuery:(NSString *)q
					successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

@end
