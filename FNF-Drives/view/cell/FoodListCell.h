//
//  FoodListCell.h
//  FNF-Shop
//
//  Created by Wenlong on 15-9-18.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@end
