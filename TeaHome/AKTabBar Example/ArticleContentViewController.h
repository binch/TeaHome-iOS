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
@property(nonatomic,strong) UILabel *favLabel;
@property(nonatomic,strong) UILabel *likeLabel;
@property(nonatomic,strong) UIImageView *likeView;
@property(nonatomic,strong) UIImageView *favView;
@property(nonatomic,strong) UIImageView *shareView;
@property(nonatomic,assign) int articleId;
@property(nonatomic,assign) bool favor;
@property(nonatomic,assign) bool like;
@property(nonatomic,assign) bool fav_state;
@property(nonatomic,assign) bool like_state;
@property(nonatomic,assign) int favorCount;
@property(nonatomic,assign) int likeCount;

@end
