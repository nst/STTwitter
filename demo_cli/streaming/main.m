//
//  main.m
//  streaming
//
//  Created by Nicolas Seriot on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

#define BOT_MODE 0

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];

#if BOT_MODE
        STTwitterAPI *twitter2 = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"" consumerSecret:@"" username:@"" password:@""];
#endif
        
        [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            NSLog(@"-- Account: %@", username);

#if BOT_MODE
            [twitter2 verifyCredentialsWithSuccessBlock:^(NSString *username) {
#endif
                [twitter postStatusesFilterUserIDs:nil
                                   keywordsToTrack:@[@"CocoaHeads"]
                             locationBoundingBoxes:nil
                                         delimited:nil
                                     stallWarnings:nil
                                     progressBlock:^(id response) {
                                         
                                         if ([response isKindOfClass:[NSDictionary class]] == NO) {
                                             NSLog(@"Invalid tweet (class %@): %@", [response class], response);
                                             exit(1);
                                             return;
                                         }
                                         
                                         printf("-----------------------------------------------------------------\n");
                                         printf("-- user: @%s\n", [[response valueForKeyPath:@"user.screen_name"] cStringUsingEncoding:NSUTF8StringEncoding]);
                                         printf("-- text: %s\n", [[response objectForKey:@"text"] cStringUsingEncoding:NSUTF8StringEncoding]);
                                         
//                                         NSString *idStr = [response objectForKey:@"id_str"];

#if BOT_MODE
                                         NSString *responseText = [NSString stringWithFormat:@"Cocoaheads Yeah! %@", [NSDate date]];
                                         
                                         [twitter2 postStatusUpdate:responseText inReplyToStatusID:idStr latitude:nil longitude:nil placeID:nil displayCoordinates:nil trimUser:nil successBlock:^(NSDictionary *status) {
                                             NSLog(@"-- status: %@", status);
                                         } errorBlock:^(NSError *error) {
                                             NSLog(@"-- error: %@", error);
                                         }];
#endif
                                         
                                     } stallWarningBlock:nil errorBlock:^(NSError *error) {
                                         NSLog(@"Stream error: %@", error);
                                         exit(1);
                                     }];

                
#if BOT_MODE
            } errorBlock:^(NSError *error) {
                NSLog(@"-- %@", [error localizedDescription]);
            }];
#endif

        } errorBlock:^(NSError *error) {
            NSLog(@"-- %@", [error localizedDescription]);
            exit(1);
        }];
        
        /**/
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    
    return 0;
}
