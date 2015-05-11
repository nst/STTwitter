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

#import "NSDate+WSCCocoaDate.h"
#import "OTCStreamingEvent.h"
#import "OTCTweet.h"
#import "OTCTwitterUser.h"

#import "_OTCGeneral.h"

@implementation OTCStreamingEvent

@synthesize JSONDict = _JSONDict;

@synthesize eventType = _eventType;
@synthesize creationDate = _creationDate;

@synthesize targetUser = _targetUser;
@synthesize sourceUser = _sourceUser;

@synthesize targetObject = _targetObject;

#pragma mark Initialization
+ ( instancetype ) eventWithJSON: ( NSDictionary* )_JSONObject
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

        self->_eventType = [ self _streamingEventTypeForJSON: _JSONObject ];
        self->_creationDate = [ [ NSDate dateWithNaturalLanguageString: [ _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"created_at" ) copy ] ] dateWithLocalTimeZone ];

        NSDictionary* targetObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"target" );
        NSDictionary* sourceObject = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( self->_JSONDict, @"source" );
        if ( targetObject )
            self->_targetUser = [ OTCTwitterUser userWithJSON: targetObject ];

        if ( sourceObject )
            self->_sourceUser = [ OTCTwitterUser userWithJSON: sourceObject ];
        }

    return self;
    }

- ( OTCStreamingEventType ) _streamingEventTypeForJSON: ( NSDictionary* )_JSONObject
    {
    OTCStreamingEventType type = OTCStreamingEventTypeUnknown;

    if ( [ _JSONObject isKindOfClass: [ NSDictionary class ] ] )
        {
        NSString* eventNameParsedOutOfJSON = _OTCCocoaValueWhichHasBeenParsedOutOfJSON( _JSONObject, @"event" );

        if ( [ eventNameParsedOutOfJSON isEqualToString: @"access_revoked" ] )
            type = OTCStreamingEventTypeAccessRevoked;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"block" ] )
            type = OTCStreamingEventTypeBlock;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"unblock" ] )
            type = OTCStreamingEventTypeUnblock;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"favorite" ] )
            type = OTCStreamingEventTypeFavorite;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"unfavorite" ] )
            type = OTCStreamingEventTypeUnfavorite;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"follow" ] )
            type = OTCStreamingEventTypeFollow;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"unfollow" ] )
            type = OTCStreamingEventTypeUnfollow;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"list_created" ] )
            type = OTCStreamingEventTypeListCreated;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"list_destroyed" ] )
            type = OTCStreamingEventTypeListDestroyed;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"list_updated" ] )
            type = OTCStreamingEventTypeListUpdated;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"list_member_added" ] )
            type = OTCStreamingEventTypeListMemberAdded;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"list_member_removed" ] )
            type = OTCStreamingEventTypeListMemberRemoved;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"list_user_subscribed" ] )
            type = OTCStreamingEventTypeListUserSubscribed;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"list_user_unsubscribed" ] )
            type = OTCStreamingEventTypeListUserUnsubscribed;

        else if ( [ eventNameParsedOutOfJSON isEqualToString: @"user_update" ] )
            type = OTCStreamingEventTypeUserUpdate;
        }

    return type;
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