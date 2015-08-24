//
//  OrderDetail.h
//  FNF-Drives
//
//  Created by Wenlong on 15-8-16.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "RootViewController.h"

@interface OrderDetail : RootViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *addressLable;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UITextField *amountLabel;
@property (weak, nonatomic) IBOutlet UITextField *paymentLabel;
@property (weak, nonatomic) IBOutlet UITextField *notesLabel;
@property (weak, nonatomic) IBOutlet UITextField *resphoneNumLabel;
@property (weak, nonatomic) IBOutlet UITextField *cusSetTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *estimateTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *actualTime;
@property (weak, nonatomic) IBOutlet UIView *deliverView;
@property (weak, nonatomic) IBOutlet UILabel *changeTitle;
@property (weak, nonatomic) IBOutlet UIButton *onlyBtn;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

- (IBAction)OnClickBack:(id)sender;
- (IBAction)OnClickSetting:(id)sender;
- (IBAction)OnClickAddr:(id)sender;
- (IBAction)OnClickCall:(id)sender;
- (IBAction)OnClickNotes:(id)sender;
- (IBAction)OnClickResCall:(id)sender;
- (IBAction)OnClickBtn:(id)sender;
- (IBAction)OnClickEstamitedTime:(id)sender;
- (IBAction)OnClickActualTime:(id)sender;
- (IBAction)OnClickCancelPick:(id)sender;
- (IBAction)OnClickConfirm:(id)sender;
@end
