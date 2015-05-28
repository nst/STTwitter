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

@class OTCPlace;
@class OTCTwitterUser;

typedef NS_ENUM( NSUInteger,  OTCTweetType )
    { OTCTweetTypeUnknown       = 0
    , OTCTweetTypeNormalTweet   = 1
    , OTCTweetTypeRetweet       = 2
    , OTCTweetTypeReply         = 3
    , OTCTweetTypeDirectMessage = 4
    };

/** Tweets are the basic atomic building block of all things Twitter. 

  @discussion Tweets, also known more generically as “status updates.” 
              Tweets can be embedded, replied to, favorited, unfavorited and deleted.
  */
@interface OTCTweet : NSObject
    {
@protected
    NSDictionary __strong* _JSONDict;

    // Identifier
    NSString* _tweetIDString;
    SInt64 _tweetID;

    // Actions
    BOOL _isFavoritedByMe;
    NSUInteger _favoriteCount;
    BOOL _isRetweetedByMe;
    NSUInteger _retweetCount;

    // Content
    OTCTweetType _type;
    NSString* _tweetText;
    NSDate __strong* _dateCreated;
    NSString* _source;
    NSString* _language;
    BOOL _isTruncated;

    NSString* _replyToUserScreenName;
    NSString* _replyToUserIDString;
    NSUInteger _replyToUserID;
    NSString* _replyToTweetIDString;
    NSUInteger _replyToTweetID;

    // Resolving Tweet
    NSArray __strong* _hashtags;
    NSArray __strong* _financialSymbols;
    NSArray __strong* _embeddedURLs;
    NSArray __strong* _userMentions;
    NSArray __strong* _media;

    // Geo
    OTCPlace __strong* _place;

    // Retweeting
    OTCTweet __strong* _originalTweet;

    // Quotation
    SInt64 _quotedTweetID;
    NSString* _quotedTweetIDString;
    OTCTweet* _quotedTweet;

    // Author
    OTCTwitterUser __strong* _author;
    }

@property ( retain, readonly ) NSDictionary* JSONArray;

#pragma mark Identifier
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
@property ( assign, readonly ) SInt64 tweetID;

#pragma mark Actions
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
@property ( assign, readonly ) NSUInteger retweetCount;

#pragma mark Content
/** Type of the tweet represented by receiver.
  */
@property ( assign, readonly ) OTCTweetType type;

/** The actual UTF-8 text of the status update. 

  @discussion See twitter-text for details on what is currently considered valid characters.
  */
@property ( copy, readonly ) NSString* tweetText;

/** UTC time when this Tweet was created. */
@property ( retain, readonly ) NSDate* dateCreated;

/** Utility used to post the Tweet, as an HTML-formatted string. 

  @discussion Tweets from the Twitter website have a source value of web.
  */
@property ( copy, readonly ) NSString* source;

/** When present, indicates a BCP 47 language identifier corresponding to the machine-detected language 
    of the Tweet text, or “und” if no language could be detected.
    
  @return This property is nilable.
  */
@property ( copy, readonly ) NSString* language;

/** Indicates whether the value of the text parameter was truncated, for example, 
    as a result of a retweet exceeding the 140 character Tweet length. 
    
  @discussion Truncated text will end in ellipsis, like this ... 
              Since Twitter now rejects long Tweets vs truncating them, 
              the large majority of Tweets will have this set to `NO`.
              Note that while native retweets may have their toplevel text property shortened, 
              the original text will be available under the `retweetedTweet` property and the `isTruncated`
              property will be set to the value of the original status (in most cases, `NO`).
  */
@property ( assign, readonly ) BOOL isTruncated;

/** If the represented Tweet is a reply, this property represents the screen name of the original Tweet’s author.

  @return This property is nilable.
  */
@property ( copy, readonly ) NSString* replyToUserScreenName;

/** If the represented Tweet is a reply, this property represents the string
    representation of the original Tweet’s author ID. 
    
  @discussion This will not necessarily always be the user directly mentioned in the Tweet.
  
  @return This property is nilable.
  */
@property ( copy, readonly ) NSString* replyToUserIDString;

/** If the represented Tweet is a reply, this property represents the integer representation of the original Tweet’s author ID.
    
  @discussion This will not necessarily always be the user directly mentioned in the Tweet.
  
  @return This property is probably zero.
  */
@property ( assign, readonly ) NSUInteger replyToUserID;

/** If the represented Tweet is a reply, this property represents the string representation of the original Tweet’s ID.

  @return This property is nilable.
  */
@property ( copy, readonly ) NSString* replyToTweetIDString;

/** If the represented Tweet is a reply, this property represents the integer representation of the original Tweet’s ID.

  @return This property is probably zero.
  */
@property ( assign, readonly ) NSUInteger replyToTweetID;

#pragma mark Resolving Tweet
/** An array of `OTCHashtag` objects which represent an array of hashtags 
    which have been parsed out of the Tweet text.
  */
@property ( strong, readonly ) NSArray* hashtags;

/** An array of `OTCFinancialSymbol` objects which represente an array of financial symbols 
    starting with the dollar sign extracted from the Tweet text.
  */
@property ( strong, readonly ) NSArray* financialSymbols;

/** An array of `OTCEmbeddedURL` objects which represent an array of embedded URLs 
    included in the text of a Tweet or within textual fields of an `OTCTwitterUser` object.
  */
@property ( strong, readonly ) NSArray* embeddedURLs;

/** An array of `OTCUserMention` objects which represent other Twitter users 
    mentioned in the text of the Tweet.
  */
@property ( strong, readonly ) NSArray* userMentions;

/** An array of `OTCMedia` objects which represent media elements uploaded with the Tweet.
  */
@property ( strong, readonly ) NSArray* media;

#pragma mark Geo
/** When present, indicates that the tweet is associated (but not necessarily originating from) a place.
  */
@property ( strong, readonly ) OTCPlace* place;

#pragma mark Retweeting
/** This property contains a representation of the original Tweet that was retweeted.

  @discussion Users can amplify the broadcast of tweets authored by other users by retweeting.
              Retweets can be distinguished from typical Tweets by the existence of a `originalTweet` property.
              Note that retweets of retweets do not show representations of the intermediary retweet, but only the original tweet.
              (Users can also unretweet a retweet they created by deleting their retweet.)
  */
@property ( strong, readonly ) OTCTweet* originalTweet;

#pragma mark Quotation
/** This property is the integer value Tweet ID of the quoted Tweet.
  */
@property ( assign, readonly ) SInt64 quotedTweetID;

/** This property is the string representation Tweet ID of the quoted Tweet.
  */
@property ( copy, readonly ) NSString* quotedTweetIDString;

/** This property is a representation of the Tweet of the original Tweet that was quoted
  */
@property ( strong, readonly ) OTCTweet* quotedTweet;

#pragma mark Author
/** The user who posted this Tweet. 

  @discussion Perspectival attributes embedded within this object are unreliable. 
              See [Why are embedded objects stale or inaccurate?](https://dev.twitter.com/docs/faq/basics/why-are-embedded-objects-stale-or-inaccurate).
  */
@property ( strong, readonly ) OTCTwitterUser* author;

#pragma mark Initialization
+ ( instancetype ) tweetWithJSON: ( NSDictionary* )_JSONDict;
- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict;

#pragma mark Comparing
- ( BOOL ) isEqualToTweet: ( OTCTweet* )_AnotherTweet;

- ( NSString* ) _stringifyTweetType: ( OTCTweetType )_TweetType;

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