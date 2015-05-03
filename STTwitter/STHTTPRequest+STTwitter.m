//
//  STHTTPRequest+STTwitter.m
//  STTwitter
//
//  Created by Nicolas Seriot on 8/6/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STHTTPRequest+STTwitter.h"
#import "NSString+STTwitter.h"
#import "NSError+STTwitter.h"

#if DEBUG
#   define STLog(...) NSLog(__VA_ARGS__)
#else
#   define STLog(...)
#endif

@implementation STHTTPRequest (STTwitter)

+ (STHTTPRequest *)twitterRequestWithURLString:(NSString *)urlString
                                    HTTPMethod:(NSString *)HTTPMethod
                              timeoutInSeconds:(NSTimeInterval)timeoutInSeconds
                  stTwitterUploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                stTwitterDownloadProgressBlock:(void(^)(NSData *data, NSUInteger totalBytesReceived, long long totalBytesExpectedToReceive))downloadProgressBlock
                         stTwitterSuccessBlock:(void(^)(NSDictionary *requestHeaders, NSDictionary *responseHeaders, id json))successBlock
                           stTwitterErrorBlock:(void(^)(NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    __block STHTTPRequest *r = [self requestWithURLString:urlString];
    __weak STHTTPRequest *wr = r;
    
    r.HTTPMethod = HTTPMethod;

    r.cookieStoragePolicyForInstance = STHTTPRequestCookiesStorageNoStorage;
    
    r.timeoutSeconds = timeoutInSeconds;
    
    r.uploadProgressBlock = uploadProgressBlock;
    
    r.downloadProgressBlock = downloadProgressBlock;
    
    r.completionDataBlock = ^(NSDictionary *responseHeaders, NSData *responseData) {
        
        STHTTPRequest *sr = wr; // strong request

        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if(json == nil) {
            successBlock(sr.requestHeaders, sr.responseHeaders, sr.responseString); // response is not necessarily json
            return;
        }
        
        successBlock(sr.requestHeaders, sr.responseHeaders, json);
    };
    
    r.errorBlock = ^(NSError *error) {
        
        STHTTPRequest *sr = wr; // strong request

        NSError *e = [NSError st_twitterErrorFromResponseData:sr.responseData responseHeaders:sr.responseHeaders underlyingError:error];
        if(e) {
            errorBlock(sr.requestHeaders, sr.responseHeaders, e);
            return;
        }

        if(error) {
            errorBlock(sr.requestHeaders, sr.responseHeaders, error);
            return;
        }
        
        e = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : sr.responseString}];
        
        if (sr.responseString) STLog(@"-- body: %@", sr.responseString);
        
        //        BOOL isCancellationError = [[error domain] isEqualToString:@"STHTTPRequest"] && ([error code] == kSTHTTPRequestCancellationError);
        //        if(isCancellationError) return;
        
        errorBlock(sr.requestHeaders, sr.responseHeaders, e);
    };
    
    return r;
}

+ (void)expandedURLStringForShortenedURLString:(NSString *)urlString
                                  successBlock:(void(^)(NSString *expandedURLString))successBlock
                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:urlString];
    
    r.cookieStoragePolicyForInstance = STHTTPRequestCookiesStorageNoStorage;

    r.preventRedirections = YES;
    
    r.completionBlock = ^(NSDictionary *responseHeaders, NSString *body) {
        
        NSString *location = [responseHeaders valueForKey:@"location"];
        if(location == nil) [responseHeaders valueForKey:@"Location"];
        
        successBlock(location);
    };
    
    r.errorBlock = ^(NSError *error) {
        errorBlock(error);
    };
    
    [r startAsynchronous];
}

@end
