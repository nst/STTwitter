//
//  NSColor+Objectwitter-C.m
//  TwitterAPILab
//
//  Created by Tong G. on 4/16/15.
//
//

#import "NSColor+Objectwitter-C.h"

#define COMPARE_WITH_CASE_INSENSITIVE( _Lhs, _Rhs )                                 \
    ( [ _Lhs compare: _Rhs options: NSCaseInsensitiveSearch ] == NSOrderedSame )    \

@implementation NSColor ( Objectwitter_C )

BOOL isCharInAtoE( NSString* );
NSUInteger mapHexAlphaToDecimalNumeric( NSString* _AlphaInHexNumeric );

+ ( NSColor* ) colorWithHTMLColor: ( NSString* )_HTMLColor
    {
    NSColor* color = nil;

    NSString* redValueInHex = [ @"0x" stringByAppendingString: [ _HTMLColor substringWithRange: NSMakeRange( 0, 2 ) ] ];
    NSString* greenValueInHex = [ @"0x" stringByAppendingString: [ _HTMLColor substringWithRange: NSMakeRange( 2, 2 ) ] ];
    NSString* blueValueInHex = [ @"0x" stringByAppendingString: [ _HTMLColor substringWithRange: NSMakeRange( 4, 2 ) ] ];

    NSUInteger redValue = OMCOperandConvertHexToDecimal( redValueInHex );
    NSUInteger greenValue = OMCOperandConvertHexToDecimal( greenValueInHex );
    NSUInteger blueValue = OMCOperandConvertHexToDecimal( blueValueInHex );

    color = [ NSColor colorWithSRGBRed: redValue / 255.f green: greenValue / 255.f blue: blueValue / 255.f alpha: 1.f ];

    return color;
    }

NSUInteger OMCOperandConvertHexToDecimal( NSString* _HexNumeric )
    {
    NSString* prefixForHex = @"0x";
    if ( ![ _HexNumeric hasPrefix: prefixForHex ] )
        return NAN;

    NSString* hexNumericWithoutPrefix = [ _HexNumeric substringFromIndex: prefixForHex.length ];

    NSUInteger resultInDecimal = 0U;
    double exponent = 0.f;
    for ( int index = ( int )hexNumericWithoutPrefix.length - 1; index >= 0; index-- )
        {
        NSString* stringForCurrentDigit = [ hexNumericWithoutPrefix substringWithRange: NSMakeRange( index, 1 ) ];
        NSUInteger valueForCurrentDigit = 0U;

        if ( isCharInAtoE( stringForCurrentDigit ) )
            valueForCurrentDigit = mapHexAlphaToDecimalNumeric( stringForCurrentDigit );
        else
            valueForCurrentDigit = ( NSUInteger )[ stringForCurrentDigit integerValue ];

        resultInDecimal += valueForCurrentDigit * ( NSUInteger )pow( 16, exponent++ );
        }

    return resultInDecimal;
    }

BOOL isCharInAtoE( NSString* _Char )
    {
    if ( COMPARE_WITH_CASE_INSENSITIVE( _Char, @"A" )
            || COMPARE_WITH_CASE_INSENSITIVE( _Char, @"B" )
            || COMPARE_WITH_CASE_INSENSITIVE( _Char, @"C" )
            || COMPARE_WITH_CASE_INSENSITIVE( _Char, @"D" )
            || COMPARE_WITH_CASE_INSENSITIVE( _Char, @"E" )
            || COMPARE_WITH_CASE_INSENSITIVE( _Char, @"F" ) )
        return YES;
    else
        return NO;
    }

NSUInteger mapHexAlphaToDecimalNumeric( NSString* _AlphaInHexNumeric )
    {
    if ( COMPARE_WITH_CASE_INSENSITIVE( _AlphaInHexNumeric, @"A" ) )
        return 10;

    if ( COMPARE_WITH_CASE_INSENSITIVE( _AlphaInHexNumeric, @"B" ) )
        return 11U;

    if ( COMPARE_WITH_CASE_INSENSITIVE( _AlphaInHexNumeric, @"C" ) )
        return 12U;

    if ( COMPARE_WITH_CASE_INSENSITIVE( _AlphaInHexNumeric, @"D" ) )
        return 13U;

    if ( COMPARE_WITH_CASE_INSENSITIVE( _AlphaInHexNumeric, @"E" ) )
        return 14U;

    if ( COMPARE_WITH_CASE_INSENSITIVE( _AlphaInHexNumeric, @"F" ) )
        return 15U;

    return NAN;
    }

@end
