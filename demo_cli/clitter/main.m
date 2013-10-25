//
//  main.m
//  clitter
//
//  Created by Nicolas Seriot on 10/10/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        NSString *h = [[NSUserDefaults standardUserDefaults] valueForKey:@"h"];
        NSString *help = [[NSUserDefaults standardUserDefaults] valueForKey:@"help"];
        NSString *sinceID = [[NSUserDefaults standardUserDefaults] valueForKey:@"pos"];
        
        if(h || help) {
            printf("Display latest favorites by friends using OS X settings.\n");
            printf("USAGE:\n");
            printf("./clitter ([-h][-help] | [-pos POSITION])\n");
            exit(1);
        }
        
        __block STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            printf("Account: %s\n", [username cStringUsingEncoding:NSUTF8StringEncoding]);
            
            if(sinceID) {
                printf("Fetching favorites starting at position: %s\n", [sinceID cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            [twitter _getActivityByFriendsSinceID:sinceID
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
                                       
                                       NSString *globalMaxPosition = nil;
                                       
                                       NSUInteger numberOfFavorites = 0;
                                       
                                       for(NSDictionary *d in favorites) {
                                           [ms appendString:@"----------\n"];
                                           
                                           NSString *maxPosition = [d valueForKey:@"max_position"];
                                           
                                           NSString *timestamp = [d valueForKey:@"created_at"];
                                           
                                           [ms appendFormat:@"max_position: %@\n", maxPosition];
                                           
                                           for(NSDictionary *source in [d valueForKey:@"sources"]) {
                                               NSString *sourceName = [source valueForKey:@"screen_name"];
                                               
                                               [ms appendFormat:@"%@ @%@ favorited:\n", timestamp, sourceName];
                                           }
                                           
                                           for(NSDictionary *target in [d valueForKey:@"targets"]) {
                                               numberOfFavorites += 1;
                                               
                                               //NSString *timestamp = [target valueForKey:@"created_at"];
                                               NSString *targetName = [target valueForKeyPath:@"user.screen_name"];
                                               NSString *text = [target valueForKey:@"text"];
                                               text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n                                    "];
                                               NSString *favouritesCount = [target valueForKey:@"favorite_count"];
                                               NSString *retweetsCount = [target valueForKey:@"retweet_count"];
                                               NSString *idString = [target valueForKey:@"id_str"];
                                               
                                               if(globalMaxPosition == nil) {
                                                   globalMaxPosition = maxPosition;
                                               } else {
                                                   NSArray *sorted = [@[globalMaxPosition, maxPosition] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                       return [obj1 compare:obj2 options:NSNumericSearch];
                                                   }];
                                                   globalMaxPosition = [sorted lastObject];
                                               }
                                               
                                               [ms appendFormat:@"%@\t[F %@] [R %@]\t@%@\t%@\n", idString, favouritesCount, retweetsCount, targetName, text];
                                           }
                                       }
                                       
                                       printf("Max Position: %s\n", [globalMaxPosition cStringUsingEncoding:NSUTF8StringEncoding]);
                                       
                                       printf("%s", [ms cStringUsingEncoding:NSUTF8StringEncoding]);
                                       
                                       exit(0);
                                       
                                   } errorBlock:^(NSError *error) {
                                       printf("%s\n", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
                                       
                                       exit(0);
                                   }];
            
        } errorBlock:^(NSError *error) {
            printf("%s\n", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
        }];
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}

