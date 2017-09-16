//
//  WSKMockWebSocketDelegate.m
//  WebSocketKit
//
//  Created by Ryosuke Ito on 9/17/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

#import "WSKMockWebSocketDelegate.h"

@implementation WSKMockWebSocketDelegate {
@private
    void (^_onOpenBlock)(WSKWebSocket *);
    void (^_onMessageBlock)(WSKWebSocket *, NSString *);
    void (^_onCloseBlock)(WSKWebSocket *);
    void (^_onErrorBlock)(WSKWebSocket *, NSError *);
}

#pragma mark Public

- (void (^)(WSKWebSocket *))onOpenBlock {
    return _onOpenBlock;
}

- (void)setOnOpenBlock:(void (^)(WSKWebSocket *))onOpenBlock {
    _onOpenBlock = [onOpenBlock copy];
}

- (void (^)(WSKWebSocket *, NSString *))onMessageBlock {
    return _onMessageBlock;
}

- (void)setOnMessageBlock:(void (^)(WSKWebSocket *, NSString *))onMessageBlock {
    _onMessageBlock = [onMessageBlock copy];
}

- (void (^)(WSKWebSocket *))onCloseBlock {
    return _onCloseBlock;
}

- (void)setOnCloseBlock:(void (^)(WSKWebSocket *))onCloseBlock {
    _onCloseBlock = [onCloseBlock copy];
}

- (void (^)(WSKWebSocket *, NSError *))onErrorBlock {
    return _onErrorBlock;
}

- (void)setOnErrorBlock:(void (^)(WSKWebSocket *, NSError *))onErrorBlock {
    _onErrorBlock = [onErrorBlock copy];
}

#pragma mark WSKWebSocketDelegate

- (void)webSocketDidOpen:(WSKWebSocket *)webSocket {
    if (_onOpenBlock) {
        _onOpenBlock(webSocket);
    }
}

- (void)webSocket:(WSKWebSocket *)webSocket didReceiveMessage:(NSString *)message {
    if (_onMessageBlock) {
        _onMessageBlock(webSocket, message);
    }
}

- (void)webSocketDidClose:(WSKWebSocket *)webSocket {
    if (_onCloseBlock) {
        _onCloseBlock(webSocket);
    }
}

- (void)webSocket:(WSKWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (_onErrorBlock) {
        _onErrorBlock(webSocket, error);
    }
}

@end
