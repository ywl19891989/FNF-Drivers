//
//  MainView.h
//  CarRoad
//
//  Created by Wenlong on 15-3-3.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "RootViewController.h"

#define ALL_ORDER       0
#define TODAY_UNAPP     1
#define ALL_UNAPP       2
#define ALL_APPED       3
#define DAI_FAPIAO      4
#define TODAY_APPED     5
#define TODAY_ORDER     6

@interface MainView : RootViewController

@property (weak, nonatomic) IBOutlet TableViewWithBlock *mTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tabSelector;

- (IBAction)OnClickBack:(id)sender;
- (IBAction)OnClickSetting:(id)sender;
- (IBAction)OnTabChange:(id)sender;

- (IBAction)OnChangeOrderType:(id)sender;


@end
