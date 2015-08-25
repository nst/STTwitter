//
//  STHTTPRequest.m
//  STHTTPRequest
//
//  Created by Nicolas Seriot on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#if __has_feature(objc_arc)
#else
// see http://www.codeography.com/2011/10/10/making-arc-and-non-arc-play-nice.html
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "STHTTPRequest.h"

NSUInteger const kSTHTTPRequestCancellationError = 1;
NSUInteger const kSTHTTPRequestDefaultTimeout = 30;

static NSMutableDictionary *localCredentialsStorage = nil;
static NSMutableArray *localCookiesStorage = nil;
static NSMutableDictionary *sessionCompletionHandlersForIdentifier = nil;

static BOOL globalIgnoreCache = NO;
static STHTTPRequestCookiesStorage globalCookiesStoragePolicy = STHTTPRequestCookiesStorageShared;

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
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *responseStringEncodingName;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSMutableArray *filesToUpload; // STHTTPRequestFileUpload instances
@property (nonatomic, strong) NSMutableArray *dataToUpload; // STHTTPRequestDataUpload instances
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURL *HTTPBodyFileURL; // created for NSURLSessionUploadTask, removed on completion
@end

@interface NSData (Base64)
- (NSString *)base64Encoding; // private API
@end

@implementation STHTTPRequest

#pragma mark Initializers

+ (instancetype)requestWithURL:(NSURL *)url {
    if(url == nil) return nil;
    return [(STHTTPRequest *)[self alloc] initWithURL:url];
}

+ (instancetype)requestWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    return [self requestWithURL:url];
}

+ (void)setGlobalIgnoreCache:(BOOL)ignoreCache {
    globalIgnoreCache = ignoreCache;
}

+ (void)setGlobalCookiesStoragePolicy:(STHTTPRequestCookiesStorage)cookieStoragePolicy {
    globalCookiesStoragePolicy = cookieStoragePolicy;
}

- (instancetype)initWithURL:(NSURL *)theURL {
    
    if (self = [super init]) {
        self.url = theURL;
        self.responseData = [[NSMutableData alloc] init];
        self.requestHeaders = [NSMutableDictionary dictionary];
        self.POSTDataEncoding = NSUTF8StringEncoding;
        self.encodePOSTDictionary = YES;
        self.encodeGETDictionary = YES;
        self.addCredentialsToURL = NO;
        self.timeoutSeconds = kSTHTTPRequestDefaultTimeout;
        self.filesToUpload = [NSMutableArray array];
        self.dataToUpload = [NSMutableArray array];
        self.HTTPMethod = @"GET"; // default
        self.cookieStoragePolicyForInstance = STHTTPRequestCookiesStorageUndefined; // globalCookiesStoragePolicy will be used
    }
    
    return self;
}

+ (void)clearSession {
    [[self class] deleteAllCookiesFromSharedCookieStorage];
    [[self class] deleteAllCookiesFromLocalCookieStorage];
    [[self class] deleteAllCredentials];
}

#pragma mark Credentials

+ (NSMutableDictionary *)sharedCredentialsStorage {
    if(localCredentialsStorage == nil) {
        localCredentialsStorage = [NSMutableDictionary dictionary];
    }
    return localCredentialsStorage;
}

+ (NSURLCredential *)sessionAuthenticationCredentialsForURL:(NSURL *)requestURL {
    return [[[self class] sharedCredentialsStorage] valueForKey:[requestURL host]];
}

+ (void)deleteAllCredentials {
    localCredentialsStorage = [NSMutableDictionary dictionary];
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

- (STHTTPRequestCookiesStorage)cookieStoragePolicy {
    if(_cookieStoragePolicyForInstance != STHTTPRequestCookiesStorageUndefined) {
        return _cookieStoragePolicyForInstance;
    }
    
    return globalCookiesStoragePolicy;
}

+ (NSMutableArray *)localCookiesStorage {
    if(localCookiesStorage == nil) {
        localCookiesStorage = [NSMutableArray array];
    }
    return localCookiesStorage;
}

+ (NSArray *)sessionCookiesInSharedCookiesStorage {
    NSArray *allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    NSArray *sessionCookies = [allCookies filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSHTTPCookie *cookie = (NSHTTPCookie *)evaluatedObject;
        return [cookie isSessionOnly];
    }]];
    
    return sessionCookies;
}

- (NSArray *)sessionCookies {
    
    NSArray *allCookies = nil;
    
    if([self cookieStoragePolicy] == STHTTPRequestCookiesStorageShared) {
        allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    } else if ([self cookieStoragePolicy] == STHTTPRequestCookiesStorageLocal) {
        allCookies = [[self class] localCookiesStorage];
    }
    
    NSArray *sessionCookies = [allCookies filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSHTTPCookie *cookie = (NSHTTPCookie *)evaluatedObject;
        return [cookie isSessionOnly];
    }]];
    
    return sessionCookies;
}

