//
//  main.m
//  clitter
//
//  Created by Nicolas Seriot on 10/10/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

#warning Replace these demo tokens with yours https://dev.twitter.com/apps
static NSString *CONSUMER_KEY = @"";
static NSString *CONSUMER_SECRET = @"";

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"u"];
        NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"p"];
        
        if(username == nil || password == nil) {
            printf("USAGE:\n");
            printf("./clitter -u USERNAME -p PASSWORD\n");
            exit(1);
        }
        
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                              consumerSecret:CONSUMER_SECRET
                                                                    username:username
                                                                    password:password];
        
        [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {

            [twitter _getActivityByFriendsSinceID:nil
                                            count:@"100"
                               contributorDetails:@(NO)
                                     includeCards:@(NO)
                                  includeEntities:@(NO)
                                includeMyRetweets:nil
                               includeUserEntites:@(NO)
                                    latestResults:@(YES)
                                   sendErrorCodes:nil successBlock:^(NSArray *activities) {
                
                NSArray *favorites = [activities filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    NSDictionary *d = (NSDictionary *)evaluatedObject;
                    return [[d valueForKey:@"action"] isEqualToString:@"favorite"];
                }]];
                
                NSMutableString *ms = [NSMutableString string];
                
                for(NSDictionary *d in favorites) {
                    [ms appendString:@"----------\n"];
                    
                    NSString *timestamp = [d valueForKey:@"created_at"];

                    for(NSDictionary *source in [d valueForKey:@"sources"]) {
                        NSString *sourceName = [source valueForKey:@"screen_name"];
                        
                        [ms appendFormat:@"%@ @%@ favorited:\n", timestamp, sourceName];
                    }
                    
                    for(NSDictionary *target in [d valueForKey:@"targets"]) {
                        //NSString *timestamp = [target valueForKey:@"created_at"];
                        NSString *targetName = [target valueForKeyPath:@"user.screen_name"];
                        NSString *text = [target valueForKey:@"text"];
                        text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n                "];
                        NSString *favouritesCount = [target valueForKey:@"favorite_count"];
                        NSString *retweetsCount = [target valueForKey:@"retweet_count"];

                        [ms appendFormat:@"[F %@]\t[R %@]\t@%@\t%@\n", favouritesCount, retweetsCount, targetName, text];
                    }
                }

                printf("%s", [ms cStringUsingEncoding:NSUTF8StringEncoding]);

                exit(0);

            } errorBlock:^(NSError *error) {
                NSLog(@"-- error: %@", error);

                exit(0);
            }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"-- error: %@", error);

            exit(0);
        }];
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    return 0;
}

