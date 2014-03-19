//
//  NSError+STTwitter.h
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 19/03/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kSTTwitterTwitterErrorDomain = @"STTwitterTwitterErrorDomain";
static NSString *kSTTwitterRateLimitLimit = @"STTwitterRateLimitLimit";
static NSString *kSTTwitterRateLimitRemaining = @"STTwitterRateLimitRemaining";
static NSString *kSTTwitterRateLimitResetDate = @"STTwitterRateLimitResetDate";

@interface NSError (STTwitter)

+ (NSError *)st_twitterErrorFromResponseData:(NSData *)responseData responseHeaders:(NSDictionary *)responseHeaders underlyingError:(NSError *)underlyingError;

@end
