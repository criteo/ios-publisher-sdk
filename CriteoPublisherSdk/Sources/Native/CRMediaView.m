//
//  CRMediaView.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>
#import "CRMediaView.h"
#import "CRMediaView+Internal.h"
#import "CRMediaContent.h"
#import "CRMediaContent+Internal.h"
#import "CRMediaDownloader.h"
#import "CR_Logging.h"

@implementation CRMediaView

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)setMediaContent:(CRMediaContent *)mediaContent {
  NSURL *url = mediaContent.url;

  // Media downloader may spend time to load the image.
  // We only set the placeholder if a new image comes.
  if (url == nil || ![url isEqual:self.imageUrl]) {
    self.imageView.image = self.placeholder;
  }

  if (url == nil) {
    _mediaContent = mediaContent;
    return;
  }

  __weak typeof(self) weakSelf = self;
  [mediaContent.mediaDownloader
          downloadImage:url
      completionHandler:^(UIImage *image, NSError *error) {
        if (image != nil) {
          weakSelf.imageView.image = image;
          weakSelf.imageUrl = url;
        } else if (error != nil) {
          CRLogWarn(@"Media", @"Error when fetching image at url: %@ for media view. Error: %@",
                    url, error);
        }
      }];

  _mediaContent = mediaContent;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.imageView.frame = self.bounds;
}

#pragma mark - Private

- (UIImageView *)imageView {
  if (_imageView == nil) {
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
  }
  return _imageView;
}

@end
