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
    WEBSCREEN                = 3
} SCREEN_TYPE;
#import <UIKit/UIKit.h>
@interface SubscriptionCtrl : UIViewController
@property(nonatomic,strong)UIViewController* successCtrl;
@property(nonatomic,assign) SCREEN_TYPE screenType;
- (id)initWithURL:(NSString*)url title:(NSString*)title;
@end
