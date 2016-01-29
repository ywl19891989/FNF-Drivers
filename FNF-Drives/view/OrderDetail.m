//
//  OrderDetail.m
//  FNF-Drives
//
//  Created by Wenlong on 15-8-16.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "OrderDetail.h"
#import "DXPopover.h"
#import "FoodListCell.h"

@interface OrderDetail () <UITableViewDataSource, UITableViewDelegate>
{
    NSDictionary* m_pCurOrderInfo;
    int m_iCurOrderState;
    int m_iCurOrderID;
    UITextField* m_pInputCache;
    UITableView* m_pTableView;
    DXPopover* m_pPop;
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
    
    m_pTableView = [[UITableView alloc] init];
    m_pTableView.frame = CGRectMake(0, 0, 300, 350);
    m_pTableView.dataSource = self;
    m_pTableView.delegate = self;
    [m_pTableView setSeparatorColor:[UIColor clearColor]];
    
    m_pPop = [DXPopover new];

    NSDictionary* curOrderInfo = [NetWorkManager GetCurOrderInfo];
    m_pCurOrderInfo = curOrderInfo;
    m_iCurOrderID = [curOrderInfo[@"ID"] intValue];
    m_iCurOrderState = [curOrderInfo[@"OrderState"] intValue];

    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, 770);
    
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
        m_pCurOrderInfo = data;
        
        
        NSString* orderCode = [NSString stringWithFormat:@"%@", data[@"OrderCode"]];
        if ([orderCode length] > 4) {
            orderCode = [orderCode substringFromIndex:[orderCode length] - 4];
        }
        
        [self.customerNameLabel setText:data[@"CustomerName"]];
        [self.merchantNameLabel setText:data[@"MerchantName"]];
        [self.titleLable setText:orderCode];
        [self.addressLabel setText:data[@"AddressDetail"]];
        [self.phoneNumLabel setText:data[@"Mobile"]];
        [self.amountLabel setText:[NSString stringWithFormat:@"%.2f", [data[@"PayAmount"] floatValue]]];
        [self.paymentLabel setText:data[@"Pay"]];
        [self.notesLabel setText:data[@"Remark"]];
        [self.resphoneNumLabel setText:data[@"MerchantPhone"]];
        
        if (m_iCurOrderState == 1) {
            [self.deliverView setHidden:YES];
            [self.changeTitle setText:@"Restaurant finish time"];
            [self.cusSetTimeLabel setText:data[@"RestaurantFinishTime"]];
            [self.onlyBtn setTitle:@"Confirm" forState:UIControlStateNormal];
            
            if ([data valueForKey:@"DriverConfirmTime"] != nil && [[data valueForKey:@"DriverConfirmTime"] length] > 0) {
                [self.onlyBtn setHidden:YES];
            }
            
        } else if (m_iCurOrderState == 2) {
            [self.deliverView setHidden:YES];
            [self.changeTitle setText:@"Customer setting time"];
            [self.cusSetTimeLabel setText:data[@"DeliveryTime"]];
            [self.estimateTimeLabel setText:data[@"DrvEstTime"]];
            [self.onlyBtn setTitle:@"Pickup" forState:UIControlStateNormal];
            
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            [self.actualTime setText:[formater stringFromDate:[NSDate date]]];
        } else if (m_iCurOrderState == 3) {
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

- (IBAction)OnClickDetail:(id)sender {
    [m_pTableView reloadData];
    CGPoint startPoint =
    CGPointMake(CGRectGetMidX(self.detailBtn.frame), CGRectGetMaxY(self.detailBtn.frame) + 5);
    [m_pPop showAtPoint:startPoint
         popoverPostion:DXPopoverPositionDown
        withContentView:m_pTableView
                 inView:self.view];
}

- (IBAction)OnClickAddr:(id)sender {
    [NetWorkManager SetCurAddress:[self.addressLabel text]];
    [AppDelegate jumpToMap];
}

- (IBAction)OnClickCall:(id)sender {
    [NetWorkManager Call:[self.phoneNumLabel text]];
}

- (IBAction)OnClickNotes:(id)sender {
    [AppDelegate ShowTips:m_pCurOrderInfo[@"Remark"]];
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
        
        [NetWorkManager UpdateOrder:m_iCurOrderID AndTime:[self.estimateTimeLabel text] WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
            if (data) {
                [AppDelegate jumpToMain];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    } else if (m_iCurOrderState == 2 || m_iCurOrderState == 3) {
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        [NetWorkManager UpdateOrder:m_iCurOrderID AndTime:[formater stringFromDate:[NSDate date]] WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [m_pPop dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (m_pCurOrderInfo[@"DetailList"]) {
        return [m_pCurOrderInfo[@"DetailList"] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellIdentifier";
    FoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FoodListCell" owner:self options:nil] objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    NSDictionary* info = [m_pCurOrderInfo[@"DetailList"] objectAtIndex:indexPath.row];
    [cell.nameLabel setText:info[@"ProductName"]];
    [cell.numLabel setText:[NSString stringWithFormat:@"x%@", info[@"BuyQty"]]];
    NSString* priceStr = [NSString stringWithFormat:@"%@", info[@"Price"]];
    float priceVal = [priceStr floatValue];
    [cell.priceLabel setText:[NSString stringWithFormat:@"$%.2f", priceVal]];
    
    return cell;
}

@end
