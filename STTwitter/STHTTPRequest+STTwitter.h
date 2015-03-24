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
                  stTwitterUploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                stTwitterDownloadProgressBlock:(void(^)(NSData *data, NSUInteger totalBytesReceived, long long totalBytesExpectedToReceive))stTwitterDownloadProgressBlock
                         stTwitterSuccessBlock:(void(^)(NSDictionary *requestHeaders, NSDictionary *responseHeaders, id json))successBlock
                           stTwitterErrorBlock:(void(^)(NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock;

+ (void)expandedURLStringForShortenedURLString:(NSString *)urlString
                                  successBlock:(void(^)(NSString *expandedURLString))successBlock
                                    errorBlock:(void(^)(NSError *error))errorBlock;

@end
