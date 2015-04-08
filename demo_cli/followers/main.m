//
//  main.m
//  streaming
//
//  Created by Nicolas Seriot on 03/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        __block NSMutableArray *followersIDs = [NSMutableArray array];
        
        STTwitterAPI *t = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@""
                                                        consumerSecret:@""
                                                              username:@""
                                                              password:@""];
        
        [t verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            
            [t fetchAndFollowCursorsForResource:@"followers/ids.json"
                                     HTTPMethod:@"GET"
                                  baseURLString:@"https://api.twitter.com/1.1"
                                     parameters:@{@"screen_name":@"0xcharlie"}
                            uploadProgressBlock:nil
                          downloadProgressBlock:nil
                                   successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response, BOOL morePagesToCome, BOOL *stop) {
                                       NSLog(@"-- success, more to come: %d, %@", morePagesToCome, response);
                                       
                                       NSArray *ids = [response valueForKey:@"ids"];
                                       if(ids) {
                                           [followersIDs addObjectsFromArray:ids];
                                           NSLog(@"-- added %lu IDs, more to come: %d", [ids count], morePagesToCome);
                                       }
                                       
                                       if(morePagesToCome == NO) {
                                           NSLog(@"-- IDs count: %lu", (unsigned long)[followersIDs count]);
                                           NSLog(@"-- IDs: %@", followersIDs);
                                       }
                                       
                                   } pauseBlock:^(NSDate *nextRequestDate) {
                                       NSLog(@"-- rate limit exhausted, nextRequestDate: %@", nextRequestDate);
                                   } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                                       NSLog(@"-- %@", error);
                                   }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"--1 %@", error);
        }];
        
        /**/
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    
    return 0;
}
