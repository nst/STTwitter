//
//  AppDelegate.m
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/5/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import "AppDelegate.h"
#import "STTwitterAPIWrapper.h"
#import "STTwitterHTML.h"

@implementation AppDelegate

- (void)dealloc {
    [_twitter release];
    [_twitterClients release];
    [_twitterClientsController release];
    [_consumerKeyTextField release];
    [_consumerSecretTextField release];
    [_osxStatusTextField release];
    [_pinURL release];
    [_pinOAuthToken release];
    [_pinTextField release];
    [_pinStatus1TextField release];
    [_pinStatus2TextField release];
    [_pinOAuthTokenTextField release];
    [_pinOAuthTokenSecretTextField release];
    [_xAuthUsernameTextField release];
    [_xAuthPasswordTextField release];
    [_xAuthStatusTextField release];
    [_xAuthOAuthTokenTextField release];
    [_xAuthOAuthTokenSecretTextField release];
    [_oauthTokenTextField release];
    [_oauthTokenSecretTextField release];
    [_oauthTokensStatusTextField release];
    [_pinGuessLoginCompletionBlock release];
    [_twitterGetTimelineStatusTextField release];
    [_twitterPostTweetTextField release];
    [_twitterPostTweetStatusTextField release];
    [_timelineStatuses release];
    [_twitterPostMediaURL release];
    [super dealloc];
}

- (void)awakeFromNib {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TwitterClients" ofType:@"plist"];
    NSArray *clientsDictionaries = [NSArray arrayWithContentsOfFile:path];
    
    NSDictionary *customClient = @{ @"name":@"Custom...", @"ck":@"", @"cs":@"" };
    
    NSArray *ma = [@[customClient] arrayByAddingObjectsFromArray:clientsDictionaries];
    
    self.twitterClients = ma;
    
    [_twitterClientsController setSelectedObjects:@[customClient]];
}

- (IBAction)popupMenuDidSelectTwitterClient:(id)sender {
    NSDictionary *selectedClient = [[_twitterClientsController selectedObjects] lastObject];
    
    BOOL isCustomClient = [[selectedClient valueForKey:@"name"] isEqualToString:@"Custom..."];
    
    _consumerKeyTextField.editable = isCustomClient;
    _consumerSecretTextField.editable = isCustomClient;
    
    _consumerKeyTextField.stringValue = [selectedClient valueForKey:@"ck"];
    _consumerSecretTextField.stringValue = [selectedClient valueForKey:@"cs"];
}

- (void)askForUsernameAndPasswordWithCompletionBlock:(UsernamePasswordBlock_t)completionBlock {
    self.pinGuessLoginCompletionBlock = completionBlock;
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"Login"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Please enter username and password:"];
    [alert setInformativeText:@"STTwitter will login on Twitter through the website and parse the HTML to guess the PIN."];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    NSTextField *usernameTextField = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,32, 180, 24)] autorelease];
    NSSecureTextField *passwordTextField = [[[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 180, 24)] autorelease];
    
    NSView *accessoryView = [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 64)] autorelease];
    [accessoryView addSubview:usernameTextField];
    [accessoryView addSubview:passwordTextField];
    
    [alert setAccessoryView:accessoryView];
    
    [alert beginSheetModalForWindow:_window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(NSDictionary *)contextInfo {
    if(returnCode != NSAlertFirstButtonReturn) return;
    
    NSArray *subviews = [alert.accessoryView subviews];
    
    NSTextField *usernameTextField = [subviews objectAtIndex:0];
    NSSecureTextField *passwordTextField = [subviews objectAtIndex:1];
    
    NSString *username = [usernameTextField stringValue];
    NSString *password = [passwordTextField stringValue];
    
    _pinGuessLoginCompletionBlock(username, password);
}

// OS X Twitter account
- (IBAction)loginOSX:(id)sender {
    self.twitter = [STTwitterAPIWrapper twitterAPIWithOAuthOSX];
    
    self.osxStatusTextField.stringValue = @"-";

    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        _osxStatusTextField.stringValue = [NSString stringWithFormat:@"Access granted for %@", username];
    } errorBlock:^(NSError *error) {
        _osxStatusTextField.stringValue = [error localizedDescription];
    }];
}

