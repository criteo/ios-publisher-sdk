//
//  CR_CustomNativeAdView.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_CustomNativeAdView.h"
#import "CRNativeAd.h"
#import "CRMediaContent+Internal.h"

@interface CR_CustomNativeAdView ()

@property (strong, nonatomic, readonly) UILabel *label;

@end

@implementation CR_CustomNativeAdView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.numberOfLines = 0;
        [self addSubview:_label];
    }
    return self;
}

- (void)setNativeAd:(CRNativeAd *)nativeAd {
    [super setNativeAd:nativeAd];
    [self clearLabel];
    [self addLabelValue:nativeAd.title  forKey:@"title"];
    [self addLabelValue:nativeAd.body  forKey:@"body"];
    [self addLabelValue:nativeAd.price  forKey:@"price"];
    [self addLabelValue:nativeAd.callToAction  forKey:@"callToAction"];
    [self addLabelValue:nativeAd.productMedia.imageUrl.absoluteString  forKey:@"productImageUrl"];
    [self addLabelValue:nativeAd.advertiserLogoMedia.imageUrl.absoluteString  forKey:@"advertiserLogoImageUrl"];
    [self addLabelValue:nativeAd.advertiserDescription  forKey:@"advertiserDescription"];
    [self addLabelValue:nativeAd.advertiserDomain  forKey:@"advertiserDomain"];
}

#pragma mark - Private

- (void)clearLabel {
    self.label.text = @"";
}

- (void)addLabelValue:(NSString *)value forKey:(NSString *)key {
    NSString *str = [[NSString alloc] initWithFormat:@"%@: %@", key, value];
    NSString *newText = [[NSString alloc] initWithFormat:@"%@\n%@",
                         self.label.text, str];
    self.label.text = newText;
}

@end
