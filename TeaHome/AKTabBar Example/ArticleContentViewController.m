//
//  ArticleContentViewController.m
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

// 资讯文章

#import "ArticleContentViewController.h"


#define share_article_url @"article/html/"


@interface ArticleContentViewController ()

@end

@implementation ArticleContentViewController

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

    self.title = self.articleTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.text]]];
//    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle:@"分享"
//                                                              style:UIBarButtonItemStyleBordered
//                                                             target:self
//                                                             action:@selector(shareAction:)];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:share, nil];
    
//    NSLog(@"%@",self.text);
}

//-(void)shareAction:(UIBarButtonItem *)item
//{
//    NSString *url = [NSString stringWithFormat:@"%@%@%d",share_root_url,share_article_url,self.articleId];
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
@end