- (void)deleteSessionCookies {
    
    for(NSHTTPCookie *cookie in [self sessionCookies]) {
        if([self cookieStoragePolicy] == STHTTPRequestCookiesStorageShared) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        } else if ([self cookieStoragePolicy] == STHTTPRequestCookiesStorageLocal) {
            [[[self class] localCookiesStorage] removeObject:cookie];
        }
    }
}

+ (void)deleteAllCookiesFromSharedCookieStorage {
    NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedCookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [sharedCookieStorage deleteCookie:cookie];
    }
}

+ (void)deleteAllCookiesFromLocalCookieStorage {
    localCookiesStorage = nil;
}

- (void)deleteAllCookies {
    if([self cookieStoragePolicy] == STHTTPRequestCookiesStorageShared) {
        [[self class] deleteAllCookiesFromSharedCookieStorage];
    } else if ([self cookieStoragePolicy] == STHTTPRequestCookiesStorageLocal) {
        [[[self class] localCookiesStorage] removeAllObjects];
    }
}

+ (void)addCookieToSharedCookiesStorage:(NSHTTPCookie *)cookie {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
#if DEBUG
    NSHTTPCookie *readCookie = [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] lastObject];
    NSAssert(readCookie, @"cannot read any cookie after adding one");
#endif
}

- (void)addCookie:(NSHTTPCookie *)cookie {
    
    NSParameterAssert(cookie);
    if(cookie == nil) return;
    
    if([self cookieStoragePolicy] == STHTTPRequestCookiesStorageShared) {
        [[self class] addCookieToSharedCookiesStorage:cookie];
    } else if ([self cookieStoragePolicy] == STHTTPRequestCookiesStorageLocal) {
        [[[self class] localCookiesStorage] addObject:cookie];
    } // else don't store anything
}

+ (void)addCookieToSharedCookiesStorageWithName:(NSString *)name value:(NSString *)value url:(NSURL *)url {
    NSHTTPCookie *cookie = [[self class] createCookieWithName:name value:value url:url];
    
    [self addCookieToSharedCookiesStorage:cookie];
}

+ (NSHTTPCookie *)createCookieWithName:(NSString *)name value:(NSString *)value url:(NSURL *)url {
    NSParameterAssert(url);
    if(url == nil) return nil;
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             name, NSHTTPCookieName,
                                             value, NSHTTPCookieValue,
                                             url, NSHTTPCookieOriginURL,
                                             @"FALSE", NSHTTPCookieDiscard,
                                             @"/", NSHTTPCookiePath,
                                             @"0", NSHTTPCookieVersion,
                                             [[NSDate date] dateByAddingTimeInterval:3600 * 24 * 30], NSHTTPCookieExpires,
                                             nil];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    
    return cookie;
}

- (void)addCookieWithName:(NSString *)name value:(NSString *)value url:(NSURL *)url {
    NSHTTPCookie *cookie = [[self class] createCookieWithName:name value:value url:url];
    
    [self addCookie:cookie];
}

- (NSArray *)requestCookies {
    
    if([self cookieStoragePolicy] == STHTTPRequestCookiesStorageShared) {
        return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[_url absoluteURL]];
    } else if ([self cookieStoragePolicy] == STHTTPRequestCookiesStorageLocal) {
        NSArray *filteredCookies = [[[self class] localCookiesStorage] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            NSHTTPCookie *cookie = (NSHTTPCookie *)evaluatedObject;
            return [[cookie domain] isEqualToString:[self.url host]];
        }]];
        return filteredCookies;
    }
    
    return nil;
}

- (void)addCookieWithName:(NSString *)name value:(NSString *)value {
    [self addCookieWithName:name value:value url:_url];
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
    
    NSMutableString *resourceSpecifier = [[url resourceSpecifier] mutableCopy];
    
    if([resourceSpecifier hasPrefix:@"//"] == NO) return nil;
    
    NSString *userPassword = [NSString stringWithFormat:@"%@:%@@", credentials.user, credentials.password];
    
    [resourceSpecifier insertString:userPassword atIndex:2];
    
    NSString *urlString = [NSString stringWithFormat:@"%@:%@", scheme, resourceSpecifier];
    
    return [NSURL URLWithString:urlString];
}

// {k2:v2, k1:v1} -> [{k1:v1}, {k2:v2}]
+ (NSArray *)dictionariesSortedByKey:(NSDictionary *)dictionary {
    
    NSArray *keys = [dictionary allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2];
        return result;
    }];
    
    NSMutableArray *sortedDictionaries = [NSMutableArray arrayWithCapacity:[dictionary count]];
    
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
    
    return data;
}

