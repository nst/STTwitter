//
//  main.m
//  streaming
//
//  Created by Nicolas Seriot on 03/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

NSString *firstTweetID = nil;

void postStatus(STTwitterAPI *twitter,
                NSMutableArray *statusesAndMediaURLs,
                NSString *previousStatusID) {
    
    NSDictionary *d = [statusesAndMediaURLs firstObject];
    if(d == nil) {
        NSLog(@"--------------------");
        NSLog(@"-- posting complete");
        NSLog(@"-- see https://www.twitter.com/statuses/%@/", firstTweetID);
        exit(0);
    }
    [statusesAndMediaURLs removeObjectAtIndex:0];
    
    NSString *status = [d objectForKey:@"status"];
    NSURL *mediaURL = [d objectForKey:@"mediaURL"];
    NSData *mediaData = [NSData dataWithContentsOfURL:mediaURL];
    
    NSLog(@"--------------------");
    NSLog(@"-- text: %@", status);
    NSLog(@"-- data: %@", [mediaURL lastPathComponent]);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"status"] = status;
    if(previousStatusID) md[@"in_reply_to_status_id"] = previousStatusID;
    md[@"media[]"] = mediaData;
    md[@"kSTPOSTDataKey"] = @"media[]";
    
    [twitter postResource:@"statuses/update_with_media.json"
            baseURLString:kBaseURLStringAPI
               parameters:md
      uploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
          NSLog(@"-- %.02f%%", 100.0 * totalBytesWritten / totalBytesExpectedToWrite);
          
      } downloadProgressBlock:^(id json) {
          
      } successBlock:^(NSDictionary *rateLimits, id response) {
          
          NSLog(@"-- x-mediaratelimit-remaining: %@", rateLimits[@"x-mediaratelimit-remaining"]);
          
          NSString *previousStatusID = [response objectForKey:@"id_str"];
          NSLog(@"-- status: %@", previousStatusID);
          
          if(firstTweetID == nil) firstTweetID = previousStatusID;
          
          postStatus(twitter, statusesAndMediaURLs, previousStatusID);
          
      } errorBlock:^(NSError *error) {
          NSLog(@"-- %@", error);
          exit(1);
      }];
    
}

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        STTwitterAPI *t = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [t verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            NSURL *mediaURL = [NSURL fileURLWithPath:@"/System/Library/CoreServices/Screen Sharing.app/Contents/Resources/DarkerTexturedBackgroundColor.png"];
            
            NSMutableArray *statusesAndMediaURLs = [ @[ @{@"status":@"asd", @"mediaURL":mediaURL},
                                                        @{@"status":@"sdf", @"mediaURL":mediaURL} ] mutableCopy];
            
            postStatus(t, statusesAndMediaURLs, nil);
            
        } errorBlock:^(NSError *error) {
            NSLog(@"-- %@", error);
        }];
        
        /**/
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    
    return 0;
}
