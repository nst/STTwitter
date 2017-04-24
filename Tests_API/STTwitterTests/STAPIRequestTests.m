//
//  STAPIRequestTests.m
//  UnitTests
//
//  Created by Yu Sugawara on 2015/03/26.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "STAPIRequestTests.h"
#import "STTwitter.h"
#import "Constants.h"

static STTwitterAPI *__twitter;
static STTwitterAPI *__twitterOS;

@interface STAPIRequestTests ()

@end

@implementation STAPIRequestTests

- (void)setUp {
    [super setUp];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            __twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey
                                                      consumerSecret:kConsumerSecret
                                                          oauthToken:kAccessToken
                                                    oauthTokenSecret:kAccessTokenSecret];
            
#if !Debug_NotVerifyCredentials
            XCTestExpectation *expectation = [self expectationWithDescription:nil];
            [__twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
                [expectation fulfill];
            } errorBlock:^(NSError *error) {
                XCTFail(@"error: %@", error);
                exit(0);
            }];
            [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
#endif
            XCTAssertNotNil(__twitter);
        }
        {
            /**
             *  TODO: Want to make it work
             *  
             *  Access to the ACAccountStore doesn't work in XCTTest.
             *  (Incorrect settings in my Mac?)
             */
#if 0
            if (!__twitterOS) {
                __twitterOS = [STTwitterAPI twitterAPIOSWithFirstAccount];
                
#if !Debug_NotVerifyCredentials
                XCTestExpectation *expectation = [self expectationWithDescription:nil];
                [__twitterOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
                    [expectation fulfill];
                } errorBlock:^(NSError *error) {
                    XCTFail(@"error: %@", error);
                    exit(0);
                }];
                [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
                    XCTAssertNil(error, @"error: %@", error);
                }];
#endif
                XCTAssertNotNil(__twitterOS);
            }
            self.twitterOS = __twitterOS;
#endif
        }
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark Timelines

- (void)testGetStatusesMentionTimeline {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getStatusesMentionTimelineWithCount:nil
                                             sinceID:nil
                                               maxID:nil
                                            trimUser:nil
                                  contributorDetails:nil
                                     includeEntities:nil
                                        successBlock:^(NSArray *statuses) {
                                            XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                            [expectation fulfill];
                                        } errorBlock:^(NSError *error) {
                                            validateError(error);
                                        }];
    }];
}

- (void)testGetStatusesUserTimeline {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getStatusesUserTimelineForUserID:nil
                                       screenName:twitter.userName
                                          sinceID:nil
                                            count:nil
                                            maxID:nil
                                         trimUser:nil
                                   excludeReplies:nil
                               contributorDetails:nil
                                  includeRetweets:nil
                                     successBlock:^(NSArray *statuses) {
                                         XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                         [expectation fulfill];
                                     } errorBlock:^(NSError *error) {
                                         validateError(error);
                                     }];
    }];
}

- (void)testGetStatusesHomeTimeline {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getStatusesHomeTimelineWithCount:nil
                                          sinceID:nil
                                            maxID:nil
                                         trimUser:nil
                                   excludeReplies:nil
                               contributorDetails:nil
                                  includeEntities:nil
                                     successBlock:^(NSArray *statuses) {
                                         XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                         [expectation fulfill];
                                     } errorBlock:^(NSError *error) {
                                         validateError(error);
                                     }];
    }];
}

- (void)testGetStatusesRetweetsOfMe {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getStatusesRetweetsOfMeWithCount:nil
                                          sinceID:nil
                                            maxID:nil
                                         trimUser:nil
                                  includeEntities:nil
                              includeUserEntities:nil
                                     successBlock:^(NSArray *statuses) {
                                         XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                         [expectation fulfill];
                                     } errorBlock:^(NSError *error) {
                                         validateError(error);
                                     }];
    }];
}

#pragma mark Tweets

- (void)testGetStatusesRetweets {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getStatusesRetweetsForID:kTargetTweetID
                                    count:nil
                                 trimUser:nil
                             successBlock:^(NSArray *statuses) {
                                 XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                 [expectation fulfill];
                             } errorBlock:^(NSError *error) {
                                 validateError(error);
                             }];
    }];
}

- (void)testGetStatusesShow {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getStatusesShowID:kTargetTweetID
                          trimUser:nil
                  includeMyRetweet:nil
                   includeEntities:nil
                      successBlock:^(NSDictionary *status) {
                          XCTAssertTrue([status isKindOfClass:[NSDictionary class]]);
                          [expectation fulfill];
                      } errorBlock:^(NSError *error) {
                          validateError(error);
                      }];
    }];
}

