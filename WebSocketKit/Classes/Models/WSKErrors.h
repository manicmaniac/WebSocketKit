//
//  WSKErrors.h
//  WebSocketKit
//
//  Created by Ryosuke Ito on 9/16/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const WSKErrorDomain; // = @"WSKErrorDomain"

typedef NS_ENUM(NSInteger, WSKErrorCode) {
    // WebSocketKit codes
    WSKGenericError = -10000,

    // JavaScript WebSocket codes
    WSKWebSocketSyntaxError = -2002,
    WSKWebSocketInvalidStateError = -2001,
    WSKWebSocketInvalidAccessError = -2000,
    WSKWebSocketNotAWebSocketURLError = -1000,

    // JavaScript CloseEvent codes
    WSKCloseEventNormalClosure = 1000,
    WSKCloseEventGoingAway = 1001,
    WSKCloseEventProtocolError = 1002,
    WSKCloseEventUnsupportedData = 1003,
    WSKCloseEventNoStatusReceived = 1005,
    WSKCloseEventAbnormalClosure = 1006,
    WSKCloseEventInvalidFramePayloadData = 1007,
    WSKCloseEventPolicyViolation = 1008,
    WSKCloseEventMessageTooBig = 1009,
    WSKCloseEventMissingExtension = 1010,
    WSKCloseEventInternalError = 1011,
    WSKCloseEventServiceRestart = 1012,
    WSKCloseEventTryAgainLater = 1013,
    WSKCloseEventBadGateway = 1014,
    WSKCloseEventTLSHandshake = 1015,
};

NS_ASSUME_NONNULL_END
