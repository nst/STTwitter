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

#import <Foundation/Foundation.h>

@class OTCTweet;
@class OTCEmbeddedURL;

/** Twitter Users can be anyone or anything. They tweet, follow, create lists, have a home_timeline, 
    can be mentioned, and can be looked up in bulk.
  */
@interface OTCTwitterUser : NSObject
    {
@private
    NSUInteger _ID;
    NSString* _IDString;

    NSString* _displayName;
    NSString* _screenName;

    BOOL _isContributorsEnabled;
    BOOL _isProtected;
    BOOL _isVerified;

    NSDate __strong* _dateCreated;
    BOOL _usesDefaultTheme;
    BOOL _usesDefaultAvatar;
    BOOL _usesBackgroundImage;

    NSString* _bio;
    NSString* _location;
    OTCEmbeddedURL __strong* _website;
    OTCEmbeddedURL __strong* _URLEmbeddedInBio;

    BOOL _profileBackgroundTile;
    NSColor __strong* _profileBackgroundColor;
    NSURL __strong* _profileBackgroundImageURL;
    NSURL __strong* _profileBackgroundImageURLOverSSL;
    NSURL __strong* _profileBannerURL;
    NSURL __strong* _avatarImageURL;
    NSURL __strong* _avatarImageURLOverSSL;

    NSColor __strong* _profileLinkColor;
    NSColor __strong* _profileSidebarBorderColor;
    NSColor __strong* _profileSidebarFillColor;
    NSColor __strong* _profileTextColor;

    NSUInteger _favoritesCount;
    NSUInteger _followersCount;
    NSUInteger _followingsCount;
    NSUInteger _listedCount;
    NSUInteger _tweetsCount;

    BOOL _sentFollowRequestByMe;
    BOOL _isFollowing;

    BOOL _isGeoEnabled;
    NSString* _language;
    NSTimeZone __strong* _timeZone;
    NSInteger _UTCOffset;
    NSString* _withheldInCountries;
    NSString* _withheldScope;

    OTCTweet __strong* _mostRecentTweet;
    }

@property ( assign, readonly ) NSUInteger ID;
@property ( copy, readonly ) NSString* IDString;

@property ( copy, readonly ) NSString* displayName;
@property ( copy, readonly ) NSString* screenName;

@property ( assign, readonly ) BOOL isContributorsEnabled;
@property ( assign, readonly ) BOOL isProtected;
@property ( assign, readonly ) BOOL isVerified;

@property ( strong, readonly ) NSDate* dateCreated;
@property ( assign, readonly ) BOOL usesDefaultTheme;
@property ( assign, readonly ) BOOL usesDefaultAvatar;
@property ( assign, readonly ) BOOL usesBackgroundImage;

@property ( copy, readonly ) NSString* bio;
@property ( copy, readonly ) NSString* location;
@property ( strong, readonly ) OTCEmbeddedURL* website;
@property ( strong, readonly ) OTCEmbeddedURL* URLEmbeddedInBio;

@property ( assign, readonly ) BOOL profileBackgroundTile;
@property ( strong, readonly ) NSColor* profileBackgroundColor;
@property ( strong, readonly ) NSURL* profileBackgroundImageURL;
@property ( strong, readonly ) NSURL* profileBackgroundImageURLOverSSL;
@property ( strong, readonly ) NSURL* profileBannerURL;
@property ( strong, readonly ) NSURL* avatarImageURL;
@property ( strong, readonly ) NSURL* avatarImageURLOverSSL;

@property ( strong, readonly ) NSColor* profileLinkColor;
@property ( strong, readonly ) NSColor* profileSidebarBorderColor;
@property ( strong, readonly ) NSColor* profileSidebarFillColor;
@property ( strong, readonly ) NSColor* profileTextColor;

@property ( assign, readonly ) NSUInteger favoritesCount;
@property ( assign, readonly ) NSUInteger followersCount;
@property ( assign, readonly ) NSUInteger followingsCount;
@property ( assign, readonly ) NSUInteger listedCount;
@property ( assign, readonly ) NSUInteger tweetsCount;

@property ( assign, readonly ) BOOL sentFollowRequestByMe;
@property ( assign, readonly ) BOOL isFollowing;

@property ( assign, readonly ) BOOL isGeoEnabled;
@property ( copy, readonly ) NSString* language;
@property ( strong, readonly ) NSTimeZone* timeZone;
@property ( assign, readonly ) NSInteger UTCOffset;
@property ( copy, readonly ) NSString* withheldInCountries;
@property ( copy, readonly ) NSString* withheldScope;

@property ( strong, readonly ) OTCTweet* mostRecentTweet;

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