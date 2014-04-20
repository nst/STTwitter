//
//  STMiscTests.m
//  STTwitterDemoOSX
//
//  Created by Nicolas Seriot on 9/10/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "STMiscTests.h"
#import "NSString+STTwitter.h"

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

@end
