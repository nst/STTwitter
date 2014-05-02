//
//  STTwitterAPI+Trends.h
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (Trends)

#pragma mark Trends

/*
 GET    trends/place
 
 Returns the top 10 trending topics for a specific WOEID, if trending information is available for it.
 
 The response is an array of "trend" objects that encode the name of the trending topic, the query parameter that can be used to search for the topic on Twitter Search, and the Twitter Search URL.
 
 This information is cached for 5 minutes. Requesting more frequently than that will not return any more data, and will count against your rate limit usage.
 */

- (void)getTrendsForWOEID:(NSString *)WOEID // 'Yahoo! Where On Earth ID', Paris is "615702"
          excludeHashtags:(NSNumber *)excludeHashtags
             successBlock:(void(^)(NSDate *asOf, NSDate *createdAt, NSArray *locations, NSArray *trends))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    trends/available
 
 Returns the locations that Twitter has trending topic information for.
 
 The response is an array of "locations" that encode the location's WOEID and some other human-readable information such as a canonical name and country the location belongs in.
 
 A WOEID is a Yahoo! Where On Earth ID.
 */

- (void)getTrendsAvailableWithSuccessBlock:(void(^)(NSArray *locations))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    trends/closest
 
 Returns the locations that Twitter has trending topic information for, closest to a specified location.
 
 The response is an array of "locations" that encode the location's WOEID and some other human-readable information such as a canonical name and country the location belongs in.
 
 A WOEID is a Yahoo! Where On Earth ID.
 */

- (void)getTrendsClosestToLatitude:(NSString *)latitude
                         longitude:(NSString *)longitude
                      successBlock:(void(^)(NSArray *locations))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock;

@end
