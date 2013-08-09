//
//  ViewController.m
//  STTwitter_iOS
//
//  Created by Nicolas Seriot on 2/19/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "ViewController.h"
#import "STTwitter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // see http://rndc.or.id/wiki/index.php/(Ab)Using_Twitter_Client
//    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:@""
//                                                              consumerKey:@""
//                                                           consumerSecret:@""
//                                                                 username:@""
//                                                                 password:@""];
//    
//    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
//        
//        NSLog(@"Access granted for %@", username);
//        
//        [twitter getUserTimelineWithScreenName:@"barackobama" successBlock:^(NSArray *statuses) {
//            NSLog(@"-- statuses: %@", statuses);
//        } errorBlock:^(NSError *error) {
//            NSLog(@"-- error: %@", error);
//        }];
//        
//    } errorBlock:^(NSError *error) {
//        NSLog(@"-- error %@", error);
//    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
