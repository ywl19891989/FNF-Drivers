//
//  MMLocationManager.m
//  DemoBackgroundLocationUpdate
//
//  Created by Ralph Li on 7/20/15.
//  Copyright (c) 2015 LJC. All rights reserved.
//

#import "MMLocationManager.h"
#import "NetWorkManager.h"
#import "AppDelegate.h"

#define UPLOAD_KEY @"upload-key"

@interface MMLocationManager()<CLLocationManagerDelegate>
{
    BOOL m_bIsOpen;
    CLLocationManager *m_pLocationManager;
}
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskIdentifier;

@end

@implementation MMLocationManager

+ (instancetype)sharedManager
{
    static MMLocationManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MMLocationManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.minSpeed = 4;
        self.minFilter = 3;
        self.minInteval = 10;
        
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        m_bIsOpen = [[defaults objectForKey:UPLOAD_KEY] boolValue];
        
        m_pLocationManager = [[CLLocationManager alloc] init];
        
        m_pLocationManager.delegate = self;
        m_pLocationManager.distanceFilter  = self.minFilter;
        m_pLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [self CheckUpload];
    }
    return self;
}

- (void)CheckUpload
{
    if (m_bIsOpen) {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
        [m_pLocationManager setAllowsBackgroundLocationUpdates:YES];
#endif
        if ([m_pLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [m_pLocationManager requestAlwaysAuthorization];
        }
        if ([m_pLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [m_pLocationManager requestWhenInUseAuthorization];
        }
        
        [m_pLocationManager startMonitoringSignificantLocationChanges];
        [m_pLocationManager startUpdatingLocation];
    } else {
        [m_pLocationManager stopMonitoringSignificantLocationChanges];
        [m_pLocationManager stopUpdatingLocation];
    }
}

- (BOOL)IsOpenUpload
{
    return m_bIsOpen;
}

- (void)Switch
{
    if (!m_bIsOpen) {
        // 判断定位操作是否被允许
        if(![CLLocationManager locationServicesEnabled]) {
            //提示用户无法进行定位操作
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Message" message:@"定位不成功 ,请确认开启定位!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
            [alertView show];
            return;
        }
    }
    
    m_bIsOpen = !m_bIsOpen;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:m_bIsOpen] forKey:UPLOAD_KEY];
    [defaults synchronize];
    
    [self CheckUpload];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations[0];
    
    NSLog(@"didUpdateLocations %@",location);
    
    [self adjustDistanceFilter:location];
    [self uploadLocation:location];
}

/**
 *  规则: 如果速度小于minSpeed m/s 则把触发范围设定为50m
 *  否则将触发范围设定为minSpeed*minInteval
 *  此时若速度变化超过10% 则更新当前的触发范围(这里限制是因为不能不停的设置distanceFilter,
 *  否则uploadLocation会不停被触发)
 */
- (void)adjustDistanceFilter:(CLLocation*)location
{
    NSLog(@"adjust:%f",location.speed);
    
    if ( location.speed < self.minSpeed )
    {
        if ( fabs(m_pLocationManager.distanceFilter - self.minFilter) > 0.1f )
        {
            m_pLocationManager.distanceFilter = self.minFilter;
        }
    }
    else
    {
        CGFloat lastSpeed = m_pLocationManager.distanceFilter/self.minInteval;
        
        if ( (fabs(lastSpeed-location.speed)/lastSpeed > 0.1f) || (lastSpeed < 0) )
        {
            CGFloat newSpeed  = (int)(location.speed+0.5f);
            CGFloat newFilter = newSpeed * self.minInteval;
            
            m_pLocationManager.distanceFilter = newFilter;
        }
    }
}


//这里仅用本地数据库模拟上传操作
- (void)uploadLocation:(CLLocation*)location
{   
    if ( [UIApplication sharedApplication].applicationState == UIApplicationStateActive )
    {
        //TODO HTTP upload
        [self uploadData:location];
        [self endBackgroundUpdateTask];
    }
    else//后台定位
    {
        //假如上一次的上传操作尚未结束 则直接return
        if ( self.taskIdentifier != UIBackgroundTaskInvalid )
        {
            return;
        }
        
        [self beingBackgroundUpdateTask:location];
    }
    
}

- (void)uploadData:(CLLocation*)location
{
    //TODO upload data
    NSLog(@"============> uploadData %@", location);
    if ([NetWorkManager GetUserId] == nil) {
        return;
    }
    [NetWorkManager UpLoadLocation:location WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
        NSLog(@"success! %@", data);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [AppDelegate HideLoading];
}

- (void)beingBackgroundUpdateTask:(CLLocation*)location
{
    self.taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self uploadData:location];
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    if ( self.taskIdentifier != UIBackgroundTaskInvalid )
    {
        [[UIApplication sharedApplication] endBackgroundTask: self.taskIdentifier];
        self.taskIdentifier = UIBackgroundTaskInvalid;
    }
}

@end
