//
//  STTwitterClock.m
//  STTwitter
//
//  Created by Kirill Nepomnyaschiy on 25.12.14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterClock.h"

@implementation STTwitterClock

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(BOOL)isAvailable {
    return _timeProvider == nil ? NO : YES;
}

-(NSTimeInterval)timestamp {
    return _timeProvider.timestamp;
}

@end
