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

@synthesize isFavoritedByMe = _isFavoritedByMe;
@synthesize favoriteCount = _favoriteCount;

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
        }

    return self;
    }

@end
