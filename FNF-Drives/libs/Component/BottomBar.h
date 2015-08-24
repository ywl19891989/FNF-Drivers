//
//  BottomBar.h
//  auline
//
//  Created by wenlong on 14/11/07.
//  Copyright (c) 2014 bigbear. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BTN_COUNT 2

@interface BottomBar : UIView {
    UIButton* _menuBtn[BTN_COUNT];
}

- (void)activeTag:(int)tag;

@end
