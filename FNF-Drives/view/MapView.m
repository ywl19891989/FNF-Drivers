//
//  MapView.m
//  FNF-Shop
//
//  Created by Wenlong on 15-9-25.
//  Copyright (c) 2015年 hali. All rights reserved.
//

#import "MapView.h"

@interface MapView ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MapView

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
    
    NSString* urlStr = [NSString stringWithFormat:@"https://www.google.com/maps/?q=%@", [NetWorkManager GetCurAddress]];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)OnClickBack:(id)sender
{
    [AppDelegate jumpToOrderDetail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
