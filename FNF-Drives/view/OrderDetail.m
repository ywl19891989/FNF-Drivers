//
//  OrderDetail.m
//  FNF-Drives
//
//  Created by Wenlong on 15-8-16.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "OrderDetail.h"

@interface OrderDetail ()
{
    NSDictionary* m_pCurOrderInfo;
    int m_iCurOrderState;
    int m_iCurOrderID;
    UITextField* m_pInputCache;
}
@end

@implementation OrderDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self addBottomBarWithTag:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDictionary* curOrderInfo = [NetWorkManager GetCurOrderInfo];
    m_pCurOrderInfo = curOrderInfo;
    m_iCurOrderID = [curOrderInfo[@"ID"] intValue];
    m_iCurOrderState = [curOrderInfo[@"OrderState"] intValue];

    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, 550);
    
    [self.pickerView setHidden:YES];
    
    [NetWorkManager GetOrderDetailByID:[curOrderInfo[@"ID"] intValue] WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
//        msg =     {
//            AddressDetail = "25 Rakaia Way,Docklands,Vic";
//            DeliveryTime = "15:00-17:00";
//            DrvActTime = "";
//            DrvEstTime = "";
//            ID = 160;
//            MerchantMobile = "";
//            MerchantPhone = 0398885003;
//            Mobile = 0469900846;
//            OrderCode = SO20150729134218184;
//            Pay = "Cash on delivery";
//            Remark = "";
//            RestaurantFinishTime = "";
//            TotalAmount = "24.8";
//        };
        
        [self.titleLable setText:[NSString stringWithFormat:@"%d", [data[@"ID"] intValue]]];
        [self.addressLable setText:data[@"AddressDetail"]];
        [self.phoneNumLabel setText:data[@"Mobile"]];
        [self.amountLabel setText:[NSString stringWithFormat:@"%d", [data[@"TotalAmount"] intValue]]];
        [self.paymentLabel setText:data[@"Pay"]];
        [self.notesLabel setText:data[@"Remark"]];
        [self.resphoneNumLabel setText:data[@"MerchantPhone"]];
        
        if (m_iCurOrderState == 1) {
            [self.deliverView setHidden:YES];
            [self.changeTitle setText:@"Restaurant finish time"];
            [self.cusSetTimeLabel setText:data[@"RestaurantFinishTime"]];
            [self.onlyBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        } else if (m_iCurOrderState == 2) {
            [self.deliverView setHidden:NO];
            [self.changeTitle setText:@"Customer setting time"];
            [self.cusSetTimeLabel setText:data[@"DeliveryTime"]];
            [self.estimateTimeLabel setText:data[@"DrvEstTime"]];
            [self.onlyBtn setTitle:@"Delivered" forState:UIControlStateNormal];
            
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            [self.actualTime setText:[formater stringFromDate:[NSDate date]]];
        } else {
            [self.deliverView setHidden:NO];
            [self.changeTitle setText:@"Customer setting time"];
            [self.cusSetTimeLabel setText:data[@"DeliveryTime"]];
            [self.estimateTimeLabel setText:data[@"DrvEstTime"]];
            [self.actualTime setText:data[@"DrvActTime"]];
            [self.onlyBtn setHidden:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnClickBack:(id)sender
{
    [AppDelegate jumpToMain];
}

- (IBAction)OnClickSetting:(id)sender {
}

- (IBAction)OnClickAddr:(id)sender {
}

- (IBAction)OnClickCall:(id)sender {
    [NetWorkManager Call:[self.phoneNumLabel text]];
}

- (IBAction)OnClickNotes:(id)sender {
}

- (IBAction)OnClickResCall:(id)sender {
    [NetWorkManager Call:[self.resphoneNumLabel text]];
}

- (IBAction)OnClickBtn:(id)sender
{
    if (m_iCurOrderState == 1) {
        if ([[self.estimateTimeLabel text] isEqualToString:@""]) {
            [AppDelegate ShowTips:@"Please Input Estamited Time!"];
            return;
        }
        
        [NetWorkManager ConfirmOrderByID:m_iCurOrderID AndEsTime:[self.estimateTimeLabel text] WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
            if (data) {
                [AppDelegate jumpToMain];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    } else if (m_iCurOrderState == 2) {
        [NetWorkManager DeliveredOrderByID:m_iCurOrderID WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
            if (data) {
                [AppDelegate jumpToMain];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (IBAction)OnClickEstamitedTime:(id)sender {
    if (m_iCurOrderState == 1) {
        m_pInputCache = self.estimateTimeLabel;
        [self.pickerView setHidden:NO];
    }
}

- (IBAction)OnClickActualTime:(id)sender {
//    if (m_iCurOrderState == 2) {
//        m_pInputCache = self.actualTime;
//        [self.pickerView setHidden:NO];
//    }
}

- (IBAction)OnClickCancelPick:(id)sender {
    [self.pickerView setHidden:YES];
}

- (IBAction)OnClickConfirm:(id)sender {
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [m_pInputCache setText:[formater stringFromDate:[self.timePicker date]]];
    [self.pickerView setHidden:YES];
}

- (void)showAlertViewForInput:(NSString*)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入内容"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定",nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* textInput = [alert textFieldAtIndex:0];
    [textInput setText:text];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField* tt = [alertView textFieldAtIndex:0];
        
        if (m_pInputCache != nil) {
            [m_pInputCache setText:[tt text]];
        }
    }
}

@end
