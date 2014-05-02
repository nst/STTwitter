//
//  STTwitterAPI+Tweets.h
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (Tweets)

#pragma mark Tweets

/*
 GET    statuses/retweets/:id
 
 Returns up to 100 of the first retweets of a given tweet.
 */
- (void)getStatusesRetweetsForID:(NSString *)statusID
                           count:(NSString *)count
                        trimUser:(NSNumber *)trimUser
                    successBlock:(void(^)(NSArray *statuses))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    statuses/show/:id
 
 Returns a single Tweet, specified by the id parameter. The Tweet's author will also be embedded within the tweet.
 
 See Embeddable Timelines, Embeddable Tweets, and GET statuses/oembed for tools to render Tweets according to Display Requirements.
 
 # About Geo
 
 If there is no geotag for a status, then there will be an empty <geo/> or "geo" : {}. This can only be populated if the user has used the Geotagging API to send a statuses/update.
 
 The JSON response mostly uses conventions laid out in GeoJSON. Unfortunately, the coordinates that Twitter renders are reversed from the GeoJSON specification (GeoJSON specifies a longitude then a latitude, whereas we are currently representing it as a latitude then a longitude). Our JSON renders as: "geo": { "type":"Point", "coordinates":[37.78029, -122.39697] }
 
 # Contributors
 
 If there are no contributors for a Tweet, then there will be an empty or "contributors" : {}. This field will only be populated if the user has contributors enabled on his or her account -- this is a beta feature that is not yet generally available to all.
 
 This object contains an array of user IDs for users who have contributed to this status (an example of a status that has been contributed to is this one). In practice, there is usually only one ID in this array. The JSON renders as such "contributors":[8285392].
 */

- (void)getStatusesShowID:(NSString *)statusID
                 trimUser:(NSNumber *)trimUser
         includeMyRetweet:(NSNumber *)includeMyRetweet
          includeEntities:(NSNumber *)includeEntities
             successBlock:(void(^)(NSDictionary *status))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	statuses/destroy/:id
 
 Destroys the status specified by the required ID parameter. The authenticating user must be the author of the specified status. Returns the destroyed status if successful.
 */

- (void)postStatusesDestroy:(NSString *)statusID
                   trimUser:(NSNumber *)trimUser
               successBlock:(void(^)(NSDictionary *status))successBlock
                 errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	statuses/update
 
 Updates the authenticating user's current status, also known as tweeting. To upload an image to accompany the tweet, use POST statuses/update_with_media.
 
 For each update attempt, the update text is compared with the authenticating user's recent tweets. Any attempt that would result in duplication will be blocked, resulting in a 403 error. Therefore, a user cannot submit the same status twice in a row.
 
 While not rate limited by the API a user is limited in the number of tweets they can create at a time. If the number of updates posted by the user reaches the current allowed limit this method will return an HTTP 403 error.
 
 - Any geo-tagging parameters in the update will be ignored if geo_enabled for the user is false (this is the default setting for all users unless the user has enabled geolocation in their settings)
 - The number of digits passed the decimal separator passed to lat, up to 8, will be tracked so that the lat is returned in a status object it will have the same number of digits after the decimal separator.
 - Please make sure to use to use a decimal point as the separator (and not the decimal comma) for the latitude and the longitude - usage of the decimal comma will cause the geo-tagged portion of the status update to be dropped.
 - For JSON, the response mostly uses conventions described in GeoJSON. Unfortunately, the geo object has coordinates that Twitter renderers are reversed from the GeoJSON specification (GeoJSON specifies a longitude then a latitude, whereas we are currently representing it as a latitude then a longitude. Our JSON renders as: "geo": { "type":"Point", "coordinates":[37.78217, -122.40062] }
 - The coordinates object is replacing the geo object (no deprecation date has been set for the geo object yet) -- the difference is that the coordinates object, in JSON, is now rendered correctly in GeoJSON.
 - If a place_id is passed into the status update, then that place will be attached to the status. If no place_id was explicitly provided, but latitude and longitude are, we attempt to implicitly provide a place by calling geo/reverse_geocode.
 - Users will have the ability, from their settings page, to remove all the geotags from all their tweets en masse. Currently we are not doing any automatic scrubbing nor providing a method to remove geotags from individual tweets.
 */

- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)existingStatusID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
                 placeID:(NSString *)placeID
      displayCoordinates:(NSNumber *)displayCoordinates
                trimUser:(NSNumber *)trimUser
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	statuses/retweet/:id
 
 Retweets a tweet. Returns the original tweet with retweet details embedded.
 
 - This method is subject to update limits. A HTTP 403 will be returned if this limit as been hit.
 - Twitter will ignore attempts to perform duplicate retweets.
 - The retweet_count will be current as of when the payload is generated and may not reflect the exact count. It is intended as an approximation.
 
 Returns Tweets (1: the new tweet)
 */

