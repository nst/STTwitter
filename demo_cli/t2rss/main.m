//
//  main.m
//  t2rss
//
//  Created by Nicolas Seriot on 13/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

@interface NSDateFormatter (STTwitter_CLI)
+ (NSDateFormatter *)rfc822Formatter;
@end

@implementation NSDateFormatter (STTwitter_CLI)
+ (NSDateFormatter *)rfc822Formatter {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
    	formatter = [[NSDateFormatter alloc] init];
    	NSLocale *enUS = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    	[formatter setLocale:enUS];
    	[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    }
    return formatter;
}
@end

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
            [lines addObject:[NSString stringWithFormat:@"<title>%@</title>", username]];
            [lines addObject:@"<link>http://localhost/</link>"];
            [lines addObject:@"<description>xxx</description>"];
            
            [t getStatusesHomeTimelineWithCount:@"100"
                                        sinceID:nil
                                          maxID:nil
                                       trimUser:nil
                                 excludeReplies:nil
                             contributorDetails:nil
                                includeEntities:nil
                                   successBlock:^(NSArray *statuses) {
                                       
                                       for(NSDictionary *d in statuses) {
                                           
                                           NSString *text = [d valueForKey:@"text"];
                                           NSString *idStr = [d valueForKey:@"id_str"];
                                           NSString *createdAtDateString = [d valueForKey:@"created_at"];
                                           NSString *urlString = [NSString stringWithFormat:@"https://www.twitter.com/statuses/%@/", idStr];
                                           
                                           [lines addObject:@""];
                                           [lines addObject:@"   <item>"];
                                           [lines addObject:[NSString stringWithFormat:@"       <author>@%@</author>", [d valueForKeyPath:@"user.screen_name"]]];
                                           [lines addObject:[NSString stringWithFormat:@"       <guid>%@</guid>", urlString]];
                                           [lines addObject:[NSString stringWithFormat:@"       <title>%@</title>", text]];
                                           [lines addObject:[NSString stringWithFormat:@"       <link>%@</link>", urlString]];
                                           [lines addObject:[NSString stringWithFormat:@"       <description>%@</description>", text]];
                                           
                                           NSDate *date = [[NSDateFormatter st_TwitterDateFormatter] dateFromString:createdAtDateString];
                                           NSString *dateString = [[NSDateFormatter rfc822Formatter] stringFromDate:date];
                                           
                                           [lines addObject:[NSString stringWithFormat:@"       <pubDate>%@</pubDate>", dateString]];
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
        
        [[NSRunLoop currentRunLoop] run];
    }
    
    return 0;
}

