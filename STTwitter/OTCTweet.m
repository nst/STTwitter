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
@synthesize tweetText = _tweetText;
@synthesize dateCreated = _dataCreated;
@synthesize source = _source;
@synthesize language = _language;
@synthesize isTruncated = _isTruncated;

@synthesize replyToUserScreenName = _replyToUserScreenName;
@synthesize replyToUserIDString = _replyToUserIDString;
@synthesize replyToUserID = _replyToUserID;
@synthesize replyToTweetIDString = _replyToTweetIDString;
@synthesize replyToTweetID = _replyToTweetID;

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

        self->_tweetIDString = _OTCStringWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"id_str" );
        self->_tweetID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"id" );

        self->_isFavoritedByMe = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"favorited" );
        self->_favoriteCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"favorite_count" );
        self->_isRetweetedByMe = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONDict,  @"retweeted" );
        self->_retweetCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"retweet_count" );

        self->_tweetText = _OTCStringWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"text" );
        self->_dataCreated = [ [ NSDate dateWithNaturalLanguageString: _OTCStringWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"created_at" ) ] dateWithLocalTimeZone ];
        self->_source = _OTCStringWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"source" );
        self->_language = _OTCStringWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"lang" );
        self->_isTruncated = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONDict,  @"truncated" );

        self->_replyToUserScreenName = _OTCStringWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_screen_name" );
        self->_replyToUserIDString = _OTCStringWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_user_id_str" );
        self->_replyToUserID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_user_id" );
        self->_replyToTweetIDString = _OTCStringWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_status_id_str" );
        self->_replyToTweetID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"in_reply_to_status_id" );
        }

    return self;
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
|                                                                                              |
└=============================================================================================*/