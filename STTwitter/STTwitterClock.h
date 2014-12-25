//
//  STTwitterClock.h
//  STTwitter
//
//  Created by Kirill Nepomnyaschiy on 25.12.14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STTwitterTimeProvider <NSObject>
-(NSTimeInterval)timestamp;
@end

@interface STTwitterClock : NSObject

@property (strong, nonatomic) id <STTwitterTimeProvider> timeProvider;

@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly, getter=isAvailable) BOOL available;

+(instancetype)sharedInstance;

@end
