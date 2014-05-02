//
//  STTwitterAPI+PlacesAndGeo.h
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (PlacesAndGeo)

#pragma mark Places & Geo

/*
 GET    geo/id/:place_id
 
 Returns all the information about a known place.
 */

- (void)getGeoIDForPlaceID:(NSString *)placeID // A place in the world. These IDs can be retrieved from geo/reverse_geocode.
              successBlock:(void(^)(NSDictionary *place))successBlock
                errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    geo/reverse_geocode
 
 Given a latitude and a longitude, searches for up to 20 places that can be used as a place_id when updating a status.
 
 This request is an informative call and will deliver generalized results about geography.
 */

- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude // eg. "37.7821120598956"
                               longitude:(NSString *)longitude // eg. "-122.400612831116"
                                accuracy:(NSString *)accuracy // eg. "5ft"
                             granularity:(NSString *)granularity // eg. "city"
                              maxResults:(NSString *)maxResults // eg. "3"
                                callback:(NSString *)callback
                            successBlock:(void(^)(NSDictionary *query, NSDictionary *result))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                               longitude:(NSString *)longitude
                            successBlock:(void(^)(NSArray *places))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    geo/search
 
 Search for places that can be attached to a statuses/update. Given a latitude and a longitude pair, an IP address, or a name, this request will return a list of all the valid places that can be used as the place_id when updating a status.
 
 Conceptually, a query can be made from the user's location, retrieve a list of places, have the user validate the location he or she is at, and then send the ID of this location with a call to POST statuses/update.
 
 This is the recommended method to use find places that can be attached to statuses/update. Unlike GET geo/reverse_geocode which provides raw data access, this endpoint can potentially re-order places with regards to the user who is authenticated. This approach is also preferred for interactive place matching with the user.
 */

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
                      errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getGeoSearchWithLatitude:(NSString *)latitude
                       longitude:(NSString *)longitude
                    successBlock:(void(^)(NSArray *places))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getGeoSearchWithIPAddress:(NSString *)ipAddress
                     successBlock:(void(^)(NSArray *places))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)getGeoSearchWithQuery:(NSString *)query
                 successBlock:(void(^)(NSArray *places))successBlock
                   errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    geo/similar_places
 
 Locates places near the given coordinates which are similar in name.
 
 Conceptually you would use this method to get a list of known places to choose from first. Then, if the desired place doesn't exist, make a request to POST geo/place to create a new one.
 
 The token contained in the response is the token needed to be able to create a new place.
 */

- (void)getGeoSimilarPlacesToLatitude:(NSString *)latitude // eg. "37.7821120598956"
                            longitude:(NSString *)longitude // eg. "-122.400612831116"
                                 name:(NSString *)name // eg. "Twitter HQ"
              placeIDContaintedWithin:(NSString *)placeIDContaintedWithin // eg. "247f43d441defc03"
               attributeStreetAddress:(NSString *)attributeStreetAddress // eg. "795 Folsom St"
                             callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                         successBlock:(void(^)(NSDictionary *query, NSArray *resultPlaces, NSString *resultToken))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	geo/place
 
 Creates a new place object at the given latitude and longitude.
 
 Before creating a place you need to query GET geo/similar_places with the latitude, longitude and name of the place you wish to create. The query will return an array of places which are similar to the one you wish to create, and a token. If the place you wish to create isn't in the returned array you can use the token with this method to create a new one.
 
 Learn more about Finding Tweets about Places.
 
 WARNING: deprecated since December 2nd, 2013 https://dev.twitter.com/discussions/22452
 */

- (void)postGeoPlaceWithName:(NSString *)name // eg. "Twitter HQ"
     placeIDContaintedWithin:(NSString *)placeIDContaintedWithin // eg. "247f43d441defc03"
           similarPlaceToken:(NSString *)similarPlaceToken // eg. "36179c9bf78835898ebf521c1defd4be"
                    latitude:(NSString *)latitude // eg. "37.7821120598956"
                   longitude:(NSString *)longitude // eg. "-122.400612831116"
      attributeStreetAddress:(NSString *)attributeStreetAddress // eg. "795 Folsom St"
                    callback:(NSString *)callback // If supplied, the response will use the JSONP format with a callback of the given name.
                successBlock:(void(^)(NSDictionary *place))successBlock
                  errorBlock:(void(^)(NSError *error))errorBlock;

@end
