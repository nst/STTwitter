//
//  main.m
//  t2rss
//
//  Created by Nicolas Seriot on 13/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        STTwitterAPI *t = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [t verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            NSMutableArray *lines = [NSMutableArray array];
            
            [lines addObject:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
            [lines addObject:@"<rss version=\"2.0\">"];
            [lines addObject:@""];
            [lines addObject:@"<channel>"];
            [lines addObject:@""];
            [lines addObject:@"<title>My Title</title>"];
            [lines addObject:@"<link>http://localhost/</link>"];
            [lines addObject:@"<description>xxx</description>"];
            
            [t getStatusesUserTimelineForUserID:nil
                                     screenName:@"nst021"
                                        sinceID:nil
                                          count:@"100"
                                          maxID:nil
                                       trimUser:nil
                                 excludeReplies:nil
                             contributorDetails:nil
                                includeRetweets:nil
                                   successBlock:^(NSArray *statuses) {
                                       NSLog(@"-- %@ statuses", @([statuses count]));
                                       
                                       for(NSDictionary *d in statuses) {
                                           
                                           [lines addObject:@""];
                                           [lines addObject:@"   <item>"];
                                           
                                           
                                           [lines addObject:[NSString stringWithFormat:@"       <author>%@</author>", [d valueForKeyPath:@"user.screen_name"]]];
                                           
                                           [lines addObject:@"       <guid></guid>"];
                                           [lines addObject:@"       <title>XML Tutorial</title>"];
                                           [lines addObject:@"       <link>http://www.w3schools.com/xml</link>"];
                                           
                                           [lines addObject:[NSString stringWithFormat:@"       <description>%@</description>", [d valueForKey:@"text"]]];
                                           [lines addObject:[NSString stringWithFormat:@"       <pubDate>%@</pubDate>", [d valueForKey:@"created_at"]]];
                                           
                                           [lines addObject:@"   </item>"];
                                       }
                                       
                                       [lines addObject:@""];
                                       [lines addObject:@"</channel>"];
                                       [lines addObject:@""];
                                       [lines addObject:@"</rss>"];
                                       
                                       NSString *s = [lines componentsJoinedByString:@"\n"];
                                       NSError *error = nil;
                                       NSString *path = @"/tmp/t2rss.xml";
                                       BOOL success = [s writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
                                       if(success == NO) {
                                           NSLog(@"-- %@", error);
                                           exit(1);
                                       }
                                       
                                       NSLog(@"-- RSS contents written in: %@", path);
                                       
                                       exit(0);
                                       
                                   } errorBlock:^(NSError *error) {
                                       NSLog(@"-- %@", error);
                                   }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"-- %@", error);
        }];
        
        /**/
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    
    return 0;
}

