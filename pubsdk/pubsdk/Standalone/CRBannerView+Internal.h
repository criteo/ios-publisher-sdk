//
//  CRBannerView+Internal.h
//  pubsdk
//
//  Created by Julien Stoeffler on 4/3/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRBannerView_Internal_h
#define CRBannerView_Internal_h

@interface CRBannerView (Internal)
- (instancetype)initWithFrame:(CGRect)frame criteo:(Criteo *)criteo webView:(WKWebView *)webView;

@end

#endif /* CRBannerView_Internal_h */
