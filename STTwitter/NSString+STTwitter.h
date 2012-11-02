//
//  NSString+STTwitter.h
//  STTwitter
//
//  Created by Nicolas Seriot on 11/2/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (STTwitter)

- (NSString *)firstMatchWithRegex:(NSString *)regex error:(NSError **)e;

@end
