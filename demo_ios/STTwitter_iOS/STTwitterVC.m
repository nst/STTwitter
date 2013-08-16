//
//  ViewController.m
//  STTwitter_iOS
//
//  Created by Nicolas Seriot on 2/19/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STTwitterVC.h"
#import "STTwitter.h"

@interface STTwitterVC ()
@property (nonatomic, retain) NSArray *statuses;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@end

@implementation STTwitterVC

- (void)dealloc {
    [_statuses release];
    [_tableView release];
    [_statusLabel release];
    [super dealloc];
}

- (IBAction)getTimelineAction:(id)sender {

    self.statuses = @[];
    self.statusLabel.text = @"";
    [self.tableView reloadData];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
                
        self.statusLabel.text = [NSString stringWithFormat:@"Fetching timeline for @%@...", username];
        
        [twitter getHomeTimelineSinceID:nil
                                  count:20
                           successBlock:^(NSArray *statuses) {
                               
                               NSLog(@"-- statuses: %@", statuses);
                               
                               self.statusLabel.text = [NSString stringWithFormat:@"@%@", username];

                               self.statuses = statuses;
                               
                               [self.tableView reloadData];
                               
                           } errorBlock:^(NSError *error) {
                               self.statusLabel.text = [error localizedDescription];
                           }];
        
    } errorBlock:^(NSError *error) {
        self.statusLabel.text = [error localizedDescription];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.statusLabel.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statuses count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STTwitterTVCellIdentifier"];
    
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"STTwitterTVCellIdentifier"] autorelease];
    }
    
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    
    NSString *text = [status valueForKey:@"text"];
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
    NSString *dateString = [status valueForKey:@"created_at"];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@ | %@", screenName, dateString];
    
    return cell;
}

@end
