//
//  AppDelegate.h
//  STTwitterConsole
//
//  Created by Nicolas Seriot on 9/17/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSPopUpButton *HTTPMethodPopUpButton;

@property (nonatomic, retain) NSString *HTTPMethod;
@property (nonatomic, retain) NSString *baseURLString;
@property (nonatomic, retain) NSString *APIEndpoint;

- (IBAction)changeHTTPMethodAction:(id)sender;
- (IBAction)sendRequestAction:(id)sender;

@end
