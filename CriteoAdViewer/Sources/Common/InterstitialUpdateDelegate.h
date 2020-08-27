//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InterstitialUpdateDelegate <NSObject>
- (void)interstitialUpdated:(BOOL)loaded;
@end
