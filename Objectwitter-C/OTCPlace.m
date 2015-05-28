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

#import "OTCPlace.h"

#import "_OTCGeneral.h"

@implementation OTCPlace

@synthesize IDString = _IDString;

@synthesize localizedCountryName = _localizedCountryName;
@synthesize countryCode = _countryCode;

@synthesize fullPlaceName = _fullPlaceName;
@synthesize simplePlaceName = _simplePlaceName;

@synthesize type = _type;

@synthesize boundingBox = _boundingBox;
@synthesize additionalMetadata = _additionalMetadata;

#pragma mark Initialization
+ ( instancetype ) placeWithJSON: ( NSDictionary* )_JSONDict
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

        self->_IDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"id" ) copy ];

        self->_localizedCountryName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"country" ) copy ];
        self->_countryCode = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"country_code" ) copy ];

        self->_fullPlaceName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"full_name" ) copy ];
        self->_simplePlaceName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"name" ) copy ];

        self->_type = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"place_type" ) copy ];

        NSDictionary* boundingBoxObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"bounding_box" );
        if ( boundingBoxObject )
            self->_boundingBox = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( boundingBoxObject, @"coordinates" ) firstObject ];

        self->_additionalMetadata = [ NSURL URLWithString: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"url" ) ];
        }

    return self;
    }

@end

NSString* const OTCPlaceTypeCountry = @"country";
NSString* const OTCPlaceTypeAdmin = @"admin";
NSString* const OTCPlaceTypeCity = @"city";
NSString* const OTCPlaceTypeStreet = @"street";

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