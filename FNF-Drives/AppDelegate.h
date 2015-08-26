//
//  AppDelegate.h
//  CarRoad
//
//  Created by Wenlong on 15-3-2.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (void) jumpToCover;
+ (void) jumpToLogin;
+ (void) jumpToMain;
+ (void) jumpToOrderDetail;

+ (void) ShowTips:(NSString*)tipsText;
+ (void) ShowToast:(NSString*)toastText;
+ (void) ShowLoading;
+ (void) HideLoading;

@end
