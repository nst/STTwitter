//
//  ViewController.m
//  STTwitterDemoiOSSafari
//
//  Created by Nicolas Seriot on 10/1/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "ViewController.h"
#import "STTwitter.h"
#import "WebViewVC.h"
#import <Accounts/Accounts.h>

@interface ViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@end

// https://dev.twitter.com/docs/auth/implementing-sign-twitter

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.accountStore = [[ACAccountStore alloc] init];
    
#warning Replace these demo tokens with yours https://dev.twitter.com/apps
    _consumerKeyTextField.text = @"PdLBPYUXlhQpt4AguShUIw";
    _consumerSecretTextField.text = @"drdhGuKSingTbsDLtYpob4m5b5dn1abf9XXYyZKQzk";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithiOSAction:(id)sender {
    
    _loginStatusLabel.text = @"Trying to login with iOS...";
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                _loginStatusLabel.text = @"Acccess not granted";
                return;
            }
            
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            
            if([_iOSAccounts count] == 1) {
                ACAccount *account = [_iOSAccounts lastObject];
                
                [self loginWithiOSAccount:account];
            } else {
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil otherButtonTitles:nil];
                for(ACAccount *account in _iOSAccounts) {
                    [as addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                }
                [as showInView:self.view.window];
            }
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
    
}

- (void)loginWithiOSAccount:(ACAccount *)account {
    
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        _loginStatusLabel.text = [NSString stringWithFormat:@"@%@", username];
        
    } errorBlock:^(NSError *error) {
        _loginStatusLabel.text = [error localizedDescription];
    }];
    
}

- (IBAction)loginOnTheWebAction:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:_consumerKeyTextField.text
                                                 consumerSecret:_consumerSecretTextField.text];
    
    _loginStatusLabel.text = @"Trying to login with Safari...";
    _loginStatusLabel.text = @"";
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSLog(@"-- url: %@", url);
        NSLog(@"-- oauthToken: %@", oauthToken);
        
        if([self.openSafariSwitch isOn]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            WebViewVC *webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewVC"];
            
            [self presentViewController:webViewVC animated:YES completion:^{
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [webViewVC.webView loadRequest:request];
            }];
        }
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"myapp://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                        _loginStatusLabel.text = [error localizedDescription];
                    }];
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        _loginStatusLabel.text = screenName;
        
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
    } errorBlock:^(NSError *error) {
        
        _loginStatusLabel.text = [error localizedDescription];
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (IBAction)getTimelineAction:(id)sender {
    
    self.getTimelineStatusLabel.text = @"";
    
    [_twitter getHomeTimelineSinceID:nil
                               count:20
                        successBlock:^(NSArray *statuses) {
                            
                            NSLog(@"-- statuses: %@", statuses);
                            
                            self.getTimelineStatusLabel.text = [NSString stringWithFormat:@"%lu statuses", (unsigned long)[statuses count]];
                            
                            self.statuses = statuses;
                            
                            [self.tableView reloadData];
                            
                        } errorBlock:^(NSError *error) {
                            self.getTimelineStatusLabel.text = [error localizedDescription];
                        }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STTwitterTVCellIdentifier"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"STTwitterTVCellIdentifier"];
    }
    
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    
    NSString *text = [status valueForKey:@"text"];
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
    NSString *dateString = [status valueForKey:@"created_at"];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@ | %@", screenName, dateString];
    
    return cell;
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == [actionSheet cancelButtonIndex]) {
        NSString *username = _twitter.userName;
        _loginStatusLabel.text = username ? [NSString stringWithFormat:@"@%@", username] : @"";
        return;
    }
    
    NSUInteger accountIndex = buttonIndex - 1;
    ACAccount *account = [_iOSAccounts objectAtIndex:accountIndex];
    
    _loginStatusLabel.text = [NSString stringWithFormat:@"Did select %@", account.username];
    
    [self loginWithiOSAccount:account];
}

@end
