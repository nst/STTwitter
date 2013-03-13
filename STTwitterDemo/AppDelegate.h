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

@property (nonatomic, retain) NSURL *pinURL;

@property (nonatomic, copy) UsernamePasswordBlock_t pinGuessLoginCompletionBlock;

@property (nonatomic, retain) NSString *osxStatus;

@property (nonatomic, retain) NSString *bearerToken;
@property (nonatomic, retain) NSString *bearerStatus;

@property (nonatomic, retain) NSString *oauthCallback;
@property (nonatomic, retain) NSString *pin;
@property (nonatomic, retain) NSString *pinStatus1;
@property (nonatomic, retain) NSString *pinStatus2;
@property (nonatomic, retain) NSString *pinOAuthToken;
@property (nonatomic, retain) NSString *pinOAuthTokenSecret;

@property (nonatomic, retain) NSString *xAuthUsername;
@property (nonatomic, retain) NSString *xAuthPassword;
@property (nonatomic, retain) NSString *xAuthStatus;
@property (nonatomic, retain) NSString *xAuthOAuthToken;
@property (nonatomic, retain) NSString *xAuthOAuthTokenSecret;

@property (nonatomic, retain) NSString *oauthToken;
@property (nonatomic, retain) NSString *oauthTokenSecret;
@property (nonatomic, retain) NSString *oauthTokensStatus;

@property (nonatomic, retain) NSString *twitterTimelineUsername;
@property (nonatomic, retain) NSString *twitterGetTimelineStatus;
@property (nonatomic, retain) NSString *twitterPostTweetText;
@property (nonatomic, retain) NSString *twitterPostTweetStatus;

@property (nonatomic, retain) NSURL *twitterPostMediaURL;
@property (nonatomic, retain) NSString *twitterPostLatitude;
@property (nonatomic, retain) NSString *twitterPostLongitude;

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

// Application Only
- (IBAction)fetchBearer:(id)sender;
- (IBAction)invalidateBearer:(id)sender;

// Twitter
- (IBAction)getTimeline:(id)sender;
- (IBAction)chooseMedia:(id)sender;
- (IBAction)postTweet:(id)sender;

@end
