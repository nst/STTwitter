//
//  OTC.m
//  TwitterAPILab
//
//  Created by Tong G. on 4/10/15.
//
//

#import "OTCStatus.h"
#import "NSDate+WSCCocoaDate.h"

@implementation OTCStatus

@synthesize JSONArray = _JSONDict;

#pragma mark Attributes
@synthesize dateCreated = _dataCreated;

// Attributes
@synthesize isFavoritedByMe = _isFavoritedByMe;
@synthesize favoriteCount = _favoriteCount;
@synthesize isRetweetedByMe = _isRetweetedByMe;
@synthesize retweetCount = _retweetCount;

// IDs
@synthesize tweetIDString = _tweetIDString;
@synthesize tweetID = _tweetID;

#pragma mark Initialization
+ ( instancetype ) statusWithJSON: ( NSDictionary* )_JSONDict
    {
    return [ [ [ self class ] alloc ] initWithJSON: _JSONDict ];
    }

- ( instancetype ) initWithJSON: ( NSDictionary* )_JSON
    {
    if ( self = [ super init ] )
        {
        self->_JSONDict = _JSON;

        self->_dataCreated = [ [ NSDate dateWithNaturalLanguageString: self->_JSONDict[ @"created_at" ] ] dateWithLocalTimeZone ];

        self->_isFavoritedByMe = [ self->_JSONDict[ @"favorited" ] boolValue ];
        self->_favoriteCount = [ self->_JSONDict[ @"favorite_count" ] unsignedIntegerValue ];
        self->_isRetweetedByMe = [ self->_JSONDict[ @"retweeted" ] boolValue ];
        self->_retweetCount = [ self->_JSONDict[ @"retweet_count" ] unsignedIntegerValue ];

        self->_tweetIDString = [ self->_JSONDict[ @"id_str" ] copy ];
        self->_tweetID = [ self->_JSONDict[ @"id" ] unsignedIntegerValue ];
        }

    return self;
    }

@end