- (void)postStatusRetweetWithID:(NSString *)statusID
                       trimUser:(NSNumber *)trimUser
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)postStatusRetweetWithID:(NSString *)statusID
                   successBlock:(void(^)(NSDictionary *status))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	statuses/update_with_media
 
 Updates the authenticating user's current status and attaches media for upload. In other words, it creates a Tweet with a picture attached.
 
 Unlike POST statuses/update, this method expects raw multipart data. Your POST request's Content-Type should be set to multipart/form-data with the media[] parameter
 
 The Tweet text will be rewritten to include the media URL(s), which will reduce the number of characters allowed in the Tweet text. If the URL(s) cannot be appended without text truncation, the tweet will be rejected and this method will return an HTTP 403 error.
 */

- (void)postStatusUpdate:(NSString *)status
          mediaDataArray:(NSArray *)mediaDataArray // only one media is currently supported, help/configuration.json returns "max_media_per_upload" = 1
       possiblySensitive:(NSNumber *)possiblySensitive
       inReplyToStatusID:(NSString *)inReplyToStatusID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
                 placeID:(NSString *)placeID
      displayCoordinates:(NSNumber *)displayCoordinates
     uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock;

// convenience
- (void)postStatusUpdate:(NSString *)status
       inReplyToStatusID:(NSString *)existingStatusID
                mediaURL:(NSURL *)mediaURL
                 placeID:(NSString *)placeID
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
     uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
            successBlock:(void(^)(NSDictionary *status))successBlock
              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    statuses/oembed
 
 Returns information allowing the creation of an embedded representation of a Tweet on third party sites. See the oEmbed specification for information about the response format.
 
 While this endpoint allows a bit of customization for the final appearance of the embedded Tweet, be aware that the appearance of the rendered Tweet may change over time to be consistent with Twitter's Display Requirements. Do not rely on any class or id parameters to stay constant in the returned markup.
 */

- (void)getStatusesOEmbedForStatusID:(NSString *)statusID
                           urlString:(NSString *)urlString
                            maxWidth:(NSString *)maxWidth
                           hideMedia:(NSNumber *)hideMedia
                          hideThread:(NSNumber *)hideThread
                          omitScript:(NSNumber *)omitScript
                               align:(NSString *)align // 'left', 'right', 'center' or 'none' (default)
                             related:(NSString *)related // eg. twitterapi,twittermedia,twitter
                                lang:(NSString *)lang
                        successBlock:(void(^)(NSDictionary *status))successBlock
                          errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    statuses/retweeters/ids
 
 Returns a collection of up to 100 user IDs belonging to users who have retweeted the tweet specified by the id parameter.
 
 This method offers similar data to GET statuses/retweets/:id and replaces API v1's GET statuses/:id/retweeted_by/ids method.
 */

- (void)getStatusesRetweetersIDsForStatusID:(NSString *)statusID
                                     cursor:(NSString *)cursor
                               successBlock:(void(^)(NSArray *ids, NSString *previousCursor, NSString *nextCursor))successBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET statuses/lookup
 
 Returns fully-hydrated tweet objects for up to 100 tweets per request, as specified by comma-separated values passed to the id parameter. This method is especially useful to get the details (hydrate) a collection of Tweet IDs. GET statuses/show/:id is used to retrieve a single tweet object.
 */

- (void)getStatusesLookupTweetIDs:(NSArray *)tweetIDs
                  includeEntities:(NSNumber *)includeEntities
                         trimUser:(NSNumber *)trimUser
                              map:(NSNumber *)map
					 successBlock:(void(^)(NSArray *tweets))successBlock
					   errorBlock:(void(^)(NSError *error))errorBlock;


@end
