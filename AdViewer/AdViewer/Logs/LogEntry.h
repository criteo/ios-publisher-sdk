//
//  LogEntry.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LogEntry <NSObject>

#pragma mark - Properties

@property (copy, nonatomic, readonly) NSDate *timestamp;
@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSString *subtitle;
@property (copy, nonatomic, readonly) NSString *detail;

@end

NS_ASSUME_NONNULL_END