// OAuth - PIN
- (IBAction)fetchPIN:(id)sender {
    
    self.pinURL = nil;
    self.pinOAuthToken = nil;
    self.pinGuessLoginCompletionBlock = nil;
    
    self.pinStatus1TextField.stringValue = @"-";
    self.pinStatus2TextField.stringValue = @"-";
    
    self.twitter = [STTwitterAPIWrapper twitterAPIWithOAuthConsumerKey:_consumerKeyTextField.stringValue
                                                        consumerSecret:_consumerSecretTextField.stringValue];
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        self.pinURL = url;
        self.pinOAuthToken = oauthToken;
        
        _pinStatus1TextField.stringValue = [url description];
        
    } errorBlock:^(NSError *error) {
        
        _pinStatus1TextField.stringValue = [error localizedDescription];
    }];
    
}

- (IBAction)openURL:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:_pinURL];
}

- (IBAction)guessPIN:(id)sender {
    
    STTwitterHTML *twitterHTML = [[[STTwitterHTML alloc] init] autorelease];
    
    [_twitter postTokenRequest:^(NSURL *pinURL, NSString *oauthToken) {
        
        [twitterHTML getLoginForm:^(NSString *authenticityToken) {
            
            [self askForUsernameAndPasswordWithCompletionBlock:^(NSString *username, NSString *password) {
                
                [twitterHTML postLoginFormWithUsername:username password:password authenticityToken:authenticityToken successBlock:^{
                    
                    [twitterHTML getAuthorizeFormAtURL:pinURL successBlock:^(NSString *authenticityToken, NSString *oauthToken) {
                        
                        [twitterHTML postAuthorizeFormResultsAtURL:pinURL authenticityToken:authenticityToken oauthToken:oauthToken successBlock:^(NSString *PIN) {
                            
                            _pinTextField.stringValue = PIN;
                            
                            self.pinOAuthToken = oauthToken;
                            
                        } errorBlock:^(NSError *error) {
                            _pinStatus2TextField.stringValue = [error localizedDescription];
                        }];
                        
                    } errorBlock:^(NSError *error) {
                        _pinStatus2TextField.stringValue = [error localizedDescription];
                    }];
                    
                } errorBlock:^(NSError *error) {
                    _pinStatus2TextField.stringValue = [error localizedDescription];
                }];
                
            }];
            
        } errorBlock:^(NSError *error) {
            _pinStatus2TextField.stringValue = [error localizedDescription];
        }];
        
    } errorBlock:^(NSError *error) {
        _pinStatus2TextField.stringValue = [error localizedDescription];
    }];
    
}

- (IBAction)loginPIN:(id)sender {
    
    [_twitter postAccessTokenRequestWithPIN:_pinTextField.stringValue
                                 oauthToken:_pinOAuthToken
                               successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
                                   
                                   _pinStatus2TextField.stringValue = [NSString stringWithFormat:@"Access granted for %@", screenName];
                                   
                                   _pinOAuthTokenTextField.stringValue = oauthToken;
                                   _pinOAuthTokenSecretTextField.stringValue = oauthTokenSecret;
                                   
                               } errorBlock:^(NSError *error) {
                                   _pinStatus2TextField.stringValue = [error localizedDescription];
                               }];
}

