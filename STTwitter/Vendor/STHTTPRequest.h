/*
 Copyright (c) 2012, Nicolas Seriot
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the Nicolas Seriot nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

extern NSUInteger const kSTHTTPRequestCancellationError;

@class STHTTPRequest;

typedef void (^uploadProgressBlock_t)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);
typedef void (^completionBlock_t)(NSDictionary *headers, NSString *body);
typedef void (^errorBlock_t)(NSError *error);

@interface STHTTPRequest : NSObject

@property (copy) uploadProgressBlock_t uploadProgressBlock;
@property (copy) completionBlock_t completionBlock;
@property (copy) errorBlock_t errorBlock;
@property (nonatomic) NSStringEncoding postDataEncoding;
@property (nonatomic, retain) NSURLCredential *credential;
@property (nonatomic, retain) NSURLCredential *proxyCredential;
@property (nonatomic, retain) NSDictionary *POSTDictionary;
@property (nonatomic, retain) NSData *POSTData;
@property (nonatomic, retain) NSMutableDictionary *requestHeaders;
@property (nonatomic, readonly) NSInteger responseStatus;
@property (nonatomic, retain, readonly) NSString *responseStringEncodingName;
@property (nonatomic, retain, readonly) NSDictionary *responseHeaders;
@property (nonatomic, retain, readonly) NSURL *url;
@property (nonatomic, retain, readonly) NSMutableData *responseData;
@property (nonatomic, retain, readonly) NSError *error;
@property (nonatomic, retain) NSString *responseString;
@property (nonatomic) NSStringEncoding forcedResponseEncoding;
@property (nonatomic) BOOL encodePOSTDictionary; // default YES
@property (nonatomic) BOOL addCredentialsToURL; // default YES

+ (STHTTPRequest *)requestWithURL:(NSURL *)url;
+ (STHTTPRequest *)requestWithURLString:(NSString *)urlString;

- (NSString *)startSynchronousWithError:(NSError **)error;
- (void)startAsynchronous;
- (void)cancel;

// Cookies
+ (void)addCookieWithName:(NSString *)name value:(NSString *)value url:(NSURL *)url;
- (void)addCookieWithName:(NSString *)name value:(NSString *)value;
- (NSArray *)requestCookies;
+ (NSArray *)sessionCookies;
+ (void)deleteSessionCookies;

// Credentials
+ (NSURLCredential *)sessionAuthenticationCredentialsForURL:(NSURL *)requestURL;
- (void)setUsername:(NSString *)username password:(NSString *)password;
- (void)setProxyUsername:(NSString *)username password:(NSString *)password;
- (NSString *)username;
- (NSString *)password;
+ (void)deleteAllCredentials;

// Headers
- (void)setHeaderWithName:(NSString *)name value:(NSString *)value;
- (void)removeHeaderWithName:(NSString *)name;
- (NSDictionary *)responseHeaders;

// Upload
- (void)setFileToUpload:(NSString *)path parameterName:(NSString *)param;
- (void)setDataToUpload:(NSData *)data parameterName:(NSString *)param;
- (void)setDataToUpload:(NSData *)data parameterName:(NSString *)param mimeType:(NSString *)mimeType fileName:(NSString *)fileName;

// Session
+ (void)clearSession; // delete all credentials and cookies

@end

@interface NSError (STHTTPRequest)
- (BOOL)st_isAuthenticationError;
- (BOOL)st_isCancellationError;
@end

@interface NSString (RFC3986)
- (NSString *)st_stringByAddingRFC3986PercentEscapesUsingEncoding:(NSStringEncoding)encoding;
@end
