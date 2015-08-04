//
//  STMiscTests.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/10/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STMiscTests.h"
#import "NSString+STTwitter.h"
#import "STTwitterStreamParser.h"

@implementation STMiscTests


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

- (void)testCharactersCount140 {
    
    NSString *s = @"0123567890";
    NSMutableString *ms = [NSMutableString string];
    for(int i = 0; i < 14; i++) {
        [ms appendString:s];
    }
    
    int c = (int)[ms st_numberOfCharactersInATweet];
    
    XCTAssertEqual(c, 140, @"c: %d", (int)c);
}

- (void)testCharactersCountUnicode {
    
    NSString *s = @"\u2070";
    
    int c = (int)[s st_numberOfCharactersInATweet];
    
    XCTAssertEqual(c, 1, @"c: %d", (int)c);
}

- (void)testCharactersCountWithDash {
    
    NSString *s = @"asd http://www.apple.com/#asd dfg";
    
    int c = (int)[s st_numberOfCharactersInATweet];
    
    int expected = 4 + (int)kSTTwitterDefaultShortURLLength + 4;
    
    XCTAssertEqual(c, expected, @"c: %d, expected %d", c, expected);
}

- (void)testCharactersCountAccentedCharacter {
    
    NSString *s = @"caf\x65\xCC\x81";
    
    int c = (int)[s st_numberOfCharactersInATweet];
    
    XCTAssertEqual(c, 4, @"c: %d", (int)c);
}

- (void)testCharactersCountHTTPTwice {
    
    NSString *s = @"asd http://www.apple.com http://www.google.com sdf";
        
    int c = (int)[s st_numberOfCharactersInATweet];
    
    int expected = 4 + (int)kSTTwitterDefaultShortURLLength + 1 + (int)kSTTwitterDefaultShortURLLength + 4;
    
    XCTAssertEqual(c, expected, @"c: %d, expected %d", c, expected);
}

- (void)testCharactersCountWithTCO {
    // https://github.com/nst/STTwitter/issues/87
    
    NSString *s = @"\"The Game of Thrones season premiere will stream on Xbox and cable after last night\'s HBO Go problems http://t.co/ZTTIOJX3l9\"";
    
    int c = (int)[s st_numberOfCharactersInATweet];
    
    XCTAssertEqual(140 - c, 15, @"c: %d", c);
}

- (void)testCharactersCountIssue209 {
    // https://github.com/nst/STTwitter/issues/209
    
    NSString *s = @"http://us1.campaign-archive2.com/?u=d0e55f3197099944345708652&id=5c51c9bebb&e=dff350d017";
    
    int c = (int)[s st_numberOfCharactersInATweet];
    
    XCTAssertEqual(140 - c, 118, @"c: %d", c);
}

- (void)testURLWithHyphens {
    // https://github.com/nst/STTwitter/issues/91
    
    NSString *s = @"asd http://www.imore.com/auki-iphone-review-ios-7-quick-reply-way-apple-would-have-done-it sdf";
    
    int c = (int)[s st_numberOfCharactersInATweet];
    
    XCTAssertEqual(140 - c, 110, @"c: %d", c);
}

- (void)testCharactersCountHTTPS {
    
    NSString *s = @"https://api.twitter.com/";
    
    int c = (int)[s st_numberOfCharactersInATweet];
    
    XCTAssertEqual(c, (int)kSTTwitterDefaultShortURLLengthHTTPS, @"c: %d", (int)c);
}

- (void)testCharactersCountEmojis {
    
    NSString *s = @"\U0001F601";
    
    int c = (int)[s st_numberOfCharactersInATweet];
    
    XCTAssertEqual(c, 1, @"c: %d", (int)c);
}

- (void)testParserOK {
    NSString *s1 = @"11\r\n{\"a\":";
    NSString *s2 = @"\"b\"}";
    
    NSData *data1 = [s1 dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data2 = [s2 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *expectedDictionary = @{@"a":@"b"};
    __block NSDictionary *readDictionary = nil;
    
    STTwitterStreamParser *parser = [[STTwitterStreamParser alloc] init];
    
    [parser parseWithStreamData:data1 parsedJSONBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
        XCTAssertFalse(YES, @"shouldn't have finished parsing incomplete JSON");
    }];

    [parser parseWithStreamData:data2 parsedJSONBlock:^(NSDictionary *json, STTwitterStreamJSONType type) {
        XCTAssertEqual(STTwitterStreamJSONTypeUnsupported, type);
        readDictionary = json;
    }];

    XCTAssertNotNil(readDictionary);
    XCTAssertEqualObjects(expectedDictionary, readDictionary);
}

@end
