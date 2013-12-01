//
//  STHTTPRequest+STTwitter.m
//  STTwitter
//
//  Created by Nicolas Seriot on 8/6/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STHTTPRequest+STTwitter.h"
#import "NSString+STTwitter.h"

#if DEBUG
#   define STLog(...) NSLog(__VA_ARGS__)
#else
#   define STLog(...)
#endif

@implementation STHTTPRequest (STTwitter)

+ (NSError *)errorFromResponseData:(NSData *)responseData {
    
    NSError *jsonError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    NSString *message = nil;
    NSInteger code = 0;
    
    if([json isKindOfClass:[NSDictionary class]]) {
        // assume {"errors":[{"message":"Bad Authentication data","code":215}]}
        
        id errors = [json valueForKey:@"errors"];
        if([errors isKindOfClass:[NSArray class]] && [(NSArray *)errors count] > 0) {
            NSDictionary *errorDictionary = [errors lastObject];
            if([errorDictionary isKindOfClass:[NSDictionary class]]) {
                message = errorDictionary[@"message"];
                code = [[errorDictionary valueForKey:@"code"] integerValue];
            }
        } else if([errors isKindOfClass:[NSString class]]) {
            // assume {errors = "Screen name can't be blank";}
            message = errors;
        }
    }
    
    if(message) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:@{NSLocalizedDescriptionKey : message}];
        return error;
    }
    
    return nil;
}

+ (STHTTPRequest *)twitterRequestWithURLString:(NSString *)urlString
                  stTwitterUploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                stTwitterDownloadProgressBlock:(void(^)(id json))downloadProgressBlock
                         stTwitterSuccessBlock:(void(^)(NSDictionary *requestHeaders, NSDictionary *responseHeaders, id json))successBlock
                           stTwitterErrorBlock:(void(^)(NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    __block STHTTPRequest *r = [self requestWithURLString:urlString];
    __weak STHTTPRequest *wr = r;
    
    r.ignoreSharedCookiesStorage = YES;
    
    r.timeoutSeconds = DBL_MAX;
    
    r.uploadProgressBlock = uploadProgressBlock;
    
    r.downloadProgressBlock = ^(NSData *data, NSInteger totalBytesReceived, NSInteger totalBytesExpectedToReceive) {
        
        if(downloadProgressBlock == nil) return;
        
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if(json) {
            downloadProgressBlock(json);
            return;
        }
        
        // we can receive several dictionaries in the same data chunk
        // such as '{..}\r\n{..}\r\n{..}' which is not valid JSON
        // so we split them up into a 'jsonChunks' array such as [{..},{..},{..}]
        
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSArray *jsonChunks = [jsonString componentsSeparatedByString:@"\r\n"];
        
        for(NSString *jsonChunk in jsonChunks) {
            if([jsonChunk length] == 0) continue;
            NSData *data = [jsonChunk dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if(json == nil) {
                //                errorBlock(wr.responseHeaders, jsonError);
                return; // not enough information to say it's an error
            }
            downloadProgressBlock(json);
        }
    };
    
    r.completionDataBlock = ^(NSDictionary *responseHeaders, NSData *responseData) {
        
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if(json == nil) {
            successBlock(wr.requestHeaders, wr.responseHeaders, wr.responseString); // response is not necessarily json
            return;
        }
        
        successBlock(wr.requestHeaders, wr.responseHeaders, json);
    };
    
    r.errorBlock = ^(NSError *error) {
        
        NSError *e = [self errorFromResponseData:wr.responseData];
        
        if(e) {
            errorBlock(wr.requestHeaders, wr.responseHeaders, e);
            return;
        }
        
        // do our best to extract Twitter error message from responseString
        
        NSError *regexError = nil;
        NSString *errorString = [wr.responseString firstMatchWithRegex:@"<error>(.*)</error>" error:&regexError];
        if(errorString == nil) {
            if(regexError) STLog(@"-- regexError: %@", [regexError localizedDescription]);
        }
        
        if(errorString) {
            error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : errorString}];
        } else if ([wr.responseString length] > 0 && [wr.responseString length] < 64) {
            error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : wr.responseString}];
        }
        
        if (wr.responseString) STLog(@"-- body: %@", wr.responseString);
        
        //        BOOL isCancellationError = [[error domain] isEqualToString:@"STHTTPRequest"] && ([error code] == kSTHTTPRequestCancellationError);
        //        if(isCancellationError) return;
        
        errorBlock(wr.requestHeaders, wr.responseHeaders, error);
    };
    
    return r;
}

+ (void)expandedURLStringForShortenedURLString:(NSString *)urlString
                                  successBlock:(void(^)(NSString *expandedURLString))successBlock
                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:urlString];
    
    r.ignoreSharedCookiesStorage = YES;
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
