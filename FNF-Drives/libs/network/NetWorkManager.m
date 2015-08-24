//
//  NetWorkManager.m
//  dengjibao
//
//  Created by Wenlong on 14-4-9.
//  Copyright (c) 2014年 wenlong. All rights reserved.
//

#import "NetWorkManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "SecurityData.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "APService.h"

@implementation NetWorkManager

static NSString* urlBase = @"http://FNF.haofengsoft.com/WebService/";
static NSString* m_sVersion = @"1.0";
static NSString* m_sDeviceType = @"iOS";
#define m_sDeviceNo [SecurityData deviceId]

#define SAVE_FILE @"test.plist"

#define USERID_KEY @"UserID"
#define USERNAME_KEY @"UserName"
#define USERMOBILE_KEY @"Mobile"

static NetWorkManager* instance = nil;

+ (void) SET_IF_NOT_NIL:(NSMutableDictionary*)dic :(NSString*)key :(id)value
{
    if (value != nil)
    {
        dic[key] = value;
    }
}

+ (void)SetUserInfo:(NSDictionary *)info
{
    m_pUserId = info[USERID_KEY];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{}];

    if (m_pUserName != nil) {
        [NetWorkManager SET_IF_NOT_NIL:userInfo :USERID_KEY :m_pUserId];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:SAVE_FILE];
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filename contents:nil attributes:nil];
    
    //创建一个dic，写到plist文件里
    [userInfo writeToFile:filename atomically:YES];
}

+ (void) InitUserInfo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:SAVE_FILE];
    NSDictionary* userInfo = [NSDictionary dictionaryWithContentsOfFile:filename];
    
    if (userInfo[USERID_KEY])
    {
        [NetWorkManager SetUserInfo:userInfo];
    }
}

NM_PROPERTY_DEFINE(NSString*, UserId);
NM_PROPERTY_DEFINE(NSString*, UserName);
NM_PROPERTY_DEFINE(NSArray*, NewOrderList);
NM_PROPERTY_DEFINE(NSArray*, ConfirmedOrderList);
NM_PROPERTY_DEFINE(NSArray*, FinishedOrderList);
NM_PROPERTY_DEFINE(NSDictionary*, CurOrderInfo);

//----------------------------------------------

+ (NSString*)formatWithDict:(NSDictionary*)dict
{
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONReadingMutableLeaves error:nil];
    NSString* res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSArray* allKeys = [dict allKeys];
//    NSString* res = @"{";
//    for (int i = 0; i < [allKeys count]; i++) {
//        NSString* key = [allKeys objectAtIndex:i];
//        id value = [dict objectForKey:key];
//        NSString* valueStr = nil;
//        if ([value isKindOfClass:[NSArray class]])
//        {
//            valueStr = @"[";
//            for (int j = 0; j < [value count]; j++) {
//                id arrVal = [value objectAtIndex:j];
//                if ([arrVal isKindOfClass:[NSDictionary class]])
//                {
//                    if (j > 0) {
//                        valueStr = [NSString stringWithFormat:@"%@,", valueStr];
//                    }
//                    valueStr = [NSString stringWithFormat:@"%@%@", valueStr, [NetWorkManager formatWithDict:arrVal]];
//                }
//            }
//            valueStr = [NSString stringWithFormat:@"%@]", valueStr];
//        }
//        else if([value isKindOfClass:[NSString class]])
//        {
//            valueStr = [NSString stringWithFormat:@"\"%@\"", [dict objectForKey:key]];
//        }
//        else if([value isKindOfClass:[NSDictionary class]])
//        {
//            valueStr = [NSString stringWithFormat:@"%@", [NetWorkManager formatWithDict:[dict objectForKey:key]]];
//        }
//        if(i > 0){
//            res = [res stringByAppendingString:@","];
//        }
//        res = [res stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@", key, valueStr]];
//    }
//    res = [res stringByAppendingString:@"}"];
    NSLog(@"formatWithDict: %@", res);
    
    return res;
}

+ (void)POST:(NSString *)path withParameters:(NSDictionary *)params success:(SuccessCallBack)success failure:(FailureCallBack)failure
{
    NSString* paramStr = [NetWorkManager formatWithDict:params];
    NSData* dd = [NetWorkManager rsaEncryptString:paramStr];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlBase, path]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    
    [request setHTTPBody:dd];
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        [AppDelegate HideLoading];
        NSLog(@"success! %@", operation.responseString);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"res: %@", dic);
        if ([dic[@"result"] isEqualToString:@"false"]) {
            [AppDelegate ShowTips:dic[@"msg"]];
            success(operation, nil);
        } else {
            success(operation, dic[@"msg"]);
            [AppDelegate ShowToast:@"加载完成!"];
        }
    } failure:^(AFHTTPRequestOperation *operation, id responseObject){
        [AppDelegate HideLoading];
        NSLog(@"failed! %@", operation.responseString);
        [AppDelegate ShowTips:operation.responseString];
        failure(operation, responseObject);
    }];
    
    NSLog(@"\npost %@%@\nparam %@", urlBase, path, paramStr);
    
    [AppDelegate ShowLoading];
    [operation start];
}

