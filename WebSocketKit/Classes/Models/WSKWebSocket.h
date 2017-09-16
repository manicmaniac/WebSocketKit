//
//  WSKWebSocket.h
//  WebSocketKit
//
//  Created by Ryosuke Ito on 9/16/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSKWebSocketDelegate;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const WSKBinaryTypeBlob;
extern NSString *const WSKBinaryTypeArrayBuffer;

typedef NS_ENUM(NSUInteger, WSKReadyState) {
    WSKReadyStateConnecting = 0,
    WSKReadyStateOpen = 1,
    WSKReadyStateClosing = 2,
    WSKReadyStateClosed = 3
};

@interface WSKWebSocket : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url protocols:(NSArray<NSString *> *)protocols NS_DESIGNATED_INITIALIZER;

- (void)open;
- (void)sendData:(NSData *)data;
- (void)sendString:(NSString *)string;
- (void)close;
- (void)closeWithCode:(NSUInteger)code reason:(NSString *)reason;

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic) NSString *binaryType;
@property (nonatomic, readonly) NSUInteger bufferedAmount;
@property (nonatomic) NSArray<NSString *> *extensions;
@property (nonatomic, weak, nullable) id<WSKWebSocketDelegate> delegate;
@property (nonatomic, readonly, nullable) NSString *protocol;
@property (nonatomic, readonly) WSKReadyState readyState;

@end

@protocol WSKWebSocketDelegate <NSObject>

@optional
- (void)webSocketDidClose:(WSKWebSocket *)webSocket;

@optional
- (void)webSocket:(WSKWebSocket *)webSocket didFailWithError:(NSError *)error;

@optional
- (void)webSocket:(WSKWebSocket *)webSocket didReceiveMessage:(NSString *)message;

@optional
- (void)webSocketDidOpen:(WSKWebSocket *)webSocket;

@end

NS_ASSUME_NONNULL_END
