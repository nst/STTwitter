//
//  STHTTPRequest+STTwitter.h
//  STTwitter
//
//  Created by Nicolas Seriot on 8/6/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STHTTPRequest.h"
#import "STTwitterRequestProtocol.h"

@interface STHTTPRequest (STTwitter) <STTwitterRequestProtocol>

+ (STHTTPRequest *)twitterRequestWithURLString:(NSString *)urlString
                                    HTTPMethod:(NSString *)HTTPMethod
                              timeoutInSeconds:(NSTimeInterval)timeoutInSeconds
                  stTwitterUploadProgressBlock:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))uploadProgressBlock
                stTwitterDownloadProgressBlock:(void(^)(NSData *data, int64_t totalBytesReceived, int64_t totalBytesExpectedToReceive))stTwitterDownloadProgressBlock
                         stTwitterSuccessBlock:(void(^)(NSDictionary *requestHeaders, NSDictionary *responseHeaders, id json))successBlock
                           stTwitterErrorBlock:(void(^)(NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock;

+ (void)expandedURLStringForShortenedURLString:(NSString *)urlString
                                  successBlock:(void(^)(NSString *expandedURLString))successBlock
                                    errorBlock:(void(^)(NSError *error))errorBlock;

@end
