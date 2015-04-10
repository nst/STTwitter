//
//  OTC.h
//  TwitterAPILab
//
//  Created by Tong G. on 4/10/15.
//
//

#import <Foundation/Foundation.h>

@interface OTCStatus : NSObject
    {
@private
    NSArray __strong* _JSONArray;
    }

@property ( retain, readonly ) NSArray* JSONArray;

@property ( retain, readonly ) NSDate* dateCreated;

+ ( instancetype ) statusWithJSON: ( NSArray* )_JSONArray;
- ( instancetype ) initWithJSON: ( NSArray* )_JSONArray;

@end
