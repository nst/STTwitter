//
//  STHTTPRequest.m
//  STHTTPRequest
//
//  Created by Nicolas Seriot on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#if __has_feature(objc_arc)
// see http://www.codeography.com/2011/10/10/making-arc-and-non-arc-play-nice.html
#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import "STHTTPRequest.h"

//#define DEBUG 1

NSUInteger const kSTHTTPRequestCancellationError = 1;
NSUInteger const kSTHTTPRequestDefaultTimeout = 30;

static NSMutableDictionary *sharedCredentialsStorage = nil;

/**/

@interface STHTTPRequestFileUpload : NSObject
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *parameterName;
@property (nonatomic, retain) NSString *mimeType;

+ (instancetype)fileUploadWithPath:(NSString *)path parameterName:(NSString *)parameterName mimeType:(NSString *)mimeType;
+ (instancetype)fileUploadWithPath:(NSString *)path parameterName:(NSString *)parameterName;
@end

@interface STHTTPRequestDataUpload : NSObject
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSString *parameterName;
@property (nonatomic, retain) NSString *mimeType; // can be nil
@property (nonatomic, retain) NSString *fileName; // can be nil
+ (instancetype)dataUploadWithData:(NSData *)data parameterName:(NSString *)parameterName mimeType:(NSString *)mimeType fileName:(NSString *)fileName;
@end

/**/

@interface STHTTPRequest ()
@property (nonatomic) NSInteger responseStatus;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *responseStringEncodingName;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic) NSInteger responseExpectedContentLength; // set by connection:didReceiveResponse: delegate method; web server must send the Content-Length header for accurate value
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSMutableArray *filesToUpload; // STHTTPRequestFileUpload instances
@property (nonatomic, retain) NSMutableArray *dataToUpload; // STHTTPRequestDataUpload instances
@end

@interface NSData (Base64)
- (NSString *)base64Encoding; // private API
@end

@implementation STHTTPRequest

#pragma mark Initializers

+ (STHTTPRequest *)requestWithURL:(NSURL *)url {
    if(url == nil) return nil;
    return [[(STHTTPRequest *)[self alloc] initWithURL:url] autorelease];
}

+ (STHTTPRequest *)requestWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    return [self requestWithURL:url];
}

- (STHTTPRequest *)initWithURL:(NSURL *)theURL {
    
    if (self = [super init]) {
        _url = [theURL retain];
        _responseData = [[NSMutableData alloc] init];
        _requestHeaders = [[NSMutableDictionary dictionary] retain];
        _postDataEncoding = NSUTF8StringEncoding;
        _encodePOSTDictionary = YES;
        _addCredentialsToURL = NO;
        _timeoutSeconds = kSTHTTPRequestDefaultTimeout;
        _filesToUpload = [[NSMutableArray alloc] init];
        _dataToUpload = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+ (void)clearSession {
    [self deleteAllCookies];
    [self deleteAllCredentials];
}

- (void)dealloc {
    if(_completionBlock) [_completionBlock release];
    if(_errorBlock) [_errorBlock release];
    if(_uploadProgressBlock) [_uploadProgressBlock release];
    if(_downloadProgressBlock) [_downloadProgressBlock release];
    
    [_connection release];
    [_responseStringEncodingName release];
    [_requestHeaders release];
    [_url release];
    [_responseData release];
    [_responseHeaders release];
    [_responseString release];
    [_POSTDictionary release];
    [_error release];
    [_filesToUpload release];
    [_dataToUpload release];
    
    [super dealloc];
}

#pragma mark Credentials

+ (NSMutableDictionary *)sharedCredentialsStorage {
    if(sharedCredentialsStorage == nil) {
        sharedCredentialsStorage = [[NSMutableDictionary dictionary] retain];
    }
    return sharedCredentialsStorage;
}

+ (NSURLCredential *)sessionAuthenticationCredentialsForURL:(NSURL *)requestURL {
    return [[[self class] sharedCredentialsStorage] valueForKey:[requestURL host]];
}

+ (void)deleteAllCredentials {
    [sharedCredentialsStorage autorelease];
    sharedCredentialsStorage = [[NSMutableDictionary dictionary] retain];
}

- (void)setCredentialForCurrentHost:(NSURLCredential *)c {
#if DEBUG
    NSAssert(_url, @"missing url to set credential");
#endif
    [[[self class] sharedCredentialsStorage] setObject:c forKey:[_url host]];
}

- (NSURLCredential *)credentialForCurrentHost {
    return [[[self class] sharedCredentialsStorage] valueForKey:[_url host]];
}

- (void)setUsername:(NSString *)username password:(NSString *)password {
    NSURLCredential *c = [NSURLCredential credentialWithUser:username
                                                    password:password
                                                 persistence:NSURLCredentialPersistenceNone];
    
    [self setCredentialForCurrentHost:c];
}

- (NSString *)username {
    return [[self credentialForCurrentHost] user];
}

- (NSString *)password {
    return [[self credentialForCurrentHost] password];
}

#pragma mark Cookies

+ (NSArray *)sessionCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    return [cookieStorage cookies];
}

+ (void)deleteSessionCookies {
    for(NSHTTPCookie *cookie in [self sessionCookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

+ (void)deleteAllCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
}

+ (void)addCookie:(NSHTTPCookie *)cookie forURL:(NSURL *)url {
    NSArray *cookies = [NSArray arrayWithObject:cookie];
	
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];
}

+ (void)addCookieWithName:(NSString *)name value:(NSString *)value url:(NSURL *)url {
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             name, NSHTTPCookieName,
                                             value, NSHTTPCookieValue,
                                             [url host], NSHTTPCookieDomain,
                                             [url host], NSHTTPCookieOriginURL,
                                             @"FALSE", NSHTTPCookieDiscard,
                                             @"/", NSHTTPCookiePath,
                                             @"0", NSHTTPCookieVersion,
                                             [[NSDate date] dateByAddingTimeInterval:3600 * 24 * 30], NSHTTPCookieExpires,
                                             nil];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    
    [[self class] addCookie:cookie forURL:url];
}

- (NSArray *)requestCookies {
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[_url absoluteURL]];
}

