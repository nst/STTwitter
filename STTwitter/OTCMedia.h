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
    // Identifier
    NSString* _mediaIDString;
    NSUInteger _mediaID;

    // Content
    NSURL __strong* _mediaURL;
    NSURL __strong* _mediaURLOverSSL;

    OTCMediaType _mediaType;
    }

#pragma mark Identifier
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

#pragma mark Content

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

@property ( assign, readonly ) OTCMediaType mediaType;

#pragma mark Initialization
+ ( instancetype ) mediaWithJSON: ( NSDictionary* )_JSONDict;

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