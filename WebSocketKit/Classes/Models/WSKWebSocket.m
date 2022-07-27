//
//  WSKWebSocket.m
//  WebSocketKit
//
//  Created by Ryosuke Ito on 9/16/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WSKWebSocket.h"
#import "WSKErrors.h"

static NSString *const kInitialJavaScriptTemplate = (@"window.webSocket = new window.WebSocket(\"%@\");"
                                                     @"window.webSocket.addEventListener('close', function(event) {"
                                                     @"  window.webkit.messageHandlers.onclose.postMessage();"
                                                     @"});"
                                                     @"window.webSocket.addEventListener('error', function(event) {"
                                                     @"  window.webkit.messageHandlers.onerror.postMessage(event.error);"
                                                     @"});"
                                                     @"window.webSocket.addEventListener('message', function(event) {"
                                                     @"  window.webkit.messageHandlers.onmessage.postMessage(event.data);"
                                                     @"});"
                                                     @"window.webSocket.addEventListener('open', function(event) {"
                                                     @"  window.webkit.messageHandlers.onopen.postMessage();"
                                                     @"});"
                                                     );
static NSString *const kOnCloseHandlerName = @"onclose";
static NSString *const kOnErrorHandlerName = @"onerror";
static NSString *const kOnMessageHandlerName = @"onmessage";
static NSString *const kOnOpenHandlerName = @"onopen";

@interface WSKWebSocket () <WKNavigationDelegate, WKScriptMessageHandler>
@end

@implementation WSKWebSocket {
@private
    NSURL *_url;
    NSArray<NSString *> *_protocols;
    __weak id<WSKWebSocketDelegate> _delegate;
    WKWebView *_webView;
}

#pragma mark Public

- (instancetype)initWithURL:(NSURL *)url {
    NSArray<NSString *> *protocols = [NSArray array];
    return [self initWithURL:url protocols:protocols];
}

- (instancetype)initWithURL:(NSURL *)url protocols:(NSArray<NSString *> *)protocols {
    self = [super init];
    if (self) {
        _url = url;
        _protocols = protocols;
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addScriptMessageHandler:self name:kOnCloseHandlerName];
        [userContentController addScriptMessageHandler:self name:kOnErrorHandlerName];
        [userContentController addScriptMessageHandler:self name:kOnMessageHandlerName];
        [userContentController addScriptMessageHandler:self name:kOnOpenHandlerName];
        [configuration setUserContentController:userContentController];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        [webView setNavigationDelegate:self];
        _webView = webView;
    }
    return self;
}