+ (NSURL *)appendURL:(NSURL *)url withGETParameters:(NSDictionary *)parameters doApplyURLEncoding:(BOOL)doApplyURLEncoding {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:[url absoluteString]];
    
    NSString *s = [urlString st_stringByAppendingGETParameters:parameters doApplyURLEncoding:doApplyURLEncoding];
    
    return [NSURL URLWithString:s];
}

- (NSURLRequest *)prepareURLRequest {
    
    NSURL *theURL = nil;
    
    if(_addCredentialsToURL) {
        NSURLCredential *credential = [self credentialForCurrentHost];
        if(credential == nil) return nil;
        theURL = [[self class] urlByAddingCredentials:credential toURL:_url];
        if(theURL == nil) return nil;
    } else {
        theURL = _url;
    }
    
    theURL = [[self class] appendURL:theURL withGETParameters:_GETDictionary doApplyURLEncoding:_encodeGETDictionary];
    
    if([_HTTPMethod isEqualToString:@"GET"]) {
        if(_POSTDictionary || _rawPOSTData || [self.filesToUpload count] > 0 || [self.dataToUpload count] > 0) {
            self.HTTPMethod = @"POST";
        }
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
    [request setHTTPMethod:_HTTPMethod];
    
    if(globalIgnoreCache || _ignoreCache) {
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    }
    
    if(self.timeoutSeconds != 0.0) {
        request.timeoutInterval = self.timeoutSeconds;
    }
    
    if([self cookieStoragePolicy] == STHTTPRequestCookiesStorageShared || [self cookieStoragePolicy] == STHTTPRequestCookiesStorageLocal) {
        NSArray *cookies = [self sessionCookies];
        NSDictionary *d = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        [request setAllHTTPHeaderFields:d];
    }
    
    // escape POST dictionary keys and values if needed
    if(_encodePOSTDictionary) {
        NSMutableDictionary *escapedPOSTDictionary = _POSTDictionary ? [NSMutableDictionary dictionary] : nil;
        [_POSTDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *k = [key st_stringByAddingRFC3986PercentEscapesUsingEncoding:self.POSTDataEncoding];
            NSString *v = [[obj description] st_stringByAddingRFC3986PercentEscapesUsingEncoding:self.POSTDataEncoding];
            [escapedPOSTDictionary setValue:v forKey:k];
        }];
        self.POSTDictionary = escapedPOSTDictionary;
    }
    
    // sort POST parameters in order to get deterministic, unit testable requests
    NSArray *sortedPOSTDictionaries = [[self class] dictionariesSortedByKey:_POSTDictionary];
    
    NSData *bodyData = nil;
    
    if([self.filesToUpload count] > 0 || [self.dataToUpload count] > 0) {
        
        NSString *boundary = @"----------kStHtTpReQuEsTbOuNdArY";
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        /**/
        
        NSMutableData *mutableBodyData = [NSMutableData data];
        
        for(STHTTPRequestFileUpload *fileToUpload in self.filesToUpload) {
            
            NSData *data = [NSData dataWithContentsOfFile:fileToUpload.path];
            if(data == nil) continue;
            NSString *fileName = [fileToUpload.path lastPathComponent];
            
            NSData *multipartData = [[self class] multipartContentWithBoundary:boundary
                                                                          data:data
                                                                      fileName:fileName
                                                                 parameterName:fileToUpload.parameterName
                                                                      mimeType:fileToUpload.mimeType];
            [mutableBodyData appendData:multipartData];
        }
        
        /**/
        
        for(STHTTPRequestDataUpload *dataToUpload in self.dataToUpload) {
            NSData *multipartData = [[self class] multipartContentWithBoundary:boundary
                                                                          data:dataToUpload.data
                                                                      fileName:dataToUpload.fileName
                                                                 parameterName:dataToUpload.parameterName
                                                                      mimeType:dataToUpload.mimeType];
            
            [mutableBodyData appendData:multipartData];
        }
        
        /**/
        
        [sortedPOSTDictionaries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *d = (NSDictionary *)obj;
            NSString *key = [[d allKeys] lastObject];
            NSObject *value = [[d allValues] lastObject];
            
            [mutableBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableBodyData appendData:[[value description] dataUsingEncoding:NSUTF8StringEncoding]];
        }];
        
        /**/
        
        [mutableBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setValue:[NSString stringWithFormat:@"%u", (unsigned int)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
        
        bodyData = mutableBodyData;
        
    } else if (_rawPOSTData) {
        
        [request setValue:[NSString stringWithFormat:@"%u", (unsigned int)[_rawPOSTData length]] forHTTPHeaderField:@"Content-Length"];
        bodyData = _rawPOSTData;
        
    } else if (_POSTDictionary != nil) { // may be empty (POST request without body)
        
        if(_encodePOSTDictionary) {
            
            CFStringEncoding cfStringEncoding = CFStringConvertNSStringEncodingToEncoding(_POSTDataEncoding);
            NSString *encodingName = (NSString *)CFStringConvertEncodingToIANACharSetName(cfStringEncoding);
            
            if(encodingName) {
                NSString *contentTypeValue = [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", encodingName];
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
        
        bodyData = [s dataUsingEncoding:_POSTDataEncoding allowLossyConversion:YES];
        
        [request setValue:[NSString stringWithFormat:@"%u", (unsigned int)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    }
    
    if(bodyData) {
        [request setHTTPBody:bodyData];
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
    
    request.HTTPShouldHandleCookies = ([self cookieStoragePolicy] == STHTTPRequestCookiesStorageShared);
    
    return request;
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

- (NSString *)responseString {
    if(_responseString == nil) {
        self.responseString = [self stringWithData:_responseData encodingName:_responseStringEncodingName];
    }
    return _responseString;
}

- (NSString *)stringWithData:(NSData *)data encodingName:(NSString *)encodingName {
    if(data == nil) return nil;
    
    if(_forcedResponseEncoding > 0) {
        return [[NSString alloc] initWithData:data encoding:_forcedResponseEncoding];
    }
    
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    /* try to use encoding declared in HTTP response headers */
    
    if(encodingName != nil) {
        
        encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName));
        
        if(encoding == kCFStringEncodingInvalidId) {
            encoding = NSUTF8StringEncoding; // by default
        }
    }
    
    return [[NSString alloc] initWithData:data encoding:encoding];
}

#pragma mark HTTP Error Codes

+ (NSString *)descriptionForHTTPStatus:(NSUInteger)status {
    NSString *s = [NSString stringWithFormat:@"HTTP Status %@", @(status)];
    
    NSString *description = nil;
    // http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
    if(status == 400) description = @"Bad Request";
    if(status == 401) description = @"Unauthorized";
    if(status == 402) description = @"Payment Required";
    if(status == 403) description = @"Forbidden";
    if(status == 404) description = @"Not Found";
    if(status == 405) description = @"Method Not Allowed";
    if(status == 406) description = @"Not Acceptable";
    if(status == 407) description = @"Proxy Authentication Required";
    if(status == 408) description = @"Request Timeout";
    if(status == 409) description = @"Conflict";
    if(status == 410) description = @"Gone";
    if(status == 411) description = @"Length Required";
    if(status == 412) description = @"Precondition Failed";
    if(status == 413) description = @"Payload Too Large";
    if(status == 414) description = @"URI Too Long";
    if(status == 415) description = @"Unsupported Media Type";
    if(status == 416) description = @"Requested Range Not Satisfiable";
    if(status == 417) description = @"Expectation Failed";
    if(status == 422) description = @"Unprocessable Entity";
    if(status == 423) description = @"Locked";
    if(status == 424) description = @"Failed Dependency";
    if(status == 425) description = @"Unassigned";
    if(status == 426) description = @"Upgrade Required";
    if(status == 427) description = @"Unassigned";
    if(status == 428) description = @"Precondition Required";
    if(status == 429) description = @"Too Many Requests";
    if(status == 430) description = @"Unassigned";
    if(status == 431) description = @"Request Header Fields Too Large";
    if(status == 432) description = @"Unassigned";
    if(status == 500) description = @"Internal Server Error";
    if(status == 501) description = @"Not Implemented";
    if(status == 502) description = @"Bad Gateway";
    if(status == 503) description = @"Service Unavailable";
    if(status == 504) description = @"Gateway Timeout";
    if(status == 505) description = @"HTTP Version Not Supported";
    if(status == 506) description = @"Variant Also Negotiates";
    if(status == 507) description = @"Insufficient Storage";
    if(status == 508) description = @"Loop Detected";
    if(status == 509) description = @"Unassigned";
    if(status == 510) description = @"Not Extended";
    if(status == 511) description = @"Network Authentication Required";
    
    if(description) {
        s = [s stringByAppendingFormat:@": %@", description];
    }
    
    return s;
}

+ (NSDictionary *)userInfoWithErrorDescriptionForHTTPStatus:(NSUInteger)status {
    NSString *s = [self descriptionForHTTPStatus:status];
    if(s == nil) return nil;
    return @{ NSLocalizedDescriptionKey : s };
}

#pragma mark Descriptions

- (NSString *)curlDescription {
    
    NSMutableArray *ma = [NSMutableArray array];
    [ma addObject:@"\U0001F300 curl -i"];
    
    if([_HTTPMethod isEqualToString:@"GET"] == NO) { // GET is optional in curl
        NSString *s = [NSString stringWithFormat:@"-X %@", _HTTPMethod];
        [ma addObject:s];
    }
    
    // -u username:password
    
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
    
    if(_rawPOSTData) {
        // try JSON
        id jsonObject = [NSJSONSerialization JSONObjectWithData:_rawPOSTData options:NSJSONReadingMutableContainers error:nil];
        if(jsonObject) {
            NSString *jsonString = [[NSString alloc] initWithData:_rawPOSTData encoding:NSUTF8StringEncoding];
            //            [ma addObject:@"-X POST"];
            [ma addObject:[NSString stringWithFormat:@"-d \'%@\'", jsonString]];
        }
    }
    
    // -F "coolfiles=@fil1.gif;type=image/gif,fil2.txt,fil3.html"   // file upload
    
    for(STHTTPRequestFileUpload *f in _filesToUpload) {
        NSString *s = [NSString stringWithFormat:@"%@=@%@", f.parameterName, f.path];
        [ma addObject:[NSString stringWithFormat:@"-F \"%@\"", s]];
    }
    
    // -H "X-you-and-me: yes"                                       // extra headers
    
    NSMutableDictionary *headers = [[_request allHTTPHeaderFields] mutableCopy];
    //    [headers removeObjectForKey:@"Cookie"];
    
    NSMutableArray *headersStrings = [NSMutableArray array];
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *s = [NSString stringWithFormat:@"-H \"%@: %@\"", key, obj];
        [headersStrings addObject:s];
    }];
    
    if([headersStrings count] > 0) {
        [ma addObject:[headersStrings componentsJoinedByString:@" \\\n"]];
    }
    
    // url
    
    NSURL *url = [_request URL] ? [_request URL] : _url;
    [ma addObject:[NSString stringWithFormat:@"\"%@\"", url]];
    
    return [ma componentsJoinedByString:@" \\\n"];
}

- (NSString *)debugDescription {
    
    NSMutableString *ms = [NSMutableString string];
    
    NSString *method = (self.POSTDictionary || [self.filesToUpload count] || [self.dataToUpload count]) ? @"POST" : @"GET";
    
    [ms appendFormat:@"%@ %@\n", method, [_request URL]];
    
    NSMutableDictionary *headers = [[_request allHTTPHeaderFields] mutableCopy];
    
    if([headers count]) [ms appendString:@"HEADERS\n"];
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [ms appendFormat:@"\t %@ = %@\n", key, obj];
    }];
    
    NSArray *kvDictionaries = [[self class] dictionariesSortedByKey:_POSTDictionary];
    
    if([kvDictionaries count]) [ms appendString:@"POST DATA\n"];
    
    for(NSDictionary *kv in kvDictionaries) {
        NSString *k = [[kv allKeys] lastObject];
        NSString *v = [[kv allValues] lastObject];
        [ms appendFormat:@"\t %@ = %@\n", k, v];
    }
    
    for(STHTTPRequestFileUpload *f in self.filesToUpload) {
        [ms appendString:@"UPLOAD FILE\n"];
        [ms appendFormat:@"\t %@ = %@\n", f.parameterName, f.path];
    }
    
    for(STHTTPRequestDataUpload *d in self.dataToUpload) {
        [ms appendString:@"UPLOAD DATA\n"];
        [ms appendFormat:@"\t %@ = [%u bytes]\n", d.parameterName, (unsigned int)[d.data length]];
    }
    
    return ms;
}

#pragma mark Start Request

- (void)startAsynchronous {
    
    NSAssert((self.completionBlock || self.completionDataBlock), @"a completion block is mandatory");
    NSAssert(self.errorBlock, @"the error block is mandatory");
    
    NSURLRequest *request = [self prepareURLRequest];
    
    BOOL useUploadTaskInBackground = [request.HTTPMethod isEqualToString:@"POST"] && request.HTTPBody != nil;
    
    NSURLSessionConfiguration *sessionConfiguration = nil;
    
    if(useUploadTaskInBackground) {
        NSString *backgroundSessionIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:backgroundSessionIdentifier];
    } else {
        sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    sessionConfiguration.allowsCellularAccess = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:nil];
    
    if(useUploadTaskInBackground) {
        NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
        self.HTTPBodyFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        [request.HTTPBody writeToURL:_HTTPBodyFileURL atomically:YES];
        self.task = [session uploadTaskWithRequest:request fromFile:_HTTPBodyFileURL];
    } else {
        self.task = [session dataTaskWithRequest:request];
    }
    
    [_task resume];
    
    self.request = [_task currentRequest];
    
    self.requestHeaders = [[_request allHTTPHeaderFields] mutableCopy];
    
    /**/
    
    BOOL showDebugDescription = [[NSUserDefaults standardUserDefaults] boolForKey:@"STHTTPRequestShowDebugDescription"];
    BOOL showCurlDescription = [[NSUserDefaults standardUserDefaults] boolForKey:@"STHTTPRequestShowCurlDescription"];
    
    NSMutableString *logString = nil;
    
    if(showDebugDescription || showCurlDescription) {
        logString = [NSMutableString stringWithString:@"\n----------\n"];
    }
    
    if(showDebugDescription) {
        [logString appendString:[self debugDescription]];
    }
    
    if(showDebugDescription && showCurlDescription) {
        [logString appendString:@"\n"];
    }
    
    if(showCurlDescription) {
        [logString appendString:[self curlDescription]];
    }
    
    if(showDebugDescription || showCurlDescription) {
        [logString appendString:@"\n----------\n"];
    }
    
    if(logString) NSLog(@"%@", logString);
    
    /**/
    
    if(_task == nil) {
        NSString *s = @"can't create task";
        self.error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey: s}];
        
        self.errorBlock(self.error);
    }
}

