//
//  CR_InMemoryUserDefaults.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_InMemoryUserDefaults.h"

@interface CR_InMemoryUserDefaults ()

@property (strong, atomic) NSMutableDictionary* data;

@end

@implementation CR_InMemoryUserDefaults

- (id)init {
    if (self = [super init]) {
        _data = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Writing

- (void)setObject:(id)value forKey:(NSString*)defaultName {
    self.data[defaultName] = value;
}

- (void)setInteger:(NSInteger)value forKey:(NSString*)defaultName {
    self.data[defaultName] = @(value);
}

- (void)setFloat:(float)value forKey:(NSString*)defaultName {
    self.data[defaultName] = @(value);
}

- (void)setBool:(BOOL)value forKey:(NSString*)defaultName {
    self.data[defaultName] = @(value);
}

- (void)setDouble:(double)value forKey:(NSString*)defaultName {
    self.data[defaultName] = @(value);
}

- (void)setURL:(NSURL*)url forKey:(NSString*)defaultName {
    self.data[defaultName] = url;
}

- (void)removeObjectForKey:(NSString*)defaultName {
    [self.data removeObjectForKey:defaultName];
}

- (BOOL)synchronize {
    return YES;
}

#pragma mark Reading

- (id)objectForKey:(NSString*)defaultName {
    return self.data[defaultName];
}

- (NSString*)stringForKey:(NSString*)defaultName {
    id stringObj = self.data[defaultName];
    if (![stringObj isKindOfClass:[NSString class]]) {
        return nil;
    }

    return stringObj;
}

- (NSArray*)arrayForKey:(NSString*)defaultName {
    id arrayObj = self.data[defaultName];
    if (![arrayObj isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return arrayObj;
}

- (NSDictionary*)dictionaryForKey:(NSString*)defaultName {
    id dictionaryObj = self.data[defaultName];
    if (![dictionaryObj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    return dictionaryObj;
}

- (NSData*)dataForKey:(NSString*)defaultName {
    id dataObj = self.data[defaultName];
    if (![dataObj isKindOfClass:[NSData class]]) {
        return nil;
    }
    return dataObj;
}

- (NSArray*)stringArrayForKey:(NSString*)defaultName {
    NSArray* arrayObject = [self arrayForKey:defaultName];
    if (nil == arrayObject) {
        return nil;
    }

    for (id obj in arrayObject) {
        if (![obj isKindOfClass:[NSString class]]) {
            return nil;
        }
    }

    return arrayObject;
}

- (NSInteger)integerForKey:(NSString*)defaultName {
    return [self.data[defaultName] integerValue];
}

- (float)floatForKey:(NSString*)defaultName {
    return [self.data[defaultName] floatValue];
}

- (double)doubleForKey:(NSString*)defaultName {
    return [self.data[defaultName] doubleValue];
}

- (BOOL)boolForKey:(NSString*)defaultName {
    return [self.data[defaultName] boolValue];
}

@end
