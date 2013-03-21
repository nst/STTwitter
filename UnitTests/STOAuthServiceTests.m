//
//  STOAuthServiceTests.m
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/5/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import "STOAuthServiceTests.h"
#import "STTwitterOAuth.h"
#import "STTwitterAppOnly.h"

#import "STHTTPRequestTestResponse.h"
#import "STHTTPRequestTestResponseQueue.h"

@interface STTwitterOAuth (Tests)

@property (nonatomic, retain) NSString *testOauthNonce;
@property (nonatomic, retain) NSString *testOauthTimestamp;

+ (NSString *)oauthHeaderValueWithParameters:(NSArray *)parameters;
+ (NSString *)signatureBaseStringWithHTTPMethod:(NSString *)httpMethod url:(NSURL *)url allParametersUnsorted:(NSArray *)parameters;
+ (NSString *)oauthSignatureWithHTTPMethod:(NSString *)httpMethod url:(NSURL *)url parameters:(NSArray *)parameters consumerSecret:(NSString *)consumerSecret tokenSecret:(NSString *)tokenSecret;

@end

@implementation STOAuthServiceTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testURLEncodedString {
    NSString *s1 = @"\"<>\%{}[]|\\^`hello #";
    STAssertEqualObjects([s1 urlEncodedString], @"\%22\%3C\%3E\%25\%7B\%7D\%5B\%5D\%7C\%5C\%5E\%60hello\%20\%23", @"s1 was not encoded properly.");
    
    NSString *s2 = @"☃";
    STAssertEqualObjects([s2 urlEncodedString], @"%E2%98%83", @"s2 was not encoded properly.");
    
    NSString *s3 = @"!*'();:@&=+$,/?%#[];/?:@&=$+{}<>,";
    STAssertEqualObjects([s3 urlEncodedString], @"%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D%3B%2F%3F%3A%40%26%3D%24%2B%7B%7D%3C%3E%2C", @"s3 was not encoded properly.");
}

- (void)testAuthorizationHeader {
    
    // https://dev.twitter.com/docs/auth/authorizing-request
    
    NSArray *parameters = @[@{@"oauth_consumer_key"     : @"xvz1evFS4wEEPTGEFPHBog"},
    @{@"oauth_nonce"            : @"kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"},
    @{@"oauth_signature"        : @"tnnArxj06cWHq44gCs1OSKk/jLY="},
    @{@"oauth_signature_method" : @"HMAC-SHA1"},
    @{@"oauth_timestamp"        : @"1318622958"},
    @{@"oauth_token"            : @"370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb"},
    @{@"oauth_version"          : @"1.0"}];
    
    NSString *s1 = [STTwitterOAuth oauthHeaderValueWithParameters:parameters];
    
    NSString *s2 = @"OAuth oauth_consumer_key=\"xvz1evFS4wEEPTGEFPHBog\", oauth_nonce=\"kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg\", oauth_signature=\"tnnArxj06cWHq44gCs1OSKk%2FjLY%3D\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"1318622958\", oauth_token=\"370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb\", oauth_version=\"1.0\"";
    
    STAssertEqualObjects(s1, s2, @"");
}

- (void)testBaseString {
    
    // http://oauth.net/core/1.0/ A.5.1
    
    NSArray *allParamsUnsorted = [NSArray arrayWithObjects:
                                  @{@"file" : @"vacation.jpg"},
                                  @{@"size" : @"original"},
                                  @{@"oauth_consumer_key" : @"dpf43f3p2l4k3l03"},
                                  @{@"oauth_token" : @"nnch734d00sl2jdk"},
                                  @{@"oauth_signature_method" : @"HMAC-SHA1"},
                                  @{@"oauth_timestamp" : @"1191242096"},
                                  @{@"oauth_nonce" : @"kllo9940pd9333jh"},
                                  @{@"oauth_version" : @"1.0"}, nil];
    
    NSURL *url = [NSURL URLWithString:@"http://photos.example.net/photos?file=vacation.jpg&size=original"];
    
    NSString *baseString = [STTwitterOAuth signatureBaseStringWithHTTPMethod:@"GET" url:url allParametersUnsorted:allParamsUnsorted];
    
    NSString *expectedBaseString = @"GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal";
    
    STAssertEqualObjects(baseString,expectedBaseString, @"bad signature");
}

