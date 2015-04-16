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
    NSDictionary __strong* _JSONObject;

    NSUInteger _ID;
    NSString* _IDString;

    NSString* _displayName;
    NSString* _screenName;

    BOOL _isContributorsEnabled;
    BOOL _isProtected;
    BOOL _isVerified;
    BOOL _isTranslator;

    NSDate __strong* _dateCreated;
    BOOL _usesDefaultTheme;
    BOOL _usesDefaultAvatar;
    BOOL _usesBackgroundImage;

    NSString* _bio;
    OTCEmbeddedURL __strong* _URLEmbeddedInBio;
    OTCEmbeddedURL __strong* _website;
    NSString* _location;

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
    NSString* _timeZoneName;
    NSInteger _UTCOffset;
    NSString* _withheldInCountries;
    NSString* _withheldScope;

    OTCTweet __strong* _mostRecentTweet;
    }

@property ( strong, readonly ) NSDictionary* JSONObject;

/** The integer representation of the unique identifier for this User. 

  @discussion This number is greater than 53 bits and some programming languages 
              may have difficulty/silent defects in interpreting it. 
              Using a signed 64 bit integer for storing this identifier is safe. 
              Use `IDString` property for fetching the identifier to stay on the safe side. 
              See Twitter IDs, JSON and Snowflake.
  */
@property ( assign, readonly ) NSUInteger ID;

/** The string representation of the unique identifier for this User. 

  @discussion Implementations should use this rather than the large, possibly un-consumable integer in `ID` property.
  */
@property ( copy, readonly ) NSString* IDString;

/** The name of the user, as they’ve defined it. 

  @discussion Not necessarily a person’s name. Typically capped at 20 characters, but subject to change.
  */
@property ( copy, readonly ) NSString* displayName;

/** The screen name, handle, or alias that this user identifies themselves with. 

  @discussion `screenName` are unique but subject to change. 
              Use `IDString` as a user identifier whenever possible. 
              Typically a maximum of 15 characters long, but some historical accounts may exist with longer names.
  */
@property ( copy, readonly ) NSString* screenName;

/** Indicates that the user has an account with “contributor mode” enabled,
    allowing for Tweets issued by the user to be co-authored by another account. 
    
  @dicussion Corresponding parameter: contributors_enabled.
    
  @return Rarely true.
  */
@property ( assign, readonly ) BOOL isContributorsEnabled;

/** When true, indicates that this user has chosen to protect their Tweets. 

  @discussion Corresponding parameter: protected.
              See About [Public and Protected Tweets](https://support.twitter.com/articles/14016-about-public-and-protected-tweets).
  */
@property ( assign, readonly ) BOOL isProtected;

/** When true, indicates that the user has a verified account. 
 
  @discussion Corresponding parameter: verified.
              See [Verified Accounts](https://support.twitter.com/articles/119135-faqs-about-verified-accounts).
  */
@property ( assign, readonly ) BOOL isVerified;

/** When true, indicates that the user is a participant in [Twitter’s translator community](http://translate.twttr.com/).
  */
@property ( assign, readonly ) BOOL isTranslator;

/** The UTC datetime that the user account was created on Twitter.

  @dicussion Corresponding parameter: created_at.
  */
@property ( strong, readonly ) NSDate* dateCreated;

/** When true, indicates that the user has not altered the theme or background of their user profile.

  @dicussion Corresponding parameter: default_profile.
  */
@property ( assign, readonly ) BOOL usesDefaultTheme;

/** When true, indicates that the user has not uploaded their own avatar and a default egg avatar is used instead.

  @dicussion Corresponding parameter: default_profile_image.
  */
@property ( assign, readonly ) BOOL usesDefaultAvatar;

/** When true, indicates the user wants their uploaded background image to be used.

  @dicussion Corresponding parameter: profile_use_background_image.
  */
@property ( assign, readonly ) BOOL usesBackgroundImage;

/** The user-defined UTF-8 string describing their account.

  @dicussion Corresponding parameter: description.
  */
@property ( copy, readonly ) NSString* bio;

/** The URL which has been parsed out of the bio of user.
  */
@property ( strong, readonly ) OTCEmbeddedURL* URLEmbeddedInBio;

/** The URL which points to the website of user.
  */
@property ( strong, readonly ) OTCEmbeddedURL* website;

/** The user-defined location for this account’s profile. 

  @discussion Not necessarily a location nor parseable. 
              This field will occasionally be fuzzily interpreted by the Search service.
  */
@property ( copy, readonly ) NSString* location;

/** When true, indicates that the user’s `profileBackgroundImageURL` should be tiled when displayed.
  */
@property ( assign, readonly ) BOOL profileBackgroundTile;

/** The `NSColor` object which represents the color chosen by the user for their background.

  @discussion Corresponding parameter: profile_background_color.
  */
@property ( strong, readonly ) NSColor* profileBackgroundColor;

/** A HTTP-based URL pointing to the background image the user has uploaded for their profile.

  @discussion Corresponding parameter: profile_background_image_url.
  */
@property ( strong, readonly ) NSURL* profileBackgroundImageURL;

/** A HTTPS-based URL pointing to the background image the user has uploaded for their profile.

  @discussion Corresponding parameter: profile_background_image_url_https.
  */
@property ( strong, readonly ) NSURL* profileBackgroundImageURLOverSSL;

