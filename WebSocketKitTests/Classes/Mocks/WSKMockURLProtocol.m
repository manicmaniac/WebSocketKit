//
//  WSKMockURLProtocol.m
//  WebSocketKit
//
//  Created by Ryosuke Ito on 9/17/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

#import "WSKMockURLProtocol.h"

NSString *const WSKMockURLString = @"ws://localhost/";

@implementation WSKMockURLProtocol {
@private
    dispatch_queue_t _queue;
}

#pragma mark Public

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [[[request URL] absoluteString] isEqualToString:WSKMockURLString];
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task {
    return [[[[task currentRequest] URL] absoluteString] isEqualToString:WSKMockURLString];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self) {
        _queue = [self createDispatchQueue];
    }
    return self;
}

- (instancetype)initWithTask:(NSURLSessionTask *)task cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    self = [super initWithTask:task cachedResponse:cachedResponse client:client];
    if (self) {
        _queue = [self createDispatchQueue];
    }
    return self;
}

- (void)startLoading {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            NSURLRequest *request = [strongSelf request];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:@"application/octet-stream" expectedContentLength:-1 textEncodingName:nil];
            [[strongSelf client] URLProtocol:strongSelf didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
            [[strongSelf client] URLProtocol:strongSelf didLoadData:[request HTTPBody]];
            [[strongSelf client] URLProtocolDidFinishLoading:strongSelf];
        }
    });
}

- (void)stopLoading {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf client] URLProtocolDidFinishLoading:strongSelf];
        }
    });
}

#pragma mark Private

- (dispatch_queue_t)createDispatchQueue {
    return dispatch_queue_create("com.github.manicmaniac.WSKMockURLProtocolQueue", DISPATCH_QUEUE_SERIAL);
}

@end
