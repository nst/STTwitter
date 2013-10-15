//
//  STRequestsVC.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/22/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STConsoleVC.h"
#import "JSONSyntaxHighlight.h"
#import "BAVPlistNode.h"

@interface STConsoleVC ()
@property (nonatomic, strong) BAVPlistNode *rootNode;
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
}

- (IBAction)sendRequestAction:(id)sender {
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
    
    self.requestHeadersTextViewAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    self.responseHeadersTextViewAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    self.bodyTextViewAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    self.rootNode = nil;
    [_outlineView reloadData];

    [_twitter fetchResource:_genericAPIEndpoint HTTPMethod:_genericHTTPMethod baseURLString:_genericBaseURLString parameters:parameters progressBlock:nil successBlock:^(NSString *requestID, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {

        self.requestHeadersTextViewAttributedString = [[NSAttributedString alloc] initWithString:[requestHeaders description] attributes:attributes];
        self.responseHeadersTextViewAttributedString = [[NSAttributedString alloc] initWithString:[responseHeaders description] attributes:attributes];
        
        JSONSyntaxHighlight *jsh = [[JSONSyntaxHighlight alloc] initWithJSON:response];
        
        NSMutableDictionary *keyAttributes = [jsh.keyAttributes mutableCopy];
        [keyAttributes addEntriesFromDictionary:attributes];

        NSMutableDictionary *stringAttributes = [jsh.stringAttributes mutableCopy];
        [stringAttributes addEntriesFromDictionary:attributes];

        NSMutableDictionary *nonStringAttributes = [jsh.nonStringAttributes mutableCopy];
        [nonStringAttributes addEntriesFromDictionary:attributes];

        jsh.keyAttributes = keyAttributes;
        jsh.stringAttributes = stringAttributes;
        jsh.nonStringAttributes = nonStringAttributes;
        
        self.bodyTextViewAttributedString = [jsh highlightJSONWithPrettyPrint:YES];
        
        self.rootNode = [BAVPlistNode plistNodeFromObject:response key:@"Root"];
        
        [_outlineView reloadData];
        
    } errorBlock:^(NSString *requestID, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
        NSString *s = @"error";
        if(error) {
            s = [error localizedDescription];
        }
        
        NSString *requestHeadersDescription = requestHeaders ? [requestHeaders description] : @"";
        NSString *responseHeadersDescription = responseHeaders ? [responseHeaders description] : @"";
        self.requestHeadersTextViewAttributedString = [[NSAttributedString alloc] initWithString:requestHeadersDescription attributes:attributes];
        self.responseHeadersTextViewAttributedString = [[NSAttributedString alloc] initWithString:responseHeadersDescription attributes:attributes];
        
        self.bodyTextViewAttributedString = [[NSAttributedString alloc] initWithString:s attributes:attributes];
        
        self.rootNode = nil;
        [_outlineView reloadData];
    }];
}

#pragma mark - NSOutlineViewDataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(BAVPlistNode *)item
{
    if (item == nil)
        return self.rootNode;
    
    return item.children[index];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(BAVPlistNode *)item
{
    if (item == nil)
        return 1;
    
    return item.children.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(BAVPlistNode *)item
{
    return item.collection;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(BAVPlistNode *)item
{
    NSString *columnId = tableColumn.identifier;
    
    if ([columnId isEqualToString:@"key"])
        return item.key;
    else if ([columnId isEqualToString:@"type"])
        return item.type;
    else if ([columnId isEqualToString:@"value"])
        return item.value;
    
    return nil;
}

@end