- (void)testSignatureValue {
    
    // http://oauth.net/core/1.0/ A.5.2
    
    NSString *baseString = @"GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal";
    
    NSString *signature = [baseString signHmacSHA1WithKey:@"kd94hf93k423kf44&pfkkdhi9sl3r4s00"];
    
    STAssertEqualObjects(@"tR3+Ty81lMeYAr/Fid0kMTYa/WM=", signature, @"bad signature");
}

- (void)testGeoSearchBaseString {

    NSArray *allParamsUnsorted = [NSArray arrayWithObjects:
                                  @{@"query" : @"Toronto"},
                                  @{@"oauth_consumer_key" : @"30d7ECqcJDGx8pBEMqxCxg"},
                                  @{@"oauth_token" : @"15111995-XFRb1CWIy4YLtr82nxPULkEKxKn5Cvh88Qkrtxni8"},
                                  @{@"oauth_signature_method" : @"HMAC-SHA1"},
                                  @{@"oauth_timestamp" : @"1351964056"},
                                  @{@"oauth_nonce" : @"ea95faa8097f4aeca24f77be0b6923a1"},
                                  @{@"oauth_version" : @"1.0"}, nil];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/geo/search.json?query=Toronto"];
    
    NSString *baseString = [STTwitterOAuth signatureBaseStringWithHTTPMethod:@"GET" url:url allParametersUnsorted:allParamsUnsorted];
    
    NSString *expectedBaseString = @"GET&https%3A%2F%2Fapi.twitter.com%2F1.1%2Fgeo%2Fsearch.json&oauth_consumer_key%3D30d7ECqcJDGx8pBEMqxCxg%26oauth_nonce%3Dea95faa8097f4aeca24f77be0b6923a1%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1351964056%26oauth_token%3D15111995-XFRb1CWIy4YLtr82nxPULkEKxKn5Cvh88Qkrtxni8%26oauth_version%3D1.0%26query%3DToronto";
    
    STAssertEqualObjects(baseString, expectedBaseString, @"bad signature");
}

- (void)testGeoSearchSignature {
    
    NSString *baseString = @"GET&https%3A%2F%2Fapi.twitter.com%2F1.1%2Fgeo%2Fsearch.json&oauth_consumer_key%3D30d7ECqcJDGx8pBEMqxCxg%26oauth_nonce%3Dea95faa8097f4aeca24f77be0b6923a1%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1351964056%26oauth_token%3D15111995-XFRb1CWIy4YLtr82nxPULkEKxKn5Cvh88Qkrtxni8%26oauth_version%3D1.0%26query%3DToronto";
    
    NSString *signature = [baseString signHmacSHA1WithKey:@"N5YupBKlcE75i7HbeqkocCKiNk418bjQTIHCRKaX4&iwKhgvXo3AJ6O61OqvEwgZJzw8jte0kwl09Twe3ik8"];
    
    STAssertEqualObjects(@"eMPFYN/QqvrbQISuKOiq2I9vQpk=", signature, @"bad signature");
}

- (void)testGeoSearchAuthorizationHeader {
    
    NSArray *parameters = @[@{@"oauth_consumer_key"     : @"30d7ECqcJDGx8pBEMqxCxg"},
    @{@"oauth_nonce"            : @"ea95faa8097f4aeca24f77be0b6923a1"},
    @{@"oauth_signature"        : @"eMPFYN/QqvrbQISuKOiq2I9vQpk="},
    @{@"oauth_signature_method" : @"HMAC-SHA1"},
    @{@"oauth_timestamp"        : @"1351964056"},
    @{@"oauth_token"            : @"15111995-XFRb1CWIy4YLtr82nxPULkEKxKn5Cvh88Qkrtxni8"},
    @{@"oauth_version"          : @"1.0"}];
    
    NSString *s1 = [STTwitterOAuth oauthHeaderValueWithParameters:parameters];
    
    NSString *s2 = @"OAuth oauth_consumer_key=\"30d7ECqcJDGx8pBEMqxCxg\", oauth_nonce=\"ea95faa8097f4aeca24f77be0b6923a1\", oauth_signature=\"eMPFYN%2FQqvrbQISuKOiq2I9vQpk%3D\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"1351964056\", oauth_token=\"15111995-XFRb1CWIy4YLtr82nxPULkEKxKn5Cvh88Qkrtxni8\", oauth_version=\"1.0\"";
    
    STAssertEqualObjects(s1, s2, @"");
}

