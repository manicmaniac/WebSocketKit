//
//  WSKWebSocketTests.m
//  WebSocketKit
//
//  Created by Ryosuke Ito on 9/17/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WSKWebSocket.h"
#import "WSKMockURLProtocol.h"
#import "WSKMockWebSocketDelegate.h"

@interface WSKWebSocketTests : XCTestCase
@end

@implementation WSKWebSocketTests {
@private
    WSKWebSocket *_webSocket;
}

- (void)setUp {
    [super setUp];
    [NSURLProtocol registerClass:[WSKMockURLProtocol class]];
    NSURL *url = [NSURL URLWithString:WSKMockURLString];
    NSArray<NSString *> *protocols = [NSArray arrayWithObject:@""];
    _webSocket = [[WSKWebSocket alloc] initWithURL:url protocols:protocols];
}

- (void)tearDown {
    [super tearDown];
    [NSURLProtocol unregisterClass:[WSKMockURLProtocol class]];
}

- (void)testSendData {

}

- (void)testSendString {
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"webSocket should receive a message."];
    WSKMockWebSocketDelegate *delegate = [[WSKMockWebSocketDelegate alloc] init];
    NSString *string = @"foo";
    [delegate setOnMessageBlock:^(WSKWebSocket *webSocket, NSString *message){
        XCTAssertEqualObjects(message, string);
        [expectation fulfill];
    }];
    [_webSocket setDelegate:delegate];
    [_webSocket open];
    [_webSocket sendString:string];
    [_webSocket close];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testURL {
    [_webSocket open];
    XCTAssertEqualObjects([[_webSocket url] absoluteString], WSKMockURLString);
    [_webSocket close];
}

- (void)testProtocols {
    [_webSocket open];
    XCTAssertEqualObjects([_webSocket protocol], @"");
    [_webSocket close];
}

@end
