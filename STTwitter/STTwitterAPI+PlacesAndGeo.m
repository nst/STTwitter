//
//  STTwitterAPI+PlacesAndGeo.m
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+PlacesAndGeo.h"

@implementation STTwitterAPI (PlacesAndGeo)

#pragma mark Places & Geo

// GET geo/id/:place_id
- (void)getGeoIDForPlaceID:(NSString *)placeID // A place in the world. These IDs can be retrieved from geo/reverse_geocode.
              successBlock:(void(^)(NSDictionary *place))successBlock
                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *resource = [NSString stringWithFormat:@"geo/id/%@.json", placeID];
    
    [self getAPIResource:resource parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET geo/reverse_geocode
- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude // eg. "37.7821120598956"
                               longitude:(NSString *)longitude // eg. "-122.400612831116"
                                accuracy:(NSString *)accuracy // eg. "5ft"
                             granularity:(NSString *)granularity // eg. "city"
                              maxResults:(NSString *)maxResults // eg. "3"
                                callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                            successBlock:(void(^)(NSDictionary *query, NSDictionary *result))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"lat"] = latitude;
    md[@"long"] = longitude;
    if(accuracy) md[@"accuracy"] = accuracy;
    if(granularity) md[@"granularity"] = granularity;
    if(maxResults) md[@"max_results"] = maxResults;
    if(callback) md[@"callback"] = callback;
    
    [self getAPIResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *query = [response valueForKeyPath:@"query"];
        NSDictionary *result = [response valueForKeyPath:@"result"];
        
        successBlock(query, result);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                               longitude:(NSString *)longitude
                            successBlock:(void(^)(NSArray *places))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    [self getGeoReverseGeocodeWithLatitude:latitude
                                 longitude:longitude
                                  accuracy:nil
                               granularity:nil
                                maxResults:nil
                                  callback:nil
                              successBlock:^(NSDictionary *query, NSDictionary *result) {
                                  successBlock([result valueForKey:@"places"]);
                              } errorBlock:^(NSError *error) {
                                  errorBlock(error);
                              }];
}

// GET geo/search

