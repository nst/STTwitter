//
//  NSError+STTwitter.h
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 19/03/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kSTTwitterRateLimitLimit = @"kSTTwitterRateLimitLimit";
static NSString *kSTTwitterRateLimitRemaining = @"kSTTwitterRateLimitRemaining";
static NSString *kSTTwitterRateLimitResetDate = @"kSTTwitterRateLimitResetDate";

@interface NSError (STTwitter)

+ (NSError *)st_twitterErrorFromResponseData:(NSData *)responseData responseHeaders:(NSDictionary *)responseHeaders underlyingError:(NSError *)underlyingError;

@end
