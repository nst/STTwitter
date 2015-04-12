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

#import "_OTCGeneral.h"
    
id _OTCCocoaValueWhichHasBeenParsedOutOfJSON( NSDictionary* _JSONObject, NSString* _JSONPropertyKey )
    {
    id cocoaValue = _JSONObject[ _JSONPropertyKey ];

    if ( !cocoaValue || ( ( id )cocoaValue == [ NSNull null ] ) )
        return nil;

    return cocoaValue;
    }

NSUInteger _OTCUnsignedIntWhichHasBeenParsedOutOfJSON( NSDictionary* _JSONObject, NSString* _JSONPropertyKey )
    {
    NSNumber* cocoaNumber = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( _JSONObject, _JSONPropertyKey );
    assert( !cocoaNumber || [ cocoaNumber respondsToSelector: @selector( unsignedIntegerValue ) ] );
    return cocoaNumber ? cocoaNumber.unsignedIntegerValue : 0U;
    }

BOOL _OTCBooleanWhichHasBeenParsedOutOfJSON( NSDictionary* _JSONObject, NSString* _JSONPropertyKey )
    {
    NSNumber* cocoaBool = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( _JSONObject, _JSONPropertyKey );
    assert( !cocoaBool || [ cocoaBool respondsToSelector: @selector( boolValue ) ] );
    return cocoaBool ? cocoaBool.boolValue : NO;
    }

NSSize _OTCSizeWhichHasBeenParsedOutOfJSON( NSDictionary* _JSONObject, NSString* _JSONPropertyKey )
    {
    NSSize size = NSMakeSize( -1.f, -1.f );

    NSDictionary* JSONObjectDict = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( _JSONObject, _JSONPropertyKey );
    assert( !JSONObjectDict || [ JSONObjectDict respondsToSelector: @selector( valueForKey: ) ] );
    size.height = [ [ JSONObjectDict valueForKey: @"h" ] doubleValue ];
    size.width = [ [ JSONObjectDict valueForKey: @"w" ] doubleValue ];

    return size;
    }

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