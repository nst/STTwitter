//
//  Constants.h
//  UnitTests
//
//  Created by Yu Sugawara on 2015/03/27.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#pragma mark - Settings

#warning Please enter the keys.
/* Required */
#define kConsumerKey @""
#define kConsumerSecret @""
#define kAccessToken @""
#define kAccessTokenSecret @""

/* Optional */
#define kOfficialConsumerKey @""
#define kOfficialConsumerSecret @""
#define kOfficialAccessToken @""
#define kOfficialAccessTokenSecret @""

#pragma mark -

// [Warning] There is a test that does not pass to the true.
#define Debug_NotVerifyCredentials 0

#define kTargetUserID @"783214" // https://twitter.com/twitter
#define kTargetScreenName @"twitter" // https://twitter.com/twitter
#define kTargetTweetID @"20" // https://twitter.com/jack/status/20

#define kListUserID @"12" // https://twitter.com/jack
#define kListOwnerID @"26642006" // https://twitter.com/Alyssa_Milano
#define kListID @"21294" // https://twitter.com/Alyssa_Milano/lists/happy-tweeting
#define kListSlug @"happy-tweeting" // https://twitter.com/Alyssa_Milano/lists/happy-tweeting

#define kPlaceID @"df51dec6f4ee2b2c"

#define kLatitude @"37.76893497"
#define kLongitude @"-122.42284884"

#define validateError(error) \
if ([error.domain isEqualToString:kSTTwitterTwitterErrorDomain] && error.code == STTwitterTwitterErrorRateLimitExceeded) {\
NSLog(@"[Warning] RateLimitExceeded: %s", __func__);\
} else {\
XCTFail(@"error: %@", error);\
}\
[expectation fulfill];