/*=============================================================================┐
|             _  _  _       _                                                  |  
|            (_)(_)(_)     | |                            _                    |██
|             _  _  _ _____| | ____ ___  ____  _____    _| |_ ___              |██
|            | || || | ___ | |/ ___) _ \|    \| ___ |  (_   _) _ \             |██
|            | || || | ____| ( (__| |_| | | | | ____|    | || |_| |            |██
|             \_____/|_____)\_)____)___/|_|_|_|_____)     \__)___/             |██
|                                                                              |██
|     _  _  _              ______             _ _______                  _     |██
|    (_)(_)(_)            / _____)           | (_______)                | |    |██
|     _  _  _ _____ _   _( (____  _____ _____| |_       ___   ____ _____| |    |██
|    | || || (____ ( \ / )\____ \| ___ (____ | | |     / _ \ / ___) ___ |_|    |██
|    | || || / ___ |) X ( _____) ) ____/ ___ | | |____| |_| | |   | ____|_     |██
|     \_____/\_____(_/ \_|______/|_____)_____|\_)______)___/|_|   |_____)_|    |██
|                                                                              |██
|                                                                              |██
|                         Copyright (c) 2015 Tong Guo                          |██
|                                                                              |██
|                             ALL RIGHTS RESERVED.                             |██
|                                                                              |██
└==============================================================================┘██
  ████████████████████████████████████████████████████████████████████████████████
  ██████████████████████████████████████████████████████████████████████████████*/


#import "NSDate+WSCCocoaDate.h"

#pragma mark NSDate+WSCCocoaDate
@implementation NSDate ( _WSCocoaDate )

+ ( NSDate* ) dateWithCSSMDate: ( CSSM_DATE )_CSSMDate
    {
    NSDate* rawDate = nil;

    NSMutableString* yearString = [ NSMutableString string ];
    for ( int _Index = 0; _Index < 4; _Index++ )
        if ( _CSSMDate.Year[ _Index ] != '\0' )
            [ yearString appendString: [ NSString stringWithFormat: @"%u", _CSSMDate.Year[ _Index ] ] ];

    NSMutableString* monthString = [ NSMutableString string ];
    for ( int _Index = 0; _Index < 2; _Index++ )
        if ( _CSSMDate.Month[ _Index ] != '\0' )
            [ monthString appendString: [ NSString stringWithFormat: @"%u", _CSSMDate.Month[ _Index ] ] ];

    NSMutableString* dayString = [ NSMutableString string ];
    for ( int _Index = 0; _Index < 2; _Index++ )
        if ( _CSSMDate.Day[ _Index ] != '\0' )
            [ dayString appendString: [ NSString stringWithFormat: @"%u", _CSSMDate.Day[ _Index ] ] ];

    if ( yearString.length !=0 && monthString.length != 0 && dayString.length != 0 )
        {
        NSDateComponents* dateComponents = nil;
    #if !__has_feature( objc_arc )
        dateComponents = [ [ [ NSDateComponents alloc ] init ] autorelease ];
    #else
        dateComponents = [ [ NSDateComponents alloc ] init ];
    #endif
        // GMT (GMT) offset 0, the standard Greenwich Mean Time, that's pretty important!
        [ dateComponents setTimeZone: [ NSTimeZone timeZoneForSecondsFromGMT: 0 ] ];

        [ dateComponents setYear: yearString.integerValue   ];
        [ dateComponents setMonth: monthString.integerValue ];
        [ dateComponents setDay: dayString.integerValue ];

        rawDate = [ [ NSCalendar autoupdatingCurrentCalendar ] dateFromComponents: dateComponents ];
        }

    return [ rawDate dateWithLocalTimeZone ];
    }

- ( NSDate* ) dateWithLocalTimeZone
    {
    return [ self dateWithCalendarFormat: nil timeZone: [ NSTimeZone localTimeZone ] ];
    }

@end // NSDate + _WSCCocoaDate

/*================================================================================┐
|                              The MIT License (MIT)                              |
|                                                                                 |
|                           Copyright (c) 2015 Tong Guo                           |
|                                                                                 |
|  Permission is hereby granted, free of charge, to any person obtaining a copy   |
|  of this software and associated documentation files (the "Software"), to deal  |
|  in the Software without restriction, including without limitation the rights   |
|    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    |
|      copies of the Software, and to permit persons to whom the Software is      |
|            furnished to do so, subject to the following conditions:             |
|                                                                                 |
| The above copyright notice and this permission notice shall be included in all  |
|                 copies or substantial portions of the Software.                 |
|                                                                                 |
|   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    |
|    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     |
|   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   |
|     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      |
|  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  |
|  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  |
|                                    SOFTWARE.                                    |
└================================================================================*/