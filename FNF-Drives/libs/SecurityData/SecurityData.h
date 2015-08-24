//
//  SecurityData.h
//  ios
//
//  Created by bigbear on 6/12/14.
//  Copyright (c) 2014 bigbear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityData : NSObject

+ (NSString *)deviceId;
+ (void)cleanDeviceId;

+ (void)setSafeValue:(NSString *)value forKey:(NSString *)key;
+ (NSString *)safeValueForKey:(NSString *)key;

@end
