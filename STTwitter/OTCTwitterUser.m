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

@implementation OTCTwitterUser

@synthesize ID = _ID;
@synthesize IDString = _IDString;

@synthesize displayName = _displayName;
@synthesize screenName = _screenName;

@synthesize isContributorsEnabled = _isContributorsEnabled;
@synthesize isProtected = _isProtected;
@synthesize isVerified = _isVerified;

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
@synthesize avatarImageURLOverSSL = _avatarImageURLOverSSL;

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
    if ( self = [ super init ] )
        {
        
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