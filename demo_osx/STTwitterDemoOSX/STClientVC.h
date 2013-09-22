//
//  STClientVC.h
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/22/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "STTwitter.h"

@interface STClientVC : NSViewController

@property (nonatomic, retain) STTwitterAPI *twitter;

@property (nonatomic, retain) NSString *twitterTimelineUsername;
@property (nonatomic, retain) NSString *twitterGetTimelineStatus;
@property (nonatomic, retain) NSString *twitterPostTweetText;
@property (nonatomic, retain) NSString *twitterPostTweetStatus;

@property (nonatomic, retain) NSURL *twitterPostMediaURL;
@property (nonatomic, retain) NSString *twitterPostLatitude;
@property (nonatomic, retain) NSString *twitterPostLongitude;

@property (nonatomic, retain) NSArray *timelineStatuses;
- (IBAction)getTimeline:(id)sender;
- (IBAction)chooseMedia:(id)sender;
- (IBAction)postTweet:(id)sender;

@end