- (void)testPostStatusesDestroy {
/*
- (NSObject<STTwitterRequestProtocol> *)postStatusesDestroy:(NSString *)statusID
                                                   trimUser:(NSNumber *)trimUser
                                               successBlock:(void(^)(NSDictionary *status))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostStatusUpdate {
/*
- (NSObject<STTwitterRequestProtocol> *)postStatusUpdate:(NSString *)status
                                       inReplyToStatusID:(NSString *)existingStatusID
                                                latitude:(NSString *)latitude
                                               longitude:(NSString *)longitude
                                                 placeID:(NSString *)placeID
                                      displayCoordinates:(NSNumber *)displayCoordinates
                                                trimUser:(NSNumber *)trimUser
                                            successBlock:(void(^)(NSDictionary *status))successBlock
                                              errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testPostStatusUpdateWithMediaIDs {
/*
- (NSObject<STTwitterRequestProtocol> *)postStatusUpdate:(NSString *)status
                                       inReplyToStatusID:(NSString *)existingStatusID
                                                mediaIDs:(NSArray *)mediaIDs
                                                latitude:(NSString *)latitude
                                               longitude:(NSString *)longitude
                                                 placeID:(NSString *)placeID
                                      displayCoordinates:(NSNumber *)displayCoordinates
                                                trimUser:(NSNumber *)trimUser
                                            successBlock:(void(^)(NSDictionary *status))successBlock
                                              errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testPostStatusRetweet {
/*
- (NSObject<STTwitterRequestProtocol> *)postStatusRetweetWithID:(NSString *)statusID
                                                       trimUser:(NSNumber *)trimUser
                                                   successBlock:(void(^)(NSDictionary *status))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testPostStatusUpdateWithMedia {
/*
- (NSObject<STTwitterRequestProtocol> *)postStatusUpdate:(NSString *)status
                                          mediaDataArray:(NSArray *)mediaDataArray // only one media is currently supported, help/configuration.json returns "max_media_per_upload" = 1
                                       possiblySensitive:(NSNumber *)possiblySensitive
                                       inReplyToStatusID:(NSString *)inReplyToStatusID
                                                latitude:(NSString *)latitude
                                               longitude:(NSString *)longitude
                                                 placeID:(NSString *)placeID
                                      displayCoordinates:(NSNumber *)displayCoordinates
                                     uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                            successBlock:(void(^)(NSDictionary *status))successBlock
                                              errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testGetStatusesOEmbed {
/*
- (NSObject<STTwitterRequestProtocol> *)getStatusesOEmbedForStatusID:(NSString *)statusID
                                                           urlString:(NSString *)urlString
                                                            maxWidth:(NSString *)maxWidth
                                                           hideMedia:(NSNumber *)hideMedia
                                                          hideThread:(NSNumber *)hideThread
                                                          omitScript:(NSNumber *)omitScript
                                                               align:(NSString *)align // 'left', 'right', 'center' or 'none' (default)
                                                             related:(NSString *)related // eg. twitterapi,twittermedia,twitter
                                                                lang:(NSString *)lang
                                                        successBlock:(void(^)(NSDictionary *status))successBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testGetStatusesRetweetersIDs {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getStatusesRetweetersIDsForStatusID:kTargetTweetID
                                              cursor:nil
                                        successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                                            XCTAssertTrue([ids isKindOfClass:[NSArray class]]);
                                            [expectation fulfill];
                                        } errorBlock:^(NSError *error) {
                                            validateError(error);
                                        }];
    }];
}

#pragma mark Search

- (void)testGetSearchTweets {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getSearchTweetsWithQuery:@"apple"
                                  geocode:nil
                                     lang:nil
                                   locale:nil
                               resultType:nil
                                    count:nil
                                    until:nil
                                  sinceID:nil
                                    maxID:nil
                          includeEntities:nil
                                 callback:nil
                             successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
                                 XCTAssertTrue([searchMetadata isKindOfClass:[NSDictionary  class]]);
                                 XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                 [expectation fulfill];
                             } errorBlock:^(NSError *error) {
                                 validateError(error);
                             }];
    }];
}

#pragma mark Streaming

- (void)testPostStatusesFilter {
/*
- (NSObject<STTwitterRequestProtocol> *)postStatusesFilterUserIDs:(NSArray *)userIDs
                                                  keywordsToTrack:(NSArray *)keywordsToTrack
                                            locationBoundingBoxes:(NSArray *)locationBoundingBoxes
                                                    stallWarnings:(NSNumber *)stallWarnings
                                                    progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testGetStatusesSample {
/*
- (NSObject<STTwitterRequestProtocol> *)getStatusesSampleStallWarnings:(NSNumber *)stallWarnings
                                                         progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testStatusesFirehose {
/*
- (NSObject<STTwitterRequestProtocol> *)getStatusesFirehoseWithCount:(NSString *)count
                                                       stallWarnings:(NSNumber *)stallWarnings
                                                       progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                          errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testUserStream {
/*
- (NSObject<STTwitterRequestProtocol> *)getUserStreamStallWarnings:(NSNumber *)stallWarnings
                               includeMessagesFromFollowedAccounts:(NSNumber *)includeMessagesFromFollowedAccounts
                                                    includeReplies:(NSNumber *)includeReplies
                                                   keywordsToTrack:(NSArray *)keywordsToTrack
                                             locationBoundingBoxes:(NSArray *)locationBoundingBoxes
                                                     progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testSiteStream {
/*
- (NSObject<STTwitterRequestProtocol> *)getSiteStreamForUserIDs:(NSArray *)userIDs
                                                      delimited:(NSNumber *)delimited
                                                  stallWarnings:(NSNumber *)stallWarnings
                                         restrictToUserMessages:(NSNumber *)restrictToUserMessages
                                                 includeReplies:(NSNumber *)includeReplies
                                                  progressBlock:(void(^)(NSDictionary *json, STTwitterStreamJSONType type))progressBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

#pragma mark Direct Messages

- (void)testGetDirectMessages {
/*
- (NSObject<STTwitterRequestProtocol> *)getDirectMessagesSinceID:(NSString *)sinceID
                                                           maxID:(NSString *)maxID
                                                           count:(NSString *)count
                                                 includeEntities:(NSNumber *)includeEntities
                                                      skipStatus:(NSNumber *)skipStatus
                                                    successBlock:(void(^)(NSArray *messages))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetDirectMessagesSent {
/*
- (NSObject<STTwitterRequestProtocol> *)getDirectMessagesSinceID:(NSString *)sinceID
                                                           maxID:(NSString *)maxID
                                                           count:(NSString *)count
                                                            page:(NSString *)page
                                                 includeEntities:(NSNumber *)includeEntities
                                                    successBlock:(void(^)(NSArray *messages))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetDirectMessagesShow {
/*
- (NSObject<STTwitterRequestProtocol> *)getDirectMessagesShowWithID:(NSString *)messageID
                                                       successBlock:(void(^)(NSArray *statuses))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostDestroyDirectMessage {
/*
- (NSObject<STTwitterRequestProtocol> *)postDestroyDirectMessageWithID:(NSString *)messageID
                                                       includeEntities:(NSNumber *)includeEntities
                                                          successBlock:(void(^)(NSDictionary *message))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostDirectMessage {
/*
- (NSObject<STTwitterRequestProtocol> *)postDirectMessage:(NSString *)status
                                            forScreenName:(NSString *)screenName
                                                 orUserID:(NSString *)userID
                                             successBlock:(void(^)(NSDictionary *message))successBlock
                                               errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

#pragma mark Friends & Followers

- (void)testGetFriendshipNoRetweetsIDs {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFriendshipNoRetweetsIDsWithSuccessBlock:^(NSArray *ids) {
            XCTAssertTrue([ids isKindOfClass:[NSArray class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetFriendsIDs {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFriendsIDsForUserID:nil
                           orScreenName:twitter.userName
                                 cursor:nil
                                  count:nil
                           successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                               XCTAssertTrue([ids isKindOfClass:[NSArray class]]);
                               [expectation fulfill];
                           } errorBlock:^(NSError *error) {
                               validateError(error);
                           }];
    }];
}

- (void)testGetFollowersIDs {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFollowersIDsForUserID:nil
                             orScreenName:twitter.userName
                                   cursor:nil
                                    count:nil
                             successBlock:^(NSArray *followersIDs, NSString *previousCursor, NSString *nextCursor) {
                                 XCTAssertTrue([followersIDs isKindOfClass:[NSArray class]]);
                                 [expectation fulfill];
                             } errorBlock:^(NSError *error) {
                                 validateError(error);
                             }];
    }];
}

- (void)testGetFriendshipsLookup {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFriendshipsLookupForScreenNames:nil
                                          orUserIDs:@[kTargetUserID]
                                       successBlock:^(NSArray *users) {
                                           XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                           [expectation fulfill];
                                       } errorBlock:^(NSError *error) {
                                           validateError(error);
                                       }];
    }];
}

- (void)testGetFriendshipIncoming {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFriendshipIncomingWithCursor:nil
                                    successBlock:^(NSArray *IDs, NSString *previousCursor, NSString *nextCursor) {
                                        XCTAssertTrue([IDs isKindOfClass:[NSArray class]]);
                                        [expectation fulfill];
                                    } errorBlock:^(NSError *error) {
                                        validateError(error);
                                    }];
    }];
}

- (void)testGetFriendshipOutgoing {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFriendshipOutgoingWithCursor:nil
                                    successBlock:^(NSArray *IDs, NSString *previousCursor, NSString *nextCursor) {
                                        XCTAssertTrue([IDs isKindOfClass:[NSArray class]]);
                                        [expectation fulfill];
                                    } errorBlock:^(NSError *error) {
                                        validateError(error);
                                    }];
    }];
}

- (void)testPostFriendshipsCreate {
/*
- (NSObject<STTwitterRequestProtocol> *)postFriendshipsCreateForScreenName:(NSString *)screenName
                                                                  orUserID:(NSString *)userID
                                                              successBlock:(void(^)(NSDictionary *befriendedUser))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostFriendshipsDestroy {
/*
- (NSObject<STTwitterRequestProtocol> *)postFriendshipsDestroyScreenName:(NSString *)screenName
                                                                orUserID:(NSString *)userID
                                                            successBlock:(void(^)(NSDictionary *unfollowedUser))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostFriendshipsUpdate {
/*
- (NSObject<STTwitterRequestProtocol> *)postFriendshipsUpdateForScreenName:(NSString *)screenName
                                                                  orUserID:(NSString *)userID
                                                 enableDeviceNotifications:(NSNumber *)enableDeviceNotifications
                                                            enableRetweets:(NSNumber *)enableRetweets
                                                              successBlock:(void(^)(NSDictionary *user))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetFriendshipShow {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFriendshipShowForSourceID:nil
                           orSourceScreenName:twitter.userName
                                     targetID:kTargetUserID
                           orTargetScreenName:nil
                                 successBlock:^(id relationship) {
                                     XCTAssertTrue([relationship isKindOfClass:[NSDictionary class]]);
                                     [expectation fulfill];
                                 } errorBlock:^(NSError *error) {
                                     validateError(error);
                                 }];
    }];
}

- (void)testGetFriendsList {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFriendsListForUserID:kTargetUserID
                            orScreenName:nil
                                  cursor:nil
                                   count:nil
                              skipStatus:nil
                     includeUserEntities:nil
                            successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                [expectation fulfill];
                            } errorBlock:^(NSError *error) {
                                validateError(error);
                            }];
    }];
}

- (void)testGetFollowersList {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFollowersListForUserID:kTargetUserID
                              orScreenName:nil
                                     count:nil
                                    cursor:nil
                                skipStatus:nil
                       includeUserEntities:nil
                              successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                  XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                  [expectation fulfill];
                              } errorBlock:^(NSError *error) {
                                  validateError(error);
                              }];
    }];
}

#pragma mark Users

- (void)testGetAccountSettings {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getAccountSettingsWithSuccessBlock:^(NSDictionary *settings) {
            XCTAssertTrue([settings isKindOfClass:[NSDictionary class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testPostAccountSettings {
/*
- (NSObject<STTwitterRequestProtocol> *)postAccountSettingsWithTrendLocationWOEID:(NSString *)trendLocationWOEID // eg. "1"
                                                                 sleepTimeEnabled:(NSNumber *)sleepTimeEnabled // eg. @(YES)
                                                                   startSleepTime:(NSString *)startSleepTime // eg. "13"
                                                                     endSleepTime:(NSString *)endSleepTime // eg. "13"
                                                                         timezone:(NSString *)timezone // eg. "Europe/Copenhagen", "Pacific/Tongatapu"
                                                                         language:(NSString *)language // eg. "it", "en", "es"
                                                                     successBlock:(void(^)(NSDictionary *settings))successBlock
                                                                       errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testPostAccountUpdate {
/*
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateDeliveryDeviceSMS:(BOOL)deliveryDeviceSMS
                                                           includeEntities:(NSNumber *)includeEntities
                                                              successBlock:(void(^)(NSDictionary *response))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostAccountUpdateProfile {
/*
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileWithName:(NSString *)name
                                                               URLString:(NSString *)URLString
                                                                location:(NSString *)location
                                                             description:(NSString *)description
                                                         includeEntities:(NSNumber *)includeEntities
                                                              skipStatus:(NSNumber *)skipStatus
                                                            successBlock:(void(^)(NSDictionary *profile))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostAccountUpdateProfileBackgroundImage {
/*
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileBackgroundImageWithImage:(NSString *)base64EncodedImage
                                                                                   title:(NSString *)title
                                                                         includeEntities:(NSNumber *)includeEntities
                                                                              skipStatus:(NSNumber *)skipStatus
                                                                                     use:(NSNumber *)use
                                                                            successBlock:(void(^)(NSDictionary *profile))successBlock
                                                                              errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostAccountUpdateProfileImage {
/*
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileImage:(NSString *)base64EncodedImage
                                                      includeEntities:(NSNumber *)includeEntities
                                                           skipStatus:(NSNumber *)skipStatus
                                                         successBlock:(void(^)(NSDictionary *profile))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetBlocksList {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getBlocksListWithincludeEntities:nil
                                       skipStatus:nil
                                           cursor:nil
                                     successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                         XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                         [expectation fulfill];
                                     } errorBlock:^(NSError *error) {
                                         validateError(error);
                                     }];
    }];
}

- (void)testGetBlocksIDs {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getBlocksIDsWithCursor:nil
                           successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
                               XCTAssertTrue([ids isKindOfClass:[NSArray class]]);
                               [expectation fulfill];
                           } errorBlock:^(NSError *error) {
                               validateError(error);
                           }];
    }];
}

- (void)testPostBlocksCreate {
/*
- (NSObject<STTwitterRequestProtocol> *)postBlocksCreateWithScreenName:(NSString *)screenName
                                                              orUserID:(NSString *)userID
                                                       includeEntities:(NSNumber *)includeEntities
                                                            skipStatus:(NSNumber *)skipStatus
                                                          successBlock:(void(^)(NSDictionary *user))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostBlocksDestroy {
/*
- (NSObject<STTwitterRequestProtocol> *)postBlocksDestroyWithScreenName:(NSString *)screenName
                                                               orUserID:(NSString *)userID
                                                        includeEntities:(NSNumber *)includeEntities
                                                             skipStatus:(NSNumber *)skipStatus
                                                           successBlock:(void(^)(NSDictionary *user))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetUsersLookup {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersLookupForScreenName:nil
                                    orUserID:kTargetUserID
                             includeEntities:nil
                                successBlock:^(NSArray *users) {
                                    XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                    [expectation fulfill];
                                } errorBlock:^(NSError *error) {
                                    validateError(error);
                                }];
    }];
}

- (void)testUsersShow {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersShowForUserID:nil
                          orScreenName:twitter.userName
                       includeEntities:nil
                          successBlock:^(NSDictionary *user) {
                              XCTAssertTrue([user isKindOfClass:[NSDictionary class]]);
                              [expectation fulfill];
                          } errorBlock:^(NSError *error) {
                              validateError(error);
                          }];
    }];
}

- (void)testGetUsersSearchQuery {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersSearchQuery:kTargetScreenName
                                page:nil
                               count:nil
                     includeEntities:nil
                        successBlock:^(NSArray *users) {
                            XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                            [expectation fulfill];
                        } errorBlock:^(NSError *error) {
                            validateError(error);
                        }];
    }];
}

- (void)testGetUsersContributees {

    /**
     *  Could not be used
     *
     *  [Normal consumer]
     *  Domain=STTwitterTwitterErrorDomain
     *  Code=220
     *  NSLocalizedDescription="Your credentials do not allow access to this resource"
     *
     *  [Official consumer]
     *  Domain=STTwitterTwitterErrorDomain 
     *  Code=87 
     *  NSLocalizedDescription="Client is not permitted to perform this action."
     */
#if 0
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersContributeesWithUserID:kTargetUserID
                                             orScreenName:nil
                                          includeEntities:nil
                                               skipStatus:nil
                                             successBlock:^(NSArray *contributees) {
                                                 XCTAssertTrue([contributees isKindOfClass:[NSArray class]]);
                                                 [expectation fulfill];
                                             } errorBlock:^(NSError *error) {
                                                 validateError(error);                                            }];
    }];
