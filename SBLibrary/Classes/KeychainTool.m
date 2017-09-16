//
//  KeychainTool.m
//  VpnNew
//
//  Created by caoyusheng on 6/4/17.
//  Copyright © 2017年 caoyusheng. All rights reserved.
//

#import "KeychainTool.h"

@implementation KeychainTool

+ (NSString *)getKeychainItem:(NSString *)identifier
{
    NSData * data = [KeychainTool searchKeychainCopyMatching:identifier];
    
    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    
    return result;
}

//获取Keychain里的对应密码
+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    //    searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    searchDictionary[(__bridge id)kSecReturnPersistentRef] = @YES;//这很重要
    searchDictionary[(__bridge id)kSecAttrSynchronizable] = @NO;
    
    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    return (__bridge NSData *)result;
}

//插入密码到Keychain
+ (void)addKeychainItem:(NSString *)identifier password:(NSString*)password
{
    NSData *passData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    //         searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecValueData] = passData;
    searchDictionary[(__bridge id)kSecAttrSynchronizable] = @NO;
    ;
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)(searchDictionary), &result);
    if (status != noErr)
    {
        NSLog(@"Keychain insert errot!");
    }
}

+ (void)deleteKeychainItem:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    //    searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrSynchronizable] = @NO;
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
    if (status != noErr)
    {
        NSLog(@"Keychain insert errot!");
    }
}

@end
