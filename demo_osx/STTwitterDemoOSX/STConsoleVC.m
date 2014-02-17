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

- (NSString *)curlDescriptionWithMethod:(NSString *)method endpoint:(NSString *)endPoint baseURLString:(NSString *)baseURLString parameters:(NSDictionary *)parameters requestHeaders:(NSDictionary *)requestHeaders {
    /*
     $ curl -i -H "Authorization: OAuth oauth_consumer_key="7YBPrscvh0RIThrWYVeGg", \
                                        oauth_nonce="DA5E6B1E-E98D-4AFB-9AAB-18A463F2", \
                                        oauth_signature_method="HMAC-SHA1", \
                                        oauth_timestamp="1381908706", \
                                        oauth_version="1.0", \
                                        oauth_token="1294332967-UsaIUBcsC4JcHv9tIYxk5EktsVisAtCLNVGKghP", \
                                        oauth_signature="gnmc02ohamTvTmkTppz%2FbH8OjAs%3D"" \
                                        "https://api.twitter.com/1.1/statuses/home_timeline.json?count=10"
     */

    if([baseURLString hasSuffix:@"/"]) baseURLString = [baseURLString substringToIndex:[baseURLString length]-1];
    if([endPoint hasPrefix:@"/"]) endPoint = [endPoint substringFromIndex:1];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@", baseURLString, endPoint];
    
    NSMutableArray *parametersArray = [NSMutableArray array];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *s = [NSString stringWithFormat:@"%@=%@", key, obj];
        [parametersArray addObject:s];
    }];
    
    NSString *POSTParameters = @"";

    NSMutableArray *ma = [NSMutableArray array];
    NSString *parameterString = [parametersArray componentsJoinedByString:@"&"];

    if([parameters count]) {
        if([method isEqualToString:@"POST"]) {
            [ma addObject:[NSString stringWithFormat:@"-d \"%@\"", parameterString]];
            POSTParameters = [ma componentsJoinedByString:@" "];
        } else {
            [urlString appendFormat:@"?%@", parameterString];
        }
    }
    
    return [NSString stringWithFormat:@"curl -i -H \"Authorization: %@\" \"%@\" %@", [requestHeaders valueForKey:@"Authorization"], urlString, POSTParameters];
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
    
    self.curlTextViewAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    self.responseHeadersTextViewAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    self.bodyTextViewAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    self.rootNode = nil;
    [_outlineView reloadData];
    
    [_twitter fetchResource:_genericAPIEndpoint
                 HTTPMethod:_genericHTTPMethod
              baseURLString:_genericBaseURLString
                 parameters:parameters
        uploadProgressBlock:nil
      downloadProgressBlock:nil
               successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                   
                   NSString *curlDescription = [self curlDescriptionWithMethod:_genericHTTPMethod endpoint:_genericAPIEndpoint baseURLString:_genericBaseURLString parameters:parameters requestHeaders:requestHeaders];
                   
                   self.curlTextViewAttributedString = [[NSAttributedString alloc] initWithString:curlDescription attributes:attributes];
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
                   
               } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                   NSString *s = @"error";
                   if(error) {
                       s = [error localizedDescription];
                   }
                   
                   NSString *requestHeadersDescription = requestHeaders ? [requestHeaders description] : @"";
                   NSString *responseHeadersDescription = responseHeaders ? [responseHeaders description] : @"";
                   self.curlTextViewAttributedString = [[NSAttributedString alloc] initWithString:requestHeadersDescription attributes:attributes];
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
