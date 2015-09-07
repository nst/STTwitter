//
//  STClientVC.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/22/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STClientVC.h"

@interface STClientVC ()

@property (nonatomic, retain) NSObject <STTwitterRequestProtocol> *streamingRequest;

@property (nonatomic, retain) NSString *twitterTimelineUsername;
@property (nonatomic, retain) NSString *twitterStreamingKeywordsString;
@property (nonatomic, retain) NSString *twitterGetTimelineStatus;
@property (nonatomic, retain) NSString *twitterPostTweetText;
@property (nonatomic, retain) NSString *twitterPostTweetStatus;
@property (nonatomic, retain) NSString *twitterStreamingStatus;

@property (nonatomic, retain) NSURL *twitterPostMediaURL;
@property (nonatomic, retain) NSString *twitterPostLatitude;
@property (nonatomic, retain) NSString *twitterPostLongitude;

@property (nonatomic, retain) NSArray *timelineStatuses;

- (IBAction)getTimeline:(id)sender;
- (IBAction)chooseMedia:(id)sender;
- (IBAction)postTweet:(id)sender;
- (IBAction)startStreaming:(id)sender;
- (IBAction)stopStreaming:(id)sender;

@end

@implementation STClientVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)postTweet:(id)sender {
    
    [_streamingRequest cancel];
    self.streamingRequest = nil;

    self.twitterPostTweetStatus = @"-";
    
    if(_twitterPostMediaURL) {
        
        [_twitter postStatusUpdate:_twitterPostTweetText
                 inReplyToStatusID:nil
                          mediaURL:_twitterPostMediaURL
                           placeID:nil
                          latitude:_twitterPostLatitude
                         longitude:_twitterPostLongitude
         
               uploadProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                   NSLog(@"%lld %lld %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
               } successBlock:^(NSDictionary *status) {
                   
                   self.twitterPostTweetText = @"";
                   self.twitterPostTweetStatus = @"OK";
                   self.twitterPostLatitude = nil;
                   self.twitterPostLongitude = nil;
                   self.twitterPostMediaURL = nil;
               } errorBlock:^(NSError *error) {
                   self.twitterPostTweetStatus = error ? [error localizedDescription] : @"Unknown error";
               }];
        
    } else {
        
        [_twitter postStatusUpdate:_twitterPostTweetText
                 inReplyToStatusID:nil
                          latitude:_twitterPostLatitude
                         longitude:_twitterPostLongitude
                           placeID:nil
                displayCoordinates:@(YES)
                          trimUser:nil
                      successBlock:^(NSDictionary *status) {
                          
                          self.twitterPostTweetText = @"";
                          self.twitterPostTweetStatus = @"OK";
                          self.twitterPostLatitude = nil;
                          self.twitterPostLongitude = nil;
                          self.twitterPostMediaURL = nil;
                      } errorBlock:^(NSError *error) {
                          self.twitterPostTweetStatus = error ? [error localizedDescription] : @"Unknown error";
                      }];
    }
}

- (IBAction)getTimeline:(id)sender {
    
    [_streamingRequest cancel];
    self.streamingRequest = nil;

    self.twitterGetTimelineStatus = @"-";
    self.timelineStatuses = [NSArray array];
    
    if([_twitterTimelineUsername length] > 0) {
        [_twitter getUserTimelineWithScreenName:_twitterTimelineUsername successBlock:^(NSArray *statuses) {
            self.timelineStatuses = statuses;
            self.twitterGetTimelineStatus = @"OK";
        } errorBlock:^(NSError *error) {
            self.twitterGetTimelineStatus = error ? [error localizedDescription] : @"Unknown error";
        }];
    } else {
        [_twitter getHomeTimelineSinceID:nil count:20 successBlock:^(NSArray *statuses) {
            self.timelineStatuses = statuses;
            self.twitterGetTimelineStatus = @"OK";
        } errorBlock:^(NSError *error) {
            self.twitterGetTimelineStatus = error ? [error localizedDescription] : @"Unknown error";
        }];
    }
}

- (IBAction)chooseMedia:(id)sender {
    self.twitterPostMediaURL = nil;
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[ @"png", @"PNG", @"jpg", @"JPG", @"jpeg", @"JPEG", @"gif", @"GIF"] ];
    
    NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
    
    [panel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result) {
        
        if (result != NSFileHandlingPanelOKButton) return;
        
        NSArray *urls = [panel URLs];
        
        NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if([evaluatedObject isKindOfClass:[NSURL class]] == NO) return NO;
            
            NSURL *url = (NSURL *)evaluatedObject;
            
            return [url isFileURL];
        }];
        
        NSArray *fileURLS = [urls filteredArrayUsingPredicate:p];
        
        NSURL *fileURL = [fileURLS lastObject];
        
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath: fileURL.path isDirectory: &isDir] == NO) return;
        
        self.twitterPostMediaURL = fileURL;
    }];
}

- (IBAction)startStreaming:(id)sender {
    
    self.timelineStatuses = [NSArray array];
    
    if(_twitterStreamingKeywordsString == nil) return;
    
    self.twitterStreamingStatus = @"Streaming started";
    
    self.streamingRequest = [_twitter postStatusesFilterKeyword:_twitterStreamingKeywordsString
                                                  tweetBlock:^(NSDictionary *tweet) {
                                                      self.timelineStatuses = [_timelineStatuses arrayByAddingObject:tweet];
                                                  } errorBlock:^(NSError *error) {
                                                      self.twitterStreamingStatus = [error localizedDescription];
                                                  }];
}

- (IBAction)stopStreaming:(id)sender {
    
    [_streamingRequest cancel];
    self.streamingRequest = nil;
    
    self.twitterStreamingStatus = @"Streaming stopped";
}

@end
