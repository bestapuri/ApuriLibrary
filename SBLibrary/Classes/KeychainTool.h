//
//  KeychainTool.h
//  VpnNew
//
//  Created by caoyusheng on 6/4/17.
//  Copyright © 2017年 caoyusheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainTool : NSObject

+ (NSString *)getKeychainItem:(NSString *)identifier;

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;

+ (void)addKeychainItem:(NSString *)identifier password:(NSString*)password;

+ (void)deleteKeychainItem:(NSString *)identifier;

@end
