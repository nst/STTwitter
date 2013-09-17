//
//  AppDelegate.m
//  STTwitterConsole
//
//  Created by Nicolas Seriot on 9/17/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.baseURLString = @"https://api.twitter.com/1.1/";
    
    [self changeHTTPMethodAction:self];
}

- (IBAction)changeHTTPMethodAction:(id)sender {
    self.HTTPMethod = [_HTTPMethodPopUpButton titleOfSelectedItem];
    NSLog(@"-- %s", __PRETTY_FUNCTION__);
    NSLog(@"-- %@", _HTTPMethod);
}

- (IBAction)sendRequestAction:(id)sender {
    NSLog(@"-- %s", __PRETTY_FUNCTION__);
}

@end