- (void)addCookie:(NSHTTPCookie *)cookie {
    [[self class] addCookie:cookie forURL:_url];
}

- (void)addCookieWithName:(NSString *)name value:(NSString *)value {
    [[self class] addCookieWithName:name value:value url:_url];
}

#pragma mark Headers

- (void)setHeaderWithName:(NSString *)name value:(NSString *)value {
    if(name == nil || value == nil) return;
    [[self requestHeaders] setObject:value forKey:name];
}

- (void)removeHeaderWithName:(NSString *)name {
    if(name == nil) return;
    [[self requestHeaders] removeObjectForKey:name];
}

+ (NSURL *)urlByAddingCredentials:(NSURLCredential *)credentials toURL:(NSURL *)url {
    
    if(credentials == nil) return nil; // no credentials to add
    
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    
    BOOL hostAlreadyContainsCredentials = [host rangeOfString:@"@"].location != NSNotFound;
    if(hostAlreadyContainsCredentials) return url;
    
    NSMutableString *resourceSpecifier = [[[url resourceSpecifier] mutableCopy] autorelease];
    
    if([resourceSpecifier hasPrefix:@"//"] == NO) return nil;
    
    NSString *userPassword = [NSString stringWithFormat:@"%@:%@@", credentials.user, credentials.password];
    
    [resourceSpecifier insertString:userPassword atIndex:2];
    
    NSString *urlString = [NSString stringWithFormat:@"%@:%@", scheme, resourceSpecifier];
    
    return [NSURL URLWithString:urlString];
}