// TODO: rewrite synch requests without NSURLConnection
- (NSString *)startSynchronousWithError:(NSError **)e {
    
    self.responseHeaders = nil;
    self.responseStatus = 0;
    
    NSURLRequest *request = [self prepareURLRequest];
    
    NSURLResponse *urlResponse = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:e];
    
    self.responseData = [NSMutableData dataWithData:data];
    
    if([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
        
        self.responseHeaders = [httpResponse allHeaderFields];
        self.responseStatus = [httpResponse statusCode];
        self.responseStringEncodingName = [httpResponse textEncodingName];
    }
    
    self.responseString = [self stringWithData:_responseData encodingName:_responseStringEncodingName];
    
    if(_responseStatus >= 400) {
        NSDictionary *userInfo = [[self class] userInfoWithErrorDescriptionForHTTPStatus:_responseStatus];
        if(e) *e = [NSError errorWithDomain:NSStringFromClass([self class]) code:_responseStatus userInfo:userInfo];
    }
    
    return _responseString;
}

- (void)cancel {
    [_task cancel];
    
    NSString *s = @"Connection was cancelled.";
    self.error = [NSError errorWithDomain:NSStringFromClass([self class])
                                     code:kSTHTTPRequestCancellationError
                                 userInfo:@{NSLocalizedDescriptionKey: s}];
    
    self.errorBlock(self.error);
}

