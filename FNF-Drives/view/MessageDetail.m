//
//  MessageDetail.m
//  FNF-Shop
//
//  Created by Wenlong on 15-9-7.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "MessageDetail.h"
#import "MessageDetailCell.h"
#import "YFInputBar.h"
#import "NetWorkManager.h"

@interface MessageDetail () <YFInputBarDelegate>
{
    CGRect viewOrigin;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet TableViewWithBlock *tableView;
@property (weak, nonatomic) IBOutlet YFInputBar *inputBat;
@end

@implementation MessageDetail

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
    
    viewOrigin = self.view.frame;
    
    NSDictionary* detailInfo = [NetWorkManager GetCurMsgInfo];
    NSArray* msgList = detailInfo[@"mesList"];
    
    [self.tableView initTableViewDataSourceAndDelegate:^NSInteger(UITableView *tableView, NSInteger section) {
        return (NSInteger)[msgList count];
    } setCellForIndexPathBlock:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        MessageDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageDetailCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageDetailCell" owner:self options:nil] objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        NSDictionary* info = [msgList objectAtIndex:(NSUInteger)indexPath.row];
        
        [cell.detailLabel setText:info[@"Content"]];
        [cell.dateLabel setText:info[@"CreateDate"]];
        
        NSString* toUserId = info[@"SendUserID"];
        if ([toUserId isEqualToString:[NetWorkManager GetUserId]]) {
            [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
            [cell.dateLabel setTextAlignment:NSTextAlignmentRight];
        } else {
            [cell.detailLabel setTextAlignment:NSTextAlignmentLeft];
            [cell.dateLabel setTextAlignment:NSTextAlignmentLeft];
        }
        
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        
    }];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView reloadData];
    
    [self.titleLabel setText:detailInfo[@"MerchantName"]];
    
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    
    YFInputBar *inputBar = [[YFInputBar alloc] initWithFrame:CGRectMake(0, frame.size.height + frame.origin.y - 44, 320, 44)];
    [inputBar.sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    [inputBar.sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    inputBar.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    
    inputBar.delegate = self;
    inputBar.clearInputWhenSend = YES;
    inputBar.resignFirstResponderWhenSend = YES;
    
    [self.view addSubview:inputBar];
}

-(void)inputBar:(YFInputBar *)inputBar sendBtnPress:(UIButton *)sendBtn withInputString:(NSString *)str
{
    
    NSLog(@"%@", str);
    
    if ([str length] == 0) {
        return;
    }

    NSDictionary* detailInfo = [NetWorkManager GetCurMsgInfo];

    NSDictionary* param = @{
                            @"OrderCode": detailInfo[@"OrderCode"],
                            @"SendUserID": [NetWorkManager GetUserId],
                            @"SendUserType": @"Merchant",
                            @"ToUserID": detailInfo[@"UserID"],
                            @"ToUserType": @"Customers",
                            @"Contents": str,
                            @"PushID": @"060f1ebd023",
                            @"DeviceNo": @"ffffffff-e866-f971-ffff-ffffc4dc73a4"
                            };
    
//    [NetWorkManager SendMessage:param WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
//        if (data) {
//            [NetWorkManager GetMessageDetail:detailInfo[@"OrderCode"] WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
//                
//                NSDictionary* detailInfo = data;
//                [NetWorkManager SetCurMsgInfo:detailInfo];
//                [AppDelegate jumpToMsgDetail];
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                
//            }];
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [((UIView*)obj) resignFirstResponder];
    }];
}

- (IBAction)OnClickBack:(id)sender
{
    [AppDelegate jumpToMsgList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
