//
//  STClientVC.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/22/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STClientVC.h"

@interface STClientVC ()

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
    
    self.twitterPostTweetStatus = @"-";
    
    if(_twitterPostMediaURL) {
        
        [_twitter postStatusUpdate:_twitterPostTweetText
                 inReplyToStatusID:nil
                          mediaURL:_twitterPostMediaURL
                           placeID:nil
                          latitude:_twitterPostLatitude
                         longitude:_twitterPostLongitude
         
               uploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
                   NSLog(@"%lu %lu %lu", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
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


@end
