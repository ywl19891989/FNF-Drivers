//
//  RootViewController.m
//  newDengjibao
//
//  Created by Wenlong on 14-11-9.
//  Copyright (c) 2014年 mudan. All rights reserved.
//

#import "RootViewController.h"
#import "BottomBar.h"



@interface RootViewController ()
{
    UITextView* textViewCache;
}

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

            CGRect rect = self.view.bounds;
            rect.origin.y = [self getTopOffsetY];
            [self.view setBounds:rect];
    }
    return self;
}

- (CGFloat)getTopOffsetY
{
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver > 6.0)
    {
        return -20;
    }
    
    return 0;
}

- (CGFloat)getTitleHeight
{
    return 50;
}

- (CGFloat)getBottomBarHeight
{
    return 50;
}

- (void)addBottomBarWithTag:(int)tag
{
    BottomBar *bar = [[BottomBar alloc] init];
    [bar activeTag:tag];
    [self.view addSubview:bar];
    float allH = [[UIScreen mainScreen] bounds].size.height;
    bar.frame = CGRectMake(0, allH - bar.frame.size.height - 20, bar.frame.size.width, bar.frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)addTextViewTopView:(UITextView *)textView
{
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:nil];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:helloButton,btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];
    [textView setInputAccessoryView:topView];
    textViewCache = textView;
}

-(IBAction)dismissKeyBoard
{
    [textViewCache resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
