//
//  AppDelegate.h
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/5/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STTwitterAPIWrapper;

typedef void (^UsernamePasswordBlock_t)(NSString *username, NSString *password);

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) STTwitterAPIWrapper *twitter;

@property (nonatomic, retain) NSArray *twitterClients;
@property (nonatomic, retain) IBOutlet NSArrayController *twitterClientsController;

@property (nonatomic, retain) IBOutlet NSTextField *consumerKeyTextField;
@property (nonatomic, retain) IBOutlet NSTextField *consumerSecretTextField;

@property (nonatomic, retain) IBOutlet NSTextField *osxStatusTextField;

@property (nonatomic, retain) NSURL *pinURL;
@property (nonatomic, retain) NSString *pinOAuthToken;
@property (nonatomic, copy) UsernamePasswordBlock_t pinGuessLoginCompletionBlock;

@property (nonatomic, retain) IBOutlet NSTextField *pinTextField;
@property (nonatomic, retain) IBOutlet NSTextField *pinStatus1TextField;
@property (nonatomic, retain) IBOutlet NSTextField *pinStatus2TextField;
@property (nonatomic, retain) IBOutlet NSTextField *pinOAuthTokenTextField;
@property (nonatomic, retain) IBOutlet NSTextField *pinOAuthTokenSecretTextField;

@property (nonatomic, retain) IBOutlet NSTextField *xAuthUsernameTextField;
@property (nonatomic, retain) IBOutlet NSTextField *xAuthPasswordTextField;
@property (nonatomic, retain) IBOutlet NSTextField *xAuthStatusTextField;
@property (nonatomic, retain) IBOutlet NSTextField *xAuthOAuthTokenTextField;
@property (nonatomic, retain) IBOutlet NSTextField *xAuthOAuthTokenSecretTextField;

@property (nonatomic, retain) IBOutlet NSTextField *oauthTokenTextField;
@property (nonatomic, retain) IBOutlet NSTextField *oauthTokenSecretTextField;
@property (nonatomic, retain) IBOutlet NSTextField *oauthTokensStatusTextField;

@property (nonatomic, retain) IBOutlet NSTextField *twitterGetTimelineStatusTextField;
@property (nonatomic, retain) IBOutlet NSTextField *twitterPostTweetTextField;
@property (nonatomic, retain) IBOutlet NSTextField *twitterPostTweetStatusTextField;
@property (nonatomic, retain) NSURL *twitterPostMediaURL;

@property (nonatomic, retain) NSArray *timelineStatuses;

- (IBAction)popupMenuDidSelectTwitterClient:(id)sender;

// OAuth - PIN
- (IBAction)fetchPIN:(id)sender;
- (IBAction)openURL:(id)sender;
- (IBAction)guessPIN:(id)sender;
- (IBAction)loginPIN:(id)sender;

// OAuth - XAuth
- (IBAction)loginXAuth:(id)sender;

// OAuth - Tokens
- (IBAction)loginTokens:(id)sender;

// OS X Twitter account
- (IBAction)loginOSX:(id)sender;

// Twitter
- (IBAction)getTimeline:(id)sender;
- (IBAction)chooseMedia:(id)sender;
- (IBAction)postTweet:(id)sender;

@end
