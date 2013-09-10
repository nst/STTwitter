//
//  NSString+STTwitter.h
//  STTwitter
//
//  Created by Nicolas Seriot on 11/2/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSUInteger kSTTwitterDefaultShortURLLength;
extern NSUInteger kSTTwitterDefaultShortURLLengthHTTPS;

@interface NSString (STTwitter)

- (NSString *)firstMatchWithRegex:(NSString *)regex error:(NSError **)e;

// use values from GET help/configuration
- (NSInteger)numberOfCharactersInATweetWithShortURLLength:(NSUInteger)shortURLLength
                                      shortURLLengthHTTPS:(NSUInteger)shortURLLengthHTTS;

// use default values for URL shortening
- (NSInteger)numberOfCharactersInATweet;

@end
