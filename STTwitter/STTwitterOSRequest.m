//
//  STTwitterOSRequest.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 20/02/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterOSRequest.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#if TARGET_OS_IPHONE
#import <Twitter/Twitter.h> // iOS 5
#endif
#import "NSString+STTwitter.h"

typedef void (^completion_block_t)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response);
typedef void (^error_block_t)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error);
typedef void (^upload_progress_block_t)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);

@interface STTwitterOSRequest ()
@property (nonatomic, copy) completion_block_t completionBlock;
@property (nonatomic, copy) error_block_t errorBlock;
@property (nonatomic, copy) upload_progress_block_t uploadProgressBlock;
@property (nonatomic, retain) NSHTTPURLResponse *httpURLResponse; // only used with streaming API
@property (nonatomic, retain) NSMutableData *data; // only used with non-streaming API
@property (nonatomic, retain) ACAccount *account;
@property (nonatomic) NSInteger httpMethod;
@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) NSString *baseURLString;
@property (nonatomic, retain) NSString *resource;
@end


@implementation STTwitterOSRequest

- (id)initWithAPIResource:(NSString *)resource
            baseURLString:(NSString *)baseURLString
               httpMethod:(NSInteger)httpMethod
               parameters:(NSDictionary *)params
                  account:(ACAccount *)account
      uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
          completionBlock:(void(^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))completionBlock
               errorBlock:(void(^)(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    NSAssert(completionBlock, @"completionBlock is missing");
    NSAssert(errorBlock, @"errorBlock is missing");
    
    self = [super init];
    
    self.resource = resource;
    self.baseURLString = baseURLString;
    self.httpMethod = httpMethod;
    self.params = params;
    self.account = account;
    self.completionBlock = completionBlock;
    self.errorBlock = errorBlock;
    self.uploadProgressBlock = uploadProgressBlock;
    
    return self;
}

- (NSURLConnection *)startRequest {
    
    NSData *mediaData = [_params valueForKey:@"media[]"];
    
    NSMutableDictionary *paramsWithoutMedia = [_params mutableCopy];
    [paramsWithoutMedia removeObjectForKey:@"media[]"];
    
    NSString *urlString = [_baseURLString stringByAppendingString:_resource];
    NSURL *url = [NSURL URLWithString:urlString];
    
    id request = nil;
    
#if TARGET_OS_IPHONE && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        TWRequestMethod method = (_httpMethod == 0) ? TWRequestMethodGET : TWRequestMethodPOST;
        request = [[TWRequest alloc] initWithURL:url parameters:paramsWithoutMedia requestMethod:method];
    } else {
        request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:_httpMethod URL:url parameters:paramsWithoutMedia];
    }
    
#else
    request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:_httpMethod URL:url parameters:paramsWithoutMedia];
#endif
    
    [request setAccount:_account];
    
    if(mediaData) {
        [request addMultipartData:mediaData withName:@"media[]" type:@"application/octet-stream" filename:@"media.jpg"];
    }
    
    // we use NSURLConnection because SLRequest doesn't play well with the streaming API
    
    NSURLRequest *preparedURLRequest = nil;
#if TARGET_OS_IPHONE && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        preparedURLRequest = [request signedURLRequest];
    } else {
        preparedURLRequest = [request preparedURLRequest];
    }
#else
    preparedURLRequest = [request preparedURLRequest];
#endif
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:preparedURLRequest delegate:self];
    [connection start];
    return connection;
}

- (NSDictionary *)requestHeadersForRequest:(id)request {
    
    if([request isKindOfClass:[NSURLRequest class]]) {
        return [request allHTTPHeaderFields];
    }
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        return [[request signedURLRequest] allHTTPHeaderFields];
    } else {
        return [[request preparedURLRequest] allHTTPHeaderFields];
    }
#else
    return [[request preparedURLRequest] allHTTPHeaderFields];
#endif
}

- (void)handleResponse:(NSHTTPURLResponse *)urlResponse request:(id)request data:(NSData *)responseData {
    
    if(responseData == nil) {
        self.errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], nil);
        return;
    }
    
    NSError *jsonError = nil;
    NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if(json == nil) {
        // do our best to extract Twitter error message from responseString
        
        NSString *rawResponse = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSError *regexError = nil;
        NSString *errorString = [rawResponse firstMatchWithRegex:@"<error.*?>(.*)</error>" error:&regexError];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            if(errorString) {
                NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : errorString}];
                self.errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], error);
                return;
            }
            
            self.completionBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], rawResponse);
        }];
        return;
    }
    
    /**/
    
    if([json isKindOfClass:[NSArray class]] == NO && [json valueForKey:@"error"]) {
        
        NSString *message = [json valueForKey:@"error"];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
        NSError *jsonErrorFromResponse = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
        
        self.errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], jsonErrorFromResponse);
        
        return;
    }
    
    /**/
    
    id jsonErrors = [json valueForKey:@"errors"];
    
    if(jsonErrors != nil && [jsonErrors isKindOfClass:[NSArray class]] == NO) {
        if(jsonErrors == nil) jsonErrors = @"";
        jsonErrors = [NSArray arrayWithObject:@{@"message":jsonErrors, @"code" : @(0)}];
    }
    
    if([jsonErrors count] > 0 && [jsonErrors lastObject] != [NSNull null]) {
        
        NSDictionary *jsonErrorDictionary = [jsonErrors lastObject];
        NSString *message = jsonErrorDictionary[@"message"];
        NSInteger code = [jsonErrorDictionary[@"code"] intValue];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
        NSError *jsonErrorFromResponse = [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:userInfo];
        
        self.errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], jsonErrorFromResponse);
        
        return;
    }
    
    /**/
    
    if(json) {
        self.completionBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], json);
    } else {
        self.errorBlock(request, [self requestHeadersForRequest:request], [urlResponse allHeaderFields], jsonError);
    }
    
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if([response isKindOfClass:[NSHTTPURLResponse class]] == NO) return;
    
    self.httpURLResponse = (NSHTTPURLResponse *)response;
    
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    BOOL isStreaming = [[[[connection originalRequest] URL] host] rangeOfString:@"stream"].location != NSNotFound;
    
    if(isStreaming) {
        [self handleResponse:_httpURLResponse request:[connection currentRequest] data:data];
    } else {
        [self.data appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSURLRequest *request = [connection currentRequest];
    NSDictionary *requestHeaders = [request allHTTPHeaderFields];
    NSDictionary *responseHeaders = [_httpURLResponse allHeaderFields];
    
    self.errorBlock(request, requestHeaders, responseHeaders, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self handleResponse:_httpURLResponse request:[connection currentRequest] data:_data];
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if(self.uploadProgressBlock == nil) return;
    self.uploadProgressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

@end
