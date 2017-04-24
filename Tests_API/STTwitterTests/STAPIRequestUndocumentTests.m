//
//  STAPIRequestUndocumentTests.m
//  UnitTests
//
//  Created by Yu Sugawara on 2015/03/27.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "STAPIRequestUndocumentTests.h"
#import "STTwitter.h"
#import "Constants.h"

static STTwitterAPI *__twitterOfficial;

@interface STAPIRequestUndocumentTests ()

@end

@implementation STAPIRequestUndocumentTests

- (void)setUp {
    [super setUp];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __twitterOfficial = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kOfficialConsumerKey
                                                          consumerSecret:kOfficialConsumerSecret
                                                              oauthToken:kOfficialAccessToken
                                                        oauthTokenSecret:kOfficialAccessTokenSecret];
#if !Debug_NotVerifyCredentials
        XCTestExpectation *expectation = [self expectationWithDescription:nil];
        [__twitterOfficial verifyCredentialsWithSuccessBlock:^(NSString *username) {
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            XCTFail(@"error: %@", error);
            exit(0);
        }];
        [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
        XCTAssertNotNil(__twitterOfficial);
#endif
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -
#pragma mark UNDOCUMENTED APIs

- (void)testGetActivityAboutMe {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        
        [twitter _getActivityAboutMeSinceID:nil
                                      count:nil
                               includeCards:nil
                               modelVersion:nil
                             sendErrorCodes:nil
                         contributorDetails:nil
                            includeEntities:nil
                           includeMyRetweet:nil
                               successBlock:^(NSArray *activities) {
                                   XCTAssertTrue([activities isKindOfClass:[NSArray class]]);
                                   [expectation fulfill];
                               } errorBlock:^(NSError *error) {
                                   validateError(error);
                               }];
    }];
}

- (void)testGetActivityByFriends {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        
        [twitter _getActivityByFriendsSinceID:nil
                                        count:nil
                           contributorDetails:nil
                                 includeCards:nil
                              includeEntities:nil
                            includeMyRetweets:nil
                           includeUserEntites:nil
                                latestResults:nil
                               sendErrorCodes:nil
                                 successBlock:^(NSArray *activities) {
                                     XCTAssertTrue([activities isKindOfClass:[NSArray class]]);
                                     [expectation fulfill];
                                 } errorBlock:^(NSError *error) {
                                     validateError(error);
                                 }];
    }];
}

- (void)testGetStatusesActivitySummary {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getStatusesActivitySummaryForStatusID:kTargetTweetID
                                           successBlock:^(NSArray *favoriters, NSArray *repliers, NSArray *retweeters, NSString *favoritersCount, NSString *repliersCount, NSString *retweetersCount) {
                                               XCTAssertTrue([favoriters isKindOfClass:[NSArray class]]);
                                               [expectation fulfill];
                                           } errorBlock:^(NSError *error) {
                                               validateError(error);
                                           }];
    }];
}

- (void)testGetConversationShow {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getConversationShowForStatusID:kTargetTweetID
                                    successBlock:^(NSArray *statuses) {
                                        XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                        [expectation fulfill];
                                    } errorBlock:^(NSError *error) {
                                        validateError(error);
                                    }];
    }];
}

