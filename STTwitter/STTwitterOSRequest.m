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
#import "STHTTPRequest.h"
#import "NSString+STTwitter.h"
#import "NSError+STTwitter.h"

typedef void (^completion_block_t)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response);
typedef void (^error_block_t)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error);
typedef void (^upload_progress_block_t)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^stream_block_t)(NSObject<STTwitterRequestProtocol> *request, NSData *data);

@interface STTwitterOSRequest ()
@property (nonatomic, copy) completion_block_t completionBlock;
@property (nonatomic, copy) error_block_t errorBlock;
@property (nonatomic, copy) upload_progress_block_t uploadProgressBlock;
@property (nonatomic, copy) stream_block_t streamBlock;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSHTTPURLResponse *httpURLResponse; // only used with streaming API
@property (nonatomic, strong) NSMutableData *data; // only used with non-streaming API
@property (nonatomic, strong) ACAccount *account;
@property (nonatomic) NSInteger httpMethod;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSString *baseURLString;
@property (nonatomic, strong) NSString *resource;
@property (nonatomic) NSTimeInterval timeoutInSeconds;
@end

@implementation STTwitterOSRequest

- (instancetype)initWithAPIResource:(NSString *)resource
                      baseURLString:(NSString *)baseURLString
                         httpMethod:(NSInteger)httpMethod
                         parameters:(NSDictionary *)params
                            account:(ACAccount *)account
                   timeoutInSeconds:(NSTimeInterval)timeoutInSeconds
                uploadProgressBlock:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))uploadProgressBlock
                        streamBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))streamBlock
                    completionBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))completionBlock
                         errorBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
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
    self.streamBlock = streamBlock;
    self.timeoutInSeconds = timeoutInSeconds;
    
    return self;
}

- (NSURLRequest *)preparedURLRequest {
    NSString *postDataKey = [_params valueForKey:kSTPOSTDataKey];
    NSString *postDataFilename = [_params valueForKey:kSTPOSTMediaFileNameKey];
    NSData *mediaData = [_params valueForKey:postDataKey];
    
    NSMutableDictionary *paramsWithoutMedia = [_params mutableCopy];
    if(postDataKey) [paramsWithoutMedia removeObjectForKey:postDataKey];
    [paramsWithoutMedia removeObjectForKey:kSTPOSTDataKey];
    [paramsWithoutMedia removeObjectForKey:kSTPOSTMediaFileNameKey];
    
    NSString *urlString = [_baseURLString stringByAppendingString:_resource];
    NSURL *url = [NSURL URLWithString:urlString];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:_httpMethod
                                                      URL:url
                                               parameters:paramsWithoutMedia];
    
    [request setAccount:_account];
    
    if(mediaData) {
        NSString *filename = postDataFilename ? postDataFilename : @"media.jpg";
        [request addMultipartData:mediaData withName:postDataKey type:@"application/octet-stream" filename:filename];
    }
    
    // we use NSURLSessionDataTask because SLRequest doesn't play well with the streaming API
    
    return [request preparedURLRequest];
}

- (void)startRequest {
    
    NSURLRequest *preparedURLRequest = [self preparedURLRequest];
    
    NSMutableURLRequest *mutablePreparedURLRequest = [preparedURLRequest mutableCopy];
    mutablePreparedURLRequest.timeoutInterval = _timeoutInSeconds;
    
    if (_task) {
        [self cancel];
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:nil];
    
    // TODO: use an uploadDataTask when appropriate, need the file URL
    self.task = [session dataTaskWithRequest:mutablePreparedURLRequest];
    
    [_task resume];
}

- (void)cancel {
    [_task cancel];
    
    NSURLRequest *request = [_task currentRequest];
    
    NSString *s = @"Connection was cancelled.";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: s};
    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:kSTHTTPRequestCancellationError
                                     userInfo:userInfo];
    self.errorBlock(self, [self requestHeadersForRequest:request], [_httpURLResponse allHeaderFields], error);
}

- (NSDictionary *)requestHeadersForRequest:(id)request {
    
    if([request isKindOfClass:[NSURLRequest class]]) {
        return [request allHTTPHeaderFields];
    }
    
    return [[request preparedURLRequest] allHTTPHeaderFields];
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if(strongSelf == nil) {
            completionHandler(NSURLSessionResponseCancel);
            return;
        }
        
        if([response isKindOfClass:[NSHTTPURLResponse class]] == NO) {
            // TODO: handle error
            completionHandler(NSURLSessionResponseCancel);
            return;
        }
        
        strongSelf.httpURLResponse = (NSHTTPURLResponse *)response;
        
        strongSelf.data = [NSMutableData data];
        
        completionHandler(NSURLSessionResponseAllow);
        
    });
    
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL isStreaming = [[[[dataTask originalRequest] URL] host] rangeOfString:@"stream"].location != NSNotFound;
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil) {
            return;
        }
        
        if(isStreaming) {
            strongSelf.streamBlock(strongSelf, data);
        } else {
            [strongSelf.data appendData:data];
        }
        
    });
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil) {
            return;
        }
        
        if(strongSelf.uploadProgressBlock == nil) return;
        
        // avoid overcommit while posting big images, like 5+ MB
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            strongSelf.uploadProgressBlock(bytesSent, totalBytesSent, totalBytesExpectedToSend);
        });
        
    });
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //NSLog(@"-- didCompleteWithError: %@", [error localizedDescription]);
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil) return;
        
        if(error) {
            NSURLRequest *request = [strongSelf.task currentRequest];
            NSDictionary *requestHeaders = [request allHTTPHeaderFields];
            NSDictionary *responseHeaders = [strongSelf.httpURLResponse allHeaderFields];
            
            strongSelf.errorBlock(strongSelf, requestHeaders, responseHeaders, error);
            return;
        }
        
        NSURLRequest *request = [_task currentRequest];
        
        if(_data == nil) {
            strongSelf.errorBlock(strongSelf, [strongSelf requestHeadersForRequest:request], [_httpURLResponse allHeaderFields], nil);
            return;
        }
        
        NSError *error = [NSError st_twitterErrorFromResponseData:_data responseHeaders:[_httpURLResponse allHeaderFields] underlyingError:nil];
        
        if(error) {
            strongSelf.errorBlock(strongSelf, [strongSelf requestHeadersForRequest:request], [_httpURLResponse allHeaderFields], error);
            return;
        }
        
        NSError *jsonError = nil;
        id response = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if(response == nil) {
            // eg. reverse auth response
            // oauth_token=xxx&oauth_token_secret=xxx&user_id=xxx&screen_name=xxx
            response = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        }
        
        if(response) {
            strongSelf.completionBlock(strongSelf, [strongSelf requestHeadersForRequest:request], [_httpURLResponse allHeaderFields], response);
        } else {
            strongSelf.errorBlock(strongSelf, [strongSelf requestHeadersForRequest:request], [_httpURLResponse allHeaderFields], jsonError);
        }
        
        [session finishTasksAndInvalidate];
    });
}

@end