// {k2:v2, k1:v1} -> [{k1:v1}, {k2:v2}]
+ (NSArray *)dictionariesSortedByKey:(NSDictionary *)dictionary {
    NSMutableArray *sortedDictionaries = [NSMutableArray arrayWithCapacity:[dictionary count]];
    NSArray *sortedKeys = [dictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    for(NSString *key in sortedKeys) {
        NSDictionary *d = @{ key : dictionary[key] };
        [sortedDictionaries addObject:d];
    }
    return sortedDictionaries;
}

+ (NSData *)multipartContentWithBoundary:(NSString *)boundary data:(NSData *)someData fileName:(NSString *)fileName parameterName:(NSString *)parameterName mimeType:(NSString *)aMimeType {
    
    NSString *mimeType = aMimeType ? aMimeType : @"application/octet-stream";
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *fileNameContentDisposition = fileName ? [NSString stringWithFormat:@"filename=\"%@\"", fileName] : @"";
    NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; %@\r\n", parameterName, fileNameContentDisposition];
    
    [data appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:someData];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [data autorelease];
}

- (NSURLRequest *)requestByAddingCredentialsToURL:(BOOL)useCredentialsInURL {
    
    NSURL *theURL = nil;
    
    if(useCredentialsInURL) {
        NSURLCredential *credential = [self credentialForCurrentHost];
        if(credential == nil) return nil;
        theURL = [[self class] urlByAddingCredentials:credential toURL:_url];
        if(theURL == nil) return nil;
    } else {
        theURL = _url;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
    
    request.timeoutInterval = self.timeoutSeconds;
    
    // escape POST dictionary keys and values if needed
    if(_encodePOSTDictionary) {
        NSMutableDictionary *escapedPOSTDictionary = _POSTDictionary ? [NSMutableDictionary dictionary] : nil;
        [_POSTDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *k = [key st_stringByAddingRFC3986PercentEscapesUsingEncoding:_postDataEncoding];
            NSString *v = [[obj description] st_stringByAddingRFC3986PercentEscapesUsingEncoding:_postDataEncoding];
            [escapedPOSTDictionary setValue:v forKey:k];
        }];
        self.POSTDictionary = escapedPOSTDictionary;
    }
    
    // sort POST parameters in order to get deterministic, unit testable requests
    NSArray *sortedPOSTDictionaries = [[self class] dictionariesSortedByKey:_POSTDictionary];
    
    if([self.filesToUpload count] > 0 || [self.dataToUpload count] > 0) {
        
        NSString *boundary = @"----------kStHtTpReQuEsTbOuNdArY";
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        /**/
        
        for(STHTTPRequestFileUpload *fileToUpload in self.filesToUpload) {
            
            NSData *data = [NSData dataWithContentsOfFile:fileToUpload.path];
            if(data == nil) continue;
            NSString *fileName = [fileToUpload.path lastPathComponent];
            
            NSData *multipartData = [[self class] multipartContentWithBoundary:boundary
                                                                          data:data
                                                                      fileName:fileName
                                                                 parameterName:fileToUpload.parameterName
                                                                      mimeType:fileToUpload.mimeType];
            [body appendData:multipartData];
        }
        
        /**/
        
        for(STHTTPRequestDataUpload *dataToUpload in self.dataToUpload) {
            NSData *multipartData = [[self class] multipartContentWithBoundary:boundary
                                                                          data:dataToUpload.data
                                                                      fileName:dataToUpload.fileName
                                                                 parameterName:dataToUpload.parameterName
                                                                      mimeType:dataToUpload.mimeType];
            
            [body appendData:multipartData];
        }
        
        /**/
        
        [sortedPOSTDictionaries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *d = (NSDictionary *)obj;
            NSString *key = [[d allKeys] lastObject];
            NSObject *value = [[d allValues] lastObject];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[value description] dataUsingEncoding:NSUTF8StringEncoding]];
        }];
        
        /**/
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%u", (unsigned int)[body length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:body];
        
    } else if(_POSTDictionary != nil) { // may be empty (POST request without body)
        
        if(_encodePOSTDictionary) {
            
            CFStringEncoding cfStringEncoding = CFStringConvertNSStringEncodingToEncoding(_postDataEncoding);
            NSString *encodingName = (NSString *)CFStringConvertEncodingToIANACharSetName(cfStringEncoding);
            
            if(encodingName) {
                NSString *contentTypeValue = [NSString stringWithFormat:@"application/x-www-form-urlencoded ; charset=%@", encodingName];
                [self setHeaderWithName:@"Content-Type" value:contentTypeValue];
            }
        }
        
        NSMutableArray *ma = [NSMutableArray arrayWithCapacity:[_POSTDictionary count]];
        
        [sortedPOSTDictionaries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *d = (NSDictionary *)obj;
            NSString *key = [[d allKeys] lastObject];
            NSObject *value = [[d allValues] lastObject];
            
            NSString *kv = [NSString stringWithFormat:@"%@=%@", key, value];
            [ma addObject:kv];
        }];
        
        NSString *s = [ma componentsJoinedByString:@"&"];
        
        NSData *data = [s dataUsingEncoding:_postDataEncoding allowLossyConversion:YES];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%u", (unsigned int)[data length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:data];
    }
    
    [_requestHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    
    NSURLCredential *credentialForHost = [self credentialForCurrentHost];
    
    if(credentialForHost) {
        NSString *authString = [NSString stringWithFormat:@"%@:%@", credentialForHost.user, credentialForHost.password];
        NSData *authData = [authString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
        [request addValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    return request;
}

- (NSURLRequest *)request {
    return [self requestByAddingCredentialsToURL:NO];
}

- (NSURLRequest *)requestByAddingCredentialsToURL {
    return [self requestByAddingCredentialsToURL:YES];
}

#pragma mark Upload

- (void)addFileToUpload:(NSString *)path parameterName:(NSString *)parameterName {
    
    STHTTPRequestFileUpload *fu = [STHTTPRequestFileUpload fileUploadWithPath:path parameterName:parameterName];
    [self.filesToUpload addObject:fu];
}

- (void)addDataToUpload:(NSData *)data parameterName:(NSString *)param {
    STHTTPRequestDataUpload *du = [STHTTPRequestDataUpload dataUploadWithData:data parameterName:param mimeType:nil fileName:nil];
    [self.dataToUpload addObject:du];
}

- (void)addDataToUpload:(NSData *)data parameterName:(NSString *)param mimeType:(NSString *)mimeType fileName:(NSString *)fileName {
    STHTTPRequestDataUpload *du = [STHTTPRequestDataUpload dataUploadWithData:data parameterName:param mimeType:mimeType fileName:fileName];
    [self.dataToUpload addObject:du];
}

#pragma mark Response

- (NSString *)stringWithData:(NSData *)data encodingName:(NSString *)encodingName {
    if(data == nil) return nil;
    
    if(_forcedResponseEncoding > 0) {
        return [[[NSString alloc] initWithData:data encoding:_forcedResponseEncoding] autorelease];
    }
    
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    /* try to use encoding declared in HTTP response headers */
    
    if(encodingName != nil) {
        
        encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName));
        
        if(encoding == kCFStringEncodingInvalidId) {
            encoding = NSUTF8StringEncoding; // by default
        }
    }
    
    return [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
}

#if DEBUG
- (NSString *)curlDescription {
    
    NSMutableArray *ma = [NSMutableArray array];
    [ma addObject:@"$ curl -i"];
    
    // -u usernane:password
    
    NSURLCredential *credential = [[self class] sessionAuthenticationCredentialsForURL:[self url]];
    if(credential) {
        NSString *s = [NSString stringWithFormat:@"-u \"%@:%@\"", credential.user, credential.password];
        [ma addObject:s];
    }
    
    // -d "k1=v1&k2=v2"                                             // POST, url encoded params
    
    if(_POSTDictionary) {
        NSMutableArray *postParameters = [NSMutableArray array];
        [_POSTDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *s = [NSString stringWithFormat:@"%@=%@", key, obj];
            [postParameters addObject:s];
        }];
        NSString *ss = [postParameters componentsJoinedByString:@"&"];
        [ma addObject:[NSString stringWithFormat:@"-d \"%@\"", ss]];
    }
    
    // -F "coolfiles=@fil1.gif;type=image/gif,fil2.txt,fil3.html"   // file upload
    
    for(STHTTPRequestFileUpload *f in _filesToUpload) {
        NSString *s = [NSString stringWithFormat:@"%@=@%@", f.parameterName, f.path];
        [ma addObject:[NSString stringWithFormat:@"-F \"%@\"", s]];
    }
    
    // -b "name=Daniel;age=35"                                      // cookies
    
    NSArray *cookies = [self requestCookies];
    
    NSMutableArray *cookiesStrings = [NSMutableArray array];
    for(NSHTTPCookie *cookie in cookies) {
        NSString *s = [NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]];
        [cookiesStrings addObject:s];
    }
    
    if([cookiesStrings count] > 0) {
        [ma addObject:[NSString stringWithFormat:@"-b \"%@\"", [cookiesStrings componentsJoinedByString:@";"]]];
    }
    
    // -H "X-you-and-me: yes"                                       // extra headers
    
    NSMutableDictionary *headers = [[[self requestHeaders] mutableCopy] autorelease];
    
    [headers addEntriesFromDictionary:[self.request allHTTPHeaderFields]];
    
    NSMutableArray *headersStrings = [NSMutableArray array];
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *s = [NSString stringWithFormat:@"-H \"%@: %@\"", key, obj];
        [headersStrings addObject:s];
    }];
    
    if([headersStrings count] > 0) {
        [ma addObject:[headersStrings componentsJoinedByString:@" \\\n"]];
    }
    
    // url
    
    [ma addObject:[NSString stringWithFormat:@"\"%@\"", _url]];
    
    return [ma componentsJoinedByString:@" \\\n"];
}