- (void)testGetDiscoverHighlight {
    
    /**
     *  deprecated? (Depending on the status of the account?)
     *
     *  Domain=STTwitterTwitterErrorDomain
     *  Code=34
     *  NSLocalizedDescription="Sorry, that page does not exist"
     *  "HTTP Status 404: Not Found"
     *  STTwitterRateLimitLimit=300, STTwitterRateLimitResetDate=2015-03-27 08:24:51 +0000, =Sorry, that page does not exist, STTwitterRateLimitRemaining=297, NSUnderlyingError=0x100191900
     */
    
#if 0
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getDiscoverHighlightWithSuccessBlock:^(NSDictionary *metadata, NSArray *modules) {
            XCTAssertTrue([metadata isKindOfClass:[NSDictionary class]]);
            XCTAssertTrue([modules isKindOfClass:[NSArray class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
#endif
}

- (void)testGetDiscoverUniversal {
    
#if 0
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getDiscoverUniversalWithSuccessBlock:^(NSDictionary *metadata, NSArray *modules) {
            XCTAssertTrue([metadata isKindOfClass:[NSDictionary class]]);
            XCTAssertTrue([modules isKindOfClass:[NSArray class]]);
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
#endif
}

- (void)testGetMediaTimeline {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getMediaTimelineWithSuccessBlock:^(NSArray *statuses) {
            XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetUsersRecommendations {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getUsersRecommendationsWithSuccessBlock:^(NSArray *recommendations) {
            XCTAssertTrue([recommendations isKindOfClass:[NSArray class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetTimelineHome {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getTimelineHomeWithSuccessBlock:^(id response) {
            XCTAssertTrue([response isKindOfClass:[NSDictionary class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetStatusesMentionsTimeline {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getStatusesMentionsTimelineWithCount:nil
                                   contributorsDetails:nil
                                       includeEntities:nil
                                      includeMyRetweet:nil
                                          successBlock:^(NSArray *statuses) {
                                              XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                              [expectation fulfill];
                                          } errorBlock:^(NSError *error) {
                                              validateError(error);
                                          }];
    }];
}

- (void)testGetTrendsAvailable {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getTrendsAvailableWithSuccessBlock:^(NSArray *places) {
            XCTAssertTrue([places isKindOfClass:[NSArray class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testPostUsersReportSpam {
/*
- (NSObject<STTwitterRequestProtocol> *)_postUsersReportSpamForTweetID:(NSString *)tweetID
                                                              reportAs:(NSString *)reportAs // spam, abused, compromised
                                                             blockUser:(NSNumber *)blockUser
                                                          successBlock:(void(^)(id userProfile))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostAccountGenerate {
/*
- (NSObject<STTwitterRequestProtocol> *)_postAccountGenerateWithADC:(NSString *)adc
                                                discoverableByEmail:(BOOL)discoverableByEmail
                                                              email:(NSString *)email
                                                         geoEnabled:(BOOL)geoEnabled
                                                           language:(NSString *)language
                                                               name:(NSString *)name
                                                           password:(NSString *)password
                                                         screenName:(NSString *)screenName
                                                      sendErrorCode:(BOOL)sendErrorCode
                                                           timeZone:(NSString *)timeZone
                                                       successBlock:(void(^)(id userProfile))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetSearchTypeahead {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getSearchTypeaheadQuery:@"apple"
                               resultType:nil
                           sendErrorCodes:nil
                             successBlock:^(id results) {
                                 XCTAssertTrue([results isKindOfClass:[NSDictionary class]]);
                                 [expectation fulfill];
                             } errorBlock:^(NSError *error) {
                                 validateError(error);
                             }];
    }];
}

- (void)testPostDirectMessage {
/*
- (NSObject<STTwitterRequestProtocol> *)_postDirectMessage:(NSString *)status
                                             forScreenName:(NSString *)screenName
                                                  orUserID:(NSString *)userID
                                                   mediaID:(NSString *)mediaID // returned by POST media/upload.json
                                              successBlock:(void(^)(NSDictionary *message))successBlock
                                                errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetConversationShowWithTweetID {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getConversationShowWithTweetID:kTargetTweetID
                                    successBlock:^(id results) {
                                        XCTAssertTrue([results isKindOfClass:[NSArray class]]);
                                        [expectation fulfill];
                                    } errorBlock:^(NSError *error) {
                                        validateError(error);
                                    }];
    }];
}

#pragma mark - UNDOCUMENTED APIS SCHEDULED TWEETS - VALID ONLY FOR TWEETDECK

- (void)testGetScheduleStatuses {

    /**
     *  Could not be used
     *
     *  Domain=STTwitterTwitterErrorDomain
     *  Code=220
     *  NSLocalizedDescription="Your credentials do not allow access to this resource"
     */
#if 0
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getScheduleStatusesWithCount:nil
                               includeEntities:nil
                           includeUserEntities:nil
                                  includeCards:nil
                                  successBlock:^(NSArray *scheduledTweets) {
                                      XCTAssertTrue([scheduledTweets isKindOfClass:[NSArray class]]);
                                      [expectation fulfill];
                                  } errorBlock:^(NSError *error) {
                                      validateError(error);
                                  }];
    }];
#endif
}

- (void)testPostScheduleStatus {
/*
- (NSObject<STTwitterRequestProtocol> *)_postScheduleStatus:(NSString *)status
                                                  executeAt:(NSString *)executeAtUnixTimestamp
                                                   mediaIDs:(NSArray *)mediaIDs
                                               successBlock:(void(^)(NSDictionary *scheduledTweet))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock;
*/
}
 
- (void)testDeleteScheduleStatus {
/*
- (NSObject<STTwitterRequestProtocol> *)_deleteScheduleStatusWithID:(NSString *)statusID
                                                       successBlock:(void(^)(NSDictionary *deletedTweet))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPutScheduleStatus {
/*
- (NSObject<STTwitterRequestProtocol> *)_putScheduleStatusWithID:(NSString *)statusID
                                                          status:(NSString *)status
                                                       executeAt:(NSString *)executeAtUnixTimestamp
                                                        mediaIDs:(NSArray *)mediaIDs
                                                    successBlock:(void(^)(NSDictionary *scheduledTweet))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

#pragma mark UNDOCUMENTED APIS FOR DIGITS AUTH

- (void)testPostGuestActivate {
/*
- (NSObject<STTwitterRequestProtocol> *)_postGuestActivateWithSuccessBlock:(void(^)(NSString *guestToken))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostDeviceRegister {
/*
- (NSObject<STTwitterRequestProtocol> *)_postDeviceRegisterPhoneNumber:(NSString *)phoneNumber // eg. @"+41764948273"
                                                            guestToken:(NSString *)guestToken
                                                          successBlock:(void(^)(id response))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostSDKAccount {
/*
- (NSObject<STTwitterRequestProtocol> *)_postSDKAccountNumericPIN:(NSString *)numericPIN
                                                   forPhoneNumber:(NSString *)phoneNumber
                                                       guestToken:(NSString *)guestToken
                                                     successBlock:(void(^)(id response, NSString *accessToken, NSString *accessTokenSecret))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

#pragma mark UNDOCUMENTED APIS FOR CONTACTS

- (void)testPostContactsUpload {
/*
- (NSObject<STTwitterRequestProtocol> *)_postContactsUpload:(NSArray *)vcards
                                               successBlock:(void(^)(id response))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetContactsUsersAndUploadedBy {

    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter _getContactsUsersAndUploadedByWithCount:nil
                                            successBlock:^(id response) {
                                                XCTAssertTrue([response isKindOfClass:[NSDictionary class]]);
                                                [expectation fulfill];
                                            } errorBlock:^(NSError *error) {
                                                validateError(error);
                                            }];
    }];
}

- (void)testGetContactsDestroyAll {
/*
- (NSObject<STTwitterRequestProtocol> *)_getContactsDestroyAllWithSuccessBlock:(void(^)(id response))successBlock
                                                                    errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

#if 0
- (void)test {
    
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        XCTAssertTrue([<#__#> isKindOfClass:[<#__#> class]]);
        [expectation fulfill];
        
        validateError(error);
    }];
}
#endif

#pragma mark - Utility

- (void)officialTwitterUsingBlock:(void(^)(STTwitterAPI *twitter, XCTestExpectation *expectation))block {
    
    if (__twitterOfficial) {
        XCTestExpectation *expectation = [self expectationWithDescription:nil];
        block(__twitterOfficial, expectation);
        [self waitForExpectationsWithTimeout:30. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }
}

@end
