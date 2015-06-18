//
//  STTwitterOSRequest.h
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 20/02/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitterRequestProtocol.h"

@class ACAccount;

@interface STTwitterOSRequest : NSObject <NSURLConnectionDelegate, STTwitterRequestProtocol>

- (instancetype)initWithAPIResource:(NSString *)resource
                      baseURLString:(NSString *)baseURLString
                         httpMethod:(NSInteger)httpMethod
                         parameters:(NSDictionary *)params
                            account:(ACAccount *)account
                   timeoutInSeconds:(NSTimeInterval)timeoutInSeconds
                uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                        streamBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))streamBlock
                    completionBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))completionBlock
                         errorBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock NS_DESIGNATED_INITIALIZER;

- (void)startRequest;
- (NSURLRequest *)preparedURLRequest;

@end
