//
//  STHTTPRequest+UnitTests.m
//
//  Created by Nicolas Seriot on 8/8/12.
//
//

#import "STHTTPRequest+UnitTests.h"
#import "STHTTPRequestTestResponse.h"
#import "STHTTPRequestTestResponseQueue.h"

#import <objc/runtime.h>
#import <objc/message.h>

void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@implementation STHTTPRequest (UnitTests)

@dynamic responseStatus;
@dynamic responseString;
@dynamic responseHeaders;
@dynamic responseData;
@dynamic error;

+ (void)initialize {
    Swizzle([STHTTPRequest class], @selector(startAsynchronous), @selector(unitTests_startAsynchronous));
    Swizzle([STHTTPRequest class], @selector(unitTests_startSynchronousWithError:), @selector(startSynchronousWithError:));
}

- (void)unitTests_startAsynchronous {
    
    NSAssert(self.errorBlock != nil, @"errorBlock needed");
    
    STHTTPRequestTestResponse *tr = [[STHTTPRequestTestResponseQueue sharedInstance] dequeue];
    
    NSAssert(tr.block != nil, @"block needed");
    
    tr.block(self); // simulate network response
    
    BOOL success = self.responseStatus < 400;
    
    if(success) {
        if(self.completionBlock) {
            self.completionBlock(self.responseHeaders, self.responseString);
        } else if(self.completionDataBlock) {
            self.completionDataBlock(self.responseHeaders, self.responseData);
        }
    } else {
        self.errorBlock(self.error);
    }
}

- (NSString *)unitTests_startSynchronousWithError:(NSError **)error {
    
    STHTTPRequestTestResponse *tr = [[STHTTPRequestTestResponseQueue sharedInstance] dequeue];
    
    NSAssert(tr.block != nil, @"block needed");
    
    tr.block(self);
    
    BOOL success = self.responseStatus < 400;
    
    if(success) {
        return self.responseString;
    } else {
        *error = self.error;
        return nil;
    }
    
    return self.responseString;
}

@end