+ (void)setBackgroundCompletionHandler:(void(^)())completionHandler forSessionIdentifier:(NSString *)sessionIdentifier {
    if(sessionCompletionHandlersForIdentifier == nil) {
        sessionCompletionHandlersForIdentifier = [NSMutableDictionary dictionary];
    }
    
    sessionCompletionHandlersForIdentifier[sessionIdentifier] = [completionHandler copy];
}

//+ (void(^)())backgroundCompletionHandlerForSessionIdentifier:(NSString *)sessionIdentifier {
//    return sessionCompletionHandlersForIdentifier[sessionIdentifier];
//}

#pragma mark NSURLSessionDelegate

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {

    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.errorBlock) {
            self.errorBlock(error);
        }
    });
}

/* If implemented, when a connection level authentication challenge
 * has occurred, this delegate will be given the opportunity to
 * provide authentication credentials to the underlying
 * connection. Some types of authentication will apply to more than
 * one request on a given connection to a server (SSL Server Trust
 * challenges).  If this delegate message is not implemented, the
 * behavior will be to use the default handling, which may involve user
 * interaction.
 */
// accept self-signed SSL certificates
#if DEBUG
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
    
}
#endif

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        void (^completionHandler)() = sessionCompletionHandlersForIdentifier[session.configuration.identifier];
        
        if(completionHandler) {
            completionHandler();
            [sessionCompletionHandlersForIdentifier removeObjectForKey:session.configuration.identifier];
        }
        
    });
}

