//
//  MMLocationManager.m
//  DemoBackgroundLocationUpdate
//
//  Created by Ralph Li on 7/20/15.
//  Copyright (c) 2015 LJC. All rights reserved.
//

#import "MMLocationManager.h"
#import "NetWorkManager.h"

#define UPLOAD_KEY @"upload-key"

@interface MMLocationManager()<CLLocationManagerDelegate>
{
    BOOL m_bIsOpen;
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
        self.minSpeed = 3;
        self.minFilter = 50;
        self.minInteval = 10;
        
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        m_bIsOpen = [[defaults objectForKey:UPLOAD_KEY] boolValue];
        
        self.delegate = self;
        self.distanceFilter  = self.minFilter;
        self.desiredAccuracy = kCLLocationAccuracyBest;
        
        [self CheckUpload];
    }
    return self;
}

- (void)CheckUpload
{
    if (m_bIsOpen) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
        [self setAllowsBackgroundLocationUpdates:YES];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        [self requestAlwaysAuthorization];
#endif
        
        [self startMonitoringSignificantLocationChanges];
    } else {
        [self stopMonitoringSignificantLocationChanges];
    }
}

- (BOOL)IsOpenUpload
{
    return m_bIsOpen;
}

- (void)Switch
{
    m_bIsOpen = !m_bIsOpen;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:m_bIsOpen] forKey:UPLOAD_KEY];
    [defaults synchronize];
    
    [self CheckUpload];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations[0];
    
    NSLog(@"%@",location);
    
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
//    NSLog(@"adjust:%f",location.speed);
    
    if ( location.speed < self.minSpeed )
    {
        if ( fabs(self.distanceFilter-self.minFilter) > 0.1f )
        {
            self.distanceFilter = self.minFilter;
        }
    }
    else
    {
        CGFloat lastSpeed = self.distanceFilter/self.minInteval;
        
        if ( (fabs(lastSpeed-location.speed)/lastSpeed > 0.1f) || (lastSpeed < 0) )
        {
            CGFloat newSpeed  = (int)(location.speed+0.5f);
            CGFloat newFilter = newSpeed*self.minInteval;
            
            self.distanceFilter = newFilter;
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
