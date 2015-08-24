//
//  OrderListCell.m
//  CarRoad
//
//  Created by Wenlong on 15-3-15.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "OrderListCell.h"

@implementation OrderListCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfo:(NSDictionary *)info
{
    [self.orderNum setText:[NSString stringWithFormat:@"%@", info[@"ID"]]];
    [self.orderDate setText:[NSString stringWithFormat:@"%@", info[@"CreateTime"]]];
    [self.orderCity setText:[NSString stringWithFormat:@"%@", info[@"City"]]];
    [self.orderRemark setText:[NSString stringWithFormat:@"%@", info[@"Remark"]]];
}

@end