#pragma mark NSURLSessionTaskDelegate

/* An HTTP request is attempting to perform a redirection to a different
 * URL. You must invoke the completion routine to allow the
 * redirection, allow the redirection with a modified request, or
 * pass nil to the completionHandler to cause the body of the redirection
 * response to be delivered as the payload of this request. The default
 * is to follow redirections.
 *
 * For tasks in background sessions, redirections will always be followed and this method will not be called.
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSURLRequest *actualRequest = weakSelf.preventRedirections ? nil : request;
        
        completionHandler(actualRequest);
        
    });
}
//
///* The task has received a request specific authentication challenge.
// * If this delegate is not implemented, the session specific authentication challenge
// * will *NOT* be called and the behavior will be the same as using the default handling
// * disposition.
// */
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
//    NSLog(@"-- 1.2");
//}
//
///* Sent if a task requires a new, unopened body stream.  This may be
// * necessary when authentication has failed for any request that
// * involves a body stream.
// */
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
// needNewBodyStream:(void (^)(NSInputStream * __nullable bodyStream))completionHandler {
//    NSLog(@"-- 1.3");
//}
//
/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil) return;
        
        if(strongSelf.uploadProgressBlock) {
            strongSelf.uploadProgressBlock(bytesSent, totalBytesSent, totalBytesExpectedToSend);
        }
        
    });
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //NSLog(@"-- didCompleteWithError: %@", [error localizedDescription]);
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil) return;
        
        //    NSString *s = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
        //
        //    _completionBlock(_responseHeaders, s);
        
        
        if([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *r = (NSHTTPURLResponse *)[task response];
            strongSelf.responseHeaders = [r allHeaderFields];
            strongSelf.responseStatus = [r statusCode];
            strongSelf.responseStringEncodingName = [r textEncodingName];
            strongSelf.responseExpectedContentLength = [r expectedContentLength];
            
            NSArray *responseCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:self.responseHeaders forURL:task.currentRequest.URL];
            for(NSHTTPCookie *cookie in responseCookies) {
                //NSLog(@"-- %@", cookie);
                [strongSelf addCookie:cookie]; // won't store anything when STHTTPRequestCookiesStorageNoStorage
            }
        } else {
            // TODO: handle error
        }
        
        if(strongSelf.HTTPBodyFileURL) {
            NSError *error = nil;
            BOOL status = [[NSFileManager defaultManager] removeItemAtURL:strongSelf.HTTPBodyFileURL error:&error];
            if(status == NO) {
                NSLog(@"-- can't remove %@, %@", strongSelf.HTTPBodyFileURL, [error localizedDescription]);
            }
        }
        
        if (error) {
            strongSelf.errorBlock(error);
            return;
        }
        
        if(strongSelf.responseStatus >= 400) {
            NSDictionary *userInfo = [[strongSelf class] userInfoWithErrorDescriptionForHTTPStatus:strongSelf.responseStatus];
            strongSelf.error = [NSError errorWithDomain:NSStringFromClass([strongSelf class]) code:strongSelf.responseStatus userInfo:userInfo];
            strongSelf.errorBlock(strongSelf.error);
            return;
        }
        
        if(strongSelf.completionDataBlock) {
            strongSelf.completionDataBlock(strongSelf.responseHeaders,strongSelf.responseData);
        }
        
        if(strongSelf.completionBlock) {
            NSString *responseString = [strongSelf stringWithData:strongSelf.responseData encodingName:strongSelf.responseStringEncodingName];
            strongSelf.completionBlock(strongSelf.responseHeaders, responseString);
        }
    });
}

