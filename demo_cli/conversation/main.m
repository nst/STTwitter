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
    NSString *filePath = [d objectForKey:@"filePath"];
    NSData *mediaData = [NSData dataWithContentsOfFile:filePath];
    
    NSLog(@"--------------------");
    NSLog(@"-- text: %@", status);
    NSLog(@"-- data: %@", [filePath lastPathComponent]);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"status"] = status;
    if(previousStatusID) md[@"in_reply_to_status_id"] = previousStatusID;
    md[@"media[]"] = mediaData;
    md[kSTPOSTDataKey] = @"media[]";
    
    [twitter postResource:@"statuses/update_with_media.json"
            baseURLString:kBaseURLStringAPI_1_1
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
            
            NSString *dirPath = @"/Users/nst/Desktop/sttwitter_cocoaheads/";
            
            NSError *error = nil;
            NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error];
            if(filenames == nil) {
                NSLog(@"-- error: %@", error);
                exit(1);
            }
            
            NSMutableArray *statusesAndMediaURLs = [NSMutableArray array];
            
            for (NSString *filename in filenames) {
                if([filename hasPrefix:@"."]) continue;
                NSString *filePath = [dirPath stringByAppendingPathComponent:filename];
                [statusesAndMediaURLs addObject:@{@"status":filename, @"filePath":filePath}];
            }
            
            postStatus(t, statusesAndMediaURLs, nil);
            
        } errorBlock:^(NSError *error) {
            NSLog(@"-- %@", error);
        }];
        
        /**/
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    
    return 0;
}