- (void)logRequest:(NSURLRequest *)request {
    
    NSLog(@"--------------------------------------");
    
    NSString *method = (self.POSTDictionary || [self.filesToUpload count] || [self.dataToUpload count]) ? @"POST" : @"GET";
    
    NSLog(@"%@ %@", method, [request URL]);
    
    NSMutableDictionary *headers = [[[self requestHeaders] mutableCopy] autorelease];
    
    [headers addEntriesFromDictionary:[request allHTTPHeaderFields]];
    
    if([headers count]) NSLog(@"HEADERS");
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"\t %@ = %@", key, obj);
    }];
    
    NSArray *cookies = [self requestCookies];
    
    if([cookies count]) NSLog(@"COOKIES");
    
    for(NSHTTPCookie *cookie in cookies) {
        NSLog(@"\t %@ = %@", [cookie name], [cookie value]);
    }
    
    NSArray *kvDictionaries = [[self class] dictionariesSortedByKey:_POSTDictionary];
    
    if([kvDictionaries count]) NSLog(@"POST DATA");
    
    for(NSDictionary *kv in kvDictionaries) {
        NSString *k = [[kv allKeys] lastObject];
        NSString *v = [[kv allValues] lastObject];
        NSLog(@"\t %@ = %@", k, v);
    }
    
    for(STHTTPRequestFileUpload *f in self.filesToUpload) {
        NSLog(@"UPLOAD FILE");
        NSLog(@"\t %@ = %@", f.parameterName, f.path);
    }
    
    for(STHTTPRequestDataUpload *d in self.dataToUpload) {
        NSLog(@"UPLOAD DATA");
        NSLog(@"\t %@ = [%u bytes]", d.parameterName, (unsigned int)[d.data length]);
    }
    
    NSLog(@"--");
    NSLog(@"%@", [self curlDescription]);
    NSLog(@"--------------------------------------");
}
#endif

