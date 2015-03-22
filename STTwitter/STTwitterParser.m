//
//  STTwitterParser.m
//  STTwitterDemoIOS
//
//  Created by Yu Sugawara on 2015/03/23.
//  Copyright (c) 2015年 Nicolas Seriot. All rights reserved.
//

#import "STTwitterParser.h"

NSString *NSStringFromSTTwitterStreamJSONType(STTwitterStreamJSONType type) {
    switch (type) {
        case STTwitterStreamJSONTypeTweet:
            return @"STTwitterStreamJSONTypeTweet";
        case STTwitterStreamJSONTypeFriendsLists:
            return @"STTwitterStreamJSONTypeFriendsLists";
        case STTwitterStreamJSONTypeDelete:
            return @"STTwitterStreamJSONTypeDelete";
        case STTwitterStreamJSONTypeScrubGeo:
            return @"STTwitterStreamJSONTypeScrubGeo";
        case STTwitterStreamJSONTypeLimit:
            return @"STTwitterStreamJSONTypeLimit";
        case STTwitterStreamJSONTypeDisconnect:
            return @"STTwitterStreamJSONTypeDisconnect";
        case STTwitterStreamJSONTypeWarning:
            return @"STTwitterStreamJSONTypeWarning";
        case STTwitterStreamJSONTypeEvent:
            return @"STTwitterStreamJSONTypeEvent";
        default:
        case STTwitterStreamJSONTypeUnsupported:
            return @"STTwitterStreamJSONTypeUnsupported";
    }
}

static inline BOOL isDigitsOnlyString(NSString *str) {
    static NSCharacterSet *__notDigits;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    });
    return str.length && [str rangeOfCharacterFromSet:__notDigits].location == NSNotFound;
}

@interface STTwitterParser ()

@property (nonatomic) NSMutableString *receivedMessage;
@property (nonatomic) int bytesExpected;

@end

@implementation STTwitterParser

- (void)parseWithStreamData:(NSData *)data
            parsedJsonBlock:(void (^)(NSDictionary *json, STTwitterStreamJSONType type))parsedJsonBlock
{
    static NSString * const kDelimiter = @"\r\n";
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    for (NSString* part in [response componentsSeparatedByString:kDelimiter]) {
        if (self.receivedMessage == nil) {
            if (isDigitsOnlyString(part)) {
                self.receivedMessage = [NSMutableString string];
                self.bytesExpected = [part intValue];
            }
        } else if (self.bytesExpected > 0) {
            if (self.receivedMessage.length < self.bytesExpected) {
                // Append the data
                if (part.length > 0) {
                    [self.receivedMessage appendString:part];
                } else {
                    [self.receivedMessage appendString:kDelimiter];
                }
                if (self.receivedMessage.length + kDelimiter.length == self.bytesExpected) {
                    [self.receivedMessage appendString:kDelimiter];
                    // Success!
                    NSError *error = nil;
                    id json = [NSJSONSerialization JSONObjectWithData:[self.receivedMessage dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:NSJSONReadingAllowFragments
                                                                error:&error];
                    
                    STTwitterStreamJSONType type = [[self class] streamJSONTypeForJSON:json];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        parsedJsonBlock(json, type);
                    });
                    
                    // Reset
                    self.receivedMessage = nil;
                    self.bytesExpected = 0;
                }
            } else {
                self.receivedMessage = nil;
                self.bytesExpected = 0;
            }
        } else {
            self.receivedMessage = nil;
            self.bytesExpected = 0;
        }
    }
}


+ (STTwitterStreamJSONType)streamJSONTypeForJSON:(id)json
{
    if ([json isKindOfClass:[NSDictionary class]]) {
        if ([json objectForKey:@"source"] && [json objectForKey:@"text"]) {
            return STTwitterStreamJSONTypeTweet;
        } else if ([json objectForKey:@"friends"] || [json objectForKey:@"friends_str"]) {
            return STTwitterStreamJSONTypeFriendsLists;
        } else if ([json objectForKey:@"delete"]) {
            return STTwitterStreamJSONTypeDelete;
        } else if ([json objectForKey:@"scrub_geo"]) {
            return STTwitterStreamJSONTypeScrubGeo;
        } else if ([json objectForKey:@"limit"]) {
            return STTwitterStreamJSONTypeLimit;
        } else if ([json objectForKey:@"disconnect"]) {
            return STTwitterStreamJSONTypeDisconnect;
        } else if ([json objectForKey:@"warning"]) {
            return STTwitterStreamJSONTypeWarning;
        } else if ([json objectForKey:@"event"]) {
            return STTwitterStreamJSONTypeEvent;
        } else {
            return STTwitterStreamJSONTypeUnsupported;
        }
    } else {
        return STTwitterStreamJSONTypeUnsupported;
    }
}

@end
