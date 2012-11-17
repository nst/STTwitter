//
//  STHTTPRequest.m
//  STHTTPRequest
//
//  Created by Nicolas Seriot on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "STHTTPRequest.h"

NSUInteger const kSTHTTPRequestCancellationError = 1;

static NSMutableDictionary *sharedCredentialsStorage;

@interface STHTTPRequest ()
@property (nonatomic) NSInteger responseStatus;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *responseStringEncodingName;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSString *POSTFilePath;
@property (nonatomic, retain) NSData *POSTFileData;
@property (nonatomic, retain) NSString *POSTFileMimeType;
@property (nonatomic, retain) NSString *POSTFileName;
@property (nonatomic, retain) NSString *POSTFileParameter;
@end

@interface NSData (Base64)
- (NSString *)base64Encoding; // private API
@end

@implementation STHTTPRequest

@synthesize credential=_credential;

#pragma mark Initializers

+ (STHTTPRequest *)requestWithURL:(NSURL *)url {
    if(url == nil) return nil;
    return [[[self alloc] initWithURL:url] autorelease];
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
        _addCredentialsToURL = YES;
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
    
    [_connection release];
    [_responseStringEncodingName release];
    [_requestHeaders release];
    [_url release];
    [_responseData release];
    [_responseHeaders release];
    [_responseString release];
    [_credential release];
    [_proxyCredential release];
    [_POSTDictionary release];
    [_POSTData release];
    [_POSTFilePath release];
    [_POSTFileData release];
    [_POSTFileMimeType release];
    [_POSTFileName release];
    [_POSTFileParameter release];
    [_error release];
    
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

- (void)setCredential:(NSURLCredential *)c {
#if DEBUG
    NSAssert(_url, @"missing url to set credential");
#endif
    [[[self class] sharedCredentialsStorage] setObject:c forKey:[_url host]];
}

- (NSURLCredential *)credential {
    return [[[self class] sharedCredentialsStorage] valueForKey:[_url host]];
}

- (void)setUsername:(NSString *)username password:(NSString *)password {
    NSURLCredential *c = [NSURLCredential credentialWithUser:username
                                                    password:password
                                                 persistence:NSURLCredentialPersistenceNone];
    
    [self setCredential:c];
}

- (void)setProxyUsername:(NSString *)username password:(NSString *)password {
    NSURLCredential *c = [NSURLCredential credentialWithUser:username
                                                    password:password
                                                 persistence:NSURLCredentialPersistenceNone];
    
    [self setProxyCredential:c];
}

- (NSString *)username {
    return [[self credential] user];
}

- (NSString *)password {
    return [[self credential] password];
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

- (NSURL *)urlWithCredentials {
    
    NSURLCredential *credentialForHost = [self credential];
    
    if(credentialForHost == nil) return _url; // no credentials to add
    
    NSString *scheme = [_url scheme];
    NSString *host = [_url host];
    
    BOOL hostAlreadyContainsCredentials = [host rangeOfString:@"@"].location != NSNotFound;
    if(hostAlreadyContainsCredentials) return _url;
    
    NSMutableString *resourceSpecifier = [[[_url resourceSpecifier] mutableCopy] autorelease];
    
    if([resourceSpecifier hasPrefix:@"//"] == NO) return nil;
    
    NSString *userPassword = [NSString stringWithFormat:@"%@:%@@", credentialForHost.user, credentialForHost.password];
    
    [resourceSpecifier insertString:userPassword atIndex:2];
    
    NSString *urlString = [NSString stringWithFormat:@"%@:%@", scheme, resourceSpecifier];
    
    return [NSURL URLWithString:urlString];
}

- (NSURLRequest *)requestByAddingCredentialsToURL:(BOOL)useCredentialsInURL sendBasicAuthenticationHeaders:(BOOL)sendBasicAuthenticationHeaders {
    
    NSURL *theURL = useCredentialsInURL ? [self urlWithCredentials] : _url;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
    
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
    
    if(_POSTFileParameter && (_POSTFilePath || _POSTFileData)) {
        
        if(_POSTDictionary == nil) self.POSTDictionary = @{};
        
        NSData *fileData = nil;
        NSString *mimeType = nil;
        NSString *fileName = nil;
        
        if (_POSTFilePath) {
            NSError *readingError = nil;
            fileData = [NSData dataWithContentsOfFile:_POSTFilePath options:0 error:&readingError];
            if(fileData == nil ) {
                NSLog(@"-- %@", [readingError localizedDescription]);
                return nil;
            }
            
            fileName = [_POSTFilePath lastPathComponent];
        } else {
            fileData = _POSTFileData;
            if (_POSTFileName) {
                fileName = _POSTFileName;
            }
        }
        
        mimeType = _POSTFileMimeType ? _POSTFileMimeType : @"application/octet-stream";
        
        NSString *boundary = @"----------kStHtTpReQuEsTbOuNdArY";
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *fileNameContentDisposition = fileName ? [NSString stringWithFormat:@"filename=\"%@\"", fileName] : @"";
        NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; %@\r\n", _POSTFileParameter, fileNameContentDisposition];
        
        [body appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:fileData];
        
        [_POSTDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[obj description] dataUsingEncoding:NSUTF8StringEncoding]];
        }];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
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
        
        for(NSString *k in _POSTDictionary) {
            NSString *kv = [NSString stringWithFormat:@"%@=%@", k, [_POSTDictionary objectForKey:k]];
            [ma addObject:kv];
        }
        
        // we sort POST parameters in order to get deterministric requests, hence unit testable
        [ma sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        NSString *s = [ma componentsJoinedByString:@"&"];
        
        NSData *data = [s dataUsingEncoding:_postDataEncoding allowLossyConversion:YES];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%ul", [data length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:data];
    } else if (_POSTData != nil) {
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%ul", [_POSTData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:_POSTData];
    }
    
    [_requestHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    
    NSURLCredential *credentialForHost = [self credential];
    
    if(sendBasicAuthenticationHeaders && credentialForHost) {
        NSString *authString = [NSString stringWithFormat:@"%@:%@", credentialForHost.user, credentialForHost.password];
        NSData *authData = [authString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
        [request addValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    return request;
}

- (NSURLRequest *)request {
    return [self requestByAddingCredentialsToURL:NO sendBasicAuthenticationHeaders:YES];
}

- (NSURLRequest *)requestByAddingCredentialsToURL {
    return [self requestByAddingCredentialsToURL:YES sendBasicAuthenticationHeaders:YES];
}

#pragma mark Upload

- (void)setFileToUpload:(NSString *)path parameterName:(NSString *)param {
    self.POSTFilePath = path;
    self.POSTFileParameter = param;
}

- (void)setDataToUpload:(NSData *)data parameterName:(NSString *)param {
    self.POSTFileData = data;
    self.POSTFileParameter = param;
}

- (void)setDataToUpload:(NSData *)data parameterName:(NSString *)param mimeType:(NSString *)mimeType fileName:(NSString *)fileName
{
    self.POSTFileData = data;
    self.POSTFileParameter = param;
    self.POSTFileMimeType = mimeType;
    self.POSTFileName = fileName;
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

- (void)logRequest:(NSURLRequest *)request {
    
    NSLog(@"--------------------------------------");
    
    NSString *method = _POSTDictionary ? @"POST" : @"GET";
    
    NSLog(@"%@ %@", method, [request URL]);
    
    NSDictionary *headers = [self requestHeaders];
    
    if([headers count]) NSLog(@"HEADERS");
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"\t %@ = %@", key, obj);
    }];
    
    NSArray *cookies = [self requestCookies];
    
    if([cookies count]) NSLog(@"COOKIES");
    
    for(NSHTTPCookie *cookie in cookies) {
        NSLog(@"\t %@ = %@", [cookie name], [cookie value]);
    }
    
    NSDictionary *d = [self POSTDictionary];
    
    if([d count]) NSLog(@"POST DATA");
    
    [d enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"\t %@ = %@", key, obj);
    }];
    
    if (_POSTFileParameter && _POSTFilePath) {
        NSLog(@"UPLOAD FILE");
        NSLog(@"\t %@ = %@", _POSTFileParameter, _POSTFilePath);
    } else if (_POSTFileParameter && _POSTFileData) {
        NSLog(@"UPLOAD DATA");
        NSLog(@"\t %@ = [%ul bytes]", _POSTFileParameter, [_POSTFileData length]);
    } else if (_POSTData) {
        NSLog(@"UPLOAD DATA");
        NSLog(@"\t [%ul bytes]", [_POSTData length]);
    }
    
    NSLog(@"--------------------------------------");
}

#pragma mark Start Request

- (void)startAsynchronous {
    
    NSURLRequest *request = [self requestByAddingCredentialsToURL:_addCredentialsToURL sendBasicAuthenticationHeaders:YES];
    
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
    
    NSURLRequest *request = [self requestByAddingCredentialsToURL:_addCredentialsToURL sendBasicAuthenticationHeaders:YES];
    
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

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge previousFailureCount] <= 2) {
        
        NSURLCredential *currentCredential = nil;
        
        if ([[challenge protectionSpace] isProxy] && _proxyCredential != nil) {
            currentCredential = _proxyCredential;
        } else {
            currentCredential = [self credential];
        }
        
        if (currentCredential) {
            [[challenge sender] useCredential:currentCredential forAuthenticationChallenge:challenge];
            return;
        }
    }
    
    [connection cancel];
    
    [[challenge sender] cancelAuthenticationChallenge:challenge];
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
    }
    
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData {
    [_responseData appendData:theData];
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
