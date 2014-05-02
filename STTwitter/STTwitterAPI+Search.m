//
//  STTwitterAPI+Search.m
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+Search.h"
#import "STHTTPRequest.h"

@implementation STTwitterAPI (Search)

#pragma mark Search

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
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSParameterAssert(q);
    
    if(geoCode) md[@"geocode"] = geoCode;
    if(lang) md[@"lang"] = lang;
    if(locale) md[@"locale"] = locale;
    if(resultType) md[@"result_type"] = resultType;
    if(count) md[@"count"] = count;
    if(until) md[@"until"] = until;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(callback) md[@"callback"] = callback;
    
    md[@"q"] = [q st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self getAPIResource:@"search/tweets.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *searchMetadata = [response valueForKey:@"search_metadata"];
        NSArray *statuses = [response valueForKey:@"statuses"];
        
        successBlock(searchMetadata, statuses);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getSearchTweetsWithQuery:(NSString *)q
                    successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getSearchTweetsWithQuery:q
                           geocode:nil
                              lang:nil
                            locale:nil
                        resultType:nil
                             count:nil
                             until:nil
                           sinceID:nil
                             maxID:nil
                   includeEntities:@(YES)
                          callback:nil
                      successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
                          successBlock(searchMetadata, statuses);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

@end