//- (void)testSignatureValue2 {
//
//    // http://code.google.com/p/twitter-api/issues/detail?id=433
//
//    NSString *baseString = @"POST&http%3A%2F%2Ftwitter.com%2Fstatuses%2Fupdate.json&oauth_consumer_key%3DrNc2JuVC6NxELft2jXUQ%26oauth_nonce%3DEA158DE861F264FDBA6C796F21B4F3AA80%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1239637280%26oauth_token%3D6631-AHu8rT9oznR3uUwHF7J99yU14s17D0vxR0OyKdRX54%26oauth_version%3D1.0%26source%3D23%26status%3Danother%2520test%252C%2520sorry";
//
//    NSString *signature = [baseString signHmacSHA1WithKey:@"kd94hf93k423kf44&pfkkdhi9sl3r4s00"];
//
//    STAssertEqualObjects(@"wkSFmqWRwBreCjgzLJFEew", signature, @"bad signature");
//}
//
//- (void)testSignatureValue3 {
//
//    // http://code.google.com/p/twitter-api/issues/detail?id=433
//
//    NSString *baseString = @"POST&http%3A%2F%2Ftwitter.com%2Fstatuses%2Fupdate.xml&oauth_consumer_key%3DwkSFmqWRwBreCjgzLJFEew%26oauth_nonce%3DH8hGlJfY9c9emMYQ%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1239641507%26oauth_token%3D16290455-6aGM6TIkG8wfb19twWPQn97M0VvFG4ZhMV9UOfkBk%26oauth_version%3D1.0%26status%3Dtest%2520status";
//
//    NSString *signature = [baseString signHmacSHA1WithKey:@"wkSFmqWRwBreCjgzLJFEew"];
//
//    STAssertEqualObjects(@"Aggf4qH9CiHV8O%2FogPZZ0TvtTMw%3D", signature, @"bad signature");
//}

- (void)testXauth {
    
    STHTTPRequestTestResponseQueue *queue = [STHTTPRequestTestResponseQueue sharedInstance];
    
    STHTTPRequestTestResponse *tr1 = [STHTTPRequestTestResponse testResponseWithBlock:^(STHTTPRequest *r) {
        r.responseString = @"oauth_token=191074378-1GWuHmFyyKQUKWV6sR6EEzSCdLGnhqyZFBqLagHp&oauth_token_secret=NpCkpRRC5hGEtikMLnQ2eEcEZ0SIVF5Hb2ZgIwmYgdA&user_id=191074378&screen_name=oauth_test_exec&x_auth_expires=0";
    }];
    
    [queue enqueue:tr1];
    
    /**/
    
    // https://dev.twitter.com/docs/oauth/xauth
    
    STTwitterOAuth *os = [STTwitterOAuth twitterServiceWithConsumerName:@"test" consumerKey:@"JvyS7DO2qd6NNTsXJ4E7zA" consumerSecret:@"9z6157pUbOBqtbm0A0q4r29Y2EYzIHlUwbF4Cl9c" username:@"oauth_test_exec" password:@"twitter-xauth"];
    
    os.testOauthNonce = @"6AN2dKRzxyGhmIXUKSmp1JcB4pckM8rD3frKMTmVAo";
    os.testOauthTimestamp = @"1284565601";
    
    [os postXAuthAccessTokenRequestWithUsername:@"oauth_test_exec" password:@"twitter-xauth" successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        STAssertEqualObjects(@"191074378-1GWuHmFyyKQUKWV6sR6EEzSCdLGnhqyZFBqLagHp", oauthToken, @"bad oauth token");
    } errorBlock:^(NSError *error) {
        STAssertTrue(NO, @"-- error: %@", [error localizedDescription]);
    }];
}

- (void)testAppOnlyCredentialsEncoding {
    
    // https://dev.twitter.com/docs/auth/application-only-auth
    
    NSString *base64EncodedCredentials = [STTwitterAppOnly base64EncodedBearerTokenCredentialsWithConsumerKey:@"xvz1evFS4wEEPTGEFPHBog" consumerSecret:@"L8qq9PZyRg6ieKGEKhZolGC0vJWLw8iEJ88DRdyOg"];

    STAssertEqualObjects(base64EncodedCredentials, @"eHZ6MWV2RlM0d0VFUFRHRUZQSEJvZzpMOHFxOVBaeVJnNmllS0dFS2hab2xHQzB2SldMdzhpRUo4OERSZHlPZw==", nil);
}

@end
