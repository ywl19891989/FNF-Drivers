//
//  CoverView.m
//  FNF-Drives
//
//  Created by Wenlong on 15-8-25.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "CoverView.h"
#import "MMLocationManager.h"

@interface CoverView ()

@end

@implementation CoverView

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

- (IBAction)OnClickEnter:(id)sender
{
    if ([NetWorkManager GetUserId]) {
        [NetWorkManager RegisterPush];
        [AppDelegate jumpToMain];
    } else {
        [AppDelegate jumpToLogin];
    }
}

@end
