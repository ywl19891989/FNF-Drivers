//
//  OrderListCell.h
//  CarRoad
//
//  Created by Wenlong on 15-3-15.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderNum;
@property (weak, nonatomic) IBOutlet UILabel *orderDate;
@property (weak, nonatomic) IBOutlet UILabel *orderCity;
@property (weak, nonatomic) IBOutlet UILabel *orderRemark;

- (void)setInfo:(NSDictionary *)info;

@end