#endif
}

- (void)testGetUsersContributorsWithUserID {
    
    /**
     *  Could not be used
     *
     *  [Normal consumer]
     *  Domain=STTwitterTwitterErrorDomain
     *  Code=220
     *  NSLocalizedDescription="Your credentials do not allow access to this resource"
     *
     *  [Official consumer]
     *  Domain=STTwitterTwitterErrorDomain
     *  Code=87
     *  NSLocalizedDescription="Client is not permitted to perform this action."
     */
#if 0
    [self officialTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersContributorsWithUserID:kTargetUserID
                                   orScreenName:nil
                                includeEntities:nil
                                     skipStatus:nil
                                   successBlock:^(NSArray *contributors) {
                                       XCTAssertTrue([contributors isKindOfClass:[NSArray class]]);
                                       [expectation fulfill];
                                   } errorBlock:^(NSError *error) {
                                       validateError(error);
                                   }];
    }];
#endif
}

- (void)testPostAccountRemoveProfileBanner {
/*
- (NSObject<STTwitterRequestProtocol> *)postAccountRemoveProfileBannerWithSuccessBlock:(void(^)(id response))successBlock
                                                                            errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

- (void)testPostAccountUpdateProfileBanner {
/*
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileBannerWithImage:(NSString *)base64encodedImage
                                                                          width:(NSString *)width
                                                                         height:(NSString *)height
                                                                     offsetLeft:(NSString *)offsetLeft
                                                                      offsetTop:(NSString *)offsetTop
                                                                   successBlock:(void(^)(id response))successBlock
                                                                     errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetUsersProfileBanner {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersProfileBannerForUserID:kTargetUserID
                                   orScreenName:nil
                                   successBlock:^(NSDictionary *banner) {
                                       XCTAssertTrue([banner isKindOfClass:[NSDictionary class]]);
                                       [expectation fulfill];
                                   } errorBlock:^(NSError *error) {
                                       validateError(error);
                                   }];
    }];
}

- (void)testPostMutesUsersCreate {
/*
- (NSObject<STTwitterRequestProtocol> *)postMutesUsersCreateForScreenName:(NSString *)screenName
                                                                 orUserID:(NSString *)userID
                                                             successBlock:(void(^)(NSDictionary *user))successBlock
                                                               errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetMutesUsersIDsWithCursor {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getMutesUsersIDsWithCursor:nil
                               successBlock:^(NSArray *userIDs, NSString *previousCursor, NSString *nextCursor) {
                                   XCTAssertTrue([userIDs isKindOfClass:[NSArray class]]);
                                   [expectation fulfill];
                               } errorBlock:^(NSError *error) {
                                   validateError(error);
                               }];
    }];
}

- (void)testGetMutesUsersListWithCursor {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getMutesUsersListWithCursor:nil
                             includeEntities:nil
                                  skipStatus:nil
                                successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                    XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                    [expectation fulfill];
                                } errorBlock:^(NSError *error) {
                                    validateError(error);
                                }];
    }];
}

#pragma mark Suggested Users

- (void)testGetUsersSuggestions {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersSuggestionsForSlug:@"twitter"
                                       lang:nil
                               successBlock:^(NSString *name, NSString *slug, NSArray *users) {
                                   XCTAssertNotNil(name);
                                   XCTAssertNotNil(slug);
                                   XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                   [expectation fulfill];
                               } errorBlock:^(NSError *error) {
                                   validateError(error);
                               }];
    }];
}

- (void)testGetUsersSuggestionsWithLanguageCode {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersSuggestionsWithISO6391LanguageCode:nil
                                               successBlock:^(NSArray *suggestions) {
                                                   XCTAssertTrue([suggestions isKindOfClass:[NSArray class]]);
                                                   [expectation fulfill];
                                               } errorBlock:^(NSError *error) {
                                                   validateError(error);
                                               }];
    }];
}

- (void)testGetUsersSuggestionsForSlugMembers {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getUsersSuggestionsForSlugMembers:@"twitter"
                                      successBlock:^(NSArray *members) {
                                          XCTAssertTrue([members isKindOfClass:[NSArray class]]);
                                          [expectation fulfill];
                                      } errorBlock:^(NSError *error) {
                                          validateError(error);
                                      }];
    }];
}

#pragma mark Favorites

- (void)testGetFavoritesList {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getFavoritesListWithUserID:kTargetUserID
                               orScreenName:nil
                                      count:nil
                                    sinceID:nil
                                      maxID:nil
                            includeEntities:nil
                               successBlock:^(NSArray *statuses) {
                                   XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                   [expectation fulfill];
                               } errorBlock:^(NSError *error) {
                                   validateError(error);
                               }];
    }];
}

- (void)testPostFavoriteDestroy {
/*
- (NSObject<STTwitterRequestProtocol> *)postFavoriteDestroyWithStatusID:(NSString *)statusID
                                                        includeEntities:(NSNumber *)includeEntities
                                                           successBlock:(void(^)(NSDictionary *status))successBlock
                                                             errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostFavoriteCreate {
/*
- (NSObject<STTwitterRequestProtocol> *)postFavoriteCreateWithStatusID:(NSString *)statusID
                                                       includeEntities:(NSNumber *)includeEntities
                                                          successBlock:(void(^)(NSDictionary *status))successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

#pragma mark Lists

- (void)testGetListsStatusesForListID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsStatusesForListID:kListID
                                   sinceID:nil
                                     maxID:nil
                                     count:nil
                           includeEntities:nil
                           includeRetweets:nil
                              successBlock:^(NSArray *statuses) {
                                  XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                  [expectation fulfill];
                              } errorBlock:^(NSError *error) {
                                  validateError(error);
                              }];
    }];
}

- (void)testGetListsStatusesForSlug {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsStatusesForSlug:kListSlug
                              screenName:nil
                                 ownerID:kListOwnerID
                                 sinceID:nil
                                   maxID:nil
                                   count:nil
                         includeEntities:nil
                         includeRetweets:nil
                            successBlock:^(NSArray *statuses) {
                                XCTAssertTrue([statuses isKindOfClass:[NSArray class]]);
                                [expectation fulfill];
                            } errorBlock:^(NSError *error) {
                                validateError(error);
                            }];
    }];
}

- (void)testPostListsMembersDestroyForListID {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsMembersDestroyForListID:(NSString *)listID
                                                            successBlock:(void(^)(id response))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsMembersDestroyForSlug {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsMembersDestroyForSlug:(NSString *)slug
                                                                userID:(NSString *)userID
                                                            screenName:(NSString *)screenName
                                                       ownerScreenName:(NSString *)ownerScreenName
                                                               ownerID:(NSString *)ownerID
                                                          successBlock:(void(^)())successBlock
                                                            errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetListsMemberships {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsMembershipsForUserID:kTargetUserID
                                 orScreenName:nil
                                       cursor:nil
                           filterToOwnedLists:nil
                                 successBlock:^(NSArray *lists, NSString *previousCursor, NSString *nextCursor) {
                                     XCTAssertTrue([lists isKindOfClass:[NSArray class]]);
                                     [expectation fulfill];
                                 } errorBlock:^(NSError *error) {
                                     validateError(error);
                                 }];
    }];
}

- (void)testGetListsSubscribersForSlug {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsSubscribersForSlug:kListSlug
                            ownerScreenName:nil
                                  orOwnerID:kListOwnerID
                                     cursor:nil
                            includeEntities:nil
                                 skipStatus:nil
                               successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                   XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                   [expectation fulfill];
                               } errorBlock:^(NSError *error) {
                                   validateError(error);
                               }];
    }];
}

- (void)testGetListsSubscribersForListID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsSubscribersForListID:kListID
                                       cursor:nil
                              includeEntities:nil
                                   skipStatus:nil
                                 successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                     XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                     [expectation fulfill];
                                 } errorBlock:^(NSError *error) {
                                     validateError(error);
                                 }];
    }];
}

- (void)testPostListSubscribersCreateForListID {
/*
- (NSObject<STTwitterRequestProtocol> *)postListSubscribersCreateForListID:(NSString *)listID
                                                              successBlock:(void(^)(id response))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListSubscribersCreateForSlug {
/*
- (NSObject<STTwitterRequestProtocol> *)postListSubscribersCreateForSlug:(NSString *)slug
                                                         ownerScreenName:(NSString *)ownerScreenName
                                                               orOwnerID:(NSString *)ownerID
                                                            successBlock:(void(^)(id response))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetListsSubscribersShowForListID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsSubscribersShowForListID:kListID
                                           userID:kListUserID
                                     orScreenName:nil
                                  includeEntities:nil
                                       skipStatus:nil
                                     successBlock:^(id response) {
                                         XCTAssertTrue([response isKindOfClass:[NSDictionary class]]);
                                         [expectation fulfill];
                                     } errorBlock:^(NSError *error) {
                                         validateError(error);
                                     }];
    }];
}

- (void)testGetListsSubscribersShowForSlug {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsSubscribersShowForSlug:kListSlug
                                ownerScreenName:nil
                                      orOwnerID:kListOwnerID
                                         userID:kListUserID
                                   orScreenName:nil
                                includeEntities:nil
                                     skipStatus:nil
                                   successBlock:^(id response) {
//                                       XCTAssertTrue([<#__#> isKindOfClass:[<#__#> class]]);
                                       [expectation fulfill];
                                   } errorBlock:^(NSError *error) {
                                       validateError(error);
                                   }];
    }];
}

- (void)testPostListSubscribersDestroyForListID {
/*
- (NSObject<STTwitterRequestProtocol> *)postListSubscribersDestroyForListID:(NSString *)listID
                                                               successBlock:(void(^)(id response))successBlock
                                                                 errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListSubscribersDestroyForSlug {
/*
- (NSObject<STTwitterRequestProtocol> *)postListSubscribersDestroyForSlug:(NSString *)slug
                                                          ownerScreenName:(NSString *)ownerScreenName
                                                                orOwnerID:(NSString *)ownerID
                                                             successBlock:(void(^)(id response))successBlock
                                                               errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsMembersCreateAllForListID {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsMembersCreateAllForListID:(NSString *)listID
                                                                   userIDs:(NSArray *)userIDs // array of strings
                                                             orScreenNames:(NSArray *)screenNames // array of strings
                                                              successBlock:(void(^)(id response))successBlock
                                                                errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsMembersCreateAllForSlug {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsMembersCreateAllForSlug:(NSString *)slug
                                                         ownerScreenName:(NSString *)ownerScreenName
                                                               orOwnerID:(NSString *)ownerID
                                                                 userIDs:(NSArray *)userIDs // array of strings
                                                           orScreenNames:(NSArray *)screenNames // array of strings
                                                            successBlock:(void(^)(id response))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetListsMembersShowForListID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsMembersShowForListID:kListID
                                       userID:kListUserID
                                   screenName:nil
                              includeEntities:nil
                                   skipStatus:nil
                                 successBlock:^(NSDictionary *user) {
                                     XCTAssertTrue([user isKindOfClass:[NSDictionary class]]);
                                     [expectation fulfill];
                                 } errorBlock:^(NSError *error) {
                                     validateError(error);
                                 }];
    }];
}

- (void)testGetListsMembersShowForSlug {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsMembersShowForSlug:kListSlug
                            ownerScreenName:nil
                                  orOwnerID:kListOwnerID
                                     userID:kListUserID
                                 screenName:nil
                            includeEntities:nil
                                 skipStatus:nil
                               successBlock:^(NSDictionary *user) {
                                   XCTAssertTrue([user isKindOfClass:[NSDictionary class]]);
                                   [expectation fulfill];
                               } errorBlock:^(NSError *error) {
                                   validateError(error);
                               }];
    }];
}

- (void)testGetListsMembersForListID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsMembersForListID:kListID
                                   cursor:nil
                                    count:nil
                          includeEntities:nil
                               skipStatus:nil
                             successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                 XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                                 [expectation fulfill];
                             } errorBlock:^(NSError *error) {
                                 validateError(error);
                             }];
    }];
}

- (void)testGetListsMembersForSlug {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsMembersForSlug:kListSlug
                        ownerScreenName:nil
                              orOwnerID:kListOwnerID
                                 cursor:nil
                                  count:nil
                        includeEntities:nil
                             skipStatus:nil
                           successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                               XCTAssertTrue([users isKindOfClass:[NSArray class]]);
                               [expectation fulfill];
                           } errorBlock:^(NSError *error) {
                               validateError(error);
                           }];
    }];
}

- (void)testPostListMemberCreateForListID {
/*
- (NSObject<STTwitterRequestProtocol> *)postListMemberCreateForListID:(NSString *)listID
                                                               userID:(NSString *)userID
                                                           screenName:(NSString *)screenName
                                                         successBlock:(void(^)(id response))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListMemberCreateForSlug {
/*
- (NSObject<STTwitterRequestProtocol> *)postListMemberCreateForSlug:(NSString *)slug
                                                    ownerScreenName:(NSString *)ownerScreenName
                                                          orOwnerID:(NSString *)ownerID
                                                             userID:(NSString *)userID
                                                         screenName:(NSString *)screenName
                                                       successBlock:(void(^)(id response))successBlock
                                                         errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsDestroyForListID {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsDestroyForListID:(NSString *)listID
                                                     successBlock:(void(^)(id response))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsDestroyForSlug {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsDestroyForSlug:(NSString *)slug
                                                ownerScreenName:(NSString *)ownerScreenName
                                                      orOwnerID:(NSString *)ownerID
                                                   successBlock:(void(^)(id response))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsUpdateForListID {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsUpdateForListID:(NSString *)listID
                                                            name:(NSString *)name
                                                       isPrivate:(BOOL)isPrivate
                                                     description:(NSString *)description
                                                    successBlock:(void(^)(id response))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsUpdateForSlug {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsUpdateForSlug:(NSString *)slug
                                               ownerScreenName:(NSString *)ownerScreenName
                                                     orOwnerID:(NSString *)ownerID
                                                          name:(NSString *)name
                                                     isPrivate:(BOOL)isPrivate
                                                   description:(NSString *)description
                                                  successBlock:(void(^)(id response))successBlock
                                                    errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsCreateWithName {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsCreateWithName:(NSString *)name
                                                      isPrivate:(BOOL)isPrivate
                                                    description:(NSString *)description
                                                   successBlock:(void(^)(NSDictionary *list))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetListsShowListID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsShowListID:kListID
                       successBlock:^(NSDictionary *list) {
                           XCTAssertTrue([list isKindOfClass:[NSDictionary class]]);
                           [expectation fulfill];
                       } errorBlock:^(NSError *error) {
                           validateError(error);
                       }];
    }];
}

- (void)testGetListsShowListSlug {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsShowListSlug:kListSlug
                      ownerScreenName:nil
                            orOwnerID:kListOwnerID
                         successBlock:^(NSDictionary *list) {
                             XCTAssertTrue([list isKindOfClass:[NSDictionary class]]);
                             [expectation fulfill];
                         } errorBlock:^(NSError *error) {
                             validateError(error);
                         }];
    }];
}

- (void)testGetListsSubscriptionsForUserID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsSubscriptionsForUserID:kListUserID
                                   orScreenName:nil
                                          count:nil
                                         cursor:nil
                                   successBlock:^(NSArray *lists, NSString *previousCursor, NSString *nextCursor) {
                                       XCTAssertTrue([lists isKindOfClass:[NSArray class]]);
                                       [expectation fulfill];
                                   } errorBlock:^(NSError *error) {
                                       validateError(error);
                                   }];
    }];
}

- (void)testPostListsMembersDestroyAllForListID {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsMembersDestroyAllForListID:(NSString *)listID
                                                                    userIDs:(NSArray *)userIDs // array of strings
                                                              orScreenNames:(NSArray *)screenNames // array of strings
                                                               successBlock:(void(^)(id response))successBlock
                                                                 errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostListsMembersDestroyAllForSlug {
/*
- (NSObject<STTwitterRequestProtocol> *)postListsMembersDestroyAllForSlug:(NSString *)slug
                                                          ownerScreenName:(NSString *)ownerScreenName
                                                                orOwnerID:(NSString *)ownerID
                                                                  userIDs:(NSArray *)userIDs // array of strings
                                                            orScreenNames:(NSArray *)screenNames // array of strings
                                                             successBlock:(void(^)(id response))successBlock
                                                               errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testGetListsOwnershipsForUserID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getListsOwnershipsForUserID:kListUserID
                                orScreenName:nil
                                       count:nil
                                      cursor:nil
                                successBlock:^(NSArray *lists, NSString *previousCursor, NSString *nextCursor) {
                                    XCTAssertTrue([lists isKindOfClass:[NSArray class]]);
                                    [expectation fulfill];
                                } errorBlock:^(NSError *error) {
                                    validateError(error);
                                }];
    }];
}

#pragma mark Saved Searches

- (void)testGetSavedSearchesList {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getSavedSearchesListWithSuccessBlock:^(NSArray *savedSearches) {
            XCTAssertTrue([savedSearches isKindOfClass:[NSArray class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetSavedSearchesShow {
    
#if 0
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getSavedSearchesShow:@""
                         successBlock:^(NSDictionary *savedSearch) {
                             XCTAssertTrue([savedSearch isKindOfClass:[NSDictionary class]]);
                             [expectation fulfill];
                         } errorBlock:^(NSError *error) {
                             validateError(error);
                         }];
    }];
#endif
}

- (void)testPostSavedSearchesCreateWithQuery {
/*
- (NSObject<STTwitterRequestProtocol> *)postSavedSearchesCreateWithQuery:(NSString *)query
                                                            successBlock:(void(^)(NSDictionary *createdSearch))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostSavedSearchesDestroy {
/*
- (NSObject<STTwitterRequestProtocol> *)postSavedSearchesDestroy:(NSString *)savedSearchID
                                                    successBlock:(void(^)(NSDictionary *destroyedSearch))successBlock
                                                      errorBlock:(void(^)(NSError *error))errorBlock;
 */
}

