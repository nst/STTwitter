//
//  STRequestsVC.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/22/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STConsoleVC.h"
#import "JSONSyntaxHighlight.h"

@interface STConsoleVC ()

@end

@implementation STConsoleVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.genericBaseURLString = @"https://api.twitter.com/1.1/";
    self.genericAPIEndpoint = @"statuses/home_timeline.json";
    
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"count", @"key", @"10", @"value", nil];
    
    self.genericRequestParameters = [ @[md] mutableCopy];
    
    [self changeHTTPMethodAction:self];
}

- (IBAction)changeHTTPMethodAction:(id)sender {
    self.genericHTTPMethod = [_genericHTTPMethodPopUpButton titleOfSelectedItem];
    NSLog(@"-- %s", __PRETTY_FUNCTION__);
    NSLog(@"-- %@", _genericHTTPMethod);
}

- (IBAction)sendRequestAction:(id)sender {
    NSLog(@"-- %s", __PRETTY_FUNCTION__);
    
    NSAssert(_genericAPIEndpoint, @"");
    NSAssert(_genericHTTPMethod, @"");
    NSAssert(_genericBaseURLString, @"");
    
    NSDictionary *attributes = @{ NSFontAttributeName : [NSFont fontWithName:@"Menlo" size:12] };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[_genericRequestParameters count]];
    
    for(NSDictionary *d in _genericRequestParameters) {
        NSString *k = d[@"key"];
        NSString *v = d[@"value"];
        [parameters setObject:v forKey:k];
    }
    
    self.genericTextViewAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    
    [_twitter fetchResource:_genericAPIEndpoint HTTPMethod:_genericHTTPMethod baseURLString:_genericBaseURLString parameters:parameters progressBlock:nil successBlock:^(NSString *requestID, NSDictionary *headers, id response) {
        
        // create the JSONSyntaxHighilight Object
        JSONSyntaxHighlight *jsh = [[JSONSyntaxHighlight alloc] initWithJSON:response];
        
        self.genericTextViewAttributedString = [jsh highlightJSONWithPrettyPrint:YES];
    } errorBlock:^(NSString *requestID, NSDictionary *headers, NSError *error) {
        NSString *s = @"error";
        if(error) {
            s = [error localizedDescription];
        }
        self.genericTextViewAttributedString = [[NSAttributedString alloc] initWithString:s attributes:attributes];
    }];
}

@end
