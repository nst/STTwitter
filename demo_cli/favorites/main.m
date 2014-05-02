//
//  main.m
//  clitter
//
//  Created by Nicolas Seriot on 10/10/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

NSString *descriptionForTarget(NSDictionary *target) {
    //NSString *timestamp = [target valueForKey:@"created_at"];
    NSString *targetName = [target valueForKeyPath:@"user.screen_name"];
    NSString *text = [target valueForKey:@"text"];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n                                    "];
    NSString *favouritesCount = [target valueForKey:@"favorite_count"];
    NSString *retweetsCount = [target valueForKey:@"retweet_count"];
    NSString *idString = [target valueForKey:@"id_str"];
    
    return [NSString stringWithFormat:@"%@\t[F %@] [R %@]\t@%@\t%@", idString, favouritesCount, retweetsCount, targetName, text];
}

NSString *descriptionForFavorites(NSArray *favorites) {
    
    NSMutableString *ms = [NSMutableString string];
    
    NSUInteger numberOfFavorites = 0;
    
    for(NSDictionary *d in favorites) {
        [ms appendString:@"----------\n"];
        
        NSString *timestamp = [d valueForKey:@"created_at"];
        
        for(NSDictionary *source in [d valueForKey:@"sources"]) {
            NSString *sourceName = [source valueForKey:@"screen_name"];
            
            [ms appendFormat:@"%@ @%@ favorited:\n", timestamp, sourceName];
        }
        
        NSArray *targets = [d valueForKey:@"targets"];
        
        numberOfFavorites += [targets count];
        
        for(NSDictionary *target in targets) {
            
            NSString *targetDescription = descriptionForTarget(target);
            
            [ms appendFormat:@"%@\n", targetDescription];
        }
    }
    
    return ms;
}

void setFavoriteStatus(STTwitterAPI *twitter, BOOL isFavorite, NSString *statusID) {
    [twitter postFavoriteState:isFavorite forStatusID:statusID successBlock:^(NSDictionary *status) {
        NSLog(@"%@", status);
        exit(0);
    } errorBlock:^(NSError *error) {
        printf("%s\n", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
        exit(1);
    }];
}

void fetchFavorites(STTwitterAPI *twitter, NSString *sinceID) {
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
                               
                               if([favorites count] == 0) {
                                   printf("No favorites found.\n");
                                   exit(0);
                               }
                               
                               NSArray *maxPositions = [favorites valueForKeyPath:@"max_position"];
                               NSString *maxPosition = [maxPositions count] ? [maxPositions objectAtIndex:0] : nil;
                               
                               if(maxPosition) {
                                   [[NSUserDefaults standardUserDefaults] setValue:maxPosition forKey:@"CurrentPosition"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                               }
                               
                               printf("Current position: %s\n", [maxPosition cStringUsingEncoding:NSUTF8StringEncoding]);
                               
                               NSString *favoritesDescription = descriptionForFavorites(favorites);
                               printf("%s", [favoritesDescription cStringUsingEncoding:NSUTF8StringEncoding]);
                               
                               exit(0);
                               
                           } errorBlock:^(NSError *error) {
                               printf("%s\n", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
                               
                               exit(1);
                           }];
}


int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        printf("Clitter displays the latest favorites by your friends, using OS X settings.\n");
        printf("By default, it remembers the latest position and will fetch only new one.\n");
        printf("USAGE: ./clitter [-fav (1|0) -status STATUS_ID] | [-pos POSITION] | [-all YES]\n\n");
        
        // 1382776597941
        
        BOOL fetchAll = [[NSUserDefaults standardUserDefaults] boolForKey:@"all"];
        NSString *setToFavoriteString = [[NSUserDefaults standardUserDefaults] valueForKey:@"fav"]; // 1 or 0
        NSString *statusID = [[NSUserDefaults standardUserDefaults] valueForKey:@"status"];
        NSString *sinceIDFromArgument = [[NSUserDefaults standardUserDefaults] valueForKey:@"pos"];
        NSString *sinceIDFromUserDefaults = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentPosition"];
        
        NSString *sinceID = nil;
        
        if(fetchAll) {
            sinceID = nil;
        } else if(sinceIDFromArgument) {
            sinceID = sinceIDFromArgument;
        } else if (sinceIDFromUserDefaults) {
            sinceID = sinceIDFromUserDefaults;
        }
        
        __block STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            printf("Account: %s\n", [username cStringUsingEncoding:NSUTF8StringEncoding]);
            
            if(setToFavoriteString && statusID) {
                BOOL setToFavorite = [@([setToFavoriteString integerValue]) boolValue];
                
                setFavoriteStatus(twitter, setToFavorite, statusID);
            } else {
                fetchFavorites(twitter, sinceID);
            }
            
        } errorBlock:^(NSError *error) {
            printf("%s\n", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            exit(1);
        }];
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}

