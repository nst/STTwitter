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
    
    int c = (int)[ms numberOfCharactersInATweet];
    
    XCTAssertEqual(c, 140, @"c: %d", (int)c);
}

- (void)testCharactersCountUnicode {
    
    NSString *s = @"\u2070";
    
    int c = (int)[s numberOfCharactersInATweet];
    
    XCTAssertEqual(c, 1, @"c: %d", (int)c);
}

- (void)testCharactersCountAccentedCharacter {
    
    NSString *s = @"caf\x65\xCC\x81";
    
    int c = (int)[s numberOfCharactersInATweet];
    
    XCTAssertEqual(c, 4, @"c: %d", (int)c);
}

- (void)testCharactersCountHTTPTwice {
    
    NSString *s = @"asd http://www.apple.com http://www.google.com sdf";
        
    int c = (int)[s numberOfCharactersInATweet];
    
    int expected = 4 + (int)kSTTwitterDefaultShortURLLength + 1 + (int)kSTTwitterDefaultShortURLLength + 4;
    
    XCTAssertEqual(c, expected, @"c: %d, expected %d", c, expected);
}

- (void)testCharactersCountHTTPS {
    
    NSString *s = @"https://api.twitter.com/";
    
    int c = (int)[s numberOfCharactersInATweet];
    
    XCTAssertEqual(c, (int)kSTTwitterDefaultShortURLLengthHTTPS, @"c: %d", (int)c);
}

@end
