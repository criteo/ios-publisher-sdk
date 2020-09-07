//
//  CMPDataStorageUserDefaults.h
//  GDPR
//

#import <Foundation/Foundation.h>
#import "CR_SPTIabTCFv2StorageProtocol.h"

@interface CR_SPTIabTCFv2StorageUserDefaults : NSObject<CR_SPTIabTCFv2StorageProtocol>
@property (nonatomic, retain) NSUserDefaults *userDefaults;
- (instancetype)initWithUserDefault:(NSUserDefaults *)userDefs;
@end
