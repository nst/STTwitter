//
//  STAuthenticationVC.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/22/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STAuthenticationVC.h"
#import <Accounts/Accounts.h>

static NSString *kCustomString = @"Custom...";

@interface STAuthenticationVC ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@end

@implementation STAuthenticationVC

- (void)setTwitter:(STTwitterAPI *)twitter {
    _twitter = twitter;
    
    [_delegate authenticationVC:self didChangeTwitterObject:twitter];
}

- (void)reloadTokenFile {
    self.twitterClients = [[self class] twitterClientsInApplicationSupport];
}

+ (NSString *)twitterClientInApplicationSupportPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    return [[paths lastObject] stringByAppendingPathComponent:@"STTwitter/TwitterClient.plist"];
}

+ (NSArray *)twitterClientsInApplicationSupport {
    
    NSString *path = [self twitterClientInApplicationSupportPath];
    
    NSArray *a = [NSArray arrayWithContentsOfFile:path];
    
    if(a == nil) {
        NSString *dirPath = [path stringByDeletingLastPathComponent];
        
        NSError *error = nil;
        BOOL dirWasCreated = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(dirWasCreated == NO) return nil;
        
        NSDictionary *d1 = @{ @"name":kCustomString, @"ck":@"", @"cs":@"" };
        NSDictionary *d2 = @{ @"name":@"- Add your tokens in this file -", @"ck":@"1234", @"cs":@"5678" };
        a = @[d1, d2];
        BOOL fileWasCreated = [a writeToFile:path atomically:YES];
        if(fileWasCreated == NO) return nil;
    }
    
    return a;
}

- (IBAction)revealConsumerTokensFileAction:(id)sender {
    
    NSString *path = [[self class] twitterClientInApplicationSupportPath];

    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:path];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
        self.accountStore = [[ACAccountStore alloc] init];
        self.twitterClients = [[self class] twitterClientsInApplicationSupport];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:NO];
    
    [_scrollView setDocumentView:_contentView];
        
    NSPoint topScrollOrigin = NSMakePoint(0.0, NSMaxY([[_scrollView documentView] frame]) - NSHeight([[_scrollView contentView] bounds]));
    
    [[_scrollView documentView] scrollPoint:topScrollOrigin];
    
    [self popupMenuDidSelectTwitterClient:self];
    
    /**/

    ACAccountType *twitterAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [_accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        
        if(granted == NO) return;
        
        self.osxAccounts = [_accountStore accountsWithAccountType:twitterAccountType];
    }];
}

- (IBAction)popupMenuDidSelectTwitterClient:(id)sender {
    NSDictionary *selectedClient = [[_twitterClientsController selectedObjects] lastObject];
    
    BOOL isCustomClient = [[selectedClient valueForKey:@"name"] isEqualToString:kCustomString];
    
    _consumerKeyTextField.editable = isCustomClient;
    _consumerSecretTextField.editable = isCustomClient;
    
    _consumerKeyTextField.stringValue = [selectedClient valueForKey:@"ck"];
    _consumerSecretTextField.stringValue = [selectedClient valueForKey:@"cs"];
}

- (void)askForUsernameAndPasswordWithCompletionBlock:(UsernamePasswordBlock_t)completionBlock {
    self.pinGuessLoginCompletionBlock = completionBlock;
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Login"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Please enter username and password:"];
    [alert setInformativeText:@"STTwitter will login on Twitter through the website and parse the HTML to guess the PIN."];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    NSTextField *usernameTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0,32, 180, 24)];
    NSSecureTextField *passwordTextField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 180, 24)];
    
    NSView *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 64)];
    [accessoryView addSubview:usernameTextField];
    [accessoryView addSubview:passwordTextField];
    
    [alert setAccessoryView:accessoryView];
    
    NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
    
    [alert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
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

- (NSString *)selectedConsumerName {
    return [[[_twitterClientsController selectedObjects] lastObject] valueForKey:@"name"];
}

// OS X Twitter account
- (IBAction)loginOSX:(id)sender {
    
    ACAccount *account = [[_osxAccountsController selectedObjects] lastObject];
    
    if(account == nil) {
        self.osxStatus = @"No account, cannot login.";
        return;
    }
    
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account];
    
    self.osxStatus = @"-";
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        self.osxStatus = [NSString stringWithFormat:@"Access granted for %@", username];
        [_delegate authenticationVC:self didChangeTwitterObject:_twitter]; // update username
    } errorBlock:^(NSError *error) {
        self.osxStatus = [error localizedDescription];
    }];
}

// OAuth - PIN
- (IBAction)fetchPIN:(id)sender {
    
    self.pinURL = nil;
    self.pinGuessLoginCompletionBlock = nil;
    
    self.pinStatus1 = @"-";
    self.pinStatus2 = @"-";
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:[self selectedConsumerName]
                                                     consumerKey:_consumerKeyTextField.stringValue
                                                  consumerSecret:_consumerSecretTextField.stringValue];
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        self.pinURL = url;
        
        self.pinStatus1 = [url description];
        
    } oauthCallback:_oauthCallback
                    errorBlock:^(NSError *error) {
                        
                        self.pinStatus1 = [error localizedDescription];
                    }];
}

- (IBAction)openURL:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:_pinURL];
}

