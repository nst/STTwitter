//
//  AppDelegate.h
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/5/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "STAuthenticationVC.h"

@class STTwitterAPI;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTabViewDelegate, STAuthenticationVCDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTabView *tabView;

@end