#pragma mark Places & Geo

- (void)testGetGeoID {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getGeoIDForPlaceID:kPlaceID
                       successBlock:^(NSDictionary *place) {
                           XCTAssertTrue([place isKindOfClass:[NSDictionary class]]);
                           [expectation fulfill];
                       } errorBlock:^(NSError *error) {
                           validateError(error);
                       }];
    }];
}

- (void)testgetGeoReverseGeocode {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getGeoReverseGeocodeWithLatitude:kLatitude
                                        longitude:kLongitude
                                         accuracy:nil
                                      granularity:nil
                                       maxResults:nil
                                         callback:nil
                                     successBlock:^(NSDictionary *query, NSDictionary *result) {
                                         XCTAssertTrue([query isKindOfClass:[NSDictionary class]]);
                                         XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
                                         [expectation fulfill];
                                     } errorBlock:^(NSError *error) {
                                         validateError(error);
                                     }];
    }];
}

- (void)testGetGeoSearch {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getGeoSearchWithLatitude:kLatitude
                                longitude:kLongitude
                                    query:nil
                                ipAddress:nil
                              granularity:nil
                                 accuracy:nil
                               maxResults:nil
                  placeIDContaintedWithin:nil
                   attributeStreetAddress:nil
                                 callback:nil
                             successBlock:^(NSDictionary *query, NSDictionary *result) {
                                 XCTAssertTrue([query isKindOfClass:[NSDictionary class]]);
                                 XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
                                 [expectation fulfill];
                             } errorBlock:^(NSError *error) {
                                 validateError(error);
                             }];
    }];
}

