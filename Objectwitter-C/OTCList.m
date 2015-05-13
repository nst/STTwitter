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

#import "OTCList.h"
#import "OTCTwitterUser.h"
#import "NSURL+Objectwitter-C.h"
#import "NSDate+WSCCocoaDate.h"

#import "_OTCGeneral.h"

@implementation OTCList

@synthesize JSONDict = _JSONDict;

@synthesize ID = _ID;
@synthesize IDString = _IDString;

@synthesize URI = _URI;
@synthesize slug = _slug;
@synthesize shortenName = _shortenName;
@synthesize fullName = _fullName;

@synthesize subscribedCount = _subscriberCount;
@synthesize memberCount = _memberCount;
@synthesize subscribing = _subscribing;

@synthesize isPrivate = _isPrivate;
@synthesize descriptionSetByCreator = _descriptionSetByCreator;
@synthesize creationDate = _creationDate;
@synthesize creator = _creator;

#pragma mark Initialization
+ ( instancetype ) listWithJSON: ( NSDictionary* )_JSONObject
    {
    return [ [ self alloc ] initWithJSON: _JSONObject ];
    }

- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONObject
    {
    if ( !_JSONObject )
        return nil;

    if ( self = [ super init ] )
        {
        self->_JSONDict = _JSONObject;

        self->_ID = _OTCSInt64WhichHasBeenParsedOutOfJSON( self->_JSONDict, @"id" );
        self->_IDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"id_str" ) copy ];

        self->_URI = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"uri" ) copy ];
        self->_slug = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"slug" ) copy ];
        self->_shortenName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"name" ) copy ];
        self->_fullName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"full_name" ) copy ];

        self->_subscriberCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"subscriber_count" );
        self->_memberCount = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"member_count" );
        self->_subscribing = _OTCBooleanWhichHasBeenParsedOutOfJSON( self->_JSONDict,  @"following" );

        self->_isPrivate = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"mode" ) isEqualToString: @"private" ];
        self->_descriptionSetByCreator = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"description" ) copy ];
        self->_creationDate = [ [ NSDate dateWithNaturalLanguageString: [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"created_at" ) copy ] ] dateWithLocalTimeZone ];
        self->_creator = [ OTCTwitterUser userWithJSON: _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"user" ) ];
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