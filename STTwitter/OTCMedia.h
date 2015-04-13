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

#import "OTCEmbeddedURL.h"

@class OTCVideoVariant;

typedef NS_ENUM( NSUInteger, OTCMediaType )
    {
    /// Unknown
      OTCMediaTypeUnknown = 0

    /// Identifies a photo
    , OTCMediaTypePhoto = 1

    /// Identifies a video
    , OTCMediaTypeVideo = 2
    };

@interface OTCMedia : OTCEmbeddedURL
    {
@private
    // Identifiers
    NSString* _mediaIDString;
    NSUInteger _mediaID;

    NSString* _sourceTweetIDString;
    NSUInteger _sourceTweetID;

    NSString* _sourceUserIDString;
    NSUInteger _sourceUserID;

    // Content
    NSURL __strong* _mediaURL;
    NSURL __strong* _mediaURLOverSSL;

    OTCMediaType _mediaType;

    NSSize _largeSize;
    NSSize _mediumSize;
    NSSize _smallSize;
    NSSize _thumbSize;

    NSSize _aspectRatio;
    NSUInteger _duration;
    NSArray __strong* _variants;
    }

#pragma mark Identifiers
/** The string representation of the unique identifier for media

  @discussion Your app should use this rather than the large integer returned by `mediaID`
  */
@property ( copy, readonly ) NSString* mediaIDString;

/** The unsigned integer representation of the unique identifier for this Tweet. 

  @discussion This number is greater than 53 bits and some programming languages may have 
              difficulty/silent defects in interpreting it.
              Using a signed 64 bit integer for storing this identifier is safe.
              Use `mediaIDString` for fetching the identifier to stay on the safe side.
  */
@property ( assign, readonly ) NSUInteger mediaID;

/** For Tweets containing media that was originally associated with a different tweet, 
    this string-based ID points to the original Tweet.
  */
@property ( copy, readonly ) NSString* sourceTweetIDString;

/** For Tweets containing media that was originally associated with a different tweet, 
    this ID points to the original Tweet.
  */
@property ( assign, readonly ) NSUInteger sourceTweetID;

/** This string-based ID points to the original author of the Tweet containing the media represented by receiver.
  */
@property ( copy, readonly ) NSString* sourceUserIDString;

/** This ID points to the original author of the Tweet containing the media represented by receiver.
  */
@property ( assign, readonly ) NSUInteger sourceUserID;

#pragma mark General Content

/** An http:// URL pointing directly to the uploaded media file.

  @discussion For media in direct messages, `mediaURL` is the same https URL as `mediaURLOverSSL` 
              and must be accessed via an authenticated twitter.com session or by signing a request
              with the user’s access token using OAuth 1.0A. 
              It is not possible to directly embed these images in a web page.
  */
@property ( strong, readonly ) NSURL* mediaURL;


/** An https:// URL pointing directly to the uploaded media file, for embedding on https pages.

  @dicussion For media in direct messages, `mediaURLOverSSL` must be accessed via an authenticated twitter.com 
             session or by signing a request with the user’s access token using OAuth 1.0A. 
             It is not possible to directly embed these images in a web page.
  */
@property ( strong, readonly ) NSURL* mediaURLOverSSL;

/** Type of uploaded media represented by receiver.
  */
@property ( assign, readonly ) OTCMediaType mediaType;

/** Information for a large-sized (in pixels) pversion of the media.
  */
@property ( assign, readonly ) NSSize largeSize;

/** Information for a medium-sized (in pixels) pversion of the media.
  */
@property ( assign, readonly ) NSSize mediumSize;

/** Information for a small-sized (in pixels) pversion of the media.
  */
@property ( assign, readonly ) NSSize smallSize;

/** Information for a thumbnail-sized (in pixels)version of the media.
  */
@property ( assign, readonly ) NSSize thumbSize;

#pragma mark Unique to Video
/** Contains information about aspect ratio. 

  @dicussion The aspect ratio of the video, as a simplified fraction of width and height in an NSSize data structure.
             Typical values are [4, 3] or [16, 9]. This property is non-nil only when there is a video in the payload.
  */
@property ( assign, readonly ) NSSize aspectRatio;

/** The length of the video, in milliseconds. 

  @dicussion This field is non-nil only when there is a video in the payload.
  */
@property ( assign, readonly ) NSUInteger duration;

/** Different encodings/streams of the video, which represented by `OTCVideoVariant` objects.

  @discussion At least one variant is returned for each video entry. 
              Video formats returned via the API are subject to change. 
              As a best practice, you should scan all returned values and use the most appropriate format 
              for their given platform. This property is non-nil only when there is a video in the payload.
  */
@property ( retain, readonly ) NSArray* variants;

#pragma mark Initialization
+ ( instancetype ) mediaWithJSON: ( NSDictionary* )_JSONDict;

@end

#pragma mark OTCVideoVariant class
@interface OTCVideoVariant : NSObject
    {
@private
    NSDictionary __strong* _JSONObject;

    NSUInteger _bitrate;
    NSString* _MIMEType;
    NSURL __strong* _URL;
    }

@property ( retain, readonly ) NSDictionary* JSONObject;

@property ( assign, readonly ) NSUInteger bitrate;
@property ( copy, readonly ) NSString* MIMEType;
@property ( strong, readonly ) NSURL* URL;

+ ( instancetype ) videoVariantWithJSON: ( NSDictionary* )_JSONDict;
- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict;

@end // OTCVideoVariant

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