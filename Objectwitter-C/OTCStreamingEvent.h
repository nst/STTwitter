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

// Constants
typedef NS_ENUM( NSInteger, OTCStreamingEventType )
    { OTCStreamingEventTypeUnknown              = -1
    , OTCStreamingEventTypeAccessRevoked        = 0
    , OTCStreamingEventTypeBlock                = 1
    , OTCStreamingEventTypeUnblock              = 2
    , OTCStreamingEventTypeFavorite             = 3
    , OTCStreamingEventTypeUnfavorite           = 4
    , OTCStreamingEventTypeFollow               = 5
    , OTCStreamingEventTypeUnfollow             = 6
    , OTCStreamingEventTypeListCreated          = 7
    , OTCStreamingEventTypeListDestroyed        = 8
    , OTCStreamingEventTypeListUpdated          = 9
    , OTCStreamingEventTypeListMemberAdded      = 10
    , OTCStreamingEventTypeListMemberRemoved    = 11
    , OTCStreamingEventTypeListUserSubscribed   = 12
    , OTCStreamingEventTypeListUserUnsubscribed = 13
    , OTCStreamingEventTypeQuotedTweet          = 14
    , OTCStreamingEventTypeUserUpdate           = 15
    };

@class OTCTweet;
@class OTCTwitterUser;

// OTCStreamingEvent class
@interface OTCStreamingEvent : NSObject
    {
@private
    NSDictionary __strong* _JSONDict;

    OTCStreamingEventType _eventType;
    NSDate __strong* _creationDate;

    OTCTwitterUser __strong* _targetUser;
    OTCTwitterUser __strong* _sourceUser;

    id _targetObject;
    }

@property ( strong, readonly ) NSDictionary* JSONDict;

@property ( assign, readonly ) OTCStreamingEventType eventType;
@property ( strong, readonly ) NSDate* creationDate;

@property ( strong, readonly ) OTCTwitterUser* targetUser;
@property ( strong, readonly ) OTCTwitterUser* sourceUser;

@property ( strong, readonly ) id targetObject;

#pragma mark Initialization
+ ( instancetype ) eventWithJSON: ( NSDictionary* )_JSONObject;
- ( instancetype ) initWithJSON: ( NSDictionary* )_JSONObject;

@end // OTCStreamingEvent class

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