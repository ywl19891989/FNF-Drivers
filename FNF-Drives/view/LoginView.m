//
//  LoginView.m
//  FNF-Drives
//
//  Created by Wenlong on 15-8-25.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "LoginView.h"

@interface LoginView ()

@end

@implementation LoginView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnClickLogin:(id)sender
{
    NSString* email = [self.emailInput text];
    NSString* pwd = [self.pwdInput text];
    
    if ([email length] <= 0) {
        [AppDelegate ShowTips:@"Please Enter Email!"];
    } else if ([pwd length] <= 0) {
        [AppDelegate ShowTips:@"Please Enter Password!"];
    } else {
        NSDictionary* param = @{
                                @"UserEmail": email,
                                @"UserPwd": pwd,
                                };
        [NetWorkManager Login:param WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
            if (data) {
                NSMutableDictionary* realData = [NSMutableDictionary dictionaryWithDictionary:data];
                [NetWorkManager SetUserInfo:realData];
                [AppDelegate jumpToMain];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (IBAction)OnClickRegister:(id)sender {
}
@end
