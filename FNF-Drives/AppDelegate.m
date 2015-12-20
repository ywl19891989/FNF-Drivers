//
//  AppDelegate.m
//  CarRoad
//
//  Created by Wenlong on 15-3-2.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "AppDelegate.h"
#import "libs/JGProgressHUD/JGProgressHUD.h"
#import "libs/MBProgressHUD/MBProgressHUD.h"
#import "APService.h"
#import "MMLocationManager.h"

#import "MainView.h"
#import "OrderDetail.h"
#import "CoverView.h"
#import "LoginView.h"
#import "MessageDetail.h"
#import "MessageList.h"
#import "SettingsView.h"

@implementation AppDelegate

static UIWindow* mainWindow;

#define CREATE_VIEW(__TYPE__) __TYPE__* view = [[__TYPE__ alloc] initWithNibName:@""#__TYPE__"" bundle:nil]; \
[mainWindow setRootViewController: view];

+ (void)jumpToCover {  CREATE_VIEW(CoverView); }
+ (void)jumpToLogin {  CREATE_VIEW(LoginView); }
+ (void)jumpToMain {  CREATE_VIEW(MainView); }
+ (void)jumpToOrderDetail {  CREATE_VIEW(OrderDetail); }
+ (void)jumpToMsgList { CREATE_VIEW(MessageList) }
+ (void)jumpToMsgDetail { CREATE_VIEW(MessageDetail) }
+ (void)jumpToSettings { CREATE_VIEW(SettingsView); }

+ (void)ShowTips:(NSString*)tipText
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tips" message:tipText delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    alert.tag = 10000;
    [alert show];
}

+ (void) ShowToast:(NSString*)toastText
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    [mainWindow addSubview:hud];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = toastText;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:0.6];
    
    [hud setUserInteractionEnabled:NO];
    [hud setYOffset:[UIScreen mainScreen].bounds.size.height / 2 - 100];
}

static MBProgressHUD *loadingAlertView = nil;

+ (void)ShowLoading
{
    loadingAlertView = [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    loadingAlertView.userInteractionEnabled = true;
	loadingAlertView.labelText = @"loading...";
}

+ (void)HideLoading
{
    [loadingAlertView hide:YES];
    loadingAlertView = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    mainWindow = self.window;
    
    [AppDelegate jumpToCover];
    
    [NetWorkManager InitUserInfo];
    
    // Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
  

    [APService setupWithOption:launchOptions];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil];

    [MMLocationManager sharedManager];
    
    return YES;
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    
    NSLog(@"extras: %@", extras);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
    
    
}

static NSString* pushOrderId = nil;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    NSLog(@"userInfo1 %@", userInfo);
    
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    NSLog(@"userInfo2 %@", userInfo);
    
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    pushOrderId = nil;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (pushOrderId != nil) {

    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
