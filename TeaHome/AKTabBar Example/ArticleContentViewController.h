//
//  ArticleContentViewController.h
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleContentViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic,strong) NSString *articleTitle;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) UIWebView *webView;
@property(nonatomic,assign) int articleId;

@end
