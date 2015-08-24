//
//  RootViewController.h
//  newDengjibao
//
//  Created by Wenlong on 14-11-9.
//  Copyright (c) 2014年 mudan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NetWorkManager.h"
#import "TableViewWithBlock.h"

@interface RootViewController : UIViewController<UITextFieldDelegate>

- (void)addBottomBarWithTag:(int)tag;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)viewDidAppear:(BOOL)animated;
- (CGFloat)getTitleHeight;
- (CGFloat)getBottomBarHeight;
- (CGFloat)getTopOffsetY;

- (void)addTextViewTopView:(UITextView*)textView;
@end