#pragma mark NSURLSessionDataDelegate

/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 *
 * This method will not be called for background upload tasks (which cannot be converted to download tasks).
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completionHandler(NSURLSessionResponseAllow);
    });
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
//didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSAssert([[NSThread currentThread] isMainThread], @"not on main thread");
//    });
//}

///*
// * Notification that a data task has become a bidirectional stream
// * task.  No future messages will be sent to the data task.  The newly
// * created streamTask will carry the original request and response as
// * properties.
// *
// * For requests that were pipelined, the stream object will only allow
// * reading, and the object will immediately issue a
// * -URLSession:writeClosedForStream:.  Pipelining can be disabled for
// * all requests in a session, or by the NSURLRequest
// * HTTPShouldUsePipelining property.
// *
// * The underlying connection is no longer considered part of the HTTP
// * connection cache and won't count against the total number of
// * connections per host.
// */
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
//didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
//    NSLog(@"-- 2.3");
//}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil) return;
        
        [strongSelf.responseData appendData:data];
        
        if (strongSelf.downloadProgressBlock) {
            strongSelf.downloadProgressBlock(data, [strongSelf.responseData length], strongSelf.responseExpectedContentLength);
        }
        
    });
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil) return;
        
        NSCachedURLResponse *actualResponse = (globalIgnoreCache || strongSelf.ignoreCache) ? nil : proposedResponse;
        
        completionHandler(actualResponse);
        
    });
}