// OAuth - XAuth
- (IBAction)loginXAuth:(id)sender {
    
    self.xAuthStatusTextField.stringValue = @"-";
    self.xAuthOAuthTokenTextField.stringValue = @"";
    self.xAuthOAuthTokenSecretTextField.stringValue = @"";

    self.twitter = [STTwitterAPIWrapper twitterAPIWithOAuthConsumerKey:_consumerKeyTextField.stringValue
                                                        consumerSecret:_consumerSecretTextField.stringValue
                                                              username:_xAuthUsernameTextField.stringValue
                                                              password:_xAuthPasswordTextField.stringValue];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        _xAuthStatusTextField.stringValue = [NSString stringWithFormat:@"Access granted for %@", username];
        
        _xAuthOAuthTokenTextField.stringValue = _twitter.oauthToken;
        _xAuthOAuthTokenSecretTextField.stringValue = _twitter.oauthTokenSecret;
        
    } errorBlock:^(NSError *error) {
        
        _xAuthStatusTextField.stringValue = [error localizedDescription];
    }];
}

// OAuth - Tokens
- (IBAction)loginTokens:(id)sender {
    
    self.oauthTokensStatusTextField.stringValue = @"-";
    
    self.twitter = [STTwitterAPIWrapper twitterAPIWithOAuthConsumerKey:_consumerKeyTextField.stringValue
                                                        consumerSecret:_consumerSecretTextField.stringValue
                                                            oauthToken:_oauthTokenTextField.stringValue
                                                      oauthTokenSecret:_oauthTokenSecretTextField.stringValue];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        _oauthTokensStatusTextField.stringValue = [NSString stringWithFormat:@"Access granted for %@", username];
        
        _oauthTokenTextField.stringValue = _twitter.oauthToken;
        _oauthTokenSecretTextField.stringValue = _twitter.oauthTokenSecret;
        
    } errorBlock:^(NSError *error) {
        
        _oauthTokensStatusTextField.stringValue = [error localizedDescription];
    }];
}

- (IBAction)getTimeline:(id)sender {
    
    self.twitterGetTimelineStatusTextField.stringValue = @"-";
    self.timelineStatuses = [NSArray array];

    [_twitter getHomeTimelineSinceID:nil count:@"20" successBlock:^(NSArray *statuses) {        
        self.timelineStatuses = statuses;
        
        _twitterGetTimelineStatusTextField.stringValue = @"OK";
    } errorBlock:^(NSError *error) {
        _twitterGetTimelineStatusTextField.stringValue = error ? [error localizedDescription] : @"Unknown error";
    }];
}

- (IBAction)chooseMedia:(id)sender {
    self.twitterPostMediaURL = nil;
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];

    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[ @"png", @"PNG", @"jpg", @"JPG", @"jpeg", @"JPEG", @"gif", @"GIF"] ];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {

        if (result != NSFileHandlingPanelOKButton) return;

        NSArray *urls = [panel URLs];
        
        NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if([evaluatedObject isKindOfClass:[NSURL class]] == NO) return NO;
            
            NSURL *url = (NSURL *)evaluatedObject;
            
            return [url isFileURL];
        }];
        
        NSArray *fileURLS = [urls filteredArrayUsingPredicate:p];
        
        NSURL *fileURL = [fileURLS lastObject];
        
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath: fileURL.path isDirectory: &isDir] == NO) return;
        
        self.twitterPostMediaURL = fileURL;
    }];
}

- (IBAction)postTweet:(id)sender {

    self.twitterPostTweetStatusTextField.stringValue = @"-";

    NSString *s = _twitterPostTweetTextField.stringValue;
    
    if(_twitterPostMediaURL) {
        [_twitter postStatusUpdate:s mediaURL:_twitterPostMediaURL successBlock:^(NSString *response) {
            _twitterPostTweetTextField.stringValue = @"";
            _twitterPostTweetStatusTextField.stringValue = @"OK";
        } errorBlock:^(NSError *error) {
            _twitterPostTweetStatusTextField.stringValue = error ? [error localizedDescription] : @"Unknown error";
        }];
    } else {
        [_twitter postStatusUpdate:s inReplyToStatusID:nil successBlock:^(NSString *response) {
            _twitterPostTweetTextField.stringValue = @"";
            _twitterPostTweetStatusTextField.stringValue = @"OK";
        } errorBlock:^(NSError *error) {
            _twitterPostTweetStatusTextField.stringValue = error ? [error localizedDescription] : @"Unknown error";
        }];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // ...
}

@end
