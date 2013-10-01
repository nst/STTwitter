//
//  ViewController.h
//  STTwitterDemoiOSSafari
//
//  Created by Nicolas Seriot on 10/1/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, strong) NSArray *statuses;

@property (nonatomic, weak) IBOutlet UITextField *consumerKeyTextField;
@property (nonatomic, weak) IBOutlet UITextField *consumerSecretTextField;
@property (nonatomic, weak) IBOutlet UILabel *loginStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *getTimelineStatusLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)loginWithiOSAction:(id)sender;
- (IBAction)loginInSafariAction:(id)sender;
- (IBAction)getTimelineAction:(id)sender;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@end