- (void)testGetGeoSimilarPlaces {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getGeoSimilarPlacesToLatitude:kLatitude
                                     longitude:kLongitude
                                          name:@"Twitter HQ"
                       placeIDContaintedWithin:nil
                        attributeStreetAddress:nil
                                      callback:nil
                                  successBlock:^(NSDictionary *query, NSArray *resultPlaces, NSString *resultToken) {
                                      XCTAssertTrue([query isKindOfClass:[NSDictionary class]]);
                                      XCTAssertTrue([resultPlaces isKindOfClass:[NSArray class]]);
                                      [expectation fulfill];
                                  } errorBlock:^(NSError *error) {
                                      validateError(error);
                                  }];
    }];
}

#pragma mark Trends

- (void)testGetTrends {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getTrendsForWOEID:@"1" // https://developer.yahoo.com/geo/geoplanet/
                   excludeHashtags:nil
                      successBlock:^(NSDate *asOf, NSDate *createdAt, NSArray *locations, NSArray *trends) {
                          XCTAssertTrue([asOf isKindOfClass:[NSDate class]]);
                          XCTAssertTrue([createdAt isKindOfClass:[NSDate class]]);
                          XCTAssertTrue([locations isKindOfClass:[NSArray class]]);
                          XCTAssertTrue([trends isKindOfClass:[NSArray class]]);
                          [expectation fulfill];
                      } errorBlock:^(NSError *error) {
                          validateError(error);
                      }];
    }];
}

