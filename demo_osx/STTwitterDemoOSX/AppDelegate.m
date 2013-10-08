//
//  AppDelegate.m
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/5/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import "AppDelegate.h"
#import "STTwitter.h"
#import "STConsoleVC.h"
#import "STClientVC.h"

@interface AppDelegate ()
@property (nonatomic, strong) STAuthenticationVC *authenticationVC;
@property (nonatomic, strong) STConsoleVC *requestsVC;
@property (nonatomic, strong) STClientVC *clientVC;
@end

@implementation AppDelegate

- (void)awakeFromNib {
    
//    [self.window setContentBorderThickness:24.0 forEdge:NSMinYEdge];
//    [self.window setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
    
    /**/
    
    [_tabView selectFirstTabViewItem:nil];
    
    self.authenticationVC = [[STAuthenticationVC alloc] initWithNibName:@"STAuthenticationVC" bundle:nil];
    _authenticationVC.delegate = self;
    
    NSTabViewItem *tvi1 = [_tabView tabViewItemAtIndex:0];
    [tvi1 setView:_authenticationVC.view];

    self.clientVC = [[STClientVC alloc] initWithNibName:@"STClientVC" bundle:nil];
    
    NSTabViewItem *tvi2 = [_tabView tabViewItemAtIndex:1];
    [tvi2 setView:_clientVC.view];
    
    self.requestsVC = [[STConsoleVC alloc] initWithNibName:@"STConsoleVC" bundle:nil];
    
    NSTabViewItem *tvi3 = [_tabView tabViewItemAtIndex:2];
    [tvi3 setView:_requestsVC.view];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // ...
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [_authenticationVC reloadTokenFile];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

#pragma mark NSTabViewDelegate

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    return YES;
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {

}

- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView {}

#pragma mark STAuthenticationVCDelegate

- (void)authenticationVC:(STAuthenticationVC *)sender didChangeTwitterObject:(STTwitterAPI *)twitter {
    _requestsVC.twitter = twitter;
    _clientVC.twitter = twitter;
    
    [self.window setTitle:[twitter prettyDescription]];
}

@end
