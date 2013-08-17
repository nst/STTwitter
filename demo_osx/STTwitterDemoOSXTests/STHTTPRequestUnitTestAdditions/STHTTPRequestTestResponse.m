#import "STHTTPRequestTestResponse.h"

@implementation STHTTPRequestTestResponse

@synthesize block;

+ (STHTTPRequestTestResponse *)testResponseWithBlock:(FillResponseBlock)block {
    STHTTPRequestTestResponse *tr = [[STHTTPRequestTestResponse alloc] init];
    tr.block = block;
    return tr;
}

@end
