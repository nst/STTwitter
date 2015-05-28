/*=============================================================================================┐
|                     _  _  _       _                                                          |  
|                    (_)(_)(_)     | |                            _                            |██
|                     _  _  _ _____| | ____ ___  ____  _____    _| |_ ___                      |██
|                    | || || | ___ | |/ ___) _ \|    \| ___ |  (_   _) _ \                     |██
|                    | || || | ____| ( (__| |_| | | | | ____|    | || |_| |                    |██
|                     \_____/|_____)\_)____)___/|_|_|_|_____)     \__)___/                     |██
|                                                                                              |██
|       _______ _     _                         _                               _______ _      |██
|      (_______) |   (_)              _        (_)  _     _                    (_______) |     |██
|       _     _| |__  _ _____  ____ _| |_ _ _ _ _ _| |_ _| |_ _____  ____ _____ _      | |     |██
|      | |   | |  _ \| | ___ |/ ___|_   _) | | | (_   _|_   _) ___ |/ ___|_____) |     |_|     |██
|      | |___| | |_) ) | ____( (___  | |_| | | | | | |_  | |_| ____| |         | |_____ _      |██
|       \_____/|____/| |_____)\____)  \__)\___/|_|  \__)  \__)_____)_|          \______)_|     |██
|                  (__/                                                                        |██
|                                                                                              |██
|                                 Copyright (c) 2015 Tong Guo                                  |██
|                                                                                              |██
|                                     ALL RIGHTS RESERVED.                                     |██
|                                                                                              |██
└==============================================================================================┘██
  ████████████████████████████████████████████████████████████████████████████████████████████████
  ██████████████████████████████████████████████████████████████████████████████████████████████*/

#import "OTCTweet.h"
#import "OTCHashtag.h"
#import "OTCFinancialSymbol.h"
#import "OTCEmbeddedURL.h"
#import "OTCUserMention.h"
#import "OTCMedia.h"
#import "OTCPlace.h"
#import "OTCTwitterUser.h"
#import "NSDate+WSCCocoaDate.h"

#import "_OTCGeneral.h"

@implementation OTCTweet

@synthesize JSONArray = _JSONDict;

#pragma mark Identifier
@synthesize tweetIDString = _tweetIDString;
@synthesize tweetID = _tweetID;

#pragma mark Actions
@synthesize isFavoritedByMe = _isFavoritedByMe;
@synthesize favoriteCount = _favoriteCount;
@synthesize isRetweetedByMe = _isRetweetedByMe;
@synthesize retweetCount = _retweetCount;

#pragma mark Content
@synthesize type = _type;
@synthesize tweetText = _tweetText;
@synthesize dateCreated = _dateCreated;
@synthesize source = _source;
@synthesize language = _language;
@synthesize isTruncated = _isTruncated;

@synthesize replyToUserScreenName = _replyToUserScreenName;
@synthesize replyToUserIDString = _replyToUserIDString;
@synthesize replyToUserID = _replyToUserID;
@synthesize replyToTweetIDString = _replyToTweetIDString;
@synthesize replyToTweetID = _replyToTweetID;

#pragma mark Resolving Tweet
@synthesize hashtags = _hashtags;
@synthesize financialSymbols = _financialSymbols;
@synthesize embeddedURLs = _embeddedURLs;
@synthesize userMentions = _userMentions;
@synthesize media = _media;

#pragma mark Geo
@synthesize place = _place;

#pragma mark Retweeting
@synthesize originalTweet = _originalTweet;

#pragma mark Quotation
@synthesize quotedTweetID = _quotedTweetID;
@synthesize quotedTweetIDString = _quotedTweetIDString;
@synthesize quotedTweet = _quotedTweet;

#pragma mark Author
@synthesize author = _author;

#pragma mark Overrides
- ( NSString* ) description
    {
    return [ NSString stringWithFormat: @"\n👳🏻 %@\n"
                                        @"%@ %@\n\n\n"
                                      , self->_author ? [ NSString stringWithFormat: @"%@ (%@)", self->_author.displayName, self->_author.screenName ] : [ NSNull null ]
                                      , [ self _stringifyTweetType: self->_type ]
                                      , self->_tweetText ];
    }

#pragma mark Initialization
+ ( instancetype ) tweetWithJSON: ( NSDictionary* )_JSONDict
    {
    return [ [ [ self class ] alloc ] initWithJSON: _JSONDict ];
    }

