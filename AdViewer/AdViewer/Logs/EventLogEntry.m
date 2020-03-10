//
//  EventLogEntry.m
//  AdViewer
//
//  Created by Vincent Guerci on 09/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "EventLogEntry.h"

@interface EventLogEntry ()

@property (copy, nonatomic) NSDate *timestamp;
@property (copy, nonatomic) NSString *event;
@property (copy, nonatomic) NSString *detail;

@end

@implementation EventLogEntry

#pragma mark - Lifecycle

- (instancetype)initWithEvent:(NSString *)event detail:(NSString *)detail {
    if (self = [super init]) {
        _timestamp = [NSDate date];
        _event = [event copy];
        _detail = [detail copy];
    }
    return self;
}


#pragma mark - Public

- (NSString *)title {
    return [NSString stringWithFormat:@"⏺ %@", self.event];
}

- (NSString *)subtitle {
    NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
    timestampFormatter.dateFormat = @"HH:mm:ss.SSS";
    NSString *ts = [timestampFormatter stringFromDate:self.timestamp];
    return ts;
}

@end
