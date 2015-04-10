//
//  OTC.m
//  TwitterAPILab
//
//  Created by Tong G. on 4/10/15.
//
//

#import "OTCStatus.h"

@implementation OTCStatus

@synthesize JSONArray = _JSONArray;

+ ( instancetype ) statusWithJSON: ( NSArray* )_JSONArray
    {
    return [ [ [ self class ] alloc ] initWithJSON: _JSONArray ];
    }

- ( instancetype ) initWithJSON: ( NSArray* )_JSON
    {
    if ( self = [ super init ] )
        self->_JSONArray = _JSON;

    return self;
    }

@end
