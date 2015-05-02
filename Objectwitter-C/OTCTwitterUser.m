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

#import "OTCTwitterUser.h"
#import "OTCTweet.h"
#import "OTCEmbeddedURL.h"
#import "NSDate+WSCCocoaDate.h"
#import "NSColor+Objectwitter-C.h"

#import "_OTCGeneral.h"

@implementation OTCTwitterUser

@synthesize JSONObject = _JSONObject;

@synthesize ID = _ID;
@synthesize IDString = _IDString;

@synthesize displayName = _displayName;
@synthesize screenName = _screenName;

@synthesize isContributorsEnabled = _isContributorsEnabled;
@synthesize isProtected = _isProtected;
@synthesize isVerified = _isVerified;
@synthesize isTranslator = _isTranslator;

@synthesize dateCreated = _dateCreated;
@synthesize usesDefaultTheme = _usesDefaultTheme;
@synthesize usesDefaultAvatar = _usesDefaultAvatar;
@synthesize usesBackgroundImage = _usesBackgroundImage;

@synthesize bio = _bio;
@synthesize URLEmbeddedInBio = _URLEmbeddedInBio;
@synthesize website = _website;
@synthesize location = _location;

@synthesize profileBackgroundTile = _profileBackgroundTile;
@synthesize profileBackgroundColor = _profileBackgroundColor;
@synthesize profileBackgroundImageURL = _profileBackgroundImageURL;
@synthesize profileBackgroundImageURLOverSSL = _profileBackgroundImageURLOverSSL;
@synthesize profileBannerURL = _profileBannerURL;
@synthesize avatarImageURL = _avatarImageURL;
@synthesize normalAvatarImageURLOverSSL = _normalAvatarImageURLOverSSL;
@synthesize biggerAvatarImageURLOverSSL = _biggerAvatarImageURLOverSSL;
@synthesize miniAvatarImageURLOverSSL = _miniAvatarImageURLOverSSL;
@synthesize originalAvatarImageURLOverSSL = _originalAvatarImageURLOverSSL;

@synthesize profileLinkColor = _profileLinkColor;
@synthesize profileSidebarBorderColor = _profileSidebarBorderColor;
@synthesize profileSidebarFillColor = _profileSidebarFillColor;
@synthesize profileTextColor = _profileTextColor;

@synthesize favoritesCount = _favoritesCount;
@synthesize followersCount = _followersCount;
@synthesize followingsCount = _followingsCount;
@synthesize listedCount = _listedCount;
@synthesize tweetsCount = _tweetsCount;

@synthesize sentFollowRequestByMe = _sentFollowRequestByMe;
@synthesize isFollowing = _isFollowing;

@synthesize isGeoEnabled = _isGeoEnabled;
@synthesize language = _language;
@synthesize timeZone = _timeZone;
@synthesize timeZoneName = _timeZoneName;
@synthesize UTCOffset = _UTCOffset;
@synthesize withheldInCountries = _withheldInCountries;
@synthesize withheldScope = _withheldScope;

@synthesize mostRecentTweet = _mostRecentTweet;

#pragma mark Initialization
+ ( instancetype ) userWithJSON: ( NSDictionary* )_JSONDict
    {
    return [ [ [ self class ] alloc ] initWithJSON: _JSONDict ];
    }

- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict
    {
    if ( !_JSONDict )
        return nil;

    if ( self = [ super init ] )
        {
        self->_JSONObject = _JSONDict;

        self->_ID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"id" );
        self->_IDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"id_str" ) copy ];

        self->_displayName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"name" ) copy ];

        NSString* tmpScreenName = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"screen_name" );
        self->_screenName = tmpScreenName ? [ @"@" stringByAppendingString: tmpScreenName ] : nil;

        self->_isContributorsEnabled = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"contributors_enabled" );
        self->_isProtected = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"protected" );
        self->_isVerified = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"verified" );
        self->_isTranslator = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"is_translator" );

        self->_dateCreated = [ [ NSDate dateWithNaturalLanguageString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"created_at" ) ] dateWithLocalTimeZone ];
        self->_usesDefaultTheme = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"default_profile" );
        self->_usesDefaultAvatar = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"default_profile_image" );
        self->_usesBackgroundImage = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_use_background_image" );

        self->_bio = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"description" ) copy ];

        NSDictionary* entitiesObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"entities" );
        if ( entitiesObject )
            {
            NSDictionary* descriptionObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( entitiesObject, @"description" );
            self->_URLEmbeddedInBio = [ _OTCArrayValueWhichHasBeenParsedOutOfJSON( descriptionObject, @"urls"
                                                                                 , [ OTCEmbeddedURL class ]
                                                                                 , @selector( embeddedURLWithJSON: )
                                                                                 ) firstObject ];

            NSDictionary* urlObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( entitiesObject, @"url" );
            self->_website = [ _OTCArrayValueWhichHasBeenParsedOutOfJSON( urlObject, @"urls"
                                                                        , [ OTCEmbeddedURL class ]
                                                                        , @selector( embeddedURLWithJSON: )
                                                                        ) firstObject ];
            }

        self->_location = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"location" ) copy ];

        self->_profileBackgroundTile = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_background_tile" );
        self->_profileBackgroundColor = [ NSColor colorWithHTMLColor: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_background_color" ) ];
        self->_profileBackgroundImageURL = [ NSURL URLWithString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_background_image_url" ) ];
        self->_profileBackgroundImageURLOverSSL = [ NSURL URLWithString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_background_image_url_https" ) ];
        self->_profileBannerURL = [ NSURL URLWithString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_banner_url" ) ];
        self->_avatarImageURL = [ NSURL URLWithString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_image_url" ) ];
        
        self->_normalAvatarImageURLOverSSL = [ NSURL URLWithString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_image_url_https" ) ];
        self->_originalAvatarImageURLOverSSL = [ self->_normalAvatarImageURLOverSSL URLByReplacingOccurrencesOfStringInPath: @"_normal" withString: @"" ];
        self->_biggerAvatarImageURLOverSSL = [ self->_originalAvatarImageURLOverSSL URLByAppendingStringToLastPathComponent: @"_bigger" ];
        self->_miniAvatarImageURLOverSSL = [ self->_originalAvatarImageURLOverSSL URLByAppendingStringToLastPathComponent: @"_mini" ];

        self->_profileLinkColor = [ NSColor colorWithHTMLColor: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_link_color" ) ];
        self->_profileSidebarBorderColor = [ NSColor colorWithHTMLColor: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_sidebar_border_color" ) ];
        self->_profileSidebarFillColor = [ NSColor colorWithHTMLColor: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_sidebar_fill_color" ) ];
        self->_profileTextColor = [ NSColor colorWithHTMLColor: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"profile_text_color" ) ];

        self->_favoritesCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"favourites_count" );
        self->_followersCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"followers_count" );
        self->_followingsCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"friends_count" );
        self->_listedCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"listed_count" );
        self->_tweetsCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"statuses_count" );

        self->_sentFollowRequestByMe = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"follow_request_sent" );
        self->_isFollowing = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"following" );

        self->_isGeoEnabled = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"geo_enabled" );
        self->_language = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"lang" ) copy ];

        self->_UTCOffset = _OTCIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"utc_offset" );
        self->_timeZone = [ NSTimeZone timeZoneForSecondsFromGMT: self->_UTCOffset ];
        self->_timeZoneName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"time_zone" ) copy ];

        self->_withheldInCountries = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"withheld_in_countries" ) copy ];
        self->_withheldScope = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"withheld_scope" ) copy ];

        self->_mostRecentTweet = [ OTCTweet tweetWithJSON: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"status" ) ];
        }

    return self;
    }

@end

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