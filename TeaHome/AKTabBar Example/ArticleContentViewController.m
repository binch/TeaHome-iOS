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

-(void)handleFavTapAction:(UITapGestureRecognizer *)gesture
{
    UIImage *favImage;
    if (self.fav_state == true) {
        favImage = [UIImage imageNamed:@"like_no"];
        self.fav_state = false;
    } else {
        favImage = [UIImage imageNamed:@"like_yes"];
        self.fav_state = true;
    }
    
    [self.favView setImage:favImage];
}

-(void)handleLikeTapAction:(UITapGestureRecognizer *)gesture
{
    UIImage *likeImage;
    if (self.like_state == true) {
        likeImage = [UIImage imageNamed:@"like_down"];
        self.like_state = false;
    } else {
        likeImage = [UIImage imageNamed:@"like_up"];
        self.like_state = true;
    }
    [self.likeView setImage:likeImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.like_state = false;
    self.fav_state = false;

    self.title = self.articleTitle;
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.webView.backgroundColor = [UIColor clearColor];
    //self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    UIImage *likeImage = [UIImage imageNamed:@"like_down"];
    self.likeView = [[UIImageView alloc] initWithFrame:CGRectMake(50, self.view.bounds.size.height - 100, 30, 30)];
    self.likeView.backgroundColor = [UIColor clearColor];
    self.likeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeTapAction:)];
    [self.likeView addGestureRecognizer:gesture];
    [self.likeView setImage:likeImage];
    //[self.view addSubview:self.likeView];
    
    UILabel *likeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.view.bounds.size.height - 100, 40, 30)];
    likeLabel.numberOfLines = 0;
    likeLabel.textAlignment = NSTextAlignmentRight;
    likeLabel.textColor = [UIColor grayColor];
    likeLabel.font = [UIFont systemFontOfSize:14];
    likeLabel.text = @"28";
    //[self.view addSubview:likeLabel];
    
    UIImage *favImage = [UIImage imageNamed:@"like_no"];
    self.favView = [[UIImageView alloc] initWithFrame:CGRectMake(140, self.view.bounds.size.height - 100, 30, 30)];
    self.favView.backgroundColor = [UIColor clearColor];
    self.favView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFavTapAction:)];
    [self.favView addGestureRecognizer:gesture2];
    [self.favView setImage:favImage];
    //[self.view addSubview:self.favView];
    
    UILabel *favLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, self.view.bounds.size.height - 100, 70, 30)];
    favLabel.numberOfLines = 0;
    favLabel.textAlignment = NSTextAlignmentRight;
    favLabel.textColor = [UIColor grayColor];
    favLabel.font = [UIFont systemFontOfSize:14];
    favLabel.text = @"28";
    //[self.view addSubview:favLabel];
    
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