- (void)open {
    NSString *javaScriptSource = [NSString stringWithFormat:kInitialJavaScriptTemplate,
                                  [self javaScriptEscapedObject:[_url absoluteString]]];
    NSError *error = nil;
    [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    if (error && [_delegate respondsToSelector:@selector(webSocket:didFailWithError:)]) {
        [_delegate webSocket:self didFailWithError:error];
    }

}

- (void)sendData:(NSData *)data {
}

- (void)sendString:(NSString *)string {
    NSString *javaScriptSource = [NSString stringWithFormat:@"window.webSocket.send(\"%@\");",
                                  [self javaScriptEscapedObject:string]];
    NSError *error = nil;
    [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    if (error && [_delegate respondsToSelector:@selector(webSocket:didFailWithError:)]) {
        [_delegate webSocket:self didFailWithError:error];
    }
}

- (void)close {
    [self closeWithCode:WSKCloseEventNormalClosure reason:@""];
}

- (void)closeWithCode:(NSUInteger)code reason:(NSString *)reason {
    _Static_assert(sizeof(code) <= sizeof(unsigned long), "`code` can perform safe-cast to unsigned long.");
    NSString *javaScriptSource = [NSString stringWithFormat:@"window.webSocket.close(%lu, \"%@\");",
                                  (unsigned long)code,
                                  [self javaScriptEscapedObject:reason]];
    NSError *error = nil;
    [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    if (error && [_delegate respondsToSelector:@selector(webSocket:didFailWithError:)]) {
        [_delegate webSocket:self didFailWithError:error];
    }
}

- (NSURL *)url {
    return _url;
}

- (NSString *)binaryType {
    NSString *javaScriptSource = @"window.webSocket.binaryType";
    NSError *error = nil;
    id object = [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    NSAssert(!error, @"should not occur errors.");
    NSAssert([object isKindOfClass:[NSString class]], @"object should be a string.");
    return (NSString *)object;
}

- (void)setBinaryType:(NSString *)binaryType {
    NSString *javaScriptSource = @"window.webSocket.binaryType = \"%@\"";
    NSError *error = nil;
    [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    NSAssert(!error, @"should not occur errors.");
}

- (NSUInteger)bufferedAmount {
    NSString *javaScriptSource = @"window.webSocket.bufferedAmount";
    NSError *error = nil;
    id object = [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    NSAssert(!error, @"should not occur errors.");
    NSAssert([object isKindOfClass:[NSNumber class]], @"object should be a number.");
    return [(NSNumber *)object unsignedIntegerValue];
}

- (NSArray<NSString *> *)extensions {
    NSString *javaScriptSource = @"window.webSocket.extensions";
    NSError *error = nil;
    id object = [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    NSAssert(!error, @"should not occur errors.");
    NSAssert([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSArray class]], @"object should be a string or an array.");
    NSArray<NSString *> *extensions = nil;
    if ([object isKindOfClass:[NSString class]]) {
        extensions = [NSArray arrayWithObject:object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        extensions = (NSArray<NSString *> *)object;
    }
    return extensions;
}

- (void)setExtensions:(NSArray<NSString *> *)extensions {
    NSString *javaScriptSource = [NSString stringWithFormat:@"window.webSocket.extensions = %@",
                                  [self javaScriptEscapedObject:extensions]];
    NSError *error = nil;
    [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    NSAssert(!error, @"should not occur errors.");
}

- (id<WSKWebSocketDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<WSKWebSocketDelegate>)delegate {
    _delegate = delegate;
}

- (NSString *)protocol {
    NSString *javaScriptSource = @"window.webSocket.protocol";
    NSError *error = nil;
    id object = [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    NSAssert(!error, @"should not occur errors.");
    NSAssert([object isKindOfClass:[NSString class]], @"object should be a string.");
    return (NSString *)object;
}

- (WSKReadyState)readyState {
    NSString *javaScriptSource = @"window.webSocket.readyState";
    NSError *error = nil;
    id object = [self synchronousEvaluateJavaScriptInWebView:javaScriptSource error:&error];
    NSAssert(!error, @"should not occur errors.");
    NSAssert([object isKindOfClass:[NSNumber class]], @"object should be a number.");
    return (WSKReadyState)[(NSNumber *)object unsignedIntegerValue];
}

#pragma mark - Private

- (nullable id)synchronousEvaluateJavaScriptInWebView:(NSString *)source error:(NSError *__autoreleasing _Nullable *)error {
    __block BOOL evaluationIsFinished = NO;
    __block id returnObject = nil;
    __block NSError *returnError = nil;
    [_webView evaluateJavaScript:source completionHandler:^(id _Nullable object, NSError *_Nullable evaluationError){
        if (object) {
            returnObject = object;
        }
        if (evaluationError) {
            returnError = evaluationError;
        }
        evaluationIsFinished = YES;
    }];
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    do {
        @autoreleasepool {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1.0 / 60.0];
            [currentRunLoop runUntilDate:date];
        }
    } while (!evaluationIsFinished);
    if (returnError && error) {
        *error = returnError;
    }
    return returnObject;
}

// brought from https://stackoverflow.com/a/13569786
- (NSString *)javaScriptEscapedObject:(id)object {
    NSArray *objectInArray = [NSArray arrayWithObject:object];
    NSError *error = nil;
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:objectInArray options:(NSJSONWritingOptions)0 error:&error];
    NSAssert(!error, @"should not occur errors.");
    NSString *serializedString = [[NSString alloc] initWithData:serializedData encoding:NSUTF8StringEncoding];
    NSRange range = NSMakeRange(2, [serializedString length] - 4);
    return [serializedString substringWithRange:range];
}

#pragma mark - WKNavigationDelegate

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *messageName = [message name];
    if ([messageName isEqualToString:kOnCloseHandlerName]) {
        if ([_delegate respondsToSelector:@selector(webSocketDidClose:)]) {
            [_delegate webSocketDidClose:self];
        }
    } else if ([messageName isEqualToString:kOnErrorHandlerName]) {
        if ([_delegate respondsToSelector:@selector(webSocket:didFailWithError:)]) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@"An error occurred." forKey:NSLocalizedDescriptionKey];
            if ([[message body] isKindOfClass:[NSString class]]) {
                [userInfo setObject:[message body] forKey:NSLocalizedFailureReasonErrorKey];
            }
            NSError *error = [NSError errorWithDomain:WSKErrorDomain code:WSKGenericError userInfo:userInfo];
            [_delegate webSocket:self didFailWithError:error];
        }

    } else if ([messageName isEqualToString:kOnMessageHandlerName]) {
        if ([_delegate respondsToSelector:@selector(webSocket:didReceiveMessage:)]) {
            NSAssert([[message body] isKindOfClass:[NSString class]], @"`[message body]` should be a String.");
            [_delegate webSocket:self didReceiveMessage:[message body]];
        }

    } else if ([messageName isEqualToString:kOnOpenHandlerName]) {
        if ([_delegate respondsToSelector:@selector(webSocketDidOpen:)]) {
            [_delegate webSocketDidOpen:self];
        }
    }
}

@end
