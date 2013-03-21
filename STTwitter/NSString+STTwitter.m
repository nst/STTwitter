//
//  NSString+STTwitter.m
//  STTwitter
//
//  Created by Nicolas Seriot on 11/2/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import "NSString+STTwitter.h"

@implementation NSString (STTwitter)

- (NSString *)firstMatchWithRegex:(NSString *)regex error:(NSError **)e {
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
    
    if(re == nil) {
        if(e) *e = error;
        return nil;
    }
    
    NSArray *matches = [re matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    if([matches count] == 0) {
        NSString *errorDescription = [NSString stringWithFormat:@"Can't find a match for regex: %@", regex];
        if(e) *e = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
        return nil;
    }
    
    NSTextCheckingResult *match = [matches lastObject];
    NSRange matchRange = [match rangeAtIndex:1];
    return [self substringWithRange:matchRange];
}

@end