/** The HTTPS-based URL pointing to the standard web representation of the user’s uploaded profile banner. 

  @discussion By adding a final path element of the URL, you can obtain different 
              image sizes optimized for specific displays. 
              In the future, an API method will be provided to serve these URLs 
              so that you need not modify the original URL. For size variations, 
              please see [User Profile Images and Banners](https://dev.twitter.com/overview/general/user-profile-images-and-banners).
              Corresponding parameter: profile_banner_url.
  */
@property ( strong, readonly ) NSURL* profileBannerURL;

/** A HTTP-based URL pointing to the user’s avatar image. 

  @discussion Corresponding parameter: profile_image_url.
              See [User Profile Images and Banners](https://dev.twitter.com/overview/general/user-profile-images-and-banners).
  */
@property ( strong, readonly ) NSURL* avatarImageURL;

/** A HTTPS-based URL pointing to the user’s avatar image.

  @discussion Corresponding parameter: profile_image_url_https.
              See [User Profile Images and Banners](https://dev.twitter.com/overview/general/user-profile-images-and-banners).
  */
@property ( strong, readonly ) NSURL* avatarImageURLOverSSL;

/** The `NSColor` object which represents the color chosen to display links with in their Twitter UI.

  @discussion Corresponding parameter: profile_link_color.
  */
@property ( strong, readonly ) NSColor* profileLinkColor;

/** The `NSColor` object which represents the color chosen to display sidebar borders with in their Twitter UI.

  @discussion Corresponding parameter: profile_sidebar_border_color.
  */
@property ( strong, readonly ) NSColor* profileSidebarBorderColor;

/** The `NSColor` object which represents the color chosen to display sidebar backgrounds with in their Twitter UI.

  @discussion Corresponding parameter: profile_sidebar_fill_color.
  */
@property ( strong, readonly ) NSColor* profileSidebarFillColor;

/** The `NSColor` object which represents the color chosen to display text with in their Twitter UI.

  @discussion Corresponding parameter: profile_text_color.
  */
@property ( strong, readonly ) NSColor* profileTextColor;

/** The number of tweets this user has favorited in the account’s lifetime.

  @discussion British spelling used in the field name for historical reasons.
              Corresponding parameter: favourites_count.
  */
@property ( assign, readonly ) NSUInteger favoritesCount;

/** The number of followers this account currently has. 

  @discussion Under certain conditions of duress, this field will temporarily indicate “0.”
              Corresponding parameter: followers_count.
  */
@property ( assign, readonly ) NSUInteger followersCount;

/** The number of users this account is following (AKA their “followings”). 

  @dicussion Under certain conditions of duress, this field will temporarily indicate “0.”
             Corresponding parameter: friends_count.
  */
@property ( assign, readonly ) NSUInteger followingsCount;

/** The number of public lists that this user is a member of.

  @discussion Corresponding parameter: listed_count.
  */
@property ( assign, readonly ) NSUInteger listedCount;

/** The number of tweets (including retweets) issued by the user.

  @discussion Corresponding parameter: statuses_count.
  */
@property ( assign, readonly ) NSUInteger tweetsCount;

/** When true, indicates that the authenticating user has issued a follow request to this protected user account.

  @discussion Corresponding parameter: follow_request_sent.
  */
@property ( assign, readonly ) BOOL sentFollowRequestByMe;

/** When true, indicates that the authenticating user is following this user. 

  @discussion Corresponding parameter: following.
              Some false negatives are possible when set to “false,” but these false negatives are 
              increasingly being represented as “null” instead. See [Discussion](http://groups.google.com/group/twitter-development-talk/browse_thread/thread/42ba883b9f8e3c6e?tvc=2).
  */
@property ( assign, readonly ) BOOL isFollowing;

/** When true, indicates that the user has enabled the possibility of geotagging their Tweets. 

  @discussion This field must be true for the current user to attach geographic data when using POST statuses / update.
              Corresponding parameter: geo_enabled.
  */
@property ( assign, readonly ) BOOL isGeoEnabled;

/** The BCP 47 code for the user’s self-declared user interface language. 

  @discussion May or may not have anything to do with the content of their Tweets.
  */
@property ( copy, readonly ) NSString* language;

/** An `NSTimeZone` object describing the Time Zone this user declares themselves within.

  @discussion Corresponding parameter: time_zone.
  */
@property ( strong, readonly ) NSTimeZone* timeZone;

/** A string describing the Time Zone this user declares themselves within.
  */
@property ( copy, readonly ) NSString* timeZoneName;

/** The offset from GMT/UTC in seconds.

  @discussion Corresponding parameter: utc_offset.
  */
@property ( assign, readonly ) NSInteger UTCOffset;

/** When present, indicates a textual representation of the two-letter country codes this user is withheld from.

  @discussion Corresponding parameter: withheld_in_countries.
  */
@property ( copy, readonly ) NSString* withheldInCountries;

/** When present, indicates whether the content being withheld is the “status” or a “user.”

  @discussion Corresponding parameter: withheld_scope.
  */
@property ( copy, readonly ) NSString* withheldScope;

/** If possible, the user’s most recent tweet or retweet. 

  @discussion Corresponding parameter: status.
              In some circumstances, this data cannot be provided and this field will be omitted, null, or empty.
              Perspectival attributes within tweets embedded within users cannot always be relied upon. 
              See [Why are embedded objects stale or inaccurate?](https://dev.twitter.com/docs/faq/basics/why-are-embedded-objects-stale-or-inaccurate).
  */
@property ( strong, readonly ) OTCTweet* mostRecentTweet;

#pragma mark Initialization
+ ( instancetype ) userWithJSON: ( NSDictionary* )_JSONDict;
- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict;

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