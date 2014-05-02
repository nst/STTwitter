//
//  main.m
//  streaming
//
//  Created by Nicolas Seriot on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        NSString * const TWITTER_CONSUMER_KEY = @"";
        NSString * const TWITTER_CONSUMER_SECRET_KEY = @"";
        
        if ([TWITTER_CONSUMER_KEY length] == 0) {
            NSLog(@"You need to set a Consumer Key.");
            exit(1);
            
        }
        if ([TWITTER_CONSUMER_SECRET_KEY length] == 0) {
            NSLog(@"You need to set a Consumer Seacret Key.");
            exit(1);
        }
        
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil consumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET_KEY];
        [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
            
            STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithFirstAccount];
            [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
                
                [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader successBlock:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName) {
                    
                    NSLog(@"REVERSE AUTH OK");
                    exit(0);
                    
                } errorBlock:^(NSError *error) {
                    
                    NSLog(@"ERROR, %@", [error localizedDescription]);
                    exit(1);
                    
                }];
                
            } errorBlock:^(NSError *error) {
                
                NSLog(@"ERROR");
                exit(1);
                
            }];
            
        } errorBlock:^(NSError *error) {
            
            NSLog(@"ERROR");
            exit(1);
            
        }];

        
        /**/
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    
    return 0;
}
