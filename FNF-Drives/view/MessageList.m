//
//  MessageList.m
//  FNF-Shop
//
//  Created by Wenlong on 15-9-6.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "MessageList.h"
#import "MessageListCell.h"

@interface MessageList ()

@property (weak, nonatomic) IBOutlet TableViewWithBlock *tableView;
@end

@implementation MessageList

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self addBottomBarWithTag:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    [NetWorkManager GetMessageListWithSuccess:^(AFHTTPRequestOperation *operation, id data) {
        NSArray* msgList = data;
        
        [self.tableView initTableViewDataSourceAndDelegate:^NSInteger(UITableView *tableView, NSInteger section) {
            return (NSInteger)[msgList count];
        } setCellForIndexPathBlock:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            MessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageListCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageListCell" owner:self options:nil] objectAtIndex:0];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            NSDictionary* info = [msgList objectAtIndex:(NSUInteger)indexPath.row];
            
            [cell.titleLabel setText:info[@"UserAccount"]];
            [cell.msgLabel setText:[NSString stringWithFormat:@"UnRead %@", info[@"NoReadCount"]]];
            
            return cell;
        } setDidSelectRowBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
            NSLog(@"OnClick cell %d", (int)indexPath.row);
            
            NSDictionary* info = [msgList objectAtIndex:(NSUInteger)indexPath.row];
            
            [NetWorkManager GetMessageDetail:info[@"OrderCode"] WithSuccess:^(AFHTTPRequestOperation *operation, id data) {
                
                NSDictionary* detailInfo = data;
                [NetWorkManager SetCurMsgInfo:detailInfo];
                [AppDelegate jumpToMsgDetail];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
        }];
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (IBAction)OnClickBack:(id)sender
{
    [AppDelegate jumpToMain];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
