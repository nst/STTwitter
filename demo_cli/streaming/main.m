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
        
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            NSLog(@"-- Account: %@", username);
            
            [twitter postStatusesFilterUserIDs:nil
                               keywordsToTrack:@[@"Apple"]
                         locationBoundingBoxes:nil
                                 stallWarnings:nil
                                 progressBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
                                     
                                     if (type != STTwitterStreamJSONTypeTweet) {
                                         NSLog(@"Invalid tweet (class %@): %@", [json class], json);
                                         exit(1);
                                         return;
                                     }
                                     
                                     printf("-----------------------------------------------------------------\n");
                                     printf("-- user: @%s\n", [[json valueForKeyPath:@"user.screen_name"] cStringUsingEncoding:NSUTF8StringEncoding]);
                                     printf("-- text: %s\n", [[json objectForKey:@"text"] cStringUsingEncoding:NSUTF8StringEncoding]);
                                     
                                 } errorBlock:^(NSError *error) {
                                     NSLog(@"Stream error: %@", error);
                                     exit(1);
                                 }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"-- %@", [error localizedDescription]);
            exit(1);
        }];
        
        /**/
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    
    return 0;
}