- ( instancetype ) initWithJSON: ( NSDictionary* )_JSON
    {
    if ( !_JSON )
        return nil;

    if ( self = [ super init ] )
        {
        self->_JSONDict = _JSON;

        // Identifier
        self->_tweetIDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"id_str" ) copy ];
        self->_tweetID = _OTCSInt64WhichHasBeenParsedOutOfJSON( self->_JSONDict, @"id" );

        // Actions
        self->_isFavoritedByMe = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"favorited" );
        self->_favoriteCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"favorite_count" );
        self->_isRetweetedByMe = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONDict,  @"retweeted" );
        self->_retweetCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"retweet_count" );

        // Content
        self->_tweetText = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"text" ) copy ];
        self->_dateCreated = [ [ NSDate dateWithNaturalLanguageString: [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"created_at" ) copy ] ] dateWithLocalTimeZone ];
        self->_source = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"source" ) copy ];
        self->_language = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"lang" ) copy ];
        self->_isTruncated = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONDict,  @"truncated" );

        self->_replyToUserScreenName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_screen_name" ) copy ];
        self->_replyToUserIDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_user_id_str" ) copy ];
        self->_replyToUserID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_user_id" );
        self->_replyToTweetIDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_status_id_str" ) copy ];
        self->_replyToTweetID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_status_id" );

        // Resolving Tweet
        NSDictionary* entitiesObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"entities" );
        self->_embeddedURLs = _OTCArrayValueWhichHasBeenParsedOutOfJSON( entitiesObject, @"urls", [ OTCEmbeddedURL class ], @selector( embeddedURLWithJSON: ) );
        self->_hashtags = _OTCArrayValueWhichHasBeenParsedOutOfJSON( entitiesObject, @"hashtags", [ OTCHashtag class ], @selector( hashtagWithJSON: ) );
        self->_financialSymbols = _OTCArrayValueWhichHasBeenParsedOutOfJSON( entitiesObject, @"symbols", [ OTCFinancialSymbol class ], @selector( financialSymbolWithJSON: ) );
        self->_userMentions = _OTCArrayValueWhichHasBeenParsedOutOfJSON( entitiesObject, @"user_mentions", [ OTCUserMention class ], @selector( userMentionWithJSON: ) );

        NSDictionary* extendedEntitiesObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"extended_entities" );
        self->_media = _OTCArrayValueWhichHasBeenParsedOutOfJSON( extendedEntitiesObject, @"media", [ OTCMedia class ], @selector( mediaWithJSON: ) );

        // Geo
        NSDictionary* placeObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"place" );
        if ( placeObject )
            self->_place = [ OTCPlace placeWithJSON: placeObject ];

        // Retweeting
        self->_originalTweet = [ OTCTweet tweetWithJSON: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"retweeted_status" ) ];

        // Quotation
        self->_quotedTweetID = _OTCSInt64WhichHasBeenParsedOutOfJSON( self->_JSONDict, @"quoted_status_id" );
        self->_quotedTweetIDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"quoted_status_id_str" ) copy ];
        self->_quotedTweet = [ OTCTweet tweetWithJSON: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"quoted_status" ) ];

        // Author
        NSDictionary* userObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"user" );
        if ( userObject )
            self->_author = [ OTCTwitterUser userWithJSON: userObject ];

        if ( self->_originalTweet )
            self->_type = OTCTweetTypeRetweet;
        else if ( self->_replyToTweetID )
            self->_type = OTCTweetTypeReply;
        else
            self->_type = OTCTweetTypeNormalTweet;
        }

    return self;
    }

#pragma mark Comparing
- ( BOOL ) isEqualToTweet: ( OTCTweet* )_AnotherTweet
    {
    if ( self == _AnotherTweet )
        return YES;

    return self.tweetID == _AnotherTweet.tweetID;
    }

- ( BOOL ) isEqual: ( id )_Object
    {
    if ( self == _Object )
        return YES;

    if ( [ _Object isKindOfClass: [ OTCTweet class ] ] )
        return [ self isEqualToTweet: ( OTCTweet* )_Object ];

    return [ super isEqual: _Object ];
    }

- ( NSString* ) _stringifyTweetType: ( OTCTweetType )_TweetType
    {
    NSString* stringRep = nil;

    switch ( _TweetType )
        {
        case OTCTweetTypeNormalTweet:   stringRep = @"📢"; break;
        case OTCTweetTypeRetweet:       stringRep = @"🔁"; break;
        case OTCTweetTypeReply:         stringRep = @"⤴️"; break;
        case OTCTweetTypeDirectMessage: stringRep = @"💬"; break;

        default: stringRep = @"Unknown";
        }

    return stringRep;
    }

@end // OTCTweet

/*=============================================================================================┐
|                                                                                              |
|                                   The BSD 3-Clause License                                   |
|                                                                                              |
|                            Copyright (c) 2015, Tong Guo (NSTongG)                            |
|                                     All rights reserved.                                     |
|                                                                                              |
|     Redistribution and use in source and binary forms, with or without modification, are     |
|                  permitted provided that the following conditions are met:                   |
|                                                                                              |
|    1. Redistributions of source code must retain the above copyright notice, this list of    |
|                           conditions and the following disclaimer.                           |
|                                                                                              |
|  2. Redistributions in binary form must reproduce the above copyright notice, this list of   |
|     conditions and the following disclaimer in the documentation and/or other materials      |
|                               provided with the distribution.                                |
|                                                                                              |
|  3. Neither the name of the copyright holder nor the names of its contributors may be used   |
|   to endorse or promote products derived from this software without specific prior written   |
|                                         permission.                                          |
|                                                                                              |
|     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY      |
|   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF    |
|  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE  |
|  COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,   |
|      EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF      |
|    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)    |
|   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR   |
|      TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS      |
|                 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                 |
|                                                                                              |
└=============================================================================================*/