+ (NSString*) encode: (NSString*) originStr
{
    NSData* originData = [originStr dataUsingEncoding:NSASCIIStringEncoding];

    NSString* encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    NSLog(@"encodeResult:%@",encodeResult);
    
    return encodeResult;
}

+ (NSString*) decode: (NSString*) encodeResult
{
    NSData* decodeData = [[NSData alloc] initWithBase64EncodedString:encodeResult options:0];

    NSString* decodeStr = [[NSString alloc] initWithData:decodeData encoding:NSASCIIStringEncoding];
    NSLog(@"decodeStr %@", decodeStr);
    return decodeStr;
}

static SecKeyRef _public_key=nil;
+ (SecKeyRef) getPublicKey
{ // 从公钥证书文件中获取到公钥的SecKeyRef指针
    if(_public_key == nil){
        NSString* cerPath = [[NSBundle mainBundle] pathForResource:@"chedao" ofType:@"cer" inDirectory:@"assets"];
        NSData* cerData = [NSData dataWithContentsOfFile:cerPath];
        SecCertificateRef myCertificate =  SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)cerData);
        SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
        SecTrustRef myTrust;
        OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
        SecTrustResultType trustResult;
        if (status == noErr) {
            status = SecTrustEvaluate(myTrust, &trustResult);
        }
        _public_key = SecTrustCopyPublicKey(myTrust);
        CFRelease(myCertificate);
        CFRelease(myPolicy);
        CFRelease(myTrust);
    }
    return _public_key;
}

+ (NSData*) rsaEncryptString:(NSString*) string
{
    SecKeyRef key = [self getPublicKey];
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    NSData *stringBytes = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t blockSize = cipherBufferSize - 11;
    size_t blockCount = (size_t)ceil([stringBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    for (int i=0; i<blockCount; i++) {
        int bufferSize = (int)MIN(blockSize,[stringBytes length] - i * blockSize);
        NSData *buffer = [stringBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes],
                                        [buffer length], cipherBuffer, &cipherBufferSize);
        if (status == noErr){
            NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }else{
            if (cipherBuffer) free(cipherBuffer);
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    //  NSLog(@"Encrypted text (%d bytes): %@", [encryptedData length], [encryptedData description]);
    //  NSLog(@"Encrypted text base64: %@", [Base64 encode:encryptedData]);
    return encryptedData;
}

+ (NSString*) GetTodayDate
{
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    return [fmt stringFromDate:[NSDate date]];
}

+ (void)TestProtocolWithSuccess:(SuccessCallBack)success failure:(FailureCallBack)failure
{
    NSDictionary* param = @{@"name":@"wangzhenzhu",@"telephone":@"13818342667"};
    [NetWorkManager POST:@"UserService.asmx/GetUserByJson" withParameters:param success:success failure:failure];
}

+ (void)Login:(NSDictionary *)data WithSuccess:(SuccessCallBack)success failure:(FailureCallBack)failure
{
    NSDictionary* param = @{
                            @"UserID": data[@"UserID"],
                            @"DeviceNo": m_sDeviceNo,
                            @"Version": m_sVersion,
                            @"DeviceType": m_sDeviceType,
                            @"Password": data[@"PassWord"],
                            };
    [NetWorkManager POST:@"UserService.asmx/Login" withParameters:param success:success failure:failure];
}

+ (void)GetOrderListByState:(int)state WithSuccess:(SuccessCallBack)success failure:(FailureCallBack)failure
{
    NSDictionary* param = @{
                    @"PageIndex": @"0",
                    @"PageSize": @"10",
                    @"Status" : [NSString stringWithFormat:@"%d", state],
                    };

    [NetWorkManager POST:@"DriverService.asmx/GetOrderList" withParameters:param success:success failure:failure];
}

+ (void)GetOrderDetailByID:(NSInteger)orderId WithSuccess:(SuccessCallBack)success failure:(FailureCallBack)failure
{
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithCapacity:10];
    [param setValue:[NSNumber numberWithInt:(NSUInteger)orderId] forKey:@"ID"];
    
    [NetWorkManager POST:@"DriverService.asmx/GetOrderDetailByID" withParameters:param success:success failure:failure];
}

+ (void)ConfirmOrderByID:(NSInteger)orderId AndEsTime:(NSString*)time WithSuccess:(SuccessCallBack)success failure:(FailureCallBack)failure
{
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithCapacity:10];
    [param setValue:[NSNumber numberWithInt:(NSUInteger)orderId] forKey:@"OrderID"];
    [param setValue:time forKey:@"drvEstTime"];
    
    [NetWorkManager POST:@"DriverService.asmx/UpdateDriverArrivedTime" withParameters:param success:success failure:failure];
}

+ (void)DeliveredOrderByID:(NSInteger)orderId WithSuccess:(SuccessCallBack)success failure:(FailureCallBack)failure
{
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithCapacity:10];
    [param setValue:[NSNumber numberWithInt:(NSUInteger)orderId] forKey:@"OrderID"];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [param setValue:[formater stringFromDate:[NSDate date]] forKey:@"DrvActTime"];
    
    [NetWorkManager POST:@"DriverService.asmx/UpdateDriverDeliveryTime" withParameters:param success:success failure:failure];
}

@end