- (IBAction)guessPIN:(id)sender {
    
    self.pin = @"";
    self.pinStatus2 = @"";
    
    STTwitterHTML *twitterHTML = [[STTwitterHTML alloc] init];
    
    [_twitter postTokenRequest:^(NSURL *pinURL, NSString *oauthToken) {
        
        [twitterHTML getLoginForm:^(NSString *authenticityToken) {
            
            [self askForUsernameAndPasswordWithCompletionBlock:^(NSString *username, NSString *password) {
                
                [twitterHTML postLoginFormWithUsername:username password:password authenticityToken:authenticityToken successBlock:^(NSString *body) {
                    
                    [twitterHTML getAuthorizeFormAtURL:pinURL successBlock:^(NSString *newAuthenticityToken, NSString *newOauthToken) {
                        
                        [twitterHTML postAuthorizeFormResultsAtURL:pinURL authenticityToken:newAuthenticityToken oauthToken:newOauthToken successBlock:^(NSString *PIN) {
                            
                            self.pin = PIN;
                            
                        } errorBlock:^(NSError *error) {
                            self.pinStatus2 = [error localizedDescription];
                        }];
                        
                    } errorBlock:^(NSError *error) {
                        self.pinStatus2 = [error localizedDescription];
                    }];
                    
                } errorBlock:^(NSError *error) {
                    self.pinStatus2 = [error localizedDescription];
                }];
                
            }];
            
        } errorBlock:^(NSError *error) {
            self.pinStatus2 = [error localizedDescription];
        }];
        
    } oauthCallback:nil
                    errorBlock:^(NSError *error) {
                        self.pinStatus2 = [error localizedDescription];
                    }];
    
}

- (IBAction)loginPIN:(id)sender {
    
    self.pinStatus2 = @"";
    self.pinOAuthToken = @"";
    self.pinOAuthTokenSecret = @"";
    
    [_twitter postAccessTokenRequestWithPIN:_pin
                               successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
                                   
                                   self.pinStatus2 = [NSString stringWithFormat:@"Access granted for %@", screenName];
                                   
                                   self.pinOAuthToken = oauthToken;
                                   self.pinOAuthTokenSecret = oauthTokenSecret;
                                   
                                   [_delegate authenticationVC:self didChangeTwitterObject:_twitter]; // update username

                               } errorBlock:^(NSError *error) {
                                   self.pinStatus2 = [error localizedDescription];
                               }];
}

//- (void)setXAuthPassword:(NSString *)s {
//    _xAuthPassword = s;
//}

// OAuth - XAuth
- (IBAction)loginXAuth:(id)sender {
    
    self.xAuthStatus = @"-";
    self.xAuthOAuthToken = @"";
    self.xAuthOAuthTokenSecret = @"";
    
    NSAssert(_xAuthUsername, @"");
    NSAssert(_xAuthPassword, @"");
        
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:[self selectedConsumerName]
                                                     consumerKey:_consumerKeyTextField.stringValue
                                                  consumerSecret:_consumerSecretTextField.stringValue
                                                        username:_xAuthUsername
                                                        password:_xAuthPassword];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        self.xAuthStatus = [NSString stringWithFormat:@"Access granted for %@", username];
        
        self.xAuthOAuthToken = _twitter.oauthAccessToken;
        self.xAuthOAuthTokenSecret = _twitter.oauthAccessTokenSecret;
        
        [_delegate authenticationVC:self didChangeTwitterObject:_twitter]; // update username
        
    } errorBlock:^(NSError *error) {
        
        self.xAuthStatus = [error localizedDescription];
    }];
}

// Application Only
- (IBAction)fetchBearer:(id)sender {
    
    self.bearerStatus = @"-";
    
    self.twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerName:[self selectedConsumerName]
                                                       consumerKey:_consumerKeyTextField.stringValue
                                                    consumerSecret:_consumerSecretTextField.stringValue];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        self.bearerToken = [_twitter bearerToken];
        [_delegate authenticationVC:self didChangeTwitterObject:_twitter]; // update username
    } errorBlock:^(NSError *error) {
        self.bearerToken = [_twitter bearerToken];
        self.bearerStatus = [error localizedDescription];
    }];
}

- (IBAction)invalidateBearer:(id)sender {
    
    self.bearerStatus = @"-";
    
    [_twitter invalidateBearerTokenWithSuccessBlock:^() {
        self.bearerToken = [_twitter bearerToken];
        self.bearerStatus = @"ok";
    } errorBlock:^(NSError *error) {
        self.bearerToken = [_twitter bearerToken];
        self.bearerStatus = [error localizedDescription];
    }];
}

// OAuth - Tokens
- (IBAction)loginTokens:(id)sender {
    
    self.oauthTokensStatus = @"-";
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:[self selectedConsumerName]
                                                     consumerKey:_consumerKeyTextField.stringValue
                                                  consumerSecret:_consumerSecretTextField.stringValue
                                                      oauthToken:_oauthToken
                                                oauthTokenSecret:_oauthTokenSecret];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        self.oauthTokensStatus = [NSString stringWithFormat:@"Access granted for %@", username];
        
        self.oauthToken = _twitter.oauthAccessToken;
        self.oauthTokenSecret = _twitter.oauthAccessTokenSecret;
        
        [_delegate authenticationVC:self didChangeTwitterObject:_twitter]; // update username
        
    } errorBlock:^(NSError *error) {
        
        self.oauthTokensStatus = [error localizedDescription];
    }];
}

@end
