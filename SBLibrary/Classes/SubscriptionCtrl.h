//
//  SubscriptionCtrl.h
//  PhotoSecurity
//
//  Created by チャン ビングエン on 2017/08/24.
//  Copyright © 2017 xiaopin. All rights reserved.
//
typedef enum {
    FULLSCREEN = 1,
    HALFSCREEN                = 2,
    WEBSCREEN                = 3,
    ONE_SREEN                = 4,
    HALFSCREEN_TRIAL                = 5
} SCREEN_TYPE;
#import <UIKit/UIKit.h>
@interface SubscriptionCtrl : UIViewController
@property(nonatomic,strong)UIViewController* successCtrl;
@property(nonatomic,assign) SCREEN_TYPE screenType;
@property(nonatomic,strong) NSString* webURL;
@property(nonatomic,strong) NSString* webTitle;
@property(nonatomic,copy) dispatch_block_t blockComplete;
@end
