//
//  ProductViewController.h
//  TeaHome
//
//  Created by andylee on 14-6-27.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductViewController : UIViewController<UIAlertViewDelegate>

@property(nonatomic,strong) NSDictionary *product;

@property(nonatomic,strong) UILabel *favorLabel;
@property(nonatomic,strong) UILabel *likeLabel;
@property(nonatomic,strong) UIImageView *likeView;
@property(nonatomic,strong) UIImageView *favView;
@property(nonatomic,assign) bool favor;
@property(nonatomic,assign) bool like;
@property(nonatomic,assign) bool fav_state;
@property(nonatomic,assign) bool like_state;
@property(nonatomic,assign) int favorCount;
@property(nonatomic,assign) int likeCount;
@property(nonatomic,assign) int tid;

@end