#pragma mark Start Request

- (void)startAsynchronous {
    
    NSURLRequest *request = [self requestByAddingCredentialsToURL:_addCredentialsToURL];
    
#if DEBUG
    [self logRequest:request];
#endif
    
    // NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    // http://www.pixeldock.com/blog/how-to-avoid-blocked-downloads-during-scrolling/
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_connection start];
    
    if(_connection == nil) {
        NSString *s = @"can't create connection";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:s forKey:NSLocalizedDescriptionKey];
        self.error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:userInfo];
        _errorBlock(_error);
    }
}

- (NSString *)startSynchronousWithError:(NSError **)e {
    
    self.responseHeaders = nil;
    self.responseStatus = 0;
    
    NSURLRequest *request = [self requestByAddingCredentialsToURL:_addCredentialsToURL];
    
    NSURLResponse *urlResponse = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:e];
    if(data == nil) return nil;
    
    self.responseData = [NSMutableData dataWithData:data];
    
    if([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
        
        self.responseHeaders = [httpResponse allHeaderFields];
        self.responseStatus = [httpResponse statusCode];
        self.responseStringEncodingName = [httpResponse textEncodingName];
    }
    
    self.responseString = [self stringWithData:_responseData encodingName:_responseStringEncodingName];
    
    if(_responseStatus >= 400) {
        if(e) *e = [NSError errorWithDomain:NSStringFromClass([self class]) code:_responseStatus userInfo:nil];
    }
    
    return _responseString;
}

