//
//  STTwitterAPI+Helps.m
//  STTwitterDemoIOS
//
//  Created by Jerome Morissard on 5/2/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI+Helps.h"

@implementation STTwitterAPI (Helps)

#pragma mark Help

// GET help/configuration
- (void)getHelpConfigurationWithSuccessBlock:(void(^)(NSDictionary *currentConfiguration))successBlock
                                  errorBlock:(void(^)(NSError *error))errorBlock {
    [self getAPIResource:@"help/configuration.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET help/languages
- (void)getHelpLanguagesWithSuccessBlock:(void (^)(NSArray *languages))successBlock
                              errorBlock:(void (^)(NSError *))errorBlock {
    [self getAPIResource:@"help/languages.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET help/privacy
- (void)getHelpPrivacyWithSuccessBlock:(void(^)(NSString *tos))successBlock
                            errorBlock:(void(^)(NSError *error))errorBlock {
    [self getAPIResource:@"help/privacy.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock([response valueForKey:@"privacy"]);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET help/tos
- (void)getHelpTermsOfServiceWithSuccessBlock:(void(^)(NSString *tos))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock {
    [self getAPIResource:@"help/tos.json" parameters:nil successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock([response valueForKey:@"tos"]);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

// GET application/rate_limit_status
- (void)getRateLimitsForResources:(NSArray *)resources // eg. statuses,friends,trends,help
                     successBlock:(void(^)(NSDictionary *rateLimits))successBlock
                       errorBlock:(void(^)(NSError *error))errorBlock {
    NSDictionary *d = nil;
    if (resources)
        d = @{ @"resources" : [resources componentsJoinedByString:@","] };
    [self getAPIResource:@"application/rate_limit_status.json" parameters:d successBlock:^(NSDictionary *rateLimits, id response) {
        successBlock(response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

@end
