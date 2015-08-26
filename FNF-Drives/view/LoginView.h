//
//  LoginView.h
//  FNF-Drives
//
//  Created by Wenlong on 15-8-25.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "RootViewController.h"

@interface LoginView : RootViewController
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *pwdInput;

- (IBAction)OnClickLogin:(id)sender;
- (IBAction)OnClickRegister:(id)sender;
@end
