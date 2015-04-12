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

#import "OTCMedia.h"

#import "_OTCGeneral.h"

@implementation OTCMedia

#pragma mark Identifier
@synthesize mediaIDString = _mediaIDString;
@synthesize mediaID = _mediaID;

@synthesize sourceTweetIDString = _sourceTweetIDString;
@synthesize sourceTweetID = _sourceTweetID;

@synthesize sourceUserIDString = _sourceUserIDString;
@synthesize sourceUserID = _sourceUserID;

#pragma mark General Content
@synthesize mediaURL = _mediaURL;
@synthesize mediaURLOverSSL = _mediaURLOverSSL;

@synthesize mediaType = _mediaType;

@synthesize largeSize = _largeSize;
@synthesize mediumSize = _mediumSize;
@synthesize smallSize = _smallSize;
@synthesize thumbSize = _thumbSize;

@synthesize aspectRatio = _aspectRatio;
@synthesize duration = _duration;
@synthesize variants = _variants;

#pragma mark Overrides
- ( NSString* ) description
    {
    return [ @{ NSLocalizedString( @"URL", nil ) : [ super description ]
              , NSLocalizedString( @"Media ID", nil ) : ( self->_mediaIDString ?: [ NSNull null ] )
              , NSLocalizedString( @"Source Tweet ID", nil ) : ( self->_sourceTweetIDString ?: [ NSNull null ] )
              , NSLocalizedString( @"Media URL", nil ) : ( self->_mediaURL ?: [ NSNull null ] )
              , NSLocalizedString( @"Media Type", nil ) : ( self->_mediaType ? @( self->_mediaType ) : [ NSNull null ] )
              , NSLocalizedString( @"Large Size", nil ) : NSStringFromSize( self->_largeSize )
              , NSLocalizedString( @"Medium Size", nil ) : NSStringFromSize( self->_mediumSize )
              , NSLocalizedString( @"Small Size", nil ) : NSStringFromSize( self->_smallSize )
              , NSLocalizedString( @"Thumbnail Size", nil ) : NSStringFromSize( self->_thumbSize )
              } description ];
    }

- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict
    {
    if ( self = [ super initWithJSON: _JSONDict ] )
        {
        self->_mediaIDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"id_str" ) copy ];
        self->_mediaID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"id" );

        self->_sourceTweetIDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"source_status_id_str" ) copy ];
        self->_sourceTweetID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"source_status_id" );

        self->_sourceUserIDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"source_user_id_str" ) copy ];
        self->_sourceUserID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"source_user_id" );

        self->_mediaURL = [ NSURL URLWithString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"media_url" ) ];
        self->_mediaURLOverSSL = [ NSURL URLWithString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"media_url_https" ) ];

        NSString* mediaTypeString = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"type" );
        if ( [ mediaTypeString isEqualToString: @"photo" ] )
            self->_mediaType = OTCMediaTypePhoto;
        else if ( [ mediaTypeString isEqualToString: @"video" ] )
            self->_mediaType = OTCMediaTypeVideo;
        else
            self->_mediaType = OTCMediaTypeUnknown;

        NSDictionary* sizesObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"sizes" );
        if ( sizesObject )
            {
            self->_largeSize  = _OTCSizeWhichHasBeenParsedOutOfJSON( sizesObject, @"large" );
            self->_mediumSize = _OTCSizeWhichHasBeenParsedOutOfJSON( sizesObject, @"medium" );
            self->_smallSize  = _OTCSizeWhichHasBeenParsedOutOfJSON( sizesObject, @"small" );
            self->_thumbSize  = _OTCSizeWhichHasBeenParsedOutOfJSON( sizesObject, @"thumb" );
            }

        NSDictionary* videoInfoObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"video_info" );
        if ( videoInfoObject )
            {
            NSArray* aspectRatioObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( videoInfoObject, @"aspect_ratio" );
            if ( aspectRatioObject )
                self->_aspectRatio = NSMakeSize( [ aspectRatioObject.firstObject doubleValue ]
                                               , [ aspectRatioObject.lastObject doubleValue ] );

            self->_duration = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( videoInfoObject, @"duration_millis" );

            NSArray* variantsObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( videoInfoObject, @"variants" );
            NSMutableArray* wrappedVariants = [ NSMutableArray array ];
            for ( NSDictionary* variantDict in variantsObject )
                [ wrappedVariants addObject: [ [ OTCVideoVariant alloc ] initWithJSON: variantDict ] ];

            if ( wrappedVariants.count > 0 )
                self->_variants = [ wrappedVariants copy ];
            }
        }

    return self;
    }

#pragma mark Initialization
+ ( instancetype ) mediaWithJSON: ( NSDictionary* )_JSONDict
    {
    return [ [ [ self class ] alloc ] initWithJSON: _JSONDict ];
    }

@end

#pragma mark OTCVideoVariant class
@implementation OTCVideoVariant : NSObject

@synthesize JSONObject = _JSONObject;
@synthesize bitrate = _bitrate;
@synthesize MIMEType = _MIMEType;
@synthesize URL = _URL;

#pragma mark Overrides
- ( NSString* ) description
    {
    return [ @{ NSLocalizedString( @"Bitrate", nil ) : ( self->_bitrate ? @( self->_bitrate ) : [ NSNull null ] )
              , NSLocalizedString( @"MIME Type", nil ) : ( self->_MIMEType ?: [ NSNull null ] )
              , NSLocalizedString( @"Video URL", nil ) : ( self->_URL ?: [ NSNull null ] )
              } description ];
    }

#pragma mark Initialization
- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict
    {
    if ( !_JSONDict )
        return nil;

    if ( self = [ super init ] )
        {
        self->_JSONObject = _JSONDict;

        self->_bitrate = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"bitrate" );
        self->_MIMEType = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"content_type" ) copy ];
        self->_URL = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"url" );
        }

    return self;
    }

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