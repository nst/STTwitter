//
//  STAuthenticationVC.h
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/22/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "STTwitter.h"

@class STAuthenticationVC;

@protocol STAuthenticationVCDelegate
- (void)authenticationVC:(STAuthenticationVC *)sender didChangeTwitterObject:(STTwitterAPI *)twitter;
@end

typedef void (^UsernamePasswordBlock_t)(NSString *username, NSString *password);

@interface STAuthenticationVC : NSViewController <STTwitterAPIOSProtocol>

@property (nonatomic, assign) id <STAuthenticationVCDelegate> delegate;

- (void)reloadTokenFile;

@end
