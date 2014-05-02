//
//  STTwitterAPI+Trends.m
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+Trends.h"

@implementation STTwitterAPI (Trends)

#pragma mark Trends

// GET trends/place
- (void)getTrendsForWOEID:(NSString *)WOEID // 'Yahoo! Where On Earth ID', Paris is "615702"
          excludeHashtags:(NSNumber *)excludeHashtags
             successBlock:(void(^)(NSDate *asOf, NSDate *createdAt, NSArray *locations, NSArray *trends))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(WOEID);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"id"] = WOEID;
    if(excludeHashtags) md[@"exclude"] = [excludeHashtags boolValue] ? @"1" : @"0";
    
    [self getAPIResource:@"trends/place.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *d = [response lastObject];
        
        NSDate *asOf = nil;
        NSDate *createdAt = nil;
        NSArray *locations = nil;
        NSArray *trends = nil;
        
        if([d isKindOfClass:[NSDictionary class]]) {
            NSString *asOfString = [d valueForKey:@"as_of"];
            NSString *createdAtString = [d valueForKey:@"created_at"];
            
            asOf = [[self dateFormatter] dateFromString:asOfString];
            createdAt = [[self dateFormatter] dateFromString:createdAtString];
            
            locations = [d valueForKey:@"locations"];
            trends = [d valueForKey:@"trends"];
        }
        
        successBlock(asOf, createdAt, locations, trends);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET trends/available
- (void)getTrendsAvailableWithSuccessBlock:(void(^)(NSArray *locations))successBlock
                                errorBlock:(void(^)(NSError *error))errorBlock {
    [self getAPIResource:@"trends/available.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET trends/closest
- (void)getTrendsClosestToLatitude:(NSString *)latitude
                         longitude:(NSString *)longitude
                      successBlock:(void(^)(NSArray *locations))successBlock
                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"lat"] = latitude;
    md[@"long"] = longitude;
    
    [self getAPIResource:@"trends/closest.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

@end
