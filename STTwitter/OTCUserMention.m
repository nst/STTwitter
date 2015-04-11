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

#import "OTCUserMention.h"

#import "_OTCGeneral.h"

@implementation OTCUserMention

@synthesize userID = _userID;
@synthesize userIDString = _userIDString;
@synthesize displayName = _displayName;
@synthesize screenName = _screenName;

#pragma mark Overrides
- ( NSString* ) description
    {
    return [ @{ NSLocalizedString( @"User ID", nil ) : ( self->_userIDString ?: [ NSNull null ] )
              , NSLocalizedString( @"Display Name", nil ) : ( self->_displayName ?: [ NSNull null ] )
              , NSLocalizedString( @"Screen Name", nil ) : ( self->_screenName ?: [ NSNull null ] )
              , NSLocalizedString( @"Display Text", nil ) : ( self->_displayText ?: [ NSNull null ] )
              , NSLocalizedString( @"Position in the Host Tweet", nil ) : NSStringFromRange( self->_position )
              } description ];
    }

- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONDict
    {
    if ( self = [ super initWithJSON: _JSONDict ] )
        {
        self->_userID = _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"id" );
        self->_userIDString = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"id_str" ) copy ];
        self->_displayName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"name" ) copy ];
        self->_screenName = [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONObject, @"screen_name" ) copy ];
        self->_displayText = self->_screenName ? [ [ @"@" stringByAppendingString: self->_screenName ] copy ] : nil;
        }

    return self;
    }

#pragma mark Initialization
+ ( instancetype ) userMentionWithJSON: ( NSDictionary* )_JSONDict
    {
    return [ [ [ self class ] alloc ] initWithJSON: _JSONDict ];
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