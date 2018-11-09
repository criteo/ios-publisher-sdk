//
//  AdViewerCdbApi.h
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef AdViewerCdbApi_h
#define AdViewerCdbApi_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

enum methodSelector
{
    LoadAd
};


@class AdViewerCdbApi;

@protocol AdViewerCdbApiDelegate <NSObject>

-(void)AdViewerAPI:(AdViewerCdbApi *)api didFinishLoading:(NSDictionary *)response message:(NSString *)message
      selector:(enum methodSelector)selector;
    
@end

@interface AdViewerCdbApi : NSObject <AdViewerCdbApiDelegate>
{
    NSString *errorMessage;
    enum methodSelector selector;
}

@property (nonatomic, strong) id<AdViewerCdbApiDelegate> delegate;
@property (nonatomic, strong) id<AdViewerCdbApiDelegate> saveDelegate;
@property NSDictionary *properties;


- (id)initWithSelector:(enum methodSelector)selector delegate:(id)delegate;
- (NSString *)LoadAd: (NSDictionary *)requestData;

    
@end


#endif /* AdViewerCdbApi_h */
