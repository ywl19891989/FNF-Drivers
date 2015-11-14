//
//  MMLocationManager.m
//  DemoBackgroundLocationUpdate
//
//  Created by Ralph Li on 7/20/15.
//  Copyright (c) 2015 LJC. All rights reserved.
//

#import "MMLocationManager.h"
#import "NetWorkManager.h"

@interface MMLocationManager()<CLLocationManagerDelegate>

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
        
        self.delegate = self;
        self.distanceFilter  = self.minFilter;
        self.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
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
