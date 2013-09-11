//
//  STHTTPRequest+UnitTests.h
//
//  Created by Nicolas Seriot on 8/8/12.
//
//

#import "STHTTPRequest.h"

@interface STHTTPRequest (UnitTests)

// expose private properties
@property (nonatomic) NSUInteger responseStatus;
@property (nonatomic, retain) NSString *responseString;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSError *error;

@end
