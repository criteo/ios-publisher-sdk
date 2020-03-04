//
//  RequestLogEntry.m
//  AdViewer
//
//  Created by Vincent Guerci on 04/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "RequestLogEntry.h"

@interface RequestLogEntry ()

@property (copy, nonatomic) NSDate *timestamp;
@property (copy, nonatomic) NSURLRequest *request;

@end

@implementation RequestLogEntry

#pragma mark - Lifecycle

- (instancetype)initWithRequest:(NSURLRequest *)request {
    if (self = [super init]) {
        _timestamp = [NSDate date];
        _request = [request copy];
    }
    return self;
}

#pragma mark - Public

- (NSString *)title {
    NSString *host = self.request.URL.host ?: @"Unknown";
    return [NSString stringWithFormat:@"⬆️ REQ: %@", host];
}

- (NSString *)subtitle {
    NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
    timestampFormatter.dateFormat = @"HH:mm:ss.SSS";
    NSString *ts = [timestampFormatter stringFromDate:self.timestamp];
    return ts;
}

- (NSString *)detail {
    if (!_request.HTTPBody) {
        return @"";
    }
    return [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
}

@end