- (void)cancel {
    [_connection cancel];
    
    NSString *s = @"Connection was cancelled.";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:s forKey:NSLocalizedDescriptionKey];
    self.error = [NSError errorWithDomain:NSStringFromClass([self class])
                                     code:kSTHTTPRequestCancellationError
                                 userInfo:userInfo];
    _errorBlock(_error);
}

#pragma mark NSURLConnectionDelegate

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //return YES to say that we have the necessary credentials to access the requested resource
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    
    // Server Trust authentication
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *serverTrustCredential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:serverTrustCredential forAuthenticationChallenge:challenge];
        return;
    }
    
    // Digest and Basic authentication
    else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest] ||
             [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        
        if([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [self credentialForCurrentHost];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        } else {
            [[[self class] sharedCredentialsStorage] removeObjectForKey:[_url host]];
            [connection cancel];
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    }
    
    // Unhandled
    else
    {
        NSLog(@"Unhandled authentication challenge type - %@", authenticationMethod);
        [connection cancel];
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
    
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (_uploadProgressBlock) {
        _uploadProgressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
        self.responseHeaders = [r allHeaderFields];
        self.responseStatus = [r statusCode];
        self.responseStringEncodingName = [r textEncodingName];
        self.responseExpectedContentLength = [r expectedContentLength];
    }
    
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData {
    
    [_responseData appendData:theData];
    
    if (_downloadProgressBlock) {
        _downloadProgressBlock(theData, [_responseData length], self.responseExpectedContentLength);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    self.responseString = [self stringWithData:_responseData encodingName:_responseStringEncodingName];
    
    if(_responseStatus >= 400) {
        self.error = [NSError errorWithDomain:NSStringFromClass([self class]) code:_responseStatus userInfo:nil];
        _errorBlock(_error);
        return;
    }
    
    _completionBlock(_responseHeaders, [self responseString]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)e {
    self.error = e;
    _errorBlock(_error);
}

@end

/**/

@implementation NSError (STHTTPRequest)

- (BOOL)st_isAuthenticationError {
    if([[self domain] isEqualToString:NSURLErrorDomain] == NO) return NO;
    
    return ([self code] == kCFURLErrorUserCancelledAuthentication || [self code] == kCFURLErrorUserAuthenticationRequired);
}

- (BOOL)st_isCancellationError {
    if([[self domain] isEqualToString:@"STHTTPRequest"] == NO) return NO;
    
    return ([self code] == kSTHTTPRequestCancellationError);
}

@end

@implementation NSString (RFC3986)
- (NSString *)st_stringByAddingRFC3986PercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    
    NSString *s = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                      (CFStringRef)self,
                                                                      NULL,
                                                                      CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                      kCFStringEncodingUTF8);
    return [s autorelease];
}
@end

/**/

#if DEBUG
@implementation NSURLRequest (IgnoreSSLValidation)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return NO;
}

@end
#endif

/**/

@implementation STHTTPRequestFileUpload

+ (instancetype)fileUploadWithPath:(NSString *)path parameterName:(NSString *)parameterName mimeType:(NSString *)mimeType {
    STHTTPRequestFileUpload *fu = [[self alloc] init];
    fu.path = path;
    fu.parameterName = parameterName;
    fu.mimeType = mimeType;
    return [fu autorelease];
}

+ (instancetype)fileUploadWithPath:(NSString *)path parameterName:(NSString *)fileName {
    return [self fileUploadWithPath:path parameterName:fileName mimeType:@"application/octet-stream"];
}

- (void)dealloc {
    [_path release];
    [_parameterName release];
    [_mimeType release];
    [super dealloc];
}

@end

@implementation STHTTPRequestDataUpload

+ (instancetype)dataUploadWithData:(NSData *)data parameterName:(NSString *)parameterName mimeType:(NSString *)mimeType fileName:(NSString *)fileName {
    STHTTPRequestDataUpload *du = [[self alloc] init];
    du.data = data;
    du.parameterName = parameterName;
    du.mimeType = mimeType;
    du.fileName = fileName;
    return [du autorelease];
}

- (void)dealloc {
    [_data release];
    [_parameterName release];
    [_mimeType release];
    [_fileName release];
    [super dealloc];
}

@end
