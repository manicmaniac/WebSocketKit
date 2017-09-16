//
//  WebSocketKitTests.m
//  WebSocketKitTests
//
//  Created by Ryosuke Ito on 9/16/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WebSocketKit.h"

@interface WebSocketKitTests : XCTestCase
@end

@implementation WebSocketKitTests

- (void)testWebSocketKitVersionNumber {
    XCTAssertGreaterThan(WebSocketKitVersionNumber, 0.0);
}

- (void)testWebSocketKitVersionString {
    XCTAssert(strlen((const char *)WebSocketKitVersionString) > 0);
}

@end
