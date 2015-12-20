//
//  SettingsView.m
//  FNF-Drives
//
//  Created by user on 15/12/20.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "SettingsView.h"
#import "MMLocationManager.h"

@interface SettingsView ()

@property (weak, nonatomic) IBOutlet UISwitch *m_pSwitch;
@end

@implementation SettingsView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.m_pSwitch setOn:[[MMLocationManager sharedManager] IsOpenUpload]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnSwitch:(id)sender {
    [[MMLocationManager sharedManager] Switch];
}
- (IBAction)OnClickBack:(id)sender {
    [AppDelegate jumpToMain];
}

@end
