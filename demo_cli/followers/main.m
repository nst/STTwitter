//
//  main.m
//  streaming
//
//  Created by Nicolas Seriot on 03/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

typedef void (^AllFollowersBlock_t)(NSArray *allFollowers);

void getFollowers(STTwitterAPI *twitter,
                  NSString *screenName,
                  NSMutableArray *followers,
                  NSString *cursor,
                  AllFollowersBlock_t allFollowersBlock) {
    
    if(followers == nil) followers = [NSMutableArray array]; 
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    md[@"skip_status"] = @"1";
    md[@"include_user_entities"] = @"0";
    
    [twitter getResource:@"followers/list.json"
           baseURLString:kBaseURLStringAPI
              parameters:md
   downloadProgressBlock:^(id json) {
       //
   } successBlock:^(NSDictionary *rateLimits, id response) {

       NSArray *users = nil;
       NSString *previousCursor = nil;
       NSString *nextCursor = nil;
       
       if([response isKindOfClass:[NSDictionary class]]) {
           users = [response valueForKey:@"users"];
           previousCursor = [response valueForKey:@"previous_cursor_str"];
           nextCursor = [response valueForKey:@"next_cursor_str"];
       }
       
       NSLog(@"-- users: %@", @([users count]));
       NSLog(@"-- previousCursor: %@", previousCursor);
       NSLog(@"-- nextCursor: %@", nextCursor);
       
       [followers addObjectsFromArray:users];

       if([nextCursor integerValue] == 0) {
           allFollowersBlock(followers);
           return;
       }
       
       /**/
       
       NSString *remainingString = [rateLimits objectForKey:@"x-rate-limit-remaining"];
       NSString *resetString = [rateLimits objectForKey:@"x-rate-limit-reset"];
       
       NSInteger remainingInteger = [remainingString integerValue];
       NSInteger resetInteger = [resetString integerValue];
       NSTimeInterval timeInterval = 0;
       
       if(remainingInteger == 0) {

           NSDate *resetDate = [[NSDate alloc] initWithTimeIntervalSince1970:resetInteger];
           timeInterval = [resetDate timeIntervalSinceDate:[NSDate date]] + 5;

       }

       NSLog(@"-- wait for %@ seconds", @(timeInterval));

       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           
           getFollowers(twitter, screenName, followers, nextCursor, allFollowersBlock);
           
       });
       
   } errorBlock:^(NSError *error) {
       NSLog(@"-- error: %@", error);
   }];
}

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        STTwitterAPI *t = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [t verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
            AllFollowersBlock_t allFollowersBlock = ^(NSArray *allFollowers) {
                NSLog(@"-- allFollowers: %@", [allFollowers valueForKey:@"screen_name"]);
            };
            
            getFollowers(t, @"SbClx", nil, nil, allFollowersBlock);
            
        } errorBlock:^(NSError *error) {
            NSLog(@"--1 %@", error);
        }];
        
        /**/
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    
    return 0;
}
