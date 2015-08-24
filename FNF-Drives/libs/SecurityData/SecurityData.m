//
//  SecurityData.m
//  ios
//
//  Created by bigbear on 6/12/14.
//  Copyright (c) 2014 bigbear. All rights reserved.
//

#import "SecurityData.h"
#import "SSKeychain.h"

#define SERVICE_NAME    @"bigbear"
#define KEY_DEVICE_ID   @"__IOS_DEVICE_ID"

@implementation SecurityData


//+ (NSString *)deviceId
//{
//    NSString* deviceId = [[SecurityData keychainForKey:KEY_DEVICE_ID] objectForKey:kSecValueData];
//    if ([deviceId length] == 0) {
//        CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
//        deviceId = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
//        CFRelease(uuidObject);
//        [[SecurityData keychainForKey:KEY_DEVICE_ID] setObject:deviceId forKey:kSecValueData];
//    }
//    return deviceId;
//}
//
//+ (void)setSafeValue:(NSString *)value forKey:(NSString *)key
//{
//    [[SecurityData keychainForKey:key] setObject:value forKey:kSecValueData];
//}
//
//+ (NSString *)safeValueForKey:(NSString *)key
//{
//    return [[SecurityData keychainForKey:key] objectForKey:kSecValueData];
//}

+ (NSString *)deviceId
{
    NSString* deviceId = [SecurityData safeValueForKey:KEY_DEVICE_ID];
    if ([deviceId length] == 0) {
        CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
        deviceId = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
        CFRelease(uuidObject);
        [SecurityData setSafeValue:deviceId forKey:KEY_DEVICE_ID];
    }
    return deviceId;
}

+ (void)cleanDeviceId
{
    [SecurityData setSafeValue:@"" forKey:KEY_DEVICE_ID];
}

+ (void)setSafeValue:(NSString *)value forKey:(NSString *)key
{
    [SSKeychain setPassword:value forService:SERVICE_NAME account:key];
}

+ (NSString *)safeValueForKey:(NSString *)key
{
    return [SSKeychain passwordForService:SERVICE_NAME account:key];
}

@end