- (void)testGetTrendsAvailable {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getTrendsAvailableWithSuccessBlock:^(NSArray *locations) {
            XCTAssertTrue([locations isKindOfClass:[NSArray class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetTrendsClosest {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getTrendsClosestToLatitude:kLatitude
                                  longitude:kLongitude
                               successBlock:^(NSArray *locations) {
                                   XCTAssertTrue([locations isKindOfClass:[NSArray class]]);
                                   [expectation fulfill];
                               } errorBlock:^(NSError *error) {
                                   validateError(error);
                               }];
    }];
}

#pragma mark Spam Reporting

- (void)testPostUsersReportSpam {
/*
- (NSObject<STTwitterRequestProtocol> *)postUsersReportSpamForScreenName:(NSString *)screenName
                                                                orUserID:(NSString *)userID
                                                            successBlock:(void(^)(id userProfile))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;

*/
}

#pragma mark OAuth

#pragma mark Help

- (void)testGetHelpConfiguration {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getHelpConfigurationWithSuccessBlock:^(NSDictionary *currentConfiguration) {
            XCTAssertTrue([currentConfiguration isKindOfClass:[NSDictionary class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetHelpLanguages {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getHelpLanguagesWithSuccessBlock:^(NSArray *languages) {
            XCTAssertTrue([languages isKindOfClass:[NSArray class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetHelpPrivacy {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getHelpPrivacyWithSuccessBlock:^(NSString *privacy) {
            XCTAssertTrue([privacy isKindOfClass:[NSString class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

- (void)testGetHelpTermsOfService {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getHelpTermsOfServiceWithSuccessBlock:^(NSString *tos) {
            XCTAssertTrue([tos isKindOfClass:[NSString class]]);
            [expectation fulfill];
        } errorBlock:^(NSError *error) {
            validateError(error);
        }];
    }];
}

#pragma mark Tweets

- (void)testGetStatusesLookup {
    
    [self enumurateAllTwitterUsingBlock:^(STTwitterAPI *twitter, XCTestExpectation *expectation) {
        [twitter getStatusesLookupTweetIDs:@[kTargetTweetID]
                           includeEntities:nil
                                  trimUser:nil
                                       map:nil
                              successBlock:^(NSArray *tweets) {
                                  XCTAssertTrue([tweets isKindOfClass:[NSArray class]]);
                                  [expectation fulfill];
                              } errorBlock:^(NSError *error) {
                                  validateError(error);
                              }];
    }];
}

#pragma mark Media

- (void)testPostMediaUpload {
/*
- (NSObject<STTwitterRequestProtocol> *)postMediaUpload:(NSURL *)mediaURL
                                    uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                           successBlock:(void(^)(NSDictionary *imageDictionary, NSString *mediaID, NSString *size))successBlock
                                             errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

- (void)testPostMediaUploadData {
/*
- (NSObject<STTwitterRequestProtocol> *)postMediaUploadData:(NSData *)data
                                                   fileName:(NSString *)fileName
                                        uploadProgressBlock:(void(^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgressBlock
                                               successBlock:(void(^)(NSDictionary *imageDictionary, NSString *mediaID, NSString *size))successBlock
                                                 errorBlock:(void(^)(NSError *error))errorBlock;
*/
}

#pragma mark - Utility

- (void)enumurateAllTwitterUsingBlock:(void(^)(STTwitterAPI *twitter, XCTestExpectation *expectation))block {
    
    for (NSUInteger i = 0; i < 2; i++) {
        STTwitterAPI *twitter;
        switch (i) {
            case 0:
                twitter = __twitter;
                break;
            case 1:
                twitter = __twitterOS;
                break;
            default:
                XCTFail(@"Unsupported case(%zd)", i);
                break;
        }
        
        if (twitter) {
            XCTestExpectation *expectation = [self expectationWithDescription:nil];
            block(twitter, expectation);
            [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
        }
    }
}

@end
