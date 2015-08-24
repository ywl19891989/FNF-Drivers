//
//  BottomBar.m
//  auline
//
//  Created by wenlong on 14/11/07.
//  Copyright (c) 2014 bigbear. All rights reserved.
//

#import "BottomBar.h"
#import "AppDelegate.h"
#import "NetWorkManager.h"

#define SELECT_COLOR [UIColor colorWithRed:116.0f/255 green:116.0f/255 blue:116.0f/255 alpha:1]
#define UNSELECT_COLOR [UIColor colorWithRed:42.0f/255 green:42.0f/255 blue:42.0f/255 alpha:1]

@interface BottomBar ()
- (void)clickMenuBtn:(UIButton*)button;
@end

@implementation BottomBar

- (id)init
{
    float originHeight = 50;
    float scale = 1;
    self = [super initWithFrame:CGRectMake(0, 0, 320, originHeight * scale)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIColor* bgColor = SELECT_COLOR;
        NSArray* normalBtnImg = [[NSArray alloc] initWithObjects:@"home_icon.png", @"user_icon.png", nil];
        NSArray* selectBtnImg = [[NSArray alloc] initWithObjects:@"home_icon.png", @"user_icon.png", nil];
        for (int i = 0; i < [normalBtnImg count]; i++) {
            float btnW = 320.0f / [normalBtnImg count];
            _menuBtn[i] = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, 80)];
            _menuBtn[i].tag = i;
            _menuBtn[i].backgroundColor = bgColor;
            UIImage* normal = [UIImage imageNamed:[normalBtnImg objectAtIndex:i]];
            CGSize size = [normal size];
            
            [_menuBtn[i] addTarget:self action:@selector(clickMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_menuBtn[i]];
            _menuBtn[i].frame = CGRectMake(i * btnW + 0.5 * (btnW - btnW * scale), 0, btnW * scale, originHeight * scale);
            
            UIImageView* icon = [[UIImageView alloc] initWithImage:normal];
            [self addSubview:icon];
            icon.frame = CGRectMake((i + 0.5) * btnW + 0.5 * (btnW - btnW * scale) - 0.5 * size.width * originHeight * scale / size.height, 0, size.width * originHeight * scale / size.height, originHeight * scale);
        }
    }
    return self;
}

- (void)clickMenuBtn:(UIButton*)button
{
    int tag = (int)[button tag];
    NSLog(@"BottomBar on click menu %d", tag);
    
    if (tag == 0)
    {
        [AppDelegate jumpToMain];
    }
    else if (tag == 1)
    {
        if ([NetWorkManager GetUserId] == nil) {
            [AppDelegate jumpToMain];
        } else {
//            [AppDelegate jumpToUser];
        }
    }
}

- (void)activeTag:(int)tag
{
    for (int i = 0; i < BTN_COUNT; i++) {
        _menuBtn[i].selected = (i == tag);
        _menuBtn[i].backgroundColor = (tag == i ? SELECT_COLOR : UNSELECT_COLOR);
    }
}

@end
