//
//  main.m
//  accounts_creation
//
//  Created by Nicolas Seriot on 17/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        STTwitterAPI *t = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"IHUYavQ7mmPBhNiBBlF9Q"
                                                        consumerSecret:@"cIBZ..."
                                                            oauthToken:@"179654598-yukdZLZcDfxU5PZBZdJcCpaJF5bKUJTdxXoxUZ9u"
                                                      oauthTokenSecret:@"YEhw..."];
        
        [t _postAccountGenerateWithADC:@"pad"
                   discoverableByEmail:YES
                                 email:@"EMAIL"
                            geoEnabled:NO
                              language:@"en"
                                  name:@"NAME"
                              password:@"PASSWORD"
                            screenName:@"SCREEN_NAME"
                         sendErrorCode:YES
                              timeZone:@"CEST"
                          successBlock:^(id userProfile) {
                              NSLog(@"-- userProfile: %@", userProfile);
                          } errorBlock:^(NSError *error) {
                              NSLog(@"-- error: %@", error);
                          }];
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
