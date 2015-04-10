//
//  OTC.h
//  TwitterAPILab
//
//  Created by Tong G. on 4/10/15.
//
//

#import <Foundation/Foundation.h>

@interface OTCStatus : NSObject
    {
@private
    NSDictionary __strong* _JSONDict;

    NSDate __strong* _dataCreated;

    // Attributes
    BOOL _isFavoritedByMe;
    NSUInteger _favoriteCount;

    BOOL _isRetweetedByMe;
    NSUInteger _retweetCount;

    // IDs
    NSString __strong* _tweetIDString;
    NSUInteger _tweetID;
    }

@property ( retain, readonly ) NSDictionary* JSONArray;

#pragma mark Attributes
/** UTC time when this Tweet was created. */
@property ( retain, readonly ) NSDate* dateCreated;

/** Indicates whether this Tweet has been favorited by the authenticating user. */
@property ( assign, readonly ) BOOL isFavoritedByMe;

/** Indicates approximately how many times this Tweet has been “favorited” by Twitter users. */
@property ( assign, readonly ) NSUInteger favoriteCount;

/** Indicates whether this Tweet has been retweeted by the authenticating user.
  */
@property ( assign, readonly ) BOOL isRetweetedByMe;

/** Number of times this Tweet has been retweeted. 

  @discussion This field is no longer capped at 99 and will not turn into a String for “100+”
  */
@property ( assign, readonly ) NSUInteger retweetCount;;

/** The string representation of the unique identifier for this Tweet. 

  @discussion Your app should use this rather than the large integer returned by `tweetID`.
  */
@property ( copy, readonly ) NSString* tweetIDString;

/** The unsigned integer representation of the unique identifier for this Tweet. 

  @discussion This number is greater than 53 bits and some programming languages may have 
              difficulty/silent defects in interpreting it.
              Using a signed 64 bit integer for storing this identifier is safe.
              Use `tweetIDString` for fetching the identifier to stay on the safe side.
  */
@property ( assign, readonly ) NSUInteger tweetID;

#pragma mark Initialization
+ ( instancetype ) statusWithJSON: ( NSDictionary* )_JSONDict;
- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict;

@end
