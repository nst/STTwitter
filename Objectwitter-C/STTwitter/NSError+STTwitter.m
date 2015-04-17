//
//  NSError+STTwitter.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 19/03/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "NSError+STTwitter.h"

static NSRegularExpression *xmlErrorRegex = nil;

@implementation NSError (STTwitter)

+ (NSRegularExpression *)st_xmlErrorRegex {
    if(xmlErrorRegex == nil) {
        xmlErrorRegex = [NSRegularExpression regularExpressionWithPattern:@"<error code=\"(.*)\">(.*)</error>" options:0 error:nil];
    }
    return xmlErrorRegex;
}

+ (NSError *)st_twitterErrorFromResponseData:(NSData *)responseData
                             responseHeaders:(NSDictionary *)responseHeaders
                             underlyingError:(NSError *)underlyingError {
    
    NSError *jsonError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    NSString *message = nil;
    NSInteger code = 0;
    
    if([json isKindOfClass:[NSDictionary class]]) {
        id errors = [json valueForKey:@"errors"];
        if([errors isKindOfClass:[NSArray class]] && [(NSArray *)errors count] > 0) {
            // assume format: {"errors":[{"message":"Sorry, that page does not exist","code":34}]}
            NSDictionary *errorDictionary = [errors lastObject];
            if([errorDictionary isKindOfClass:[NSDictionary class]]) {
                message = errorDictionary[@"message"];
                code = [[errorDictionary valueForKey:@"code"] integerValue];
            }
        } else if ([json valueForKey:@"error"] && [json valueForKey:@"error"] != [NSNull null]) {
            /*
             eg. when requesting timeline from a protected account
             {
             error = "Not authorized.";
             request = "/1.1/statuses/user_timeline.json?count=20&screen_name=premfe";
             }
             also, be robust to null errors such as in:
             {
             error = "<null>";
             state = AwaitingComplete;
             }
             */
            message = [json valueForKey:@"error"];
        } else if([errors isKindOfClass:[NSString class]]) {
            // assume format {errors = "Screen name can't be blank";}
            message = errors;
        }
    }
    
    if(json == nil) {
        // look for XML errors, eg.
        /*
         <?xml version="1.0" encoding="UTF-8"?>
         <errors>
         <error code="87">Client is not permitted to perform this action</error>
         </errors>
         */
        
        NSString *s = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSRegularExpression *xmlErrorRegex = [self st_xmlErrorRegex];
        NSAssert(xmlErrorRegex, @"");
        
        NSTextCheckingResult *match = [xmlErrorRegex firstMatchInString:s options:0 range:NSMakeRange(0, [s length])];
        
        if(match) {
            NSRange group1Range = [match rangeAtIndex:1];
            NSRange group2Range = [match rangeAtIndex:2];
            
            NSString *codeString = [s substringWithRange:group1Range];
            NSString *errorMessaage = [s substringWithRange:group2Range];
            
            return [NSError errorWithDomain:kSTTwitterTwitterErrorDomain code:[codeString integerValue] userInfo:@{NSLocalizedDescriptionKey:errorMessaage}];
        }
    }
    
    if(message) {
        NSString *rateLimitLimit = [responseHeaders valueForKey:@"x-rate-limit-limit"];
        NSString *rateLimitRemaining = [responseHeaders valueForKey:@"x-rate-limit-remaining"];
        NSString *rateLimitReset = [responseHeaders valueForKey:@"x-rate-limit-reset"];
        
        NSDate *rateLimitResetDate = rateLimitReset ? [NSDate dateWithTimeIntervalSince1970:[rateLimitReset doubleValue]] : nil;
        
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        md[NSLocalizedDescriptionKey] = message;
        if(underlyingError) md[NSUnderlyingErrorKey] = underlyingError;
        if(rateLimitLimit) md[kSTTwitterRateLimitLimit] = rateLimitLimit;
        if(rateLimitRemaining) md[kSTTwitterRateLimitRemaining] = rateLimitRemaining;
        if(rateLimitResetDate) md[kSTTwitterRateLimitResetDate] = rateLimitResetDate;
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:md];
        
        return [NSError errorWithDomain:kSTTwitterTwitterErrorDomain code:code userInfo:userInfo];
    }
    
    return nil;
}

@end
