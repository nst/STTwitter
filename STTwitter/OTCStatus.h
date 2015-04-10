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

    BOOL _isFavoritedByMe;
    NSUInteger _favoriteCount;
    }

@property ( retain, readonly ) NSDictionary* JSONArray;

#pragma mark Attributes
/** UTC time when this Tweet was created. */
@property ( retain, readonly ) NSDate* dateCreated;

/** Indicates whether this Tweet has been favorited by the authenticating user. */
@property ( assign, readonly ) BOOL isFavoritedByMe;

/** Indicates approximately how many times this Tweet has been “favorited” by Twitter users. */
@property ( assign, readonly ) NSUInteger favoriteCount;

#pragma mark Initialization
+ ( instancetype ) statusWithJSON: ( NSDictionary* )_JSONDict;
- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict;

@end