- (void)getGeoSearchWithLatitude:(NSString *)latitude // eg. "37.7821120598956"
                       longitude:(NSString *)longitude // eg. "-122.400612831116"
                           query:(NSString *)query // eg. "Twitter HQ"
                       ipAddress:(NSString *)ipAddress // eg. 74.125.19.104
                     granularity:(NSString *)granularity // eg. "city"
                        accuracy:(NSString *)accuracy // eg. "5ft"
                      maxResults:(NSString *)maxResults // eg. "3"
         placeIDContaintedWithin:(NSString *)placeIDContaintedWithin // eg. "247f43d441defc03"
          attributeStreetAddress:(NSString *)attributeStreetAddress // eg. "795 Folsom St"
                        callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                    successBlock:(void(^)(NSDictionary *query, NSDictionary *result))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(latitude) md[@"lat"] = latitude;
    if(longitude) md[@"long"] = longitude;
    if(query) md[@"query"] = query;
    if(ipAddress) md[@"ip"] = ipAddress;
    if(granularity) md[@"granularity"] = granularity;
    if(accuracy) md[@"accuracy"] = accuracy;
    if(maxResults) md[@"max_results"] = maxResults;
    if(placeIDContaintedWithin) md[@"contained_within"] = placeIDContaintedWithin;
    if(attributeStreetAddress) md[@"attribute:street_address"] = attributeStreetAddress;
    if(callback) md[@"callback"] = callback;
    
    [self getAPIResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *query = [response valueForKeyPath:@"query"];
        NSDictionary *result = [response valueForKeyPath:@"result"];
        
        successBlock(query, result);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)getGeoSearchWithLatitude:(NSString *)latitude
                       longitude:(NSString *)longitude
                    successBlock:(void(^)(NSArray *places))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    [self getGeoSearchWithLatitude:latitude
                         longitude:longitude
                             query:nil
                         ipAddress:nil
                       granularity:nil
                          accuracy:nil
                        maxResults:nil
           placeIDContaintedWithin:nil
            attributeStreetAddress:nil
                          callback:nil
                      successBlock:^(NSDictionary *query, NSDictionary *result) {
                          successBlock([result valueForKey:@"places"]);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

- (void)getGeoSearchWithIPAddress:(NSString *)ipAddress
                     successBlock:(void(^)(NSArray *places))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(ipAddress);
    
    [self getGeoSearchWithLatitude:nil
                         longitude:nil
                             query:nil
                         ipAddress:ipAddress
                       granularity:nil
                          accuracy:nil
                        maxResults:nil
           placeIDContaintedWithin:nil
            attributeStreetAddress:nil
                          callback:nil
                      successBlock:^(NSDictionary *query, NSDictionary *result) {
                          successBlock([result valueForKey:@"places"]);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

- (void)getGeoSearchWithQuery:(NSString *)query
                 successBlock:(void(^)(NSArray *places))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(query);
    
    [self getGeoSearchWithLatitude:nil
                         longitude:nil
                             query:query
                         ipAddress:nil
                       granularity:nil
                          accuracy:nil
                        maxResults:nil
           placeIDContaintedWithin:nil
            attributeStreetAddress:nil
                          callback:nil
                      successBlock:^(NSDictionary *query, NSDictionary *result) {
                          successBlock([result valueForKey:@"places"]);
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
}

// GET geo/similar_places

- (void)getGeoSimilarPlacesToLatitude:(NSString *)latitude // eg. "37.7821120598956"
                            longitude:(NSString *)longitude // eg. "-122.400612831116"
                                 name:(NSString *)name // eg. "Twitter HQ"
              placeIDContaintedWithin:(NSString *)placeIDContaintedWithin // eg. "247f43d441defc03"
               attributeStreetAddress:(NSString *)attributeStreetAddress // eg. "795 Folsom St"
                             callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                         successBlock:(void(^)(NSDictionary *query, NSArray *resultPlaces, NSString *resultToken))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    NSParameterAssert(name);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"lat"] = latitude;
    md[@"long"] = longitude;
    md[@"name"] = name;
    if(placeIDContaintedWithin) md[@"contained_within"] = placeIDContaintedWithin;
    if(attributeStreetAddress) md[@"attribute:street_address"] = attributeStreetAddress;
    if(callback) md[@"callback"] = callback;
    
    [self getAPIResource:@"geo/reverse_geocode.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        
        NSDictionary *query = [response valueForKey:@"query"];
        NSDictionary *result = [response valueForKey:@"result"];
        NSArray *places = [result valueForKey:@"places"];
        NSString *token = [result valueForKey:@"token"];
        
        successBlock(query, places, token);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// POST get/place

// WARNING: deprecated since December 2nd, 2013 https://dev.twitter.com/discussions/22452

- (void)postGeoPlaceWithName:(NSString *)name // eg. "Twitter HQ"
     placeIDContaintedWithin:(NSString *)placeIDContaintedWithin // eg. "247f43d441defc03"
           similarPlaceToken:(NSString *)similarPlaceToken // eg. "36179c9bf78835898ebf521c1defd4be"
                    latitude:(NSString *)latitude // eg. "37.7821120598956"
                   longitude:(NSString *)longitude // eg. "-122.400612831116"
      attributeStreetAddress:(NSString *)attributeStreetAddress // eg. "795 Folsom St"
                    callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                successBlock:(void(^)(NSDictionary *place))successBlock
                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"name"] = name;
    md[@"contained_within"] = placeIDContaintedWithin;
    md[@"token"] = similarPlaceToken;
    md[@"lat"] = latitude;
    md[@"long"] = longitude;
    if(attributeStreetAddress) md[@"attribute:street_address"] = attributeStreetAddress;
    if(callback) md[@"callback"] = callback;
    
    [self postAPIResource:@"get/create.json" parameters:md successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

@end