//
//#pragma mark NSURLSessionDownloadDelegate
//
///* Sent when a download task that has completed a download.  The delegate should
// * copy or move the file at the given location to a new location as it will be
// * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
// * still be called.
// */
//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
//didFinishDownloadingToURL:(NSURL *)location {
//
//    NSLog(@"-- 3.1");
//
//    NSData *responseData = [[NSFileManager defaultManager] contentsAtPath:[location filePathURL].path];
//
//    self.responseData = responseData;
//
//    /**/
//
//    if([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]] == NO) {
//        // TODO: handle error
//        //completionHandler(NSURLSessionResponseCancel);
//        self.errorBlock(nil);
//        return;
//    }
//
//    NSHTTPURLResponse *r = (NSHTTPURLResponse *)downloadTask.response;
//    self.responseHeaders = [r allHeaderFields];
//    self.responseStatus = [r statusCode];
//    self.responseStringEncodingName = [r textEncodingName];
//    self.responseExpectedContentLength = [r expectedContentLength];
//
//    NSArray *responseCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:self.responseHeaders forURL:downloadTask.currentRequest.URL];
//    for(NSHTTPCookie *cookie in responseCookies) {
//        NSLog(@"-- %@", cookie);
//        [self addCookie:cookie]; // won't store anything when STHTTPRequestCookiesStorageNoStorage
//    }
//
//
////    dispatch_async(dispatch_get_main_queue(), ^{
////        self.completionDataBlock(_responseHeaders, _responseData);
////    });
////
//
//}
//
///* Sent periodically to notify the delegate of download progress. */
//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
//      didWriteData:(int64_t)bytesWritten
// totalBytesWritten:(int64_t)totalBytesWritten
//totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//    NSLog(@"-- 3.2");
//
//    NSLog(@"-- percent bytes written: %f", 100.0 * totalBytesWritten / totalBytesExpectedToWrite);
//
//}
//
///* Sent when a download has been resumed. If a download failed with an
// * error, the -userInfo dictionary of the error will contain an
// * NSURLSessionDownloadTaskResumeData key, whose value is the resume
// * data.
// */
//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
// didResumeAtOffset:(int64_t)fileOffset
//expectedTotalBytes:(int64_t)expectedTotalBytes {
//    NSLog(@"-- 3.3");
//}
//

@end

/**/

@implementation NSError (STHTTPRequest)

- (BOOL)st_isAuthenticationError {
    
    if ([[self domain] isEqualToString:@"STHTTPRequest"] && ([self code] == 401)) return YES;
    
    if ([[self domain] isEqualToString:NSURLErrorDomain] && ([self code] == kCFURLErrorUserCancelledAuthentication || [self code] == kCFURLErrorUserAuthenticationRequired)) return YES;
    
    return NO;
}

- (BOOL)st_isCancellationError {
    return ([[self domain] isEqualToString:@"STHTTPRequest"] && [self code] == kSTHTTPRequestCancellationError);
}

@end

@implementation NSString (RFC3986)
- (NSString *)st_stringByAddingRFC3986PercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    
    NSString *s = (__bridge_transfer NSString *)(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)self,
                                                                                         NULL,
                                                                                         CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                         kCFStringEncodingUTF8));
    return s;
}
@end

/**/

@implementation NSString (STUtilities)

- (NSString *)st_stringByAppendingGETParameters:(NSDictionary *)parameters doApplyURLEncoding:(BOOL)doApplyURLEncoding {
    
    NSMutableString *ms = [self mutableCopy];
    
    __block BOOL questionMarkFound = NO;
    
    NSArray *sortedParameters = [STHTTPRequest dictionariesSortedByKey:parameters];
    
    [sortedParameters enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        
        NSString *key = [[d allKeys] lastObject];
        NSString *value = [[[d allValues] lastObject] description];
        
        if(questionMarkFound == NO) {
            questionMarkFound = [ms rangeOfString:@"?"].location != NSNotFound;
        }
        
        [ms appendString: (questionMarkFound ? @"&" : @"?") ];
        
        if(doApplyURLEncoding) {
            key = [key st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
            value = [value st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [ms appendFormat:@"%@=%@", key, value];
    }];
    
    return ms;
}

@end
//
///**/
//
//#if DEBUG
//@implementation NSURLRequest (IgnoreSSLValidation)
//
//+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
//    return NO;
//}
//
//@end
//#endif
//
/**/

@implementation STHTTPRequestFileUpload

+ (instancetype)fileUploadWithPath:(NSString *)path parameterName:(NSString *)parameterName mimeType:(NSString *)mimeType {
    STHTTPRequestFileUpload *fu = [[self alloc] init];
    fu.path = path;
    fu.parameterName = parameterName;
    fu.mimeType = mimeType;
    return fu;
}

+ (instancetype)fileUploadWithPath:(NSString *)path parameterName:(NSString *)fileName {
    return [self fileUploadWithPath:path parameterName:fileName mimeType:@"application/octet-stream"];
}

@end

@implementation STHTTPRequestDataUpload

+ (instancetype)dataUploadWithData:(NSData *)data parameterName:(NSString *)parameterName mimeType:(NSString *)mimeType fileName:(NSString *)fileName {
    STHTTPRequestDataUpload *du = [[self alloc] init];
    du.data = data;
    du.parameterName = parameterName;
    du.mimeType = mimeType;
    du.fileName = fileName;
    return du;
}

@end
