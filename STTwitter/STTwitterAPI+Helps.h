//
//  STTwitterAPI+Helps.h
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (Helps)

#pragma mark Help

/*
 GET    help/configuration
 
 Returns the current configuration used by Twitter including twitter.com slugs which are not usernames, maximum photo resolutions, and t.co URL lengths.
 
 It is recommended applications request this endpoint when they are loaded, but no more than once a day.
 */

- (void)getHelpConfigurationWithSuccessBlock:(void(^)(NSDictionary *currentConfiguration))successBlock
                                  errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    help/languages
 
 Returns the list of languages supported by Twitter along with their ISO 639-1 code. The ISO 639-1 code is the two letter value to use if you include lang with any of your requests.
 */

- (void)getHelpLanguagesWithSuccessBlock:(void(^)(NSArray *languages))successBlock
                              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    help/privacy
 
 Returns Twitter's Privacy Policy.
 */

- (void)getHelpPrivacyWithSuccessBlock:(void(^)(NSString *privacy))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    help/tos
 
 Returns the Twitter Terms of Service in the requested format. These are not the same as the Developer Rules of the Road.
 */

- (void)getHelpTermsOfServiceWithSuccessBlock:(void(^)(NSString *tos))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    application/rate_limit_status
 
 Returns the current rate limits for methods belonging to the specified resource families.
 
 Each 1.1 API resource belongs to a "resource family" which is indicated in its method documentation. You can typically determine a method's resource family from the first component of the path after the resource version.
 
 This method responds with a map of methods belonging to the families specified by the resources parameter, the current remaining uses for each of those resources within the current rate limiting window, and its expiration time in epoch time. It also includes a rate_limit_context field that indicates the current access token or application-only authentication context.
 
 You may also issue requests to this method without any parameters to receive a map of all rate limited GET methods. If your application only uses a few of methods, please explicitly provide a resources parameter with the specified resource families you work with.
 
 When using app-only auth, this method's response indicates the app-only auth rate limiting context.
 
 Read more about REST API Rate Limiting in v1.1 and review the limits.
 */

- (void)getRateLimitsForResources:(NSArray *)resources // eg. statuses,friends,trends,help
					 successBlock:(void(^)(NSDictionary *rateLimits))successBlock
					   errorBlock:(void(^)(NSError *error))errorBlock;

@end
