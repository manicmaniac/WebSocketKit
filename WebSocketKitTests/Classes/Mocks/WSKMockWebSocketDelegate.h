//
//  WSKMockWebSocketDelegate.h
//  WebSocketKit
//
//  Created by Ryosuke Ito on 9/17/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSKWebSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSKMockWebSocketDelegate: NSObject <WSKWebSocketDelegate>

@property (nonatomic, copy, nullable) void (^onOpenBlock)(WSKWebSocket *);
@property (nonatomic, copy, nullable) void (^onMessageBlock)(WSKWebSocket *, NSString *);
@property (nonatomic, copy, nullable) void (^onCloseBlock)(WSKWebSocket *);
@property (nonatomic, copy, nullable) void (^onErrorBlock)(WSKWebSocket *, NSError *);

@end

NS_ASSUME_NONNULL_END
