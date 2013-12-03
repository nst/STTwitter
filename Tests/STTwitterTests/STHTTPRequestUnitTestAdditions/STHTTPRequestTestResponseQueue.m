#import "STHTTPRequestTestResponseQueue.h"
#import "STHTTPRequestTestResponse.h"

static STHTTPRequestTestResponseQueue *sharedInstance = nil;

@implementation STHTTPRequestTestResponseQueue

+ (STHTTPRequestTestResponseQueue *)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[STHTTPRequestTestResponseQueue alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    self.responses = [NSMutableArray array];
    return self;
}

/**/

- (void)enqueue:(STHTTPRequestTestResponse *)response {
    NSAssert(response != nil, @"can't enqueue nil");

    [_responses insertObject:response atIndex:0];
}

- (STHTTPRequestTestResponse *)dequeue {
    
    NSAssert([_responses count] > 0, @"can't dequeue because queue is empty, count is %lu", [_responses count]);

    if([_responses count] == 0) {
        return nil;
    }
    
    NSUInteger lastIndex = [_responses count] - 1;
    
    STHTTPRequestTestResponse *response = [_responses objectAtIndex:lastIndex];
    
    [_responses removeObjectAtIndex:lastIndex];
    
    return response;
}

@end
