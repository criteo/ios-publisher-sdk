//
//  CMPDataStorageUserDefaults.h
//  GDPR
//

#import <Foundation/Foundation.h>
#import "CR_SPTIabTCFv1StorageProtocol.h"

@interface CR_SPTIabTCFv1StorageUserDefaults : NSObject <CR_SPTIabTCFv1StorageProtocol>
@property(nonatomic, retain) NSUserDefaults *userDefaults;
- (instancetype)initWithUserDefault:(NSUserDefaults *)userDefs;
@end
