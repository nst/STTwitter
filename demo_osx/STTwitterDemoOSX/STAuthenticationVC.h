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

@interface STAuthenticationVC : NSViewController

@property (nonatomic, assign) IBOutlet NSScrollView *scrollView;
@property (nonatomic, assign) IBOutlet NSView *contentView;

@property (nonatomic, retain) STTwitterAPI *twitter;
@property (nonatomic, assign) id <STAuthenticationVCDelegate> delegate;

@property (nonatomic, retain) NSArray *twitterClients;
@property (nonatomic, assign) IBOutlet NSArrayController *twitterClientsController;

@property (nonatomic, retain) NSArray *osxAccounts;
@property (nonatomic, assign) IBOutlet NSArrayController *osxAccountsController;

@property (nonatomic, assign) IBOutlet NSTextField *consumerKeyTextField;
@property (nonatomic, assign) IBOutlet NSTextField *consumerSecretTextField;

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

- (void)reloadTokenFile;

- (IBAction)popupMenuDidSelectTwitterClient:(id)sender;
- (IBAction)revealConsumerTokensFileAction:(id)sender;

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

@end